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

@objc public class LibraryWindowController: NSWindowController
{
    @IBOutlet private var machines: NSArrayController!
    
    public override var windowNibName: NSNib.Name?
    {
        return "LibraryWindowController"
    }
    
    override public func windowDidLoad()
    {
        super.windowDidLoad()
    }
    
    @IBAction private func newVirtualMachine( _ sender: Any?  )
    {
        guard let window = self.window else
        {
            NSSound.beep()
            
            return
        }
        
        let panel                  = NSSavePanel()
        panel.allowedFileTypes     = [ "qvm" ]
        panel.canCreateDirectories = true
        
        panel.beginSheetModal( for: window )
        {
            r in if r != .OK
            {
                return
            }
            
            guard let url = panel.url else
            {
                NSSound.beep()
                
                return
            }
            
            do
            {
                let machine          = VirtualMachine()
                machine.config.title = ( url.lastPathComponent as NSString ).deletingPathExtension
                
                try machine.save( to: url )
            
                self.machines.addObject( machine )
            }
            catch let error
            {
                let alert = NSAlert( error: error )
                
                alert.beginSheetModal( for: window, completionHandler: nil )
            }
        }
    }
    
    @IBAction private func newDocument( _ sender: Any?  )
    {
        self.newVirtualMachine( sender )
    }
}
