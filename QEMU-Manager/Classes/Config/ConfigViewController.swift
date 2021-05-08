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

public class ConfigViewController: NSViewController
{
    @objc public dynamic var icon:    NSImage?
    @objc public dynamic var sorting: Int = 0
    
    public init( title: String, icon: NSImage? = nil, sorting: Int = 0 )
    {
        super.init( nibName: nil, bundle: nil )
        
        self.title   = title
        self.icon    = icon ?? NSImage( named: NSImage.applicationIconName )
        self.sorting = sorting
    }
    
    required init?( coder: NSCoder )
    {
        return nil
    }
}
