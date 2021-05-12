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

public class SharedFolder: NSObject, Codable
{
    @objc public enum Kind: Int
    {
        case fat
        case floppy
        case smb
    }
    
    public enum CodingKeys: String, CodingKey
    {
        case uuid
        case url
        case kind
    }
    
    public enum Error: Swift.Error
    {
        case invalidKind
    }
    
    @objc public dynamic var uuid: UUID
    @objc public dynamic var url:  URL
    @objc public dynamic var kind: Kind
    
    public init( url: URL, kind: Kind )
    {
        self.uuid = UUID()
        self.url  = url
        self.kind = kind
    }
    
    public required init( from decoder: Decoder ) throws
    {
        let values = try decoder.container( keyedBy: CodingKeys.self )
        
        self.uuid = try values.decode( UUID.self, forKey: .uuid )
        self.url  = try values.decode( URL.self, forKey: .url )
        
        guard let kind = Kind( string: ( try? values.decode( String.self, forKey: .kind ) ) ?? "" ) else
        {
            throw Error.invalidKind
        }
        
        self.kind = kind
    }
    
    public func encode( to encoder: Encoder ) throws
    {
        var container = encoder.container( keyedBy: CodingKeys.self )
        
        try container.encode( self.uuid,             forKey: .uuid )
        try container.encode( self.url,              forKey: .url )
        try container.encode( self.kind.description, forKey: .kind )
    }
}

extension SharedFolder.Kind: CustomStringConvertible
{
    public init?( string: String )
    {
        switch string
        {
            case "fat":    self.init( rawValue: SharedFolder.Kind.fat.rawValue )
            case "floppy": self.init( rawValue: SharedFolder.Kind.floppy.rawValue )
            case "smb":    self.init( rawValue: SharedFolder.Kind.smb.rawValue )
            default:       return nil
        }
    }
    
    public var description: String
    {
        switch self
        {
            case .fat:    return "fat"
            case .floppy: return "floppy"
            case .smb:    return "smb"
        }
    }
}
