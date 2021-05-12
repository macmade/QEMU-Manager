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

import Cocoa

public class VirtualMachine: NSObject
{
    public enum Error: Swift.Error
    {
        case invalidURL
    }
    
    @objc public private( set ) dynamic var config:   Config
    @objc public private( set ) dynamic var url:      URL?
    @objc public private( set ) dynamic var icon:     NSImage?
    @objc public private( set ) dynamic var running = false
    
    private var process:               Process?
    private var iconObserver:          NSKeyValueObservation?
    private var errorWindowController: QEMUErrorWindowController?
    
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
        self.icon = NSImage( named: self.config.icon ?? "Generic" )
        
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
    
    public func start()
    {
        let delegate = NSApp.delegate as? ApplicationDelegate
        
        DispatchQueue.main.async
        {
            self.errorWindowController?.window?.close()
            
            self.errorWindowController = nil
            
            if self.running
            {
                let alert             = NSAlert()
                alert.messageText     = "Already Running"
                alert.informativeText = "The virtual machine \( self.config.title ) is already running."
                
                alert.tryBeginSheetModal( for: delegate?.libraryWindowController.window, completionHandler: nil )
                
                return
            }
            
            self.running = true
            
            DispatchQueue.global( qos: .userInitiated ).async
            {
                do
                {
                    try QEMU.System.start( vm: self )
                    
                    DispatchQueue.main.async
                    {
                        self.running = false
                    }
                }
                catch let error as QEMU.Executable.LaunchFailure
                {
                    DispatchQueue.main.async
                    {
                        self.errorWindowController?.window?.close()
                        
                        self.errorWindowController = QEMUErrorWindowController( error: error )
                        self.running               = false
                        
                        self.errorWindowController?.window?.center()
                        self.errorWindowController?.window?.makeKeyAndOrderFront( nil )
                    }
                }
                catch let error
                {
                    DispatchQueue.main.async
                    {
                        self.running = false
                        
                        NSAlert( error: error ).tryBeginSheetModal( for: delegate?.libraryWindowController.window, completionHandler: nil )
                    }
                }
            }
        }
    }
}
