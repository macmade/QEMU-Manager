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

public class AboutWindowController: NSWindowController
{
    @objc private dynamic var name:      String?
    @objc private dynamic var version:   String?
    @objc private dynamic var copyright: String?
    
    public override var windowNibName: NSNib.Name?
    {
        return "AboutWindowController"
    }
    
    override public func windowDidLoad()
    {
        super.windowDidLoad()
        
        let version = Bundle.main.object( forInfoDictionaryKey: "CFBundleShortVersionString" ) as? String ?? "0.0.0"
        
        if let build = Bundle.main.object( forInfoDictionaryKey: "CFBundleVersion" ) as? String
        {
            self.version = "\(version) (\(build))"
        }
        else
        {
            self.version = version
        }
        
        self.name      = Bundle.main.object( forInfoDictionaryKey: "CFBundleName"             ) as? String
        self.copyright = Bundle.main.object( forInfoDictionaryKey: "NSHumanReadableCopyright" ) as? String
    }
}
