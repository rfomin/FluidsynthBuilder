# Fluidsynth builder for Windows

This repo contains a script and docker environment for building Fluidsynth for
Windows. The resulting libraries should be statically linked making them easy
to redistribute.

To use just run build.sh and it will take care of all the details. Before
running make sure that Docker is installed and if you're on Windows you'll want
to install Git for git-bash.

Results will be in build/x86_64/bin and build/i686/bin.
