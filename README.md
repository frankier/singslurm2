# singslurm2 = Snakemake + Singularity + SLURM

This profile configures Snakemake installed within a Singularity container to run on the [SLURM Workload Manager](https://slurm.schedmd.com/)

The project integrates [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and [singreqrun](https://github.com/frankier/singreqrun).

## Running

First perform a **recursive** clone of this repository:

    $ cd ~
    $ git clone --recursive https://github.com/frankier/singslurm2.git

Then it can be run using `~/singslurm2/run.sh`. Arguments are passed
using environment variables:

 * `$SIF_PATH`: Path to Singularity SIF file for everything -- the Snakemake
   control job and the execution jobs on the cluster
 * `$SNAKEFILE`: Path within container to directory containing Snakefile
 * `$CLUSC_CONF`: Path within container to file mapping rules to resource requirements
 * `$TRACE`: Trace this script
 * `$SBATCH_DEFAULTS`: Default arguments to pass to sbatch
 * `$NUM_JOBS`: Max jobs at the Snakemake level. Each may include many SLURM tasks. 128 by default.

Anything passed as an actual arguments to `run.sh` will be passed to
Snakemake within the container.

If you want to run the control job a cluster node, rather than a login node,
just put your environment variable arguments and execution of
`~/singslurm2/run.sh` in a script `run_myproj.sh` and submit manually e.g.:

    $ sbatch --time 5-00:00:00 ./run_myproj.sh

## Customisation for different cluster environments

Some cluster computing environments have different directory layouts for where
project and scratch data are stored. You can customise `$SING_EXTRA_ARGS` at
the last moment -- when environment variables are pointing at the correct
places `` using `$PRE_COORDINATOR_SCRIPT` and `$PRE_JOB_SCRIPT`. You can then
source this in your job script `./run_myproj.sh`. An example of this for CSC is
available in `contrib/csc.sh`. To use it you would add for example
`/path/to/contrib/csc.sh` to the beginning of all your job scripts.

## More information

More information can be found from [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and
[singreqrun](https://github.com/frankier/singreqrun).
