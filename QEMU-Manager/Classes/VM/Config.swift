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

public class Config: NSObject, Codable
{
    @objc public enum Architecture: Int
    {
        case aarch64
        case arm
        case x86_64
        case i386
        case ppc64
        case ppc
        case riscv64
        case riscv32
        case m68k
    }
    
    @objc public private( set ) dynamic var version:       UInt64           = 0
    @objc public private( set ) dynamic var uuid:          UUID             = UUID()
    @objc public                dynamic var architecture:  Architecture     = .aarch64
    @objc public                dynamic var machine:       String?          = nil
    @objc public                dynamic var cpu:           String?          = nil
    @objc public                dynamic var vga:           String?          = nil
    @objc public                dynamic var cores:         UInt64           = 1
    @objc public                dynamic var memory:        UInt64           = 2147483648
    @objc public                dynamic var title:         String           = "Untitled"
    @objc public                dynamic var icon:          String?          = nil
    @objc public private( set ) dynamic var disks:         [ Disk ]         = []
    @objc public                dynamic var cdImage:       URL?             = nil
    @objc public                dynamic var boot:          String           = "d"
    @objc public private( set ) dynamic var sharedFolders: [ SharedFolder ] = []
    @objc public                dynamic var arguments:     [ String ]       = []
    
    public override init()
    {}
    
    public enum CodingKeys: String, CodingKey
    {
        case version
        case uuid
        case architecture
        case machine
        case cpu
        case vga
        case cores
        case memory
        case title
        case icon
        case disks
        case cdImage
        case boot
        case sharedFolders
        case arguments
    }
    
    public enum Error: Swift.Error
    {
        case invalidArchitecture
    }
    
    public required init( from decoder: Decoder ) throws
    {
        let values = try decoder.container( keyedBy: CodingKeys.self )
        
        self.version       = try values.decode( UInt64.self,           forKey: .version )
        self.uuid          = try values.decode( UUID.self,             forKey: .uuid )
        self.icon          = try values.decode( String?.self,          forKey: .icon )
        self.machine       = try values.decode( String?.self,          forKey: .machine )
        self.cpu           = try values.decode( String?.self,          forKey: .cpu )
        self.vga           = try values.decode( String?.self,          forKey: .vga )
        self.cores         = try values.decode( UInt64.self,           forKey: .cores )
        self.memory        = try values.decode( UInt64.self,           forKey: .memory )
        self.title         = try values.decode( String.self,           forKey: .title )
        self.disks         = try values.decode( [ Disk ].self,         forKey: .disks )
        self.cdImage       = try values.decode( URL?.self,             forKey: .cdImage )
        self.boot          = try values.decode( String.self,           forKey: .boot )
        self.sharedFolders = try values.decode( [ SharedFolder ].self, forKey: .sharedFolders )
        self.arguments     = try values.decode( [ String ].self,       forKey: .arguments )
        
        guard let arch = Architecture( string: ( try? values.decode( String.self, forKey: .architecture ) ) ?? "" ) else
        {
            throw Error.invalidArchitecture
        }
        
        self.architecture = arch
    }
    
    public func encode( to encoder: Encoder ) throws
    {
        var container = encoder.container( keyedBy: CodingKeys.self )
        
        try container.encode( self.version,                  forKey: .version )
        try container.encode( self.uuid,                     forKey: .uuid )
        try container.encode( self.architecture.description, forKey: .architecture )
        try container.encode( self.machine,                  forKey: .machine )
        try container.encode( self.cpu,                      forKey: .cpu )
        try container.encode( self.vga,                      forKey: .vga )
        try container.encode( self.cores,                    forKey: .cores )
        try container.encode( self.memory,                   forKey: .memory )
        try container.encode( self.title,                    forKey: .title )
        try container.encode( self.icon,                     forKey: .icon )
        try container.encode( self.disks,                    forKey: .disks )
        try container.encode( self.cdImage,                  forKey: .cdImage )
        try container.encode( self.boot,                     forKey: .boot )
        try container.encode( self.sharedFolders,            forKey: .sharedFolders )
        try container.encode( self.arguments,                forKey: .arguments )
    }
    
    public func addDisk( _ disk: Disk )
    {
        self.disks.append( disk )
    }
    
    public func removeDisk( _ disk: Disk )
    {
        self.disks.removeAll { $0.uuid == disk.uuid }
    }
    
    public func addSharedFolder( _ folder: SharedFolder )
    {
        self.sharedFolders.append( folder )
    }
    
    public func removeSharedFolder( _ folder: SharedFolder )
    {
        self.sharedFolders.removeAll { $0.uuid == folder.uuid }
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
