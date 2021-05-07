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

@objc public class NewDiskWindowController: NSWindowController
{
    @objc public private( set ) dynamic var machine: VirtualMachine
    @objc public private( set ) dynamic var label:   String
    @objc public private( set ) dynamic var size:    UInt64
    @objc public private( set ) dynamic var min:     UInt64
    @objc public private( set ) dynamic var max:     UInt64
    @objc public private( set ) dynamic var loading: Bool
    
    @IBOutlet private var formatter: SizeFormatter!
    
    public init( machine: VirtualMachine )
    {
        self.machine = machine
        self.label   = "Untitled"
        self.size    = 1024 * 1024 * 1024 * 20
        self.min     = 1024 * 1024
        self.max     = 1024 * 1024 * 1024 * 500
        self.loading = false
        
        super.init( window: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "NewDiskWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.formatter.min = self.min
        self.formatter.max = self.max
    }
    
    @IBAction private func cancel( _ sender: Any? )
    {
        guard let window = self.window,
              let parent = self.window?.sheetParent
        else
        {
            NSSound.beep()
            
            return
        }
        
        parent.endSheet( window, returnCode: .cancel )
    }
    
    @IBAction private func createDisk( _ sender: Any? )
    {
        guard let window = self.window,
              let parent = self.window?.sheetParent,
              let url    = self.machine.url
        else
        {
            NSSound.beep()
            
            return
        }
        
        if self.loading
        {
            return
        }
        
        self.loading = true
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let disk   = Disk()
            disk.label = self.label
            let path   = url.appendingPathComponent( disk.uuid.uuidString ).appendingPathExtension( "qcow2" ).path
            
            do
            {
                try QEMU.Img.create( url: URL( fileURLWithPath: path ), size: self.size, format: "qcow2" )
                self.machine.config.addDisk( disk )
                try self.machine.save()
                
                DispatchQueue.main.asyncAfter( deadline: .now() + .milliseconds( 500 ) )
                {
                    parent.endSheet( window, returnCode: .OK )
                }
            }
            catch let error
            {
                try? FileManager.default.removeItem( atPath: path )
                
                DispatchQueue.main.async
                {
                    self.loading = false
                    
                    NSAlert( error: error ).beginSheetModal( for: window, completionHandler: nil )
                }
            }
        }
    }
}
