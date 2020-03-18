#!/bin/bash

readonly FluidSynthVersion=2.1.1
readonly GlibVersion=2.64.1
readonly ProxyLibintlVersion=0.1
readonly LibffiVersion=meson
readonly ZlibVersion=1.2.11
readonly ZlibPatchVersion=1.2.11-3

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
		-DCMAKE_FIND_ROOT_PATH="/usr/$Arch-w64-mingw32" \
		-DCMAKE_RC_COMPILER="$Arch-w64-mingw32-windres" \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -lintl -Wl,-Bdynamic,--no-whole-archive" \
		-DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -lintl -Wl,-Bdynamic,--no-whole-archive" &&

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

			build_glib "$Arch" &&
				build_fluidsynth "$Arch" || return
		done
	elif [[ $Mode == 'clean' ]]; then
		rm -rf build fluidsynth glib "$ScriptDir/"*.tar* || return
	else
		fetch_sources &&
			patch_sources &&
			launch_container || return
	fi
}

main "$@"; exit
