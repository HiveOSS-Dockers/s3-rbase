#!/bin/bash
if [[ $# -eq 0 ]] 
then
  /usr/bin/supervisord
  exit 0
else
  case $1 in
    "install")
      exec Rscript /home/scripts/setup.R;;
    "install.packages")
      exec Rscript /home/scripts/setupPackages.R $@;;
    "bio")
      exec Rscript /home/scripts/setupBio.R;;
    "available")
      exec Rscript -e 'installed.packages("/home/rlib")[,1]';;
    *)
      exec Rscript $@;;
  esac
fi