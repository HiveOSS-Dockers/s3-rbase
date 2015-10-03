# read in arguments
# arg1 - directory of interest
# arg2 - file of interest
args <- commandArgs(trailingOnly = TRUE)

# set work directory at the directory of interest
setwd(paste("/home/shared/s3",args[1],sep='/'))

# list content of working directory
list.files(path=".")