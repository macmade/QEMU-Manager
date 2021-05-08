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

public class Icon: InfoValue
{
    public static var all: [ Icon ] =
    {
        return [
            Icon( name: "AppleTemplate",   title: "Apple",          sorting: 1 ),
            Icon( name: "AppleLegacy",     title: "Apple Legacy",   sorting: 2 ),
            Icon( name: "MacOS",           title: "Mac OS",         sorting: 3 ),
            Icon( name: "WindowsTemplate", title: "Windows",        sorting: 4 ),
            Icon( name: "WindowsLegacy",   title: "Windows Legacy", sorting: 5 ),
            Icon( name: "Linux",           title: "Linux",          sorting: 6 ),
            Icon( name: "Fedora",          title: "Fedora",         sorting: 7 ),
            Icon( name: "Ubuntu",          title: "Ubuntu",         sorting: 8 ),
            Icon( name: "FreeBSD",         title: "FreeBSD",        sorting: 9 ),
        ]
    }()
    
    public override var description: String
    {
        return self.title
    }
}
