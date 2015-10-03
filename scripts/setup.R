rlib = "/home/rlib"
libraries = readLines("/home/packages/packages.txt",skipNul=T)
available = installed.packages(rlib)[,1]

for(library in libraries) { 
  if (!is.element(library, available))
      install.packages(library, lib=rlib, clean = T)
}
