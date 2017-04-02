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

brew update
brew install lua
brew install ragel
brew install lcov

echo "axl_override_setting (GCC_FLAG_COVERAGE -coverage)" >> settings.cmake
