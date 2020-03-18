FROM ubuntu:19.10

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y install cmake meson pkg-config mingw-w64-tools g++-mingw-w64-i686 g++-mingw-w64-x86-64 wine64 wine32 \
	                   git python3-setuptools

WORKDIR /src
ENTRYPOINT [ "/src/build.sh", "compile" ]
