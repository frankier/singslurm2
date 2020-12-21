snakemake \
  -j$NUM_JOBS \
  --profile $tmp_dir/slurmprofile \
  --snakefile $SNAKEFILE \
  $@
