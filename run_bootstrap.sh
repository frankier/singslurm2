snakemake \
  -j$NUM_JOBS \
  --profile $TMP_DIR/slurmprofile \
  --snakefile $SNAKEFILE \
  $@
