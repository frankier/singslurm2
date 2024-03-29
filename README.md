# singslurm2 = Snakemake + Singularity + SLURM

This profile configures Snakemake installed within a Singularity container to
run on the [SLURM Workload Manager](https://slurm.schedmd.com/).

The project integrates [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and
[singreqrun](https://github.com/frankier/singreqrun).

`singslurm2` also supports spawning extra Singularity containers using
[Snakemake's Singularity
support](https://snakemake.readthedocs.io/en/v5.7.3/snakefiles/deployment.html#running-jobs-in-containers),
however this requires Snakemake 6.10.0 and only rules written with the `shell`
directive are supported.

## Running

Installation is performed by [download a packaged
release](https://github.com/frankier/singslurm2/releases/) and then unzipping
it.

Assuming the latest release is `$VERSION`, you can run:

    $ cd ~
    $ wget https://github.com/frankier/singslurm2/releases/download/$VERSION/singslurm2.pkg.zip
    $ unzip singslurm2.pkg.zip

After performing these steps the entrypoint is `~/singslurm2/run.sh`. Arguments
are passed using environment variables. Compulsory arguments are shown in
**bold**:

 * Options relating to Singularity:
   * **`$SIF_PATH`**: Path to Singularity SIF file within which both the
     Snakemake control job and the execution of the rules will occur on the
     cluster
   * `SING_EXTRA_ARGS`: Extra arguments to pass to `singularity exec` and
     `singularity shell`. Most often you might use this to pass in extra
     `--bind` commands.
 * Options relating only to Snakemake:
   * **`$SNAKEFILE`**: Path within container to directory containing Snakefile
 * Options relating to SLURM/Snakemake:
   * **`$CLUSTER_CONFIG`**: Path within container to file mapping rules to resource
     requirements
   * `$CLUSTER_NAME`: Some HPCs define multiple SLURM clusters. In this case
     you may need to specify the cluster using this environment variable.
   * `$NUM_JOBS`: Max jobs at the Snakemake level. Each may include many SLURM
     tasks. 128 by default.
   * `$SBATCH_DEFAULTS`: Default arguments to pass to sbatch
   * `$RESTART_TIMES`: Maximum number of times to restart a failing job. 3 by
     default.
   * `$LATENCY_WAIT`: The number of seconds to wait for a rule's output before
     concluding it has failed. 30 by default.
 * Other options:
   * `$TRACE`: Trace the script -- useful for debugging
   * `$PRE_COORDINATOR_SCRIPT` and `$PRE_JOB_SCRIPT`: script fragments, typically
     setting or modifying environment variables, which will run at the
     beginning of the coordinator and job processes respectively. See
     *Customisation for different cluster environments* for typical usage.

Anything passed as an actual arguments to `run.sh` will be passed to Snakemake
within the container.

If you want to run the control job a cluster node, rather than a login node,
just put your environment variable arguments and execution of
`~/singslurm2/run.sh` in a script `run_myproj.sh` and submit manually e.g.:

    $ sbatch --time 5-00:00:00 ./run_myproj.sh

## Customisation for different cluster environments

Some cluster computing environments have different directory layouts. They
might for example have separate project and scratch data directory trees. In
some cases, scratch directories are only available on SLURM job nodes. You can
use `$PRE_COORDINATOR_SCRIPT` and `$PRE_JOB_SCRIPT` to customise things, for
example `--bind` within `$SING_EXTRA_ARGS` at the last moment, within the
correct environment with the directories and environment variables pointing at
them available.

A typical usage might be to put this cluster specific setup into a script,
which you then source this in your job running script i.e. put `source
~/myclustersetup.sh` at the top of `run_myproj.sh`. Examples for CSC (national
Finnish HPC provider) are available in `contrib/csc_mahti.sh` and
`contrib/csc_puhti.sh`. This might be useful as a starting point for other
providers. To use it you would add for example `/path/to/contrib/csc.sh` to the
beginning of all your job scripts.

## More information

More information can be found from [the SLURM Snakemake
profile](https://github.com/Snakemake-Profiles/slurm) and
[singreqrun](https://github.com/frankier/singreqrun).
