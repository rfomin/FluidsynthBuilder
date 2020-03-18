#!/bin/bash

readonly FluidSynthVersion=2.1.1
readonly GlibVersion=2.64.1
readonly ProxyLibintlVersion=0.1
readonly LibffiVersion=meson
readonly ZlibVersion=1.2.11
readonly ZlibPatchVersion=1.2.11-3
readonly LibInstPatchVersion=1.1.3

# libsndfile deps
readonly OggVersion=1.3.4
readonly VorbisVersion=1.3.6
readonly FlacVersion=1.3.3
readonly OpusVersion=1.3.1
readonly SndfileVersion=4bdd7414602946a18799b514001b0570e8693a47

readonly ScriptDir=${0%/*}

build_glib() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/glib-$Arch" &&
	cd "$ScriptDir/build/glib-$Arch" &&

	meson ../../glib \
		--prefix="$ScriptDir/build/$Arch" \
		--cross-file "$ScriptDir/cross-$Arch.txt" \
		--buildtype release \
		--default-library static \
		-D nls=disabled \
		-D libmount=disabled &&

	ninja &&
	ninja install
}

build_fluidsynth() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/fluidsynth-$Arch" &&
	cd "$ScriptDir/build/fluidsynth-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../fluidsynth \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -lintl -Wl,-Bdynamic,--no-whole-archive" \
		-DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -lintl -Wl,-Bdynamic,--no-whole-archive" &&

	ninja &&
	ninja install/strip
}

build_libogg() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/libogg-$Arch" &&
	cd "$ScriptDir/build/libogg-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../libogg \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" &&

	ninja &&
	ninja install/strip
}

build_flac() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/flac-$Arch" &&
	cd "$ScriptDir/build/flac-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../flac \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_CXXLIBS=OFF

	ninja &&
	ninja install/strip &&

	# pkg-config file in wrong location
	mv "$ScriptDir/build/$Arch/"{share,lib}/pkgconfig/flac.pc
}

build_opus() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/opus-$Arch" &&
	cd "$ScriptDir/build/opus-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../opus \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" \
		-DBUILD_SHARED_LIBS=OFF \
		-DOPUS_STACK_PROTECTOR=OFF &&

	ninja &&
	ninja install/strip
}


build_vorbis() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/vorbis-$Arch" &&
	cd "$ScriptDir/build/vorbis-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../vorbis \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" &&

	ninja &&
	ninja install/strip
}

build_libinstpatch() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/libinstpatch-$Arch" &&
	cd "$ScriptDir/build/libinstpatch-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../libinstpatch \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lintl -Wl,-Bdynamic,--no-whole-archive" \
		-DBUILD_SHARED_LIBS=OFF &&

	ninja &&
	ninja install/strip || return

	if [[ $Arch == 'x86_64' ]]; then
		# Installs 64-bit stuff to lib64 but we don't look there
		mv "$ScriptDir/build/$Arch/lib64/"*.a "$ScriptDir/build/$Arch/lib/" &&
		mv "$ScriptDir/build/$Arch/lib64/pkgconfig/"* "$ScriptDir/build/$Arch/lib/pkgconfig/" || return
	fi
}

# We want to build libsndfile as a shared library since ZMusic uses it as well
build_libsndfile() {
	declare Arch=$1
	shift

	mkdir -p "$ScriptDir/build/libsndfile-$Arch" &&
	cd "$ScriptDir/build/libsndfile-$Arch" &&

	CXX="$Arch-w64-mingw32-g++-posix" CC="$Arch-w64-mingw32-gcc-posix" cmake ../../libsndfile \
		-GNinja \
		-DCMAKE_INSTALL_PREFIX="$ScriptDir/build/$Arch" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Windows \
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32;$ScriptDir/build/$Arch" \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_SYSROOT="/usr/$Arch-w64-mingw32" \
		-DENABLE_STATIC_RUNTIME=ON \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TESTING=OFF \
		-DBUILD_PROGRAMS=OFF \
		-DBULID_REGTEST=OFF &&

	ninja &&
	ninja install/strip
}

fetch_source() {
	declare Filename=$1
	shift
	declare Url=$1
	shift

	declare Dirname=${Filename%.tar*}
	if [[ ! -f "$Filename" ]]; then
		rm -rf "${Dirname%%-*}" &&
			curl -L -o "$Filename" "$Url" &&
			tar xf "$Filename" &&
			mv "$Dirname" "${Dirname%%-*}"
	fi
}

fetch_sources() {
	fetch_source "fluidsynth-$FluidSynthVersion.tar.gz" "https://github.com/FluidSynth/fluidsynth/archive/v$FluidSynthVersion.tar.gz" &&
	fetch_source "glib-$GlibVersion.tar.xz" "https://download.gnome.org/sources/glib/2.64/glib-$GlibVersion.tar.xz" &&
	fetch_source "proxy-libintl-$ProxyLibintlVersion.tar.gz" "https://github.com/frida/proxy-libintl/archive/$ProxyLibintlVersion.tar.gz" &&
	fetch_source "libffi-$LibffiVersion.tar.gz" "https://gitlab.freedesktop.org/gstreamer/meson-ports/libffi/-/archive/meson/libffi-$LibffiVersion.tar.gz" &&
	fetch_source "zlib-$ZlibVersion.tar.gz" "https://zlib.net/fossils/zlib-$ZlibVersion.tar.gz" || return
	fetch_source "libogg-$OggVersion.tar.xz" "http://downloads.xiph.org/releases/ogg/libogg-$OggVersion.tar.xz" || return
	# For some reason the libvorbis and flac source distribution doesn't include the CMakeFiles from the git repo
	fetch_source "vorbis-$VorbisVersion.tar.gz" "https://github.com/xiph/vorbis/archive/v$VorbisVersion.tar.gz" || return
	fetch_source "flac-$FlacVersion.tar.gz" "https://github.com/xiph/flac/archive/$FlacVersion.tar.gz" || return
	fetch_source "opus-$OpusVersion.tar.gz" "https://archive.mozilla.org/pub/opus/opus-$OpusVersion.tar.gz" || return
	fetch_source "libsndfile-$SndfileVersion.tar.gz" "https://github.com/erikd/libsndfile/archive/$SndfileVersion.tar.gz" || return
	fetch_source "libinstpatch-$LibInstPatchVersion.tar.gz" "https://github.com/swami/libinstpatch/archive/v$LibInstPatchVersion.tar.gz" || return

	if [[ -d proxy ]]; then
		rm -rf glib/subprojects/proxy-libintl &&
			mv proxy glib/subprojects/proxy-libintl || return
	fi

	if [[ -d libffi ]]; then
		rm -rf  glib/subprojects/libffi &&
			mv libffi glib/subprojects/ || return
	fi

	if [[ -d zlib ]]; then
		rm -rf "glib/subprojects/zlib-$ZlibVersion" &&
			mv zlib "glib/subprojects/zlib-$ZlibVersion" || return

		# If we have fresh zlib sources then we should probably fetch this again
		rm -f "zlib-$ZlibPatchVersion.tar.gz" &&
			fetch_source "zlib-$ZlibPatchVersion.tar.gz" "https://github.com/mesonbuild/zlib/archive/$ZlibPatchVersion.tar.gz" &&
			mv zlib/* glib/subprojects/zlib-$ZlibVersion/ &&
			rm -rf zlib || return
	fi

	# Missing file in 1.3.1 distribution
	if [[ ! -f opus/opus_buildtype.cmake ]]; then
		touch opus/opus_buildtype.cmake || return
	fi
}

patch_sources() {
	# Check if already applied
	if ! patch -Np0 -R --dry-run --silent < static.patch; then
		patch -Np0 < static.patch
	fi
}

readonly ImageName=fluidsynth-builder
launch_container() {
	if ! docker image inspect "$ImageName" &> /dev/null; then
		docker build -t "$ImageName" . || return
	fi
	docker run --rm -it -v "$(pwd):/src" "$ImageName"
}

main() {
	declare Mode=$1
	shift

	if [[ $Mode == 'compile' ]]; then
		rm -rf "$ScriptDir/build" || return

		declare Arch
		for Arch in i686 x86_64; do
			export PKG_CONFIG_PATH
			PKG_CONFIG_PATH="$ScriptDir/build/$Arch/lib/pkgconfig"

			build_libogg "$Arch" &&
				build_flac "$Arch" &&
				build_opus "$Arch" &&
				build_vorbis "$Arch" || return

			build_libsndfile "$Arch" || return

			build_glib "$Arch" &&
				build_libinstpatch "$Arch" &&
				build_fluidsynth "$Arch" || return
		done
	elif [[ $Mode == 'clean' ]]; then
		rm -rf build flac fluidsynth glib libinstpatch libogg libsndfile opus vorbis "$ScriptDir/"*.tar* || return
	else
		fetch_sources &&
			patch_sources &&
			launch_container || return
	fi
}

main "$@"; exit
