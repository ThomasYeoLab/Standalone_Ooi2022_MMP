#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import argparse
import string
import json
import mapred_utils as util


# ------------------------------ ========== ------------------------------
# ------------------------------ ========== ------------------------------


# Template strings to be formatted and saved as bash scripts.

'''
Line to appear in the task file, running a single worker.
Matlab is run with singleCompThread, but multi-threaded mex can still be executed.
'''
TPL_MAP = string.Template("""matlab -singleCompThread -nodisplay -r "cd '${startdir}'; startup; cd '${workdir}'; obj = ${classname}(); obj.run_worker('${savedir}',${workerid}); exit(0);" """)

'''
The reduce script basically aggregates all the worker's results into a single MAT file.
'''
TPL_REDUCE = string.Template("""#!/bin/bash

matlab -singleCompThread -nodisplay -r "cd '${startdir}'; startup; cd '${workdir}'; obj = ${classname}(); obj.run_reduce('${savedir}'); exit(0);" """)

'''
The submission scripts submits a job-array defined in the task file (map-phase), 
and a reduce job waiting for completion of the job array.
'''
TPL_SUBMIT = string.Template("""#!/bin/bash

# remove info in all job subfolders
for folder in job_*; do
    [ -f $${folder}/info.json ] && rm -f $${folder}/info.json
done

# submit map/reduce job to the cluster
mid=$$(fsl_sub -q ${queue} -M ${email} -m ${mailopt} ${threads} -N ${jobname} -l "${logdir}" -t "${mapscript}")
rid=$$(fsl_sub -j $${mid} -q ${queue} -M ${email} -m ${mailopt} -N ${jobname} -l "${logdir}" ./"${redscript}")

# Show IDs
echo "Submitted map with ID $${mid} and reduce with ID $${rid}. Use qstat and mapred_status to monitor the progress."
""")

'''
Runworker can be used ad hoc to run the desired worker locally with nohup.
'''
TPL_RUNWORKER = string.Template("""#!/bin/bash

if [ $$# -lt 1 ]; then
    echo "Usage: runworker <WorkerID>"
fi

nohup nice \\
    matlab -singleCompThread -nodisplay \\
    -r "cd '${startdir}'; startup; cd '${workdir}'; obj = ${classname}(); obj.run_worker('${savedir}',$$1); exit;" \\
    >| "${logdir}/runworker_$${1}.log" 2>&1 &

echo "Running with pid $$!."
""")


'''
Message to be displayed if an existing configuration is found in the target folder.
'''
MSG_WARN = """WARNING:
    Another configuration was found in folder '%s', and it looks compatible with the current one.
    Going through with this build might result in OVERWRITING existing results.
    The options in the current configuration are:\n%s

    The options in the existing configuration are:\n%s

    Do you wish to proceed with the build?"""


# ------------------------------ ========== ------------------------------
# ------------------------------ ========== ------------------------------


def check_existing(cfg):

    folder = cfg['folders']['save']
    if os.path.isdir(folder):

        # If the reduced file already exists
        redfile = os.path.join( folder, cfg['files']['reduce'] )
        assert not os.path.isfile(redfile), \
            'Reduced file "%s" already exists, either back it up or change "files.reduce" field.' % (redfile)

        # If any of the workers outputs already exists
        nworkers = len(cfg['exec']['workers'])
        for i in xrange(nworkers):

            workerfile = os.path.join( folder, cfg['files']['worker'] % (i+1) )
            assert not os.path.isfile(workerfile), \
                'Worker file "%s" already exists, either back it up or change "files.worker" field.' % (workerfile)

        # If there is an existing config ..
        cfgfile = os.path.join( folder, 'config/config.json' )
        if os.path.isfile(cfgfile):

            # .. make sure it is compatible with the current one
            other = util.read_json(cfgfile)
            assert other['id'] == cfg['id'], \
                'Id mismatch with existing configuration "%s".' % (cfgfile)

            assert len(other['exec']['jobs']) == len(cfg['exec']['jobs']), \
                'Number of jobs mismatch with existing configuration "%s".' % (cfgfile)


            # format options as strings for comparison
            opt_new = json.dumps( cfg['exec']['options'], indent=4 )
            opt_old = json.dumps( other['exec']['options'], indent=4 )

            # Return true if the folder already exists
            return util.query_yes_no( MSG_WARN % ( folder, opt_new, opt_old ), "no" )


    return True


# Write new config to save folder
def make_config( cfg, folder ):

    # creat config folder if it doesnt exist
    cfg_folder = os.path.join( folder, 'config' )
    if not os.path.isdir( cfg_folder ):
        os.makedirs( cfg_folder )
        print 'Created folder "%s".' % (cfg_folder)


    # link and filename
    cfg_name  = 'config_%s.json' % (util.sortable_timestamp())
    link_file = os.path.join( cfg_folder, 'config.json' )
    cfg_file  = os.path.join( cfg_folder, cfg_name )


    util.write_json( cfg_file, cfg )
    util.relink( link_file, cfg_name )



# Write scripts according to current config
def make_scripts( cfg, folder ):

    # default configuration
    workdir = cfg['folders']['work']
    if not workdir:
        workdir = cfg['folders']['start']

    # substitution values from config
    sub = dict(cfg['cluster'])
    sub.update({
          'savedir': cfg['folders']['save'],
         'startdir': cfg['folders']['start'],
          'workdir': workdir,
        'classname': cfg['exec']['class'],
           'logdir': 'logs',
        'mapscript': 'map.task',
        'redscript': 'reduce'
    })

    # multithreading
    if 'threads' in cfg['cluster'] and cfg['cluster']['threads'] > 1:
        sub['threads'] = '-s openmp,%d' % (cfg['cluster']['threads'])
    else:
        sub['threads'] = ''


    # put the scripts together
    nworkers = len(cfg['exec']['workers'])
    scripts = {
         'map.task': "\n".join([ TPL_MAP.substitute(sub,workerid=(i+1)) for i in xrange(nworkers) ]) + "\n",
           'reduce': TPL_REDUCE.substitute(sub) + "\n",
        'runworker': TPL_RUNWORKER.substitute(sub),
           'submit': TPL_SUBMIT.substitute(sub)
    }


    # create log folder
    logdir = os.path.join( folder, 'logs' )
    if not os.path.isdir(logdir):
        os.mkdir(logdir)

    # create scripts and make executable
    for name,text in scripts.iteritems():
        sname = os.path.join(folder,name)
        with open( sname, 'w' ) as f:
            f.write(text)

        util.make_executable(sname)



# Success message
msg_success = """
Successful build (%d jobs across %d workers). To submit to the cluster, run:
    cd %s
    ./submit
"""

def main(args):

    # Try different extensions in case it's missing
    config = args.config
    if os.path.isfile(config + '.json'):
        config = config + '.json'
    elif os.path.isfile(config + 'apred.json'):
        config = config + 'apred.json'
    elif os.path.isfile(config + '.mapred.json'):
        config = config + '.mapred.json'
    else:
        assert os.path.isfile(config), 'File "%s" not found.' % (config)


    # Load config and validate it
    config = util.parse_config(config)

    # Save folder
    folder = args.savedir
    if not folder:
        folder = config['folders']['save']
    else:
        print 'Overriding configured savedir "%s" to "%s".' % (config['folders']['save'],folder)
        config['folders']['save'] = folder


    # Process config
    if check_existing(config):

        # Create save folder
        if not os.path.isdir( folder ):
            os.makedirs( folder )
            print 'Created savedir "%s".' % (folder)

        # Create config and scripts
        make_config( config, folder )
        make_scripts( config, folder )

        # Success message
        njobs = len(config['exec']['jobs'])
        nworkers = len(config['exec']['workers'])
        print msg_success % ( njobs, nworkers, folder )


if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog='mapred_build' )
    parser.add_argument('config', help='Configuration file to be built')
    parser.add_argument('--savedir', default='', help='Override save folder in config')
    main(parser.parse_args())
