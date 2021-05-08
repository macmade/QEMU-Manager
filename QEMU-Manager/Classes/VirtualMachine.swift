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

import Cocoa

@objc public class VirtualMachine: NSObject
{
    public enum Error: Swift.Error
    {
        case invalidURL
    }
    
    @objc public private( set ) dynamic var config: Config
    @objc public private( set ) dynamic var url:    URL?
    @objc public private( set ) dynamic var icon:   NSImage?
    
    private var iconObserver: NSKeyValueObservation?
    
    public override init()
    {
        self.config = Config()
        
        super.init()
        self.updateIcon()
        
        self.iconObserver = self.observe( \.config.icon )
        {
            o, c in self.updateIcon()
        }
    }
    
    public init?( url: URL )
    {
        var isDir = ObjCBool( false )
        
        if FileManager.default.fileExists( atPath: url.path, isDirectory: &isDir ) == false || isDir.boolValue == false
        {
            return nil
        }
        
        do
        {
            let data    = try Data( contentsOf: url.appendingPathComponent( "Config.json" ) )
            self.config = try JSONDecoder().decode( Config.self, from: data )
            self.url    = url
            
            super.init()
            self.updateIcon()
            
            self.iconObserver = self.observe( \.config.icon )
            {
                o, c in self.updateIcon()
            }
        }
        catch
        {
            return nil
        }
    }
    
    private func updateIcon()
    {
        switch self.config.icon
        {
            case .generic:       self.icon = NSImage( named: "Generic" )
            case .apple:         self.icon = NSImage( named: "AppleTemplate" )
            case .macOS:         self.icon = NSImage( named: "macOS" )
            case .windows:       self.icon = NSImage( named: "WindowsTemplate" )
            case .windowsLegacy: self.icon = NSImage( named: "WindowsLegacy" )
        }
        
        if self.icon == nil
        {
            self.icon = NSImage( named: "Generic" )
        }
    }
    
    public func save( to url: URL ) throws
    {
        self.url = url
        
        try self.save()
    }
    
    public func save() throws
    {
        guard let url = self.url else
        {
            throw Error.invalidURL
        }
        
        var isDir = ObjCBool( booleanLiteral: false )
        
        if FileManager.default.fileExists( atPath: url.path, isDirectory: &isDir ) == false
        {
            try FileManager.default.createDirectory( at: url, withIntermediateDirectories: true, attributes: nil )
        }
        else if isDir.boolValue == false
        {
            throw Error.invalidURL
        }
        
        let encoder              = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data                 = try encoder.encode( self.config )
        
        try data.write( to: url.appendingPathComponent( "Config.json" ) )
    }
    
    public var disks: [ DiskInfo ]
    {
        return self.config.disks.compactMap { DiskInfo( vm: self, disk: $0 ) }
    }
}
