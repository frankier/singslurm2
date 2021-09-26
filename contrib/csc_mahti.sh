PRE_SCRIPT=$(cat <<'END_PRE_SCRIPT'
# Modified from CSC singularity_wrapper

# Bind common CSC environment directories
CSC_SING_FLAGS="-B /users:/users -B /projappl:/projappl -B /scratch:/scratch"

# Bind TMPDIR if it is set and directory exists
if [ -d "$TMPDIR" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B $TMPDIR:$TMPDIR"
fi

# Bind LOCAL_SCRATCH if it is set and directory exists
if [ -d "$LOCAL_SCRATCH" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B $LOCAL_SCRATCH:$LOCAL_SCRATCH"
fi

# Bind /fmi if it is set and directory exists
if [ -d "/fmi" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B /fmi:/fmi"
fi

# Bind /appl/data
if [ -d "/appl/data" ]; then
    CSC_SING_FLAGS="$CSC_SING_FLAGS -B /appl/data:/appl/data"
fi

# Put into start of $SING_EXTRA_ARGS
SING_EXTRA_ARGS="$CSC_SING_FLAGS $SING_EXTRA_ARGS"
END_PRE_SCRIPT
)

export PRE_COORDINATOR_SCRIPT="$PRE_SCRIPT"
export PRE_JOB_SCRIPT="$PRE_SCRIPT"
