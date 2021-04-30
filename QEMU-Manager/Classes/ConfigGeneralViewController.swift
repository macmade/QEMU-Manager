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

@objc public class ConfigGeneralViewController: ConfigViewController
{
    @objc private dynamic var machine:      VirtualMachine
    @objc private dynamic var path:         String
    @objc private dynamic var architecture: Int
    {
        didSet
        {
            if let arch = Config.Architecture( rawValue: self.architecture )
            {
                self.machine.config.architecture = arch
            }
        }
    }
    @objc private dynamic var machineIcon: Int
    {
        didSet
        {
            if let icon = Config.Icon( rawValue: self.machineIcon )
            {
                self.machine.config.icon = icon
            }
        }
    }
    
    private var architectureObserver: NSKeyValueObservation?
    
    public init( machine: VirtualMachine )
    {
        self.machine      = machine
        self.path         = machine.url?.path ?? "--"
        self.architecture = machine.config.architecture.rawValue
        self.machineIcon  = machine.config.icon.rawValue
        
        super.init( title: "General", icon: nil, sorting: 0 )
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
        guard let url = self.machine.url else
        {
            NSSound.beep()
            
            return
        }
        
        NSWorkspace.shared.selectFile( url.path, inFileViewerRootedAtPath: "" )
    }
}
