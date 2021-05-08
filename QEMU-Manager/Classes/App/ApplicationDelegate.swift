/*******************************************************************************
 * QEMU Manager
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
import GitHubUpdates

@main public class ApplicationDelegate: NSObject, NSApplicationDelegate
{
    public let aboutWindowController   = AboutWindowController()
    public let libraryWindowController = LibraryWindowController()
    
    @IBOutlet private var updater: GitHubUpdater!
    
    public func applicationDidFinishLaunching( _ notification: Notification )
    {
        self.showLibraryWindow( nil )
        
        DispatchQueue.main.asyncAfter( deadline: .now() + .seconds( 2 ) )
        {
            self.updater.checkForUpdatesInBackground()
        }
    }

    public func applicationWillTerminate( _ notification: Notification )
    {
        Preferences.shared.lastStart = Date()
    }
    
    public func applicationShouldTerminate( _ sender: NSApplication ) -> NSApplication.TerminateReply
    {
        for vm in self.libraryWindowController.virtualMachines
        {
            if vm.running
            {
                let alert = NSAlert()
                
                alert.messageText     = "Virtual Machines are running"
                alert.informativeText = "Please shut-down all virtual machines before quitting."
                
                alert.addButton( withTitle: "OK" )
                
                alert.tryBeginSheetModal( for: self.libraryWindowController.window, completionHandler: nil )
                
                return .terminateCancel
            }
        }
        
        return .terminateNow
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
    
    public func application( _ application: NSApplication, open urls: [ URL ] )
    {
        self.libraryWindowController.addVirtualMachines( from: urls )
    }
    
    @IBAction private func checkForUpdates( _ sender: Any? )
    {
        self.updater.checkForUpdates( sender )
    }
}
