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

@objc public class LibraryWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate
{
    @IBOutlet private var machines:  NSArrayController!
    @IBOutlet private var tableView: NSTableView!
    
    private var configWindowControllers = [ UUID : ConfigWindowController ]()
    
    public override var windowNibName: NSNib.Name?
    {
        return "LibraryWindowController"
    }
    
    override public func windowDidLoad()
    {
        super.windowDidLoad()
        
        Preferences.shared.virtualMachines().forEach { self.machines.addObject( $0 ) }
    }
    
    public func configWindowController( for machine: VirtualMachine ) -> ConfigWindowController?
    {
        return self.configWindowControllers[ machine.config.uuid ]
    }
    
    @IBAction public func showConfigWindow( _ sender: Any? )
    {
        guard let machine = sender as? VirtualMachine else
        {
            NSSound.beep()
            
            return
        }
        
        self.showConfigWindow( for: machine )
    }
    
    public func showConfigWindow( for machine: VirtualMachine )
    {
        if self.configWindowControllers.contains( where: { $0.key == machine.config.uuid } ) == false
        {
            self.configWindowControllers[ machine.config.uuid ] = ConfigWindowController( machine: machine )
        }
        
        guard let window = self.configWindowControllers[ machine.config.uuid ]?.window else
        {
            NSSound.beep()
            
            return
        }
        
        if window.isVisible == false
        {
            window.center()
        }
        
        window.makeKeyAndOrderFront( nil )
    }
    
    @IBAction private func newVirtualMachine( _ sender: Any?  )
    {
        guard let window = self.window else
        {
            NSSound.beep()
            
            return
        }
        
        let panel                  = NSSavePanel()
        panel.allowedFileTypes     = [ "qvm" ]
        panel.canCreateDirectories = true
        
        panel.beginSheetModal( for: window )
        {
            r in if r != .OK
            {
                return
            }
            
            guard let url = panel.url else
            {
                NSSound.beep()
                
                return
            }
            
            do
            {
                let machine          = VirtualMachine()
                machine.config.title = ( url.lastPathComponent as NSString ).deletingPathExtension
                
                try machine.save( to: url )
                
                Preferences.shared.addVirtualMachines( machine )
                self.machines.addObject( machine )
                self.showConfigWindow( for: machine )
            }
            catch let error
            {
                let alert = NSAlert( error: error )
                
                alert.beginSheetModal( for: window, completionHandler: nil )
            }
        }
    }
    
    @IBAction private func newDocument( _ sender: Any?  )
    {
        self.newVirtualMachine( sender )
    }
    
    @IBAction private func configure( _ sender: Any?  )
    {
        guard let item    = sender                 as? NSMenuItem,
              let machine = item.representedObject as? VirtualMachine
        else
        {
            NSSound.beep()
            
            return
        }
        
        self.showConfigWindow( for: machine )
    }
    
    @IBAction private func delete( _ sender: Any?  )
    {
        guard let item    = sender                 as? NSMenuItem,
              let machine = item.representedObject as? VirtualMachine,
              let window  = self.window,
              let url     = machine.url
        else
        {
            NSSound.beep()
            
            return
        }
        
        let alert = NSAlert()
        
        alert.messageText     = "Delete \( machine.config.title )?"
        alert.informativeText = "Are you sure you want to delete this virtual machine?"
        
        alert.addButton( withTitle: "Remove and Keep Files" )
        alert.addButton( withTitle: "Cancel" )
        alert.addButton( withTitle: "Remove and Move to Trash" )
        
        alert.beginSheetModal( for: window )
        {
            r in
            
            if r == .alertSecondButtonReturn
            {
                return
            }
            
            self.configWindowController( for: machine )?.close()
            self.machines.removeObject( machine )
            Preferences.shared.removeVirtualMachines( machine )
            
            if r == .alertThirdButtonReturn
            {
                try? FileManager.default.trashItem( at: url, resultingItemURL: nil )
            }
        }
    }
    
    public func menuWillOpen( _ menu: NSMenu )
    {
        let setEnabled: ( NSMenu, Bool ) -> Void =
        {
            menu, enabled in
            
            menu.items.forEach { $0.isEnabled = enabled }
        }
        
        guard let arranged = self.machines.arrangedObjects as? [ VirtualMachine ] else
        {
            setEnabled( menu, false )
            
            return
        }
        
        if self.tableView.clickedRow < 0 || self.tableView.clickedRow >= arranged.count
        {
            setEnabled( menu, false )
            
            return
        }
        
        setEnabled( menu, true )
        
        let machine = arranged[ self.tableView.clickedRow ]
        
        menu.items.forEach { $0.representedObject = machine }
    }
}
