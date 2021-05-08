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

extension QEMU.Img
{
    static func create( url: URL, size: UInt64, format: String ) throws
    {
        let args =
        [
            "create",
            "-f",
            format,
            url.path,
            "\( size )"
        ]
        
        let _ = try QEMU.Img().execute( arguments: args )
    }
    
    static func info( url: URL ) throws -> [ String ]
    {
        let res = try QEMU.Img().execute( arguments: [ "info", url.path ] )
        
        return res?.out.components( separatedBy: .newlines ).map { $0.trimmingCharacters( in: .whitespaces ) } ?? []
    }
    
    static func size( url: URL ) throws -> String?
    {
        let info = try QEMU.Img.info( url: url )
        
        for line in info
        {
            if line.hasPrefix( "virtual size:" )
            {
                return String( line.suffix( from: line.index( line.startIndex, offsetBy: 13 ) ) ).trimmingCharacters( in: .whitespaces )
            }
        }
        
        return nil
    }
}
