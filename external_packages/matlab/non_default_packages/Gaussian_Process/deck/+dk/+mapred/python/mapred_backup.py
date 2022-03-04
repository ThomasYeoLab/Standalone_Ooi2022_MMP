#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import glob
import shutil
import tarfile
import argparse
import mapred_utils as util

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', default=os.getcwd(), help='The "save folder" of the map/reduce task being backed up')
    parser.add_argument('--name', default=util.sortable_timestamp(), help='Name of the subfolder to create in the data directory')
    parser.add_argument('--force', action='store_true', help='Go on with the backup even if folder already exists')
    parser.add_argument('--no-jobs', dest='jobs', action='store_false', help='Exclude jobs from backup')
    parser.add_argument('--compress', action='store_true', help='Compress jobs using bz2')
    args = parser.parse_args()

    # Make sure save folder exists
    saveFolder = args.folder
    assert os.path.isdir(saveFolder), 'Folder not found: ' + saveFolder


    # Find config file
    cfgFile = os.path.join( saveFolder, 'config', 'config.json' )
    assert os.path.isfile(cfgFile), 'Could not find config file: ' + cfgFile
    config = util.read_json(cfgFile)


    # Create backup folder
    backupFolder = os.path.join( saveFolder, 'data', args.name )
    if os.path.isdir(backupFolder):
        assert args.force, 'Folder "%s" already exists, aborting.' % (backupFolder)
    else:
        os.makedirs( backupFolder )

    # Copy current config
    shutil.copy2( cfgFile, backupFolder )


    # Move workers output
    nworkers = len(config['exec']['workers'])
    wmove = []

    for i in xrange(nworkers):

        wname = config['files']['worker'] % (i+1)
        wfile = os.path.join( saveFolder, wname )

        if os.path.isfile(wfile):
            wmove.append(wname)
            os.rename( wfile, os.path.join(backupFolder,wname) )


    # Move reduced output
    if 'reduced' in config['files']:
        rname = config['files']['reduced'] # compatibility issue
    else:
        rname = config['files']['reduce']


    rfile = os.path.join( saveFolder, rname )
    if os.path.isfile(rfile):
        os.rename( rfile, os.path.join(backupFolder,rname) )


    # Move log folder (should match substitution in mapred_build)
    try:

        logFolder = os.path.join(saveFolder,'logs')
        shutil.move( logFolder, backupFolder )
        os.makedirs( logFolder ) # make a new one

    except:
        print "Could not find or move logs folder: " + logFolder


    # Compress job folders
    jmove = []
    if args.jobs:

        if args.compress: cx = {'ext': '.tar.bz2', 'fmt': 'w:bz2'}
        else: cx = {'ext': '.tar', 'fmt': 'w'}

        jobFolders = glob.glob(os.path.join( saveFolder, 'job_*' ))
        jobArchive = os.path.join( backupFolder, 'jobs' + cx['ext'] )

        print "Compressing %d jobs outputs to archive %s (please wait)..." % ( len(jobFolders), jobArchive )
        with tarfile.open( jobArchive, cx['fmt'] ) as tar:

            for job in jobFolders:
                jobName = os.path.basename(job)
                jmove.append( jobName )
                tar.add( job, arcname=jobName )

    # Write summary
    print 'Backed up to folder "%s" (%d output(s), %d folder(s))' % (backupFolder,len(wmove),len(jmove))
    