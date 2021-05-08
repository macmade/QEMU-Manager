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

import Foundation

public class InfoValue: NSObject
{
    @objc public private( set ) dynamic var name:    String
    @objc public private( set ) dynamic var title:   String
    @objc public private( set ) dynamic var sorting: Int
    
    public init( name: String, title: String, sorting: Int )
    {
        self.name    = name
        self.title   = title
        self.sorting = sorting
    }
    
    public override var description: String
    {
        if self.title.count > 0
        {
            return "\( self.name ) - \( self.title )"
        }
        
        return self.name
    }
    
    public override func isEqual( _ object: Any? ) -> Bool
    {
        guard let format = object as? ImageFormat else
        {
            return false
        }
        
        return self.name == format.name
    }
}
