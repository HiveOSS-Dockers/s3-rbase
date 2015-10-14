rlib = "/home/rlib"
libraries = commandArgs(trailingOnly = TRUE)
available = installed.packages(rlib)[,1]

print(libraries)

for(library in libraries[-1]) { 
  if (!is.element(library, available))
      install.packages(library, lib=rlib, clean = T)
}