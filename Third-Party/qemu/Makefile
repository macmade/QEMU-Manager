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
