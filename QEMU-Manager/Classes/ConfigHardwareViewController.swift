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

@objc public class ConfigHardwareViewController: ConfigViewController
{
    @IBOutlet private var sizeFormatter: SizeFormatter!
    @IBOutlet private var machines:      NSArrayController!
    @IBOutlet private var cpus:          NSArrayController!
    
    @objc private dynamic var minMemory:    UInt64
    @objc private dynamic var maxMemory:    UInt64
    @objc private dynamic var machine:      VirtualMachine
    @objc private dynamic var architecture: Int
    {
        didSet
        {
            if let machines = self.machines.content as? [ String ]
            {
                machines.forEach { self.machines.removeObject( $0 ) }
            }
            
            if let cpus = self.cpus.content as? [ String ]
            {
                cpus.forEach { self.machines.removeObject( $0 ) }
            }
            
            if let arch = Config.Architecture( rawValue: self.architecture )
            {
                self.machine.config.architecture = arch
                
                QEMU.System.machines( for: arch ).forEach { self.machines.addObject( $0.0 ) }
                QEMU.System.cpus(     for: arch ).forEach { self.cpus.addObject( $0.0 ) }
            }
        }
    }
    
    public init( machine: VirtualMachine )
    {
        self.minMemory    = 1024 * 1024
        self.maxMemory    = ProcessInfo().physicalMemory / 2
        self.machine      = machine
        self.architecture = machine.config.architecture.rawValue
        
        super.init( title: "Hardware", icon: nil, sorting: 0 )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigHardwareViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.sizeFormatter.min = self.minMemory
        self.sizeFormatter.max = self.maxMemory
        
        if let arch = Config.Architecture( rawValue: self.architecture )
        {
            QEMU.System.machines( for: arch ).forEach { self.machines.addObject( $0.0 ) }
            QEMU.System.cpus(     for: arch ).forEach { self.cpus.addObject( $0.0 ) }
        }
    }
}
