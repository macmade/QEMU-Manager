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

public class ConfigGeneralViewController: ConfigViewController
{
    @IBOutlet private var machineIcons: NSArrayController!
    
    @objc private dynamic var vm:          VirtualMachine
    @objc private dynamic var path:        String
    @objc private dynamic var machineIcon: Icon?
    {
        didSet
        {
            if let icon = self.machineIcon, icon.sorting != -1
            {
                self.vm.config.icon = icon.name
            }
            else
            {
                self.vm.config.icon = nil
            }
        }
    }
    
    public init( vm: VirtualMachine, sorting: Int )
    {
        self.vm   = vm
        self.path = vm.url?.path ?? "--"
        
        super.init( title: "General", icon: NSImage( named: "InfoTemplate" ), sorting: sorting )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigGeneralViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.machineIcons.sortDescriptors = [
            NSSortDescriptor( key: "sorting", ascending: true ),
            NSSortDescriptor( key: "name",    ascending: true ),
            NSSortDescriptor( key: "title",   ascending: true )
        ]
        
        self.updateIcons()
    }
    
    private func updateIcons()
    {
        if let existing = self.machineIcons.content as? [ Icon ]
        {
            existing.forEach { self.machineIcons.removeObject( $0 ) }
        }
        
        let unknown = Icon( name: "Generic", title: "Default", sorting: -1 )
        let icons   = Icon.all
        
        self.machineIcons.addObject( unknown )
        self.machineIcons.add( contentsOf: icons )
        
        self.machineIcon = icons.first { $0.name == vm.config.icon } ?? unknown
    }
    
    @IBAction private func revealInFinder( _ sender: Any? )
    {
        guard let url = self.vm.url else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( url.path, inFileViewerRootedAtPath: "" )
    }
}
