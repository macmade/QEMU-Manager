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

public class DropView: NSView
{
    public var onDrag: ( ( [ URL ] ) -> Bool )?
    public var onDrop: ( ( [ URL ] ) -> Bool )?
    
    @objc public private( set ) dynamic var dragging  = false
    @objc public                dynamic var allowDrop = true
    {
        didSet
        {
            self.unregisterDraggedTypes()
            
            if self.allowDrop
            {
                self.registerForDraggedTypes( [ .fileURL ] )
            }
        }
    }
    
    public override func awakeFromNib()
    {
        if self.allowDrop
        {
            self.registerForDraggedTypes( [ .fileURL ] )
        }
    }
    
    public override func draggingEntered( _ sender: NSDraggingInfo ) -> NSDragOperation
    {
        if self.onDrop == nil || self.allowDrop == false
        {
            return []
        }
        
        if let onDrag = self.onDrag
        {
            guard let urls = sender.draggingPasteboard.readObjects( forClasses: [ NSURL.self ], options: nil ) as? [ URL ] else
            {
                return []
            }
            
            if onDrag( urls ) == false
            {
                return []
            }
        }
        
        self.dragging = true
        
        return .copy
    }
    
    public override func draggingExited( _ sender: NSDraggingInfo? )
    {
        self.dragging = false
    }
    
    public override func draggingEnded( _ sender: NSDraggingInfo )
    {
        self.dragging = false
    }
    
    public override func performDragOperation( _ sender: NSDraggingInfo ) -> Bool
    {
        if self.allowDrop == false
        {
            return false
        }
        
        guard let onDrop = self.onDrop else
        {
            return false
        }
        
        guard let urls = sender.draggingPasteboard.readObjects( forClasses: [ NSURL.self ], options: nil ) as? [ URL ] else
        {
            return false
        }
        
        return onDrop( urls )
    }
}
