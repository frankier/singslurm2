snakemake \
  -j$NUM_JOBS \
  --profile $TMP_DIR/slurmprofile \
  --snakefile $SNAKEFILE \
  $SNAKEMAKE_EXTRA_ARGS \
  $ARGS
