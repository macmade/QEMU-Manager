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

import Foundation

@objc public class Boot: NSObject
{
    @objc public private( set ) dynamic var name:    String
    @objc public private( set ) dynamic var title:   String
    @objc public private( set ) dynamic var sorting: Int
    
    public static var all: [ Boot ] =
    {
        return [
            Boot( name: "a", title: "Floppy",  sorting: 0 ),
            Boot( name: "c", title: "Disk",    sorting: 1 ),
            Boot( name: "d", title: "CD",      sorting: 2 ),
            Boot( name: "n", title: "Network", sorting: 3 ),
        ]
    }()
    
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
            return self.title
        }
        
        return self.name
    }
    
    public override func isEqual( _ object: Any? ) -> Bool
    {
        guard let order = object as? Boot else
        {
            return false
        }
        
        return self.name == order.name
    }
}
