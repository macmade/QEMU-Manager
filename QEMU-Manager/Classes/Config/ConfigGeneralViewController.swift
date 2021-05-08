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

public class ConfigGeneralViewController: ConfigViewController
{
    @objc private dynamic var vm:          VirtualMachine
    @objc private dynamic var path:        String
    @objc private dynamic var machineIcon: Int
    {
        didSet
        {
            if let icon = Config.Icon( rawValue: self.machineIcon )
            {
                self.vm.config.icon = icon
            }
        }
    }
    
    public init( vm: VirtualMachine )
    {
        self.vm           = vm
        self.path         = vm.url?.path ?? "--"
        self.machineIcon  = vm.config.icon.rawValue
        
        super.init( title: "General", icon: NSImage( named: "InfoTemplate" ), sorting: 0 )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigGeneralViewController"
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
