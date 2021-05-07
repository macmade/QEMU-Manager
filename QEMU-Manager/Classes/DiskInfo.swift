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

import Foundation

@objc public class DiskInfo: NSObject
{
    @objc public private( set ) dynamic var machine: VirtualMachine
    @objc public private( set ) dynamic var disk:    Disk
    @objc public private( set ) dynamic var url:     URL
    @objc public private( set ) dynamic var size:    UInt64
    
    public init?( machine: VirtualMachine, disk: Disk )
    {
        guard let url = machine.url else
        {
            return nil
        }
        
        if machine.config.disks.contains( where: { $0.uuid == disk.uuid } ) == false
        {
            return nil
        }
        
        self.machine = machine
        self.disk    = disk
        self.url     = url.appendingPathComponent( disk.uuid.uuidString ).appendingPathExtension( "qcow2" )
        
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
