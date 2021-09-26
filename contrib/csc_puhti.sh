PRE_SCRIPT=$(cat <<'END_PRE_SCRIPT'
# From CSC singularity_wrapper
CSC_SING_FLAGS="-B /users:/users -B /projappl:/projappl -B /scratch:/scratch -B /appl/data:/appl/data"
if [ -n "$TMPDIR" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B $TMPDIR:$TMPDIR"
fi
if [ -n "$LOCAL_SCRATCH" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B $LOCAL_SCRATCH:$LOCAL_SCRATCH"
fi
SING_EXTRA_ARGS="$CSC_SING_FLAGS $SING_EXTRA_ARGS"
END_PRE_SCRIPT
)

export PRE_COORDINATOR_SCRIPT="$PRE_SCRIPT"
export PRE_JOB_SCRIPT="$PRE_SCRIPT"
