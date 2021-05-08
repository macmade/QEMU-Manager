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

import Foundation

public class DiskInfo: NSObject
{
    @objc public private( set ) dynamic var vm:      VirtualMachine
    @objc public private( set ) dynamic var disk:    Disk
    @objc public private( set ) dynamic var url:     URL
    @objc public private( set ) dynamic var size:    UInt64
    
    public init?( vm: VirtualMachine, disk: Disk )
    {
        guard let url = vm.url else
        {
            return nil
        }
        
        if vm.config.disks.contains( where: { $0.uuid == disk.uuid } ) == false
        {
            return nil
        }
        
        self.vm   = vm
        self.disk = disk
        self.url  = url.appendingPathComponent( disk.uuid.uuidString ).appendingPathExtension( disk.format )
        
        do
        {
            guard let size   = try QEMU.Img.size( url: self.url ),
                  let number = SizeFormatter().number( from: size )
            else
            {
                return nil
            }
            
            self.size = number.uint64Value
        }
        catch
        {
            return nil
        }
    }
}
