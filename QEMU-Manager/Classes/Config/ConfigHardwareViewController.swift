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

public class ConfigHardwareViewController: ConfigViewController
{
    @IBOutlet private var sizeFormatter: SizeFormatter!
    @IBOutlet private var machines:      NSArrayController!
    @IBOutlet private var cpus:          NSArrayController!
    @IBOutlet private var vgas:          NSArrayController!
    @IBOutlet private var cores:         NSArrayController!
    
    @objc private dynamic var minCores:     UInt64
    @objc private dynamic var maxCores:     UInt64
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
            self.updateVGAs()
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
    
    @objc private dynamic var vga: VGA?
    {
        didSet
        {
            if let vga = self.vga, vga.sorting != -1
            {
                self.vm.config.vga = vga.name
            }
            else
            {
                self.vm.config.vga = nil
            }
        }
    }
    
    public init( vm: VirtualMachine, sorting: Int )
    {
        self.minCores     = 1
        self.maxCores     = UInt64( ProcessInfo().processorCount )
        self.minMemory    = 1024 * 1024
        self.maxMemory    = ProcessInfo().physicalMemory / 2
        self.vm           = vm
        self.architecture = vm.config.architecture.rawValue
        
        super.init( title: "Hardware", icon: NSImage( named: "HardwareTemplate" ), sorting: sorting )
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
        self.updateVGAs()
        
        for i in self.minCores ..< self.maxCores
        {
            self.cores.addObject( i )
        }
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
        
        self.machines.add( contentsOf: machines )
        
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
        
        self.cpus.add( contentsOf: cpus )
        
        self.cpu = cpus.first { $0.name == vm.config.cpu } ?? unknown
    }
    
    private func updateVGAs()
    {
        if let existing = self.vgas.content as? [ VGA ]
        {
            existing.forEach { self.vgas.removeObject( $0 ) }
        }
        
        let unknown = VGA( name: "Default", title: "Unspecified VGA", sorting: -1 )
        
        self.vgas.addObject( unknown )
        
        guard let arch = Config.Architecture( rawValue: self.architecture ),
              let vgas = VGA.all[ arch ]
        else
        {
            self.vga = unknown
            
            return
        }
        
        self.vgas.add( contentsOf: vgas )
        
        self.vga = vgas.first { $0.name == vm.config.vga } ?? unknown
    }
}
