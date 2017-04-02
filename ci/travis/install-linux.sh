#...............................................................................
#
#  This file is part of the Graco toolkit.
#
#  Graco is distributed under the MIT license.
#  For details see accompanying license.txt file,
#  the public copy of which is also available at:
#  http://tibbo.com/downloads/archive/graco/license.txt
#
#...............................................................................

# manually install CMake -- we need at least CMake 3.3

CMAKE_VERSION=3.3.2
CMAKE_VERSION_DIR=v3.3
CMAKE_OS=Linux-x86_64
CMAKE_TAR=cmake-$CMAKE_VERSION-$CMAKE_OS.tar.gz
CMAKE_URL=http://www.cmake.org/files/$CMAKE_VERSION_DIR/$CMAKE_TAR
CMAKE_DIR=$(pwd)/cmake-$CMAKE_VERSION

wget --quiet $CMAKE_URL
mkdir -p $CMAKE_DIR
tar --strip-components=1 -xzf $CMAKE_TAR -C $CMAKE_DIR
export PATH=$CMAKE_DIR/bin:$PATH

# now to official APT packages

if [ "$TARGET_CPU" != "x86" ]; then
	sudo apt-get -qq update
	sudo apt-get install -y liblua5.2-dev
else
	sudo dpkg --add-architecture i386
	sudo apt-get -qq update
	sudo apt-get install -y liblua5.2-dev:i386

	# install g++-multilib -- in the end, after i386 packages!

	sudo apt-get install -y g++-multilib

	# CMake fails to properly switch between 32-bit and 64-bit libraries on Ubuntu

	echo "set (LUA_LIB_DIR /usr/lib/i386-linux-gnu)" >> paths.cmake
	echo "set (OPENSSL_INC_DIR DISABLED)" >> paths.cmake
	echo "set (EXPAT_INC_DIR DISABLED)" >> paths.cmake
fi

# lcov doesn't work with clang on ubuntu out-of-the-box
# also, coverage should be collected without optimizations

if [ "$CC" != "clang" ] && [ "$BUILD_CONFIGURATION" == "Debug" ]; then
	sudo apt-get install -y lcov
	echo "axl_override_setting (GCC_FLAG_COVERAGE -coverage)" >> settings.cmake
fi
