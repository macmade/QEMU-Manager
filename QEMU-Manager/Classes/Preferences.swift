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

@objc public class Preferences: NSObject, Synchronizable
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
    
    public func addVirtualMachines( _ machine: VirtualMachine )
    {
        guard let url = machine.url else
        {
            return
        }
        
        self.synchronized
        {
            var machines = self.vmURLs
            
            machines.append( url.absoluteString )
            
            self.vmURLs = machines
        }
    }
    
    public func removeVirtualMachines( _ machine: VirtualMachine )
    {
        guard let url = machine.url else
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
