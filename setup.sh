# Copy slurm profile
cp -r \
  "$SCRIPTPATH/../slurm-profile/{{cookiecutter.profile_name}}" \
 slurmprofile

cd slurmprofile

# Patch out cookiecutter stuff and replace with import
# TODO: Support cluster_name
awk '
/cookiecutter/ { inCc = 1 }
inCc {
    if ( /RESOURCE_MAPPING/ ) {
        print("from config import SBATCH_DEFAULTS, CLUSTER_CONFIG, ADVANCED_ARGUMENT_CONVERSION\n")
        inCc = 0
    }
    else {
        next
    }
}
{ print }
' slurm-submit.py > tmp && \
  cat tmp > slurm-submit.py && \
  rm tmp
 
awk '
/{% if cookiecutter.cluster_name %}/ { inCc = 1 }
inCc {
    if ( /{% endif %}/ ) {
        print("cluster = \047\047\n")
        inCc = 0
    }
    next
}
{ print }
' slurm-status.py > tmp && \
  cat tmp > slurm-status.py && \
  rm tmp

sed -i \
  's/import subprocess /import fake_subprocess /g' \
  slurm-status.py \
  slurm_utils.py

# Configure via environment variables instead of cookiecutter
cat << CONFIGPY > config.py
SBATCH_DEFAULTS = "$SBATCH_DEFAULTS"
CLUSTER_CONFIG = "$CLUSC_CONF"
ADVANCED_ARGUMENT_CONVERSION = False
CONFIGPY

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
if [[ -n "\$PRE_JOB_SCRIPT" ]]; then
  eval "\$PRE_JOB_SCRIPT"
fi

cat << EXECJOB | singularity shell $SING_EXTRA_ARGS --nv $SIF_PATH 
{exec_job}
EXECJOB
JOBSCRIPT

chmod +x slurm-jobscript.sh

# Symlink req_run.py so that it used instead of subprocess.py

cp $SCRIPTPATH/req_run.py .
cp $SCRIPTPATH/fake_subprocess.py .

cd ..
