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

public class Preferences: NSObject, Synchronizable
{
    @objc public  dynamic var lastStart: Date?
    @objc private dynamic var vmURLs:    [ String ] = []
    
    @objc public static let shared = Preferences()
    
    override init()
    {
        super.init()
        
        guard let path = Bundle.main.path( forResource: "Defaults", ofType: "plist" ) else
        {
            return
        }
        
        UserDefaults.standard.register( defaults: NSDictionary( contentsOfFile: path ) as? [ String : Any ] ?? [ : ] )
        
        for c in Mirror( reflecting: self ).children
        {
            guard let key = c.label else
            {
                continue
            }
            
            self.setValue( UserDefaults.standard.object( forKey: key ), forKey: key )
            self.addObserver( self, forKeyPath: key, options: .new, context: nil )
        }
    }
    
    deinit
    {
        for c in Mirror( reflecting: self ).children
        {
            guard let key = c.label else
            {
                continue
            }
            
            self.removeObserver( self, forKeyPath: key )
        }
    }
    
    public func virtualMachines() -> [ VirtualMachine ]
    {
        self.synchronized
        {
            self.vmURLs = self.vmURLs.filter
            {
                guard let url = URL( string: $0 ) else
                {
                    return false
                }
                
                return FileManager.default.fileExists( atPath: url.path )
            }
            
            return self.vmURLs.compactMap
            {
                guard let url = URL( string: $0 ) else
                {
                    return nil
                }
                
                return VirtualMachine( url: url )
            }
        }
    }
    
    public func addVirtualMachines( _ vm: VirtualMachine )
    {
        guard let url = vm.url else
        {
            return
        }
        
        self.synchronized
        {
            var vms = self.vmURLs
            
            vms.append( url.absoluteString )
            
            self.vmURLs = vms
        }
    }
    
    public func removeVirtualMachines( _ vm: VirtualMachine )
    {
        guard let url = vm.url else
        {
            return
        }
        
        self.synchronized
        {
            self.vmURLs = self.vmURLs.filter { $0 != url.absoluteString }
        }
    }
    
    @objc public override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey : Any ]?, context: UnsafeMutableRawPointer? )
    {
        for c in Mirror( reflecting: self ).children
        {
            guard let key = c.label else
            {
                continue
            }
            
            if( key == keyPath )
            {
                UserDefaults.standard.set( change?[ NSKeyValueChangeKey.newKey ], forKey: key )
            }
        }
    }
}
