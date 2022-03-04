# Map-Reduce Framework

- Overview
- Installation
- Creating a new task
- Templates
- Running a task

---

## Overview

Unroll for-loop type tasks and assign subset of iterations to be executed on separate machines.
Assumes that iterations are _independent_ from each other. A given iteration is called a **job**, and a given machine is called a **worker**.

The purpose of this submodule is to ease the process of distributing an iterative task of arbitrary length to an arbitrary number of workers on an arbitrary cluster (for now, the SGE cluster at FMRIB). You can configure things quite deeply, but if you don't care about the details, the basic usage should be fairly painless.

Each task is defined by a class, and an associated configuration file in JSON format. Once a task is defined, you can configure it as many times as you want to be distributed across any number of workers with any number of options. This means that you can reuse the code of a single task to run several iterations with different parameters, and save the results in different places.

Once a task is configured, you can set it up for running on the cluster using the Python scripts provided. These scripts create a folder (in a place that you specify) in which all the results and logs will be saved. It also generates bash files with which you can submit the whole task array, or re-run individual workers if anything caused them to fail. When it is running, the structure of this folder typically looks like this:

```
folder/
 |- config/
 |--- config.json -> config_{TIMESTAMP}.json
 |--- config_{TIMESTAMP}.json
 |- logs/
 |--- backup.sh
 |--- {JOBNAME}.e{PID}.{TID}
 |--- {JOBNAME}.o{PID}.{TID}
 |--- job_{PID}/
 |- data/
 |--- {BACKUPNAME}/
 |- job_*/
 |--- info.json
 |- worker_*_output.mat
 |- map.sh
 |- reduce.sh
 |- runworker
 |- submit
```

## Installation

From Matlab:
```
dk.mapred.install( bindir='~/local/bin' )
```

From the terminal:
```
cd +dk/+mapred/
./install.sh ${HOME}/local/bin
```

## Creating a new task

The quickest way, using default options:
```
dk.mapred.init( 'foo.Bar' )
```

## Configuring a task

Manually by editing the file `ClassName.mapred.json`.

In an automated manner from the Matlab console:
```
obj = ClassName();
obj.configure( nworkers, options... );
```

This will update the splitting of jobs and save the configuration in the JSON file.
Note that this will NOT overwrite the cluster configuration (ie queue, email, etc).

## Templates

Create templates in the folder `+dk/+mapred/templates` by copying the default one. You can then use them with `dk.mapred.init( className, tplName, tplOptions=struct() )`.

## Running a task
