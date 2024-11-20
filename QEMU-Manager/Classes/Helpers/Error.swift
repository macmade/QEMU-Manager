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

public class Error: NSError, @unchecked Sendable
{
    public init( title: String, message: String, code: Int = -1 )
    {
        let info =
        [
            NSLocalizedDescriptionKey             : title,
            NSLocalizedRecoverySuggestionErrorKey : message,
        ]
        
        super.init( domain: "com.DigiDNA.iMazing-Crashes", code: code, userInfo: info )
    }
    
    required init?( coder: NSCoder )
    {
        super.init( coder: coder )
    }
}
