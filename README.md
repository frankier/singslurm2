# singslurm

This profile configures Snakemake installed within a Singularity container to run on the [SLURM Workload Manager](https://slurm.schedmd.com/)

The project integrates [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and [singreqrun](https://github.com/frankier/singreqrun).

## Running

First perform a **recursive** clone of this repository:

    $ cd ~
    $ git clone --recursive https://github.com/frankier/singslurm2.git

Then it can be run using `~/singslurm2/run.sh`. Arguments are passed
using environment variables:

 * $SIF_PATH: Path to Singularity SIF file for everything -- the Snakemake
   control job and the execution jobs on the cluster
 * $SNAKEFILE: Path within container to directory containing Snakefile
 * $CLUSC_CONF: Path within container to file mapping rules to resource requirements
 * $TRACE: Trace this script
 * $SBATCH_DEFAULTS: Default arguments to pass to sbatch
 * $NUM_JOBS: Max jobs at the Snakemake level. Each may include many SLURM tasks. 128 by default.

Its actual arguments will be passed to Snakemake within the container.

If you want to run the control job a cluster node, rather than a login node,
just put your environment variable arguments and execution of
`~/singslurm2/run.sh` in a script `run_myproj.sh` and submit manually e.g.:

    $ sbatch --time 5-00:00:00 ./run_myproj.sh

## More information

More information can be found from [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and
[singreqrun](https://github.com/frankier/singreqrun).
