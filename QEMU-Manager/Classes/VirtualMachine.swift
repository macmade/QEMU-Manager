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

public class VirtualMachine: NSObject
{
    @objc public private( set ) dynamic var config: Config
    @objc public private( set ) dynamic var url:    URL
    
    public init?( url: URL )
    {
        self.url  = url
        var isDir = ObjCBool( false )
        
        if FileManager.default.fileExists( atPath: url.path, isDirectory: &isDir ) == false
        {
            self.config = Config()
            
            super.init()
            
            do
            {
                try FileManager.default.createDirectory( at: url, withIntermediateDirectories: true, attributes: nil )
                try self.save()
            }
            catch
            {
                return nil
            }
        }
        else
        {
            if isDir.boolValue == false
            {
                return nil
            }
            
            do
            {
                let data    = try Data( contentsOf: url.appendingPathComponent( "Config.json" ) )
                self.config = try JSONDecoder().decode( Config.self, from: data )
                
                super.init()
            }
            catch
            {
                return nil
            }
        }
    }
    
    public func save() throws
    {
        let encoder              = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data                 = try encoder.encode( self.config )
        
        try data.write( to: url.appendingPathComponent( "Config.json" ) )
    }
}
