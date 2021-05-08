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

@objc( ArchitectureToString ) public class ArchitectureToString: ValueTransformer
{
    public override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }
    
    public override class func allowsReverseTransformation() -> Bool
    {
        false
    }
    
    public override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let n    = ( value as? NSNumber )?.intValue,
              let arch = Config.Architecture( rawValue: n )
        else
        {
            return "--"
        }
        
        switch arch
        {
            case .aarch64: return "ARM 64-bits - aarch64"
            case .arm:     return "ARM 32-bits - arm"
            case .x86_64:  return "Intel 64-bits - x86-64"
            case .i386:    return "Intel 32-bits - i386"
            case .ppc64:   return "PowerPC 64-bits - ppc64"
            case .ppc:     return "PowerPC 32-bits - ppc"
            case .riscv64: return "RISC-V 64-bits - riscv64"
            case .riscv32: return "RISC-V 32-bits - riscv32"
            case .m68k:    return "Motorola 68k - m68k"
        }
    }
}
