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

@objc public class ConfigWindowController: NSWindowController, NSTableViewDelegate
{
    @IBOutlet private var controllers:      NSArrayController!
    @IBOutlet private var container:        NSView!
    @IBOutlet private var sidebarContainer: NSView!
    @IBOutlet private var sidebarWidth:     NSLayoutConstraint!
    
    private var selectionObserver: NSKeyValueObservation?
    private var animating        = false
    
    @objc public private( set ) dynamic var machine: VirtualMachine
    
    public init( machine: VirtualMachine )
    {
        self.machine = machine
        
        super.init( window: nil )
        
        let _ = self.window
        
        self.addController( ConfigGeneralViewController() )
        self.addController( ConfigHardwareViewController() )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var windowNibName: NSNib.Name?
    {
        "ConfigWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.window?.title = self.machine.config.title
        
        self.controllers.sortDescriptors = [
            NSSortDescriptor( key: "sorting", ascending: false ),
            NSSortDescriptor( key: "title", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) )
        ]
        
        self.selectionObserver = self.controllers.observe( \.selectionIndex )
        {
            [ weak self ] o, c in self?.selectionChanged()
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
