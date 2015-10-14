# s3-rbase
Docker image to execute R scripts together with AWS S3 buckets. 

The image is based on [r-base](https://hub.docker.com/_/r-base/) with [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) and [supervisor](http://supervisord.org).

## Quick Start

Create a [data container](https://docs.docker.com/userguide/dockervolumes/) named `rlib` to hold the R packages. This is to save space and time when you are running multiple instances of the image - they can share the libraries.
```
docker create -v /home/rlib --name rlib busybox
```

Run the s3-rbase container and mount the data container.
```
docker run -d --name s3-rbase1 --volumes-from rlib --privileged --cap-add SYS_ADMIN --device /dev/fuse -d -e "BUCKETNAME=$BUCKETNAME" -e "AWSACCESSKEYID=$AWSACCESSKEYID" -e "AWSSECRETACCESSKEY=$AWSSECRETACCESSKEY" hiveoss/s3-rbase
```

Install the all the R packages specified in `/home/packages/packages.txt`.
```
docker exec -ti s3-rbase1 cmd install
```

Install the R packages manually.
```
docker exec -ti s3-rbase1 cmd install.packages <PACKAGE_NAME_1> <PACKAGE_NAME_2> <PACKAGE_NAME_3>
```

Setup to include BioConductor repo.
```
docker exec -ti s3-rbase1 cmd bio
```

Check the installed R packages.
```
docker exec -ti s3-rbase1 cmd available
```

Execute a demo Rscript.
```
docker exec -ti s3-rbase1 cmd demo.R
```

## Configurations

#### Environment variables
The environment variables are used to indicate the bucket to mount and to provide credentials to access the bucket.

- `$BUCKETNAME` - the AWS bucket name
- `$AWSACCESSKEYID` - the AWS key id
- `$AWSSECRETACCESSKEY` - the AWS secret token

#### s3fs-fuse
You can overwrite `scripts/runS3fs.sh` to change the parameters for the s3fs.
```
mkdir -p /home/shared/s3 && 
mkdir -p /tmp && 
s3fs $BUCKETNAME /home/shared/s3 -o use_cache=/tmp -o allow_other -o umask=0002 -o use_rrs -f
``` 

#### supervisor
You can overwrite `config/supervisord.conf` to change the parameters for the supervisord. But usually you do not need to unless you need to start additional processes. Noted that daemon is off by default for supervisor.

#### S3 folder
The default s3 bucket is mounted at `/home/shared/s3`.

#### R lib folder
The default R lib folder is mounted at `/home/rlib`.

#### Listing for required R Packages
The required packages can be found at `/home/packages/packages.txt`. Existing packages will not be installed again.

You can either [mount a host directory](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume) into the container and include your own `packages.txt`, or create a new [`Dockerfile`](https://docs.docker.com/reference/builder/) pulling from this image and replacing the `packages.txt`.

#### Rscripts
All R scripts should be found in `/home/rscripts`. 

You can either [mount a host directory](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume) into the container and include your own R scripts, or create a new [`Dockerfile`](https://docs.docker.com/reference/builder/) pulling from this image and inserting your R scripts files into `/home/rscripts`.

#### cmd
The image comes with a `cmd` helper. You can use it via [`docker exec`](https://docs.docker.com/reference/commandline/exec/). There are 4 possible arguments - `no argument`, `install`, `available`, `*`.

- `no argument`: where there are no arguments, `cmd` will start the supervisor, and mount the S3 buckets (generally not required, as it is execute when you run the container).
- `install`: install the R packages listed in `/home/packages/packages.txt`. Only new packages will be installed.
- `available`: list the available installed R packages in `/home/rlib`.
- `*`: wildcard to the filename of the R script to execute.

Example
```
# execute the Rscript in demo.R
docker exec -ti s3-rbase1 cmd demo.R
```

## docker-compose
A sample `docker-compose.yml` is available at our [github repo](https://github.com/HiveOSS-Dockers/s3-rbase).

```
r-lib-vol:
  image: busybox
  container_name: rlib
  volumes:
    - /home/rlib 

r-test:
  image: hiveoss/s3-rbase:latest
  container_name: rtest
  privileged: true
  cap_add:
    - SYS_ADMIN
  devices:
    - /dev/fuse
  environment:
    - BUCKETNAME=SOME_AWS_BUCKETNAME
    - AWSACCESSKEYID=SOME_AWS_ID
    - AWSSECRETACCESSKEY=SOME_AWS_KEY
  volumes:
    - ./rscripts:/home/rscripts
    - ./default_packages.txt:/home/packages/packages.txt
  volumes_from:
    - r-lib-vol
```

## Note: Data container
Docker will not warn you when removing a container without providing the -v option to delete its volumes. If you remove containers without using the -v option, you may end up with “dangling” volumes; volumes that are no longer referenced by a container. Dangling volumes are difficult to get rid of and can take up a large amount of disk space. 