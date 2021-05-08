/*******************************************************************************
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ******************************************************************************/

import Foundation

public class Machine: InfoValue
{
    public static var all: [ Config.Architecture : [ Machine ] ] =
    {
        () -> [ Config.Architecture : [ Machine ] ] in
        
        let archs: [ Config.Architecture ]               = [ .aarch64, .arm, .i386, .x86_64, .ppc, .ppc64, .riscv32, .riscv64, .m68k ]
        var all:   [ Config.Architecture : [ Machine ] ] = [:]
        
        archs.forEach
        {
            all[ $0 ] = QEMU.System.machines( for: $0 ).map
            {
                Machine( name: $0.0, title: $0.1, sorting: 0 )
            }
        }
        
        return all
    }()
}
