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
    @objc private dynamic var vm:           VirtualMachine
    @objc private dynamic var architecture: Int
    {
        didSet
        {
            if let arch = Config.Architecture( rawValue: self.architecture )
            {
                self.vm.config.architecture = arch
            }
            
            self.updateMachines()
            self.updateCPUs()
        }
    }
    
    @objc private dynamic var machine: Machine?
    {
        didSet
        {
            if let machine = self.machine, machine.sorting != -1
            {
                self.vm.config.machine = machine.name
            }
            else
            {
                self.vm.config.machine = nil
            }
        }
    }
    
    @objc private dynamic var cpu: CPU?
    {
        didSet
        {
            if let cpu = self.cpu, cpu.sorting != -1
            {
                self.vm.config.cpu = cpu.name
            }
            else
            {
                self.vm.config.cpu = nil
            }
        }
    }
    
    public init( vm: VirtualMachine )
    {
        self.minMemory    = 1024 * 1024
        self.maxMemory    = ProcessInfo().physicalMemory / 2
        self.vm           = vm
        self.architecture = vm.config.architecture.rawValue
        
        super.init( title: "Hardware", icon: NSImage( named: "HardwareTemplate" ), sorting: 0 )
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
        
        self.machines.sortDescriptors = [
            NSSortDescriptor( key: "sorting", ascending: true ),
            NSSortDescriptor( key: "name",    ascending: true ),
            NSSortDescriptor( key: "title",   ascending: true )
        ]
        
        self.cpus.sortDescriptors = [
            NSSortDescriptor( key: "sorting", ascending: true ),
            NSSortDescriptor( key: "name",    ascending: true ),
            NSSortDescriptor( key: "title",   ascending: true )
        ]
        
        self.updateMachines()
        self.updateCPUs()
    }
    
    private func updateMachines()
    {
        if let existing = self.machines.content as? [ Machine ]
        {
            existing.forEach { self.machines.removeObject( $0 ) }
        }
        
        let unknown = Machine( name: "Default", title: "Unspecified machine", sorting: -1 )
        
        self.machines.addObject( unknown )
        
        guard let arch     = Config.Architecture( rawValue: self.architecture ),
              let machines = Machine.all[ arch ]
        else
        {
            self.machine = unknown
            
            return
        }
        
        machines.forEach { self.machines.addObject( $0 ) }
        
        self.machine = machines.first { $0.name == vm.config.machine } ?? unknown
    }
    
    private func updateCPUs()
    {
        if let existing = self.cpus.content as? [ CPU ]
        {
            existing.forEach { self.cpus.removeObject( $0 ) }
        }
        
        let unknown = CPU( name: "Default", title: "Unspecified CPU", sorting: -1 )
        
        self.cpus.addObject( unknown )
        
        guard let arch = Config.Architecture( rawValue: self.architecture ),
              let cpus = CPU.all[ arch ]
        else
        {
            self.cpu = unknown
            
            return
        }
        
        cpus.forEach { self.cpus.addObject( $0 ) }
        
        self.cpu = cpus.first { $0.name == vm.config.cpu } ?? unknown
    }
}
