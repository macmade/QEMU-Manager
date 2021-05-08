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

@objc public class ConfigDisksViewController: ConfigViewController, NSTableViewDataSource, NSTableViewDelegate
{
    @objc private dynamic var vm: VirtualMachine
    
    @IBOutlet private var disks: NSArrayController!
    
    private var newDiskWindowController: NewDiskWindowController?
    
    public init( vm: VirtualMachine )
    {
        self.vm = vm
        
        super.init( title: "Disks", icon: nil, sorting: 2 )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigDisksViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.reloadDisks()
    }
    
    @IBAction private func addRemoveDisk( _ sender: Any? )
    {
        guard let button = sender as? NSSegmentedControl else
        {
            NSSound.beep()
            
            return
        }
        
        switch button.selectedSegment
        {
            case 0:  self.addDisk( sender )
            case 1:  self.removeDisk( sender )
            default: NSSound.beep()
        }
    }
    
    @IBAction private func addDisk( _ sender: Any? )
    {
        if self.newDiskWindowController != nil
        {
            NSSound.beep()
            
            return
        }
        
        let controller = NewDiskWindowController( vm: self.vm )
        
        guard let window = self.view.window,
              let sheet  = controller.window
        else
        {
            NSSound.beep()
            
            return
        }
        
        self.newDiskWindowController = controller
        
        window.beginSheet( sheet )
        {
            r in
            
            self.newDiskWindowController = nil
            
            if r == .OK
            {
                self.reloadDisks()
            }
        }
    }
    
    @IBAction private func removeDisk( _ sender: Any? )
    {
        guard let disk   = self.disks.selectedObjects.first as? DiskInfo,
              let window = self.view.window
        else
        {
            NSSound.beep()
            
            return
        }
        
        let alert             = NSAlert()
        alert.messageText     = "Delete Disk"
        alert.informativeText = "Are you sure you want to delete the selected disk? All data will be permanently lost."
        
        alert.addButton( withTitle: "Delete" )
        alert.addButton( withTitle: "Cancel" )
        
        alert.beginSheetModal( for: window )
        {
            r in if r != .alertFirstButtonReturn
            {
                return
            }
            
            do
            {
                try FileManager.default.removeItem( at: disk.url )
                self.vm.config.removeDisk( disk.disk )
                try self.vm.save()
                self.reloadDisks()
            }
            catch let error
            {
                NSAlert( error: error ).beginSheetModal( for: window, completionHandler: nil )
            }
        }
    }
    
    private func reloadDisks()
    {
        if let existing = self.disks.content as? [ DiskInfo ]
        {
            existing.forEach { self.disks.removeObject( $0 ) }
        }
        
        self.vm.disks.forEach { self.disks.addObject( $0 ) }
    }
    
    @IBAction private func chooseImage( _ sender: Any? )
    {
        guard let window = self.view.window else
        {
            NSSound.beep()
            
            return
        }
        
        let panel                     = NSOpenPanel()
        panel.canChooseFiles          = true
        panel.canChooseDirectories    = false
        panel.allowsMultipleSelection = false
        
        panel.beginSheetModal( for: window )
        {
            r in if r != .OK
            {
                return
            }
            
            self.vm.config.cdImage = panel.url
        }
    }
    
    @objc @IBAction public func revealDisk( _ sender: Any? )
    {
        guard let disk = sender as? DiskInfo else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( disk.url.path, inFileViewerRootedAtPath: "" )
    }
    
    @IBAction private func removeCDImage( _ sender: Any? )
    {
        self.vm.config.cdImage = nil
    }
}
