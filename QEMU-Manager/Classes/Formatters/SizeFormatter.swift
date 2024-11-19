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

@objc( SizeFormatter ) public class SizeFormatter: NumberFormatter, @unchecked Sendable
{
    public enum Style
    {
        case standard
        case qemu
    }
    
    private static let kiloByte: UInt64 = 1024
    private static let megaByte: UInt64 = 1024 * 1024
    private static let gigaByte: UInt64 = 1024 * 1024 * 1024
    private static let teraByte: UInt64 = 1024 * 1024 * 1024 * 1024
    
    @IBInspectable public dynamic var min: UInt64 = 0
    @IBInspectable public dynamic var max: UInt64 = 0
    
    private func clamp( value: Double ) -> NSNumber
    {
        if UInt64( value ) < self.min
        {
            return NSNumber( value: self.min )
        }
        else if self.max > 0 && UInt64( value ) > self.max
        {
            return NSNumber( value: self.max )
        }
        
        return NSNumber( value: value )
    }
    
    override public func getObjectValue( _ obj: AutoreleasingUnsafeMutablePointer< AnyObject? >?, for string: String, range: UnsafeMutablePointer< NSRange >? ) throws
    {
        if string.count == 0
        {
            obj?.pointee = NSNumber( integerLiteral: 0 )
            
            return
        }
        
        var skip: CharacterSet = .whitespacesAndNewlines
        
        skip.formUnion( .controlCharacters )
        skip.formUnion( .symbols )
        skip.formUnion( .illegalCharacters )
        
        let scanner                   = Scanner( string: string )
        scanner.charactersToBeSkipped = skip
        
        guard let bytes = scanner.scanDouble() else
        {
            obj?.pointee = nil
            
            return
        }
        
        guard let unit = scanner.scanUpToCharacters( from: .whitespaces )?.uppercased() else
        {
            obj?.pointee = self.clamp( value: bytes )
            
            return
        }
        
        switch unit
        {
            case "TB":  obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.teraByte ) )
            case "TIB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.teraByte ) )
            case "GB":  obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.gigaByte ) )
            case "GIB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.gigaByte ) )
            case "MB":  obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.megaByte ) )
            case "MIB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.megaByte ) )
            case "KB":  obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.kiloByte ) )
            case "KIB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.kiloByte ) )
            default:    obj?.pointee = self.clamp( value: bytes )
        }
    }
    
    override public func string( for obj: Any? ) -> String?
    {
        guard let n = obj as? NSNumber else
        {
            return nil
        }
        
        return self.string( from: n )
    }
    
    override public func string( from number: NSNumber ) -> String
    {
        return self.string( from: number, style: .standard )
    }
    
    public func string( from number: NSNumber, style: Style ) -> String
    {
        let bytes = number.uintValue
        let info: ( String, String ) =
        {
            if bytes < SizeFormatter.kiloByte
            {
                return ( "\( bytes )", style == .standard ? " bytes" : "" )
            }
            else if bytes < SizeFormatter.megaByte
            {
                return ( String( format: "%.2f", Double( bytes ) / Double( SizeFormatter.kiloByte ) ), style == .standard ? " KB" : "K" )
            }
            else if bytes < SizeFormatter.gigaByte
            {
                return ( String( format: "%.2f", Double( bytes ) / Double( SizeFormatter.megaByte ) ), style == .standard ? " MB" : "M" )
            }
            else if bytes < SizeFormatter.teraByte
            {
                return ( String( format: "%.2f", Double( bytes ) / Double( SizeFormatter.gigaByte ) ), style == .standard ? " GB" : "G" )
            }
            
            return ( String( format: "%.2f", Double( bytes ) / Double( SizeFormatter.teraByte ) ), style == .standard ? " TB" : "T" )
        }()
        
        return "\( info.0 )\( info.1 )"
    }

    override public func number( from string: String ) -> NSNumber?
    {
        var n: AnyObject?
        
        try? self.getObjectValue( &n, for: string, range: nil )
        
        return n as? NSNumber
    }
}
