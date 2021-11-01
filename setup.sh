# Copy slurm profile
cp -r \
  "$SCRIPTPATH/slurm-profile" \
 slurmprofile

cd slurmprofile

# Configure via environment variables instead of cookiecutter
cat << SETTINGSJSON > settings.json
{
    "SBATCH_DEFAULTS": "$SBATCH_DEFAULTS",
    "CLUSTER_NAME": "$CLUSTER_NAME",
    "CLUSTER_CONFIG": "$CLUSTER_CONFIG",
    "ADVANCED_ARGUMENT_CONVERSION": "no"
}
SETTINGSJSON

# Also allow some config.yaml options to be specified with environment
# variables
if [[ -n "$RESTART_TIMES" ]]; then
  sed -i "s/restart-times:.*/restart-times: $RESTART_TIMES/" config.yaml
fi

if [[ -n "$LATENCY_WAIT" ]]; then
  sed -i "s/latency-wait:.*/latency-wait: $LATENCY_WAIT/" config.yaml
fi

# Modify job starting script to use Singularity
cat << JOBSCRIPT > slurm-jobscript.sh
#!/bin/bash
# properties = {properties}

# Skip since we are also executing the PRE_COORDINATOR_SCRIPT
#if [[ -n "\$PRE_JOB_SCRIPT" ]]; then
#  eval "\$PRE_JOB_SCRIPT"
#fi

NO_COORDINATOR_SETUP=1
DEFAULT_HOST_PROGS="singularity"
SCRIPTPATH="$SCRIPTPATH"

. \$SCRIPTPATH/coordinator.sh

cat << 'EXECJOB' | singularity shell \$SING_EXTRA_ARGS --bind \$tmp_dir/req_run/:/var/run/req_run --nv $SIF_PATH
export PATH=/hostbin:\$PATH
{exec_job}
EXECJOB
JOBSCRIPT

chmod +x slurm-jobscript.sh

cd ..
