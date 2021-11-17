all: package.zip

clean:
	rm -rf build
	cd singreqrun/ && make clean

singreqrun/clients/unix/client.com:
	cd singreqrun/ && make

build/singslurm2/README.md: singreqrun/clients/unix/client.com
	mkdir -p build/singslurm2
	cp -r \
	  singreqrun/executor.sh \
	  singreqrun/entrypoint.sh \
	  singreqrun/coordinator.sh \
	  singreqrun/patch_path_then.sh \
	  run_bootstrap.sh \
	  setup.sh \
	  README.md \
	  singreqrun/clients/unix/client.com \
	  singreqrun/contrib \
	  build/singslurm2
	cp -r \
	  slurm-profile/{{cookiecutter.profile_name}} \
	  build/singslurm2/slurm-profile

package.zip: build/singslurm2/README.md
	cd build/ && zip -r package.zip singslurm2
	mv build/package.zip .
