# Copy slurm profile
cp -r \
  "$SCRIPTPATH/../slurm-profile/{{cookiecutter.profile_name}}" \
 slurmprofile

cd slurmprofile

sed -i \
  's/import subprocess/import fake_subprocess/g' \
  slurm-status.py \
  slurm_utils.py

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

if [[ -n "\$PRE_JOB_SCRIPT" ]]; then
  eval "\$PRE_JOB_SCRIPT"
fi

cat << 'EXECJOB' | singularity shell \$SING_EXTRA_ARGS --nv $SIF_PATH
{exec_job}
EXECJOB
JOBSCRIPT

chmod +x slurm-jobscript.sh

# Symlink req_run.py so that it used instead of subprocess.py

cp $SCRIPTPATH/req_run.py .
cp $SCRIPTPATH/fake_subprocess.py .

cd ..

# If we are asked to patch Snakemake within the container to use Singularity on the host

if [[ -n "$SNAKEMAKE_HOST_SINGULARITY" ]]; then
  mkdir snakemake_host_singularity
  cd snakemake_host_singularity
  PWD=$(pwd)

  cat << 'GET_SNAKEMAKE_SINGULARITY_SCRIPT' > get-snakemake-singularity-script.sh
TARGET=$(python -c 'import snakemake.deployment.singularity as s; print(s.__file__)')
"cp" $TARGET ./snakemake_singularity_module.py && echo $TARGET
GET_SNAKEMAKE_SINGULARITY_SCRIPT

  chmod +x get-snakemake-singularity-script.sh
  TARGET=$(singularity exec --bind $PWD $SIF_PATH $PWD/get-snakemake-singularity-script.sh)

  sed -i 's/import subprocess/import fake_subprocess/g' snakemake_singularity_module.py

  SING_EXTRA_ARGS="\
--bind $tmp_dir/snakemake_host_singularity/snakemake_singularity_module.py:$TARGET \
--bind $SCRIPTPATH/fake_subprocess.py:$(dirname $TARGET)/fake_subprocess.py \
$SING_EXTRA_ARGS"
  SNAKEMAKE_EXTRA_ARGS="--use-singularity $SNAKEMAKE_EXTRA_ARGS"
  cd ..
fi
