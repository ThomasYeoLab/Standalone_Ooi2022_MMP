#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import argparse
import mapred_utils as util
from datetime import datetime as date
from datetime import timedelta
from dateutil import parser as dateparser


# Read job information
def read_info( folder, jobid ):
    infofile = os.path.join( folder, 'job_' + str(jobid), 'info.json' )
    return util.read_json(infofile) if os.path.isfile(infofile) else {}


# Parse Matlab timestamp and return elapsed time
def time_remaining( startstamp, fraction ):

    # estimate remaining time in seconds
    if fraction > 0:

        remaining = date.now() - dateparser.parse(startstamp)
        remaining = remaining.total_seconds()
        remaining = remaining/float(fraction) - remaining

        return timedelta( seconds=remaining )

    else:
        return None



# Worker progress report
def worker_progress( folder, workerid, jobids, more=False ):

    # Group jobs by status
    pgr = { 'running': [], 'done': [], 'failed': [] }
    for job in jobids:

        info = read_info(folder,job)
        if info:
            pgr[ info['status'].lower() ].append(job)


    # Jobs remaining to be executed
    pgr['remaining'] = list(set(jobids) - set( pgr['running'] + pgr['done'] + pgr['failed'] ))

    # List counts
    cpgr = { key:len(value) for key,value in pgr.iteritems() }
    cpgr['total'] = len(jobids)


    # Estimate remaining time
    info = read_info(folder,jobids[0])
    if not info:
        remaining = '<null>'
    else:
        remaining = str(time_remaining( info['start'], float(cpgr['done'])/max(0.5,cpgr['total']-cpgr['failed']) ))


    # Print information about worker and timeleft
    head = 'Worker #%d [ %d %%, timeleft: %s ]' % \
        ( workerid, 100 * float(cpgr['done']+cpgr['failed'])/cpgr['total'], remaining )

    cprint = util.ColorPrinter()
    if cpgr['failed'] > 0:
        cprint.cfg('w','r','b').out(head)
    elif cpgr['done'] == cpgr['total']:
        cprint.cfg('g').out(head)
    else:
        print head


    # Print job lists
    if more:
        if cpgr['failed'] > 0:
            print '\t    Failed: ' + ','.join(map(str,pgr['failed']))
        if cpgr['remaining'] > 0.75*cpgr['total']:
            print '\t      Done: ' + ','.join(map(str,pgr['done']))
        elif cpgr['remaining'] > 0:
            print '\t Remaining: ' + ','.join(map(str,pgr['remaining']))
        elif cpgr['running'] > 0:
            print '\t   Running: ' + ','.join(map(str,pgr['running']))


    # Summary
    print "\t (%s total), (%s done), (%s failed)" % \
        ( cprint.fg('c').fmt(cpgr['total']), cprint.fg('g').fmt(cpgr['done']), cprint.fg('r').fmt(cpgr['failed']) )



def main(args):

    # Get config file and read it
    cfgfile = args.config
    if not cfgfile:
        cfgfile = util.find_config()

    config = util.read_json(cfgfile)
    folder = config['folders']['save']

    # Analyse workers progress
    workers  = config['exec']['workers']
    nworkers = len(workers)

    for w in xrange(nworkers):
        worker_progress( folder, w+1, workers[w], args.more )


if __name__ == '__main__':

    parser = argparse.ArgumentParser( prog='mapres_status' )
    parser.add_argument('--config', default='', help='Configuration file (search for it if omitted)')
    parser.add_argument('--more', action='store_true', help='More information')
    main(parser.parse_args())

    
