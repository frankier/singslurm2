# Copy slurm profile
cp -r \
  "$SCRIPTPATH/../slurm-profile/{{cookiecutter.profile_name}}" \
 slurmprofile

cd slurmprofile

# Patch out cookiecutter stuff and replace with import
awk '
/cookiecutter/ { inCc = 1 }
inBlock {
    if ( /cookiecutter/ ) {
        next
    }
    else {
        print("from config import SBATCH_DEFAULTS, CLUSTER_CONFIG, ADVANCED_ARGUMENT_CONVERSION\n")
        inBlock = 0
    }
}
{ print }
' slurm-submit.py > tmp && \
  mv tmp slurm-submit.py

# Configure via environment variables instead of cookiecutter
cat << CONFIGPY > config.py
SBATCH_DEFAULTS = "$SBATCH_DEFAULTS"
CLUSTER_CONFIG = "$CLUSC_CONF"
ADVANCED_ARGUMENT_CONVERSION = False
CONFIGPY

# Modify job starting script to use Singularity
cat << JOBSCRIPT > slurm-jobscript.sh
#!/bin/bash
# properties = {properties}
cat << EXECJOB | singularity shell $SING_EXTRA_ARGS --nv $SIF_PATH 
{exec_job}
EXECJOB
JOBSCRIPT

chmod +x slurm-jobscript.sh

cd ..
