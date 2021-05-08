/*******************************************************************************
 * QEMU Manager
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
        
        self.machines.sortDescriptors = [ NSSortDescriptor( key: "config.title", ascending: true ) ]
    }
    
    public var virtualMachines: [ VirtualMachine ]
    {
        return self.machines.content as? [ VirtualMachine ] ?? []
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
        if vm.running
        {
            let alert = NSAlert()
            
            alert.messageText     = "Virtual Machine is Running"
            alert.informativeText = "The virtual machine \( vm.config.title ) is running. Are you sure you want to edit its configuration?"
            
            alert.addButton( withTitle: "Configure" )
            alert.addButton( withTitle: "Cancel" )
            
            if alert.runModal() == .alertSecondButtonReturn
            {
                return
            }
        }
        
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
    
    public func addVirtualMachines( from urls: [ URL ] )
    {
        let _        = self.window
        let existing = self.virtualMachines
        
        urls.forEach
        {
            url in
            
            if let _ = existing.first( where: { $0.url == url } )
            {
                return
            }
            
            guard let vm = VirtualMachine( url: url ) else
            {
                let alert = NSAlert()
                
                alert.messageText     = "Incompatible Virtual Machine"
                alert.informativeText = "An error occured while reading the virtual machine \( url.lastPathComponent )."
                
                alert.addButton( withTitle: "OK" )
                
                alert.runModal()
                
                return
            }
            
            Preferences.shared.addVirtualMachines( vm )
            self.machines.addObject( vm )
        }
    }
}
