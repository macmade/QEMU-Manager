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

public class LibraryWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate
{
    @IBOutlet private var machines:  NSArrayController!
    @IBOutlet private var tableView: NSTableView!
    
    private var configWindowControllers = [ UUID : ConfigWindowController ]()
    
    @objc private dynamic var loading = true
    
    public override var windowNibName: NSNib.Name?
    {
        return "LibraryWindowController"
    }
    
    override public func windowDidLoad()
    {
        super.windowDidLoad()
        
        Preferences.shared.virtualMachines().forEach { self.machines.addObject( $0 ) }
        
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let _ = Machine.all
            let _ = CPU.all
            
            DispatchQueue.main.async
            {
                self.loading = false
            }
        }
    }
    
    public func configWindowController( for vm: VirtualMachine ) -> ConfigWindowController?
    {
        return self.configWindowControllers[ vm.config.uuid ]
    }
    
    @IBAction public func showConfigWindow( _ sender: Any? )
    {
        guard let vm = self.getVM( for: sender ) else
        {
            NSSound.beep()
            
            return
        }
        
        self.showConfigWindow( for: vm )
    }
    
    public func showConfigWindow( for vm: VirtualMachine )
    {
        if self.configWindowControllers.contains( where: { $0.key == vm.config.uuid } ) == false
        {
            self.configWindowControllers[ vm.config.uuid ] = ConfigWindowController( vm: vm )
        }
        
        guard let window = self.configWindowControllers[ vm.config.uuid ]?.window else
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
                let vm          = VirtualMachine()
                vm.config.title = ( url.lastPathComponent as NSString ).deletingPathExtension
                
                try vm.save( to: url )
                
                Preferences.shared.addVirtualMachines( vm )
                self.machines.addObject( vm )
                self.showConfigWindow( for: vm )
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
        guard let vm = self.getVM( for: sender ) else
        {
            NSSound.beep()
            
            return
        }
        
        self.showConfigWindow( for: vm )
    }
    
    @IBAction private func revealInFinder( _ sender: Any?  )
    {
        guard let vm  = self.getVM( for: sender ),
              let url = vm.url
        else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( url.path, inFileViewerRootedAtPath: "" )
    }
    
    @IBAction private func delete( _ sender: Any?  )
    {
        guard let window = self.window,
              let vm     = self.getVM( for: sender ),
              let url    = vm.url
        else
        {
            NSSound.beep()
            
            return
        }
        
        let alert = NSAlert()
        
        alert.messageText     = "Delete \( vm.config.title )?"
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
            
            self.configWindowController( for: vm )?.close()
            self.machines.removeObject( vm )
            Preferences.shared.removeVirtualMachines( vm )
            
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
        
        let vm = arranged[ self.tableView.clickedRow ]
        
        menu.items.forEach { $0.representedObject = vm }
    }
    
    @IBAction private func start( _ sender: Any? )
    {
        guard let vm = self.getVM( for: sender ) else
        {
            NSSound.beep()
            
            return
        }
        
        vm.start()
    }
    
    private func getVM( for sender: Any? ) -> VirtualMachine?
    {
        if let vm = sender as? VirtualMachine
        {
            return vm
        }
        
        if let item = sender                 as? NSMenuItem,
           let vm   = item.representedObject as? VirtualMachine
        {
            return vm
        }
        
        guard let arranged = self.machines.arrangedObjects as? [ VirtualMachine ] else
        {
            return nil
        }
        
        if self.tableView.clickedRow < 0 || self.tableView.clickedRow >= arranged.count
        {
            return nil
        }
        
        return arranged[ self.tableView.clickedRow ]
    }
}
