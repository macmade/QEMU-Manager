################################################################################
# Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
################################################################################

_DIR_BUILD       := $(realpath .)/build
_DIR_BUILD_INTEL := $(_DIR_BUILD)/x86-64
_DIR_BUILD_ARM   := $(_DIR_BUILD)/aarch64
_DIR_DIST        := $(realpath .)/dist
_DIR_TMP         := $(realpath .)/temp
_DIR_SRC         := $(realpath .)/source

_SPACE := $() $()
_COMMA := ,

_LIBUSB_VERSION := 1.0.24
_LIBUSB_ARCHIVE := v$(_LIBUSB_VERSION).zip
_LIBUSB_URL     := https://github.com/libusb/libusb/archive/refs/tags/$(_LIBUSB_ARCHIVE)
_LIBUSB_CONFIG  := --enable-shared=no

_FLAGS_INTEL := "-target x86_64-apple-macos11"
_FLAGS_ARM   := "-target arm64-apple-macos11"

.PHONY: clean download unpack build build_intel build_arm dist

all: download unpack build dist
	
	@:
	
clean:
	
	@rm -rf $(_DIR_BUILD_INTEL)/*
	@rm -rf $(_DIR_BUILD_ARM)/*
	@rm -rf $(_DIR_TMP)/*
	@rm -rf $(_DIR_SRC)/*
	
download:
	
	@if [ ! -f "$(_DIR_TMP)/$(_LIBUSB_ARCHIVE)" ]; then cd "$(_DIR_TMP)" && wget "$(_LIBUSB_URL)"; fi

unpack:
	
	@if [ ! -d "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)" ]; then unzip "$(_DIR_TMP)/$(_LIBUSB_ARCHIVE)" -d "$(_DIR_SRC)" && mv "$(_DIR_SRC)/libusb-$(_LIBUSB_VERSION)" "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)"; fi
	@if [ ! -d "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)" ]; then unzip "$(_DIR_TMP)/$(_LIBUSB_ARCHIVE)" -d "$(_DIR_SRC)" && mv "$(_DIR_SRC)/libusb-$(_LIBUSB_VERSION)" "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)"; fi

build: build_intel build_arm
	
	@:
	
build_intel:
	
	@cd "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)" && ./autogen.sh
	@cd "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)" && ./configure --prefix="$(_DIR_BUILD_INTEL)" $(_LIBUSB_CONFIG) CFLAGS=$(_FLAGS_INTEL) CPPFLAGS=$(_FLAGS_INTEL) LDFLAGS=$(_FLAGS_INTEL)
	@cd "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)" && make CFLAGS=$(_FLAGS_INTEL) CPPFLAGS=$(_FLAGS_INTEL) LDFLAGS=$(_FLAGS_INTEL)
	@cd "$(_DIR_SRC)/libusb-intel-$(_LIBUSB_VERSION)" && make install

build_arm:
	
	@cd "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)" && ./autogen.sh
	@cd "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)" && ./configure --prefix="$(_DIR_BUILD_ARM)" $(_LIBUSB_CONFIG) CFLAGS=$(_FLAGS_ARM) CPPFLAGS=$(_FLAGS_ARM) LDFLAGS=$(_FLAGS_ARM)
	@cd "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)" && make CFLAGS=$(_FLAGS_ARM) CPPFLAGS=$(_FLAGS_ARM) LDFLAGS=$(_FLAGS_ARM)
	@cd "$(_DIR_SRC)/libusb-arm-$(_LIBUSB_VERSION)" && make install

dist:
	
	@lipo -create -output $(_DIR_DIST)/lib/libusb-1.0.a $(_DIR_BUILD_INTEL)/lib/libusb-1.0.a $(_DIR_BUILD_ARM)/lib/libusb-1.0.a
	@rsync -a $(_DIR_BUILD_INTEL)/include/ $(_DIR_DIST)/include/
