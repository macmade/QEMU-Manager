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

@objc( SizeFormatter ) public class SizeFormatter: NumberFormatter
{
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
        else if UInt64( value ) > self.max
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
            case "TB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.teraByte ) )
            case "GB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.gigaByte ) )
            case "MB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.megaByte ) )
            case "KB": obj?.pointee = self.clamp( value: bytes * Double( SizeFormatter.kiloByte ) )
            default:   obj?.pointee = self.clamp( value: bytes )
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
        let bytes = number.uintValue
        
        if bytes < SizeFormatter.kiloByte
        {
            return "\( bytes ) bytes"
        }
        else if bytes < SizeFormatter.megaByte
        {
            return "\( String( format: "%.2f KB", Double( bytes ) / Double( SizeFormatter.kiloByte ) ) )"
        }
        else if bytes < SizeFormatter.gigaByte
        {
            return "\( String( format: "%.2f MB", Double( bytes ) / Double( SizeFormatter.megaByte ) ) )"
        }
        else if bytes < SizeFormatter.teraByte
        {
            return "\( String( format: "%.2f GB", Double( bytes ) / Double( SizeFormatter.gigaByte ) ) )"
        }
        
        return "\( String( format: "%.2f TB", Double( bytes ) / Double( SizeFormatter.teraByte ) ) )"
    }

    override public func number( from string: String ) -> NSNumber?
    {
        var n: AnyObject?
        
        try? self.getObjectValue( &n, for: string, range: nil )
        
        return n as? NSNumber
    }
}
