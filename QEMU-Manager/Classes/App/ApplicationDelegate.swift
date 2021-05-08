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

@main public class ApplicationDelegate: NSObject, NSApplicationDelegate
{
    private let aboutWindowController   = AboutWindowController()
    private let libraryWindowController = LibraryWindowController()
    
    public func applicationDidFinishLaunching( _ notification: Notification )
    {
        self.showLibraryWindow( nil )
    }

    public func applicationWillTerminate( _ notification: Notification )
    {
        Preferences.shared.lastStart = Date()
    }
    
    @IBAction func invertAppearance( _ sender: Any? )
    {
        let name = NSApp.effectiveAppearance.name
        
        if name == NSAppearance.Name.aqua
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.darkAqua )
        }
        else if name == NSAppearance.Name.darkAqua
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.aqua )
        }
        else if name == NSAppearance.Name.vibrantLight
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.vibrantDark )
        }
        else if name == NSAppearance.Name.vibrantDark
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.vibrantLight )
        }
        else if name == NSAppearance.Name.accessibilityHighContrastAqua
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.accessibilityHighContrastDarkAqua )
        }
        else if name == NSAppearance.Name.accessibilityHighContrastDarkAqua
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.accessibilityHighContrastAqua )
        }
        else if name == NSAppearance.Name.accessibilityHighContrastVibrantDark
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.accessibilityHighContrastVibrantLight )
        }
        else if name == NSAppearance.Name.accessibilityHighContrastVibrantLight
        {
            NSApp.appearance = NSAppearance( named: NSAppearance.Name.accessibilityHighContrastVibrantDark )
        }
    }
    
    @IBAction func showAboutWindow( _ sender: Any? )
    {
        guard let window = self.aboutWindowController.window else
        {
            NSSound.beep()
            
            return
        }
        
        window.layoutIfNeeded()
        
        if window.isVisible == false
        {
            window.center()
        }
        
        window.makeKeyAndOrderFront( nil )
    }
    
    @IBAction func showLibraryWindow( _ sender: Any? )
    {
        guard let window = self.libraryWindowController.window else
        {
            NSSound.beep()
            
            return
        }
        
        window.layoutIfNeeded()
        
        if window.isVisible == false && Preferences.shared.lastStart == nil
        {
            window.center()
        }
        
        window.makeKeyAndOrderFront( nil )
    }
}
