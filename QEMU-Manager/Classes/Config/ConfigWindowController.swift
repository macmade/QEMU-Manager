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

public class ConfigWindowController: NSWindowController, NSTableViewDelegate
{
    @IBOutlet private var controllers:      NSArrayController!
    @IBOutlet private var container:        NSView!
    @IBOutlet private var sidebarContainer: NSView!
    @IBOutlet private var sidebarWidth:     NSLayoutConstraint!
    
    private var selectionObserver: NSKeyValueObservation?
    private var animating        = false
    
    @objc public private( set ) dynamic var vm: VirtualMachine
    
    public init( vm: VirtualMachine )
    {
        self.vm = vm
        
        super.init( window: nil )
        
        let _ = self.window
        
        self.addController( ConfigGeneralViewController(  vm: vm, sorting: 0 ) )
        self.addController( ConfigHardwareViewController( vm: vm, sorting: 1 ) )
        self.addController( ConfigDisksViewController(    vm: vm, sorting: 2 ) )
        self.addController( ConfigSharingViewController(  vm: vm, sorting: 3 ) )
        self.addController( ConfigQEMUViewController(     vm: vm, sorting: 4 ) )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver( self )
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "ConfigWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.window?.bind( NSBindingName( "title" ), to: self, withKeyPath: "vm.config.title", options: nil )
        
        self.controllers.sortDescriptors = [
            NSSortDescriptor( key: "sorting", ascending: true ),
            NSSortDescriptor( key: "title", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) )
        ]
        
        self.selectionObserver = self.controllers.observe( \.selectionIndex )
        {
            [ weak self ] o, c in self?.selectionChanged()
        }
        
        NotificationCenter.default.addObserver( self, selector: #selector( windowWillClose( _: ) ), name: NSWindow.willCloseNotification, object: self.window )
    }
    
    @objc private func windowWillClose( _ notification: NSNotification )
    {
        guard let window = notification.object as? NSWindow else
        {
            return
        }
        
        if window != self.window
        {
            return
        }
        
        do
        {
            if self.vm.config.title.trimmingCharacters( in: .whitespaces ).count == 0
            {
                self.vm.config.title = "Untitled"
            }
            
            try self.vm.save()
        }
        catch let error
        {
            NSAlert( error: error ).beginSheetModal( for: window, completionHandler: nil )
        }
    }
    
    @objc public func addController( _ controller: ConfigViewController )
    {
        self.controllers.addObject( controller )
        self.controllers.rearrangeObjects()
        
        if let controllers = self.controllers.arrangedObjects as? [ ConfigViewController ],
               controllers.count == 1
        {
            self.controllers.setSelectedObjects( [ controller ] )
        }
    }
    
    private func windowFrame( for controller: ConfigViewController ) -> NSRect
    {
        guard let container = self.container,
              let window    = self.window
        else
        {
            return NSRect.zero
        }
        
        let diffX = container.frame.size.width  - controller.view.frame.size.width
        let diffY = container.frame.size.height - controller.view.frame.size.height
        var rect  = window.frame
        
        rect.origin.x    += diffX / 2
        rect.origin.y    += diffY
        rect.size.width  -= diffX
        rect.size.height -= diffY
        
        return rect
    }
    
    @objc private func selectionChanged()
    {
        guard let controller       = self.controllers.selectedObjects.first as? ConfigViewController,
              let container        = self.container,
              let sidebarContainer = self.sidebarContainer,
              let window           = self.window
        else
        {
            return
        }
        
        if controller.view == container.subviews.first
        {
            return
        }
        
        let rect = self.windowFrame( for: controller )
        
        container.subviews.forEach { $0.removeFromSuperview() }
        
        if window.isVisible
        {
            let sidebarFixedWidth      = NSLayoutConstraint( item: sidebarContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: sidebarContainer.frame.size.width )
            self.sidebarWidth.isActive = false
            self.animating             = true
            
            self.sidebarContainer.superview?.addConstraint( sidebarFixedWidth )
            
            controller.view.alphaValue = 0
            
            self.window?.layoutIfNeeded()
            container.layoutSubtreeIfNeeded()
            controller.view.layoutSubtreeIfNeeded()
            
            NSAnimationContext.runAnimationGroup(
                {
                    context in
                    
                    self.window?.layoutIfNeeded()
                    container.layoutSubtreeIfNeeded()
                    controller.view.layoutSubtreeIfNeeded()
                    
                    window.animator().setFrame( rect, display: true, animate: true )
                },
                completionHandler:
                {
                    container.addSubview( controller.view )
                    container.addConstraint( NSLayoutConstraint( item: container, attribute: .width,   relatedBy: .equal, toItem: controller.view, attribute: .width,   multiplier: 1, constant: 0 ) )
                    container.addConstraint( NSLayoutConstraint( item: container, attribute: .height,  relatedBy: .equal, toItem: controller.view, attribute: .height,  multiplier: 1, constant: 0 ) )
                    container.addConstraint( NSLayoutConstraint( item: container, attribute: .centerX, relatedBy: .equal, toItem: controller.view, attribute: .centerX, multiplier: 1, constant: 0 ) )
                    container.addConstraint( NSLayoutConstraint( item: container, attribute: .centerY, relatedBy: .equal, toItem: controller.view, attribute: .centerY, multiplier: 1, constant: 0 ) )
                    self.sidebarContainer.superview?.removeConstraint( sidebarFixedWidth )
                    
                    self.sidebarWidth.isActive            = true
                    controller.view.animator().alphaValue = 1
                    self.animating                        = false
                }
            )
        }
        else
        {
            self.window?.setFrame( rect, display: false, animate: false )
            container.addSubview( controller.view )
            container.addConstraint( NSLayoutConstraint( item: container, attribute: .width,   relatedBy: .equal, toItem: controller.view, attribute: .width,   multiplier: 1, constant: 0 ) )
            container.addConstraint( NSLayoutConstraint( item: container, attribute: .height,  relatedBy: .equal, toItem: controller.view, attribute: .height,  multiplier: 1, constant: 0 ) )
            container.addConstraint( NSLayoutConstraint( item: container, attribute: .centerX, relatedBy: .equal, toItem: controller.view, attribute: .centerX, multiplier: 1, constant: 0 ) )
            container.addConstraint( NSLayoutConstraint( item: container, attribute: .centerY, relatedBy: .equal, toItem: controller.view, attribute: .centerY, multiplier: 1, constant: 0 ) )
        }
    }
    
    public func tableView( _ tableView: NSTableView, shouldSelectRow row: Int ) -> Bool
    {
        return self.animating == false
    }
}
