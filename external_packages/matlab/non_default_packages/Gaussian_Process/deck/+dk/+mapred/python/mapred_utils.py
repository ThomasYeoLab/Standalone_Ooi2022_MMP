# -*- coding: utf-8 -*-

import time
import json
import stat
import sys
import os

# From http://stackoverflow.com/a/3041990/472610
def query_yes_no( question, default=None ):
    
    # Set prompt depending on default
    if default is None:
        prompt = " (yes/no) "
    elif default == "yes":
        prompt = " ([yes]/no) "
    elif default == "no":
        prompt = " (yes/[no]) "
    else:
        raise ValueError("Invalid default answer: '%s'" % default)

    # Ask question until a valid answer is given
    valid = {"yes": True, "no": False}
    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().strip().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond either 'yes' or 'no'.\n")

# Get formatted timestamp
def sortable_timestamp():
    return time.strftime('%Y%m%d-%H%M%S')

def matlab_timestamp():
    return time.strftime('%d-%b-%Y %H:%M:%S')

# Make a file executable
def make_executable( filename ):
    if os.path.isfile(filename):
        st = os.stat(filename)
        os.chmod( filename, st.st_mode | stat.S_IXUSR )

# Relink symbolic link
def relink( linkfile, newtarget ):
    if os.path.islink(linkfile):
        os.unlink(linkfile)

    os.symlink( newtarget, linkfile )

# Test is something is a string
def is_string( x, notempty=True ):
    return isinstance(x,basestring) and ( not notempty or x )

# Write JSON object to file
def write_json( filename, obj ):
    with open(filename,'w') as f:
        f.write(json.dumps( obj, indent=4 ))

# Read JSON file with comments
def read_json( filename ):
    with open(filename,'r') as f:
        return json.load(f)


# ==================== *** *** ====================
# ==================== *** *** ====================


# Search for config file in current directory
def find_config():

    # Look for config folder
    if os.path.isdir( 'config' ):
        return os.path.join( os.getcwd(), 'config/config.json' )

    # Look for config.json file
    if os.path.isfile( 'config.json' ):
        return os.path.join( os.getcwd(), 'config.json' )

    # Don't know what else to do
    raise Exception("Could not find configuration file!")

# Parse config file, validate fields and reformat if needed
def parse_config(filename):

    def _parse_cluster(cfg):
        """
        For the mail option m:
            ‘b’     Mail is sent at the beginning of the job.
            ‘e’     Mail is sent at the end of the job.
            ‘a’     Mail is sent when the job is aborted or rescheduled.
            ‘s’     Mail is sent when the job is suspended.
            ‘n’     No mail is sent.
        """
        
        valid_queues = ['veryshort', 'short', 'long', 'verylong', 'bigmem', 'cuda']
        valid_queues_q = [ queue + '.q' for queue in valid_queues ]
        valid_mailopts = ['b','e','a','s','n']

        assert {'jobname', 'queue', 'email', 'mailopt'} <= set(cfg), '[cluster] Missing field(s).'
        assert is_string(cfg['jobname']), '[cluster.jobname] Empty or invalid string.'
        assert is_string(cfg['email']), '[cluster.email] Empty or invalid string.'
        assert cfg['mailopt'] in valid_mailopts, '[cluster.mailopt] Invalid mailopt.'

        if cfg['queue'] in valid_queues:
            cfg['queue'] += '.q'

        assert cfg['queue'] in valid_queues_q, '[cluster.queue] Invalid queue.'
        
        if 'threads' in cfg:
            assert isinstance(cfg['threads'],int), '[cluster.threads] Should be an int'

    def _parse_exec(cfg):

        assert {'class', 'jobs', 'workers', 'options'} <= set(cfg), '[exec] Missing field(s).'
        assert is_string(cfg['class']), '[exec.class] Empty or invalid string.'
        assert isinstance(cfg['workers'],list) and cfg['workers'], '[exec.workers] Empty or invalid list.'
        assert isinstance(cfg['options'],dict), '[exec.options] Invalid options.'
        
        # JSON library encodes non-vector struct-arrays as objects
        jobs = cfg['jobs']
        if isinstance(jobs,dict) and jobs.has_key('_value'):
            jobs = jobs['_value']
            
        assert isinstance(jobs,list) and jobs, '[exec.jobs] Empty or invalid list.'
        cfg['jobs'] = jobs

        # chec consistency
        assert sum(map( len, cfg['workers'] )) == len(cfg['jobs']), '[exec] Jobs/workers size mismatch.'

    def _parse_files(cfg):

        assert {'reduce', 'worker'} <= set(cfg), '[files] Missing field(s).'
        assert is_string(cfg['reduce']), '[files.reduce] Empty or invalid string.'
        assert is_string(cfg['worker']), '[files.worker] Empty or invalid string.'
        try:
            cfg['worker'] % (1)
        except:
            raise Exception("[files.worker] Worker filename cannot be formatted.")

    def _parse_folders(cfg):

        assert { 'start', 'work', 'save' } <= set(cfg), '[folders] Missing field(s).'
        assert is_string(cfg['start']), '[folders.start] Empty or invalid string.'
        assert is_string(cfg['save']), '[folders.save] Empty or invalid string.'
        assert is_string(cfg['work'],False), '[folders.work] Invalid string.'


    cfg = read_json(filename)
    cfg = {k: cfg[k] for k in ('id', 'cluster', 'exec', 'files', 'folders')} # filter required

    assert is_string(cfg['id']), '[id] Empty or invalid string.'
    _parse_cluster(cfg['cluster'])
    _parse_exec(cfg['exec'])
    _parse_files(cfg['files'])
    _parse_folders(cfg['folders'])

    return cfg


# ==================== *** *** ====================
# ==================== *** *** ====================


class ColorPrinter:
    """
    Usage:
    cprint = ColorPrinter()
    cprint.cfg('c','m','bux').out('Hello','World!')
    cprint.rst().out('Bye now...')

    See: http://stackoverflow.com/a/21786287/472610 
    See: https://en.wikipedia.org/wiki/ANSI_escape_code
    """

    COLCODE = {
        'k': 0, # black
        'r': 1, # red
        'g': 2, # green
        'y': 3, # yellow
        'b': 4, # blue
        'm': 5, # magenta
        'c': 6, # cyan
        'w': 7  # white
    }

    FMTCODE = {
        'b': 1, # bold
        'f': 2, # faint
        'i': 3, # italic
        'u': 4, # underline
        'x': 5, # blinking
        'y': 6, # fast blinking
        'r': 7, # reverse
        'h': 8, # hide
        's': 9, # strikethrough
    }

    def __init__(self):
        self.rst()

    # ------------------------------
    # Group actions
    # ------------------------------

    def rst(self):
        self.prop = { 'st': [], 'fg': None, 'bg': None }
        return self
    
    def cfg(self,fg,bg=None,st=None):
        return self.rst().st(st).fg(fg).bg(bg)

    # ------------------------------
    # Set individual properties
    # ------------------------------

    def st(self,st):
        if isinstance(st,int):
            assert (st >= 0) and (st < 10), 'Style should be in {0 .. 9}.'
            self.prop['st'].append(st)
        elif isinstance(st,basestring):
            for s in st:
                self.st(self.FMTCODE[s]) 
        return self

    def fg(self,fg):
        if isinstance(fg,int):
            assert (fg >= 0) and (fg < 8), 'Color should be in {0 .. 7}.'
            self.prop['fg'] = 30+fg
        elif isinstance(fg,basestring):
            self.fg(self.COLCODE[fg])
        return self

    def bg(self,bg):
        if isinstance(bg,int):
            assert (bg >= 0) and (bg < 8), 'Color should be in {0 .. 7}.'
            self.prop['bg'] = 40+bg
        elif isinstance(bg,basestring):
            self.bg(self.COLCODE[bg])
        return self

    # ------------------------------
    # Format and standard output
    # ------------------------------

    def fmt(self,*args):

        # accept multiple inputs, and concatenate them with spaces
        s = " ".join(map(str,args))

        # get anything that is not None
        w = self.prop['st'] + [ self.prop['fg'], self.prop['bg'] ]
        w = [ str(x) for x in w if x is not None ]

        # return formatted string
        return '\x1b[%sm%s\x1b[0m' % ( ';'.join(w), s ) if w else s

    def out(self,*args):
        print self.fmt(*args)
