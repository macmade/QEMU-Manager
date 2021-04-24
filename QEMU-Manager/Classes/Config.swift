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

@objc public class Config: NSObject, Codable
{
    @objc public enum Architecture: Int
    {
        case aarch64
        case arm
        case i386
        case m68k
        case ppc
        case ppc64
        case riscv32
        case riscv64
        case x86_64
    }
    
    @objc public private( set ) dynamic var uuid:         UUID         = UUID()
    @objc public                dynamic var architecture: Architecture = .aarch64
    @objc public                dynamic var memory:       UInt64       = 2147483648
    @objc public                dynamic var title:        String       = "Untitled"
    
    public override init()
    {}
    
    public enum CodingKeys: String, CodingKey
    {
        case uuid
        case architecture
        case memory
        case title
    }
    
    public enum Error: Swift.Error
    {
        case invalidArchitecture
    }
    
    public required init( from decoder: Decoder ) throws
    {
        let values = try decoder.container( keyedBy: CodingKeys.self )
        
        self.uuid   = try values.decode( UUID.self,   forKey: .uuid )
        self.memory = try values.decode( UInt64.self, forKey: .memory )
        self.title  = try values.decode( String.self, forKey: .title )
        
        guard let arch = Architecture( string: ( try? values.decode( String.self, forKey: .architecture ) ) ?? "" ) else
        {
            throw Error.invalidArchitecture
        }
        
        self.architecture = arch
    }
    
    public func encode( to encoder: Encoder ) throws
    {
        var container = encoder.container( keyedBy: CodingKeys.self )
        
        try container.encode( self.uuid,                     forKey: .uuid )
        try container.encode( self.architecture.description, forKey: .architecture )
        try container.encode( self.memory,                   forKey: .memory )
        try container.encode( self.title,                    forKey: .title )
    }
}

extension Config.Architecture: CustomStringConvertible
{
    public init?( string: String )
    {
        switch string
        {
            case "aarch64": self.init( rawValue: Config.Architecture.aarch64.rawValue )
            case "arm":     self.init( rawValue: Config.Architecture.arm.rawValue )
            case "i386":    self.init( rawValue: Config.Architecture.i386.rawValue )
            case "m68k":    self.init( rawValue: Config.Architecture.m68k.rawValue )
            case "ppc":     self.init( rawValue: Config.Architecture.ppc.rawValue )
            case "ppc64":   self.init( rawValue: Config.Architecture.ppc64.rawValue )
            case "riscv32": self.init( rawValue: Config.Architecture.riscv32.rawValue )
            case "riscv64": self.init( rawValue: Config.Architecture.riscv64.rawValue )
            case "x86_64":  self.init( rawValue: Config.Architecture.x86_64.rawValue )
            default:        return nil
        }
    }
    
    public var description: String
    {
        switch self
        {
            case .aarch64: return "aarch64"
            case .arm:     return "arm"
            case .i386:    return "i386"
            case .m68k:    return "m68k"
            case .ppc:     return "ppc"
            case .ppc64:   return "ppc64"
            case .riscv32: return "riscv32"
            case .riscv64: return "riscv64"
            case .x86_64:  return "x86_64"
        }
    }
}
