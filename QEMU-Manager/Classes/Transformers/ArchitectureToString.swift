/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
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
