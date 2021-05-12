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

public class ConfigSharingViewController: ConfigViewController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet private var folders: NSArrayController!
    
    @objc private dynamic var vm: VirtualMachine
    
    public init( vm: VirtualMachine, sorting: Int )
    {
        self.vm   = vm
        
        super.init( title: "Sharing", icon: NSImage( named: "FolderTemplate" ), sorting: sorting )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigSharingViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.reloadFolders()
    }
    
    @IBAction private func revealFolder( _ sender: Any? )
    {
        guard let folder = sender as? SharedFolder else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( folder.url.path, inFileViewerRootedAtPath: "" )
    }
    
    @IBAction private func addRemoveFolder( _ sender: Any? )
    {
        guard let button = sender as? NSSegmentedControl else
        {
            NSSound.beep()
            
            return
        }
        
        switch button.selectedSegment
        {
            case 0:  self.addFolder( sender )
            case 1:  self.removeFolder( sender )
            default: NSSound.beep()
        }
    }
    
    @IBAction private func addFolder( _ sender: Any? )
    {
        guard let window = self.view.window else
        {
            NSSound.beep()
            
            return
        }
        
        let accessoryView             = SharedFolderAccessoryViewController()
        let panel                     = NSOpenPanel()
        panel.canChooseFiles          = false
        panel.canChooseDirectories    = true
        panel.allowsMultipleSelection = false
        panel.accessoryView           = accessoryView.view
        
        panel.beginSheetModal( for: window )
        {
            if $0 != .OK
            {
                return
            }
            
            guard let url = panel.url else
            {
                return
            }
            
            do
            {
                let folder = SharedFolder( url: url, kind: accessoryView.sharedFolderKind )
                
                self.folders.addObject( folder )
                self.vm.config.addSharedFolder( folder )
                try self.vm.save()
            }
            catch let error
            {
                NSAlert( error: error ).beginSheetModal( for: window, completionHandler: nil )
            }
        }
    }
    
    @IBAction private func removeFolder( _ sender: Any? )
    {
        guard let folder = self.folders.selectedObjects.first as? SharedFolder else
        {
            NSSound.beep()
            
            return
        }
        
        do
        {
            self.vm.config.removeSharedFolder( folder )
            try self.vm.save()
            self.reloadFolders()
        }
        catch let error
        {
            NSAlert( error: error ).tryBeginSheetModal( for: self.view.window, completionHandler: nil )
        }
    }
    
    private func reloadFolders()
    {
        if let existing = self.folders.content as? [ SharedFolder ]
        {
            existing.forEach { self.folders.removeObject( $0 ) }
        }
        
        self.folders.add( contentsOf: self.vm.config.sharedFolders )
    }
}
