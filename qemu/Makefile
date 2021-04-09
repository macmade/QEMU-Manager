################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################################################

QEMU_ENABLE  := capstone parallels dmg cocoa
QEMU_TARGETS := aarch64-softmmu \
			    arm-softmmu     \
			    i386-softmmu    \
			    m68k-softmmu    \
			    ppc-softmmu     \
			    ppc64-softmmu   \
			    riscv32-softmmu \
			    riscv64-softmmu \
			    x86_64-softmmu

_DIR_DIST := $(realpath .)/dist
_DIR_SRC  := $(realpath .)/source

_SPACE := $() $()
_COMMA := ,

_QEMU_TARGETS := $(subst $(_SPACE),$(_COMMA),$(QEMU_TARGETS))
_QEMU_ENABLE  := $(addprefix --enable-,$(QEMU_ENABLE))
_QEMU_CONFIG  := --prefix="$(_DIR_DIST)/qemu" --target-list=$(_QEMU_TARGETS) $(_QEMU_ENABLE) --extra-cflags="-I/opt/homebrew/include" --extra-cxxflags="-I/opt/homebrew/include" --extra-ldflags="-L/opt/homebrew/lib"

all: clone update configure build install
	
	@:
	
clean:
	
	@rm -rf $(_DIR_SRC)/qemu
	
clone:
	
	@if [ ! -d "$(_DIR_SRC)/qemu" ]; then git clone https://gitlab.com/qemu-project/qemu.git "$(_DIR_SRC)/qemu"; fi

update:
	
	@cd "$(_DIR_SRC)/qemu" && git pull

configure:
	
	@cd "$(_DIR_SRC)/qemu" && ./configure $(_QEMU_CONFIG)

build:
	
	@cd "$(_DIR_SRC)/qemu" && make

install:
	
	@cd "$(_DIR_SRC)/qemu" && make install
