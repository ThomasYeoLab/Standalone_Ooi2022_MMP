# Map-Reduce Framework

This submodule allows you to distribute the computation of some iterative process (typically something that can be written in the form of a for-loop with independent iterations) on a computing cluster.

It contains Python scripts that should be **installed** on the user profile. Specifically, they should be copied to a folder that is on the user's `PATH`.
For now, the scripts assume that the user is using `fsl_sub` to submit a parallel job to the computing cluster, but this can be changed if necessary.

## Overview

Consider the following loop:
```matlab
% define options that apply to the entire loop
Pre = pre_processing();

for i = 1:n

    % get iteration-specific parameters
    Param = acquire_parameters(i);

    % do something, and store results
    Res{i} = repetitive_task( Param, Pre );

end
```

The submodule `dk.mapred` essentially allows you to store the pre-processing results in a configuration file, and write down the implementations of the functions `acquire_parameters` and `repetitive_task` into a class.
Note that each iteration _must_ be independent from the others; that is, the for loop should be readily parallelisable.

The main purpose of this submodule is to:

 - break down the for-loop into groups of indices,
 - run each group on a separate compute node,
 - and aggregate the results once all groups are computed.

The program in charge of running each group is called a **worker**, and each task corresponding to a specific index is called a **job**.

In addition, this implementation allows you to save intermediary results into a job-specific folder, and return results to be aggregated as the main output. Ideally, the main results should be reasonably small in size (especially if there are a lot of iterations), but the intermediary results can be arbitrarily large.

## Define your processing task

Assuming that Deck is on your Matlab path, run:
```matlab
dk.mapred.init( 'MyProcessingTask' )
```

This should create **two** new files in the current directory:

 - `MyProcessingTask.m`
 - `MyProcessingTask.mapred.json`

The first file contains a **class definition** with two methods:

 - `inputs = get_inputs(self,index)`: if called with a single index, this method should return a struct of parameters for the corresponding iteration.
 Otherwise if called with an array of indices (or without input), it should return a struct-array for the corresponding iterations (or all iterations).
 You might want to have a look at `dk.struct.array` for a practical implementation.
 - `output = process(self,inputs,folder,varargin)`: this method should run the computations of interest for a given struct of parameters, and will be invoked with a folder where intermediary results can be saved, and an additional structure of options if you specified it (see configuration below). For testing purposes (before you run it on the cluster), you might want to implement this method to accept only one input.

The second file contains **processing options** with five main categories:

 - `id`: this field is assigned automatically when calling `dk.mapred.init`;
 - `cluster`: assigned by `set_cluster` during configuration, and contains options to be passed to `fs_sub`, such as the queue name, your e-mail, and the name of your process;
 - `exec`: assigned by `configure` during configuration, and contains all necessary information to distribute the computations on the cluster;
 - `folders`: assigned by `set_folders` during configuration, the paths of the various folders
 - `files`: the names of the files aggregating the main outputs, you may want to customise this;

## Configuration

The methods to call are in `dk.mapred.Abstract`, specifically:

 - `configure`: number of workers and options, the number of jobs is given by the length of the struct-array returned by `get_inputs()`;
 - `set_cluster`: set cluster options, such as queue name and e-mail;
 - `set_folder`: set working folders.

## Running on the cluster

Call `mapred_build`.

While it runs, track the task that are finished with `mapred_status`.

Once it has run, call `mapred_backup`.

## Creating your own template

Put them in folder `dk.mapred.path('templates')`.
You can use `${variable}` syntax in the class template.

Available templates can be listed with `dk.mapred.list_templates`.

When calling `dk.mapred.init`, the second argument is the name of the template, and the third argument allows you to specify interpolation strings for template `${variables}`.

## TODO

 - Create Python module instead of independent scripts.
 - Create abstract cluster interface, and implement one for `fsl_sub`.
 - Instead of the fourth argument in `dk.mapred.init`, add a method to `dk.mapred.Abstract` to edit any first-level field in the configuration.
 - Make `start` folder optional (if empty, don't put it in the Matlab command).
