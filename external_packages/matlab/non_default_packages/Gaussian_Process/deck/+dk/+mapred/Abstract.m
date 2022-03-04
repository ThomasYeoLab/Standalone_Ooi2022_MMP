classdef Abstract < handle

    properties (Abstract,Constant)
        name
        id
    end

    methods (Abstract)

        % This method gets called to retrieve the parameters of a single job, or an array
        % of parameters for all jobs if called without index.
        %
        % Return a struct-array with named parameters the same length as the unrolled loop.
        % If index is specified, then output only the structure at that index.
        %
        inputs = get_inputs(self,index);

        % This method gets called to execute a single job.
        %
        % inputs: structure similar to that returned by get_inputs(k) for some index k.
        % folder: path to the folder in which data will be saved (if any).
        % varargin: options that can be parsed by dk.obj.kwArgs (eg key/value pairs, or struct).
        %
        output = process(self,inputs,folder,varargin);

    end

    methods

        function cfg = load_config(self)
            cfg = dk.json.read(self.config_file);
            %cfg = fix_config(cfg);
        end

        function cfg = configure(self,nworkers,varargin)

            cfg     = self.load_config();
            inputs  = self.get_inputs();
            njobs   = numel(inputs);
            workers = split_jobs( njobs, nworkers );
            options = dk.obj.kwArgs(varargin{:});

            % edit the exec field
            cfg.exec.class   = self.name;
            cfg.exec.jobs    = inputs;
            cfg.exec.workers = workers;
            cfg.exec.options = options.parsed;

            % save edited config
            dk.print('[MapReduce] Configuration edited in "%s".',self.config_file);
            dk.json.write(self.config_file,cfg);

        end

        function cfg = set_folders(self,start,work,save)

            cfg = self.load_config();
            cfg.folders.start = start;
            cfg.folders.work  = work;
            cfg.folders.save  = save;

            % save edited config
            dk.print('[MapReduce] Configuration edited in "%s".',self.config_file);
            dk.json.write(self.config_file,cfg);

        end

        function cfg = set_cluster(self,queue,email,threads,jobname,mailopt)
        %
        % Mailopt option:
        %     ‘b’     Mail is sent at the beginning of the job.
        %     ‘e’     Mail is sent at the end of the job.
        %     ‘a’     Mail is sent when the job is aborted or rescheduled.
        %     ‘s’     Mail is sent when the job is suspended.
        %     ‘n’     No mail is sent.
        %
        % By default, mailopt is 'a'.
        %
            
            if nargin < 4, threads=1; end
            if nargin < 5, jobname='dk.mapred'; end
            if nargin < 6, mailopt='a'; end

            cfg = self.load_config();
            cfg.cluster.queue   = queue;
            cfg.cluster.email   = email;
            cfg.cluster.jobname = jobname;
            cfg.cluster.mailopt = mailopt;
            
            % only set threads if there are more than 1
            if threads > 1
                cfg.cluster.threads = threads;
            end

            % save edited config
            dk.print('[MapReduce] Configuration edited in "%s".',self.config_file);
            dk.json.write(self.config_file,cfg);

        end

    end

    methods (Hidden)

        function f = config_file(self)
            f = [dk.mapred.name2relpath(self.name) '.mapred.json'];
        end

        function config = load_running_config( self, folder )

            % load config (contains options)
            config = dk.json.read(fullfile( folder, 'config', 'config.json' ));
            %config = fix_config(config);

            % make sure the ID is correct
            dk.assert( strcmp(config.id,self.id), 'ID mismatch between this class (%s) and running config (%s).', self.id, config.id );

            % save the folder from where the config was loaded
            % this allows to move the folder around without affecting the processing
            config.folder = folder;

        end

        function [output,failed] = run_job( self, workerid, jobid, config )

            % not failed if the processing runs without error
            failed = true;

            % create folder for storage if it doesn't already exist
            jobfolder = fullfile( config.folders.save, sprintf('job_%d',jobid) );
            if ~dk.fs.isdir( jobfolder )
                dk.assert( mkdir(jobfolder), 'Could not create folder "%s".', jobfolder );
            end

            % parse options and make sure it's a struct
            options = config.exec.options;
            if isempty(options)
                options = struct();
            end

            % update info
            info.worker  = workerid;
            info.job     = jobid;
            info.inputs  = config.exec.jobs(jobid);
            info.options = options;
            info.status  = 'running';
            info.start   = get_timestamp();
            info.stop    = '';
            info.errmsg  = '';
            dk.json.write( fullfile(jobfolder,'info.json'), info );

            % processing
            try
                output = self.process( info.inputs, jobfolder, info.options );
                info.status = 'done';
                failed = false;
            catch ME
                output = [];
                info.status = 'failed';
                info.errmsg = ME.message;
            end

            % update info
            info.stop = get_timestamp();
            dk.json.write( fullfile(jobfolder,'info.json'), info );

        end

        function output = run_worker( self, folder, workerid )

            % load config (contains options)
            config = self.load_running_config(folder);

            % set worker id from environment if not provided
            if nargin < 3
                workerid = get_task_id();
            end

            % get all jobs to run
            jobids = config.exec.workers{workerid};
            njobs  = numel(jobids);

            dk.print('[MapReduce.START] Worker #%d',workerid);
            dk.print('         folder : %s',pwd);
            dk.print('           host : %s',dk.env.hostname);
            dk.print('           date : %s',get_timestamp);
            dk.print('          njobs : %d',njobs);
            dk.print('-----------------\n');

            timer  = dk.time.Timer();
            output = cell(1,njobs);

            for i = 1:njobs
                jobid = jobids(i);
                try
                    [output{i},failed] = self.run_job( workerid, jobid, config );
                    assert(~failed); % force exception to issue FAIL message
                    dk.print('Job #%d (%d/%d, timeleft %s)...',jobid,i,njobs,timer.timeleft_str(i/njobs));
                catch
                    dk.print('Job #%d (%d/%d)... FAILED',jobid,i,njobs);
                end
            end

            % save output file
            outfile = fullfile( folder, sprintf( config.files.worker, workerid ) );
            dk.print('\n\t Saving output file to "%s" (%s)...',outfile,get_timestamp);
            dk.savehd( outfile, output );

            fprintf('\n\n');
            dk.print('[MapReduce.STOP] Worker #%d',workerid);
            dk.print('          date : %s',get_timestamp);
            dk.print('        output : %s',outfile);
            dk.print('----------------\n');

        end

        function output = run_reduce( self, folder )

            % load config (contains options)
            config = self.load_running_config(folder);

            % prepare output
            njobs    = numel(config.exec.jobs);
            nworkers = numel(config.exec.workers);
            outfile  = fullfile( folder, config.files.reduce );

            dk.print('[MapReduce.START] Reduce');
            dk.print('         folder : %s',pwd);
            dk.print('           host : %s',dk.env.hostname);
            dk.print('           date : %s',get_timestamp);
            dk.print('       nworkers : %d',nworkers);
            dk.print('-----------------\n');

            if dk.fs.isfile(outfile)
                warning( 'Reduce file "%s" already exists, outputs will be merged.', outfile );
                output = load(outfile);
                output = output.output;
                assert( numel(output)==njobs, 'Wrong number of jobs in existing reduce file, aborting.' );
            else
                output = cell( 1, njobs );
            end

            % concatenate outputs
            timer = dk.time.Timer();
            for i = 1:nworkers

                workerfile = fullfile( folder, sprintf( config.files.worker, i ) );
                try
                    workerdata = load( workerfile );
                    output( config.exec.workers{i} ) = workerdata.output;
                    dk.print('Worker %d/%d merged, timeleft %s...',i,nworkers,timer.timeleft_str(i/nworkers));
                    % delete( workerfile );
                catch
                    dk.print('Worker %d/%d... FAILED',i,nworkers);
                end
            end

            % save output file
            dk.print('\n\t Saving reduced file to "%s" (%s)...',outfile,get_timestamp);
            dk.savehd( outfile, output );

            fprintf('\n\n');
            dk.print('[MapReduce.STOP] Reduce');
            dk.print('          date : %s',get_timestamp);
            dk.print('        output : %s',outfile);
            dk.print('----------------\n');

        end

    end

end

function t = get_timestamp()

    % return a nice timestamp with date and time
    t = datestr(now,'dd-mmm-yyyy HH:MM:SS');

end

function id = get_task_id()

    % get current task ID from computing environment variables (for now, only SGE)
    id = str2num(getenv('SGE_TASK_ID')); %#ok

end

function jobids = split_jobs( njobs, nworkers )

    % split a given number of jobs equally across a given number of workers
    % output is a 1xNworkers cell, each containing a list of job IDs
    assert( nworkers>0 && njobs>0, 'Inputs should be positive.' );

    njobs_per_worker  = ceil( njobs / nworkers );
    jobstrides = [0,cumsum(njobs_per_worker*ones(1,nworkers-1)),njobs];
    jobids = cell( 1, nworkers );
    for i = 1:nworkers
        jobids{i} = (1+jobstrides(i)):jobstrides(i+1);
    end

end

% apply corrections because of crap JSON parsing
function config = fix_config(config)

    % make sure the workers are stored in a cell
    assert( iscell(config.exec.workers) || ismatrix(config.exec.workers), 'Unexpected worker type.' );

    if ~iscell(config.exec.workers)
        n = size(config.exec.workers,1);
        config.exec.workers = dk.mapfun( @(k) config.exec.workers(k,:), 1:n, false );
    end

end
