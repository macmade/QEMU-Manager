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

@objc( BytesToString ) public class BytesToString: ValueTransformer
{
    public override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }
    
    public override class func allowsReverseTransformation() -> Bool
    {
        false
    }
    
    public override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let bytes = value as? NSNumber else
        {
            return "--" as NSString
        }
        
        if bytes.uint64Value < 1024
        {
            return "\( bytes.uint64Value ) bytes" as NSString
        }
        else if bytes.uint64Value < ( 1024 * 1024 )
        {
            return "\( String( format: "%.2f KB", Double( bytes.uint64Value ) / 1024.0 ) )" as NSString
        }
        else if bytes.uint64Value < ( 1024 * 1024 * 1024 )
        {
            return "\( String( format: "%.2f MB", ( Double( bytes.uint64Value ) / 1024.0 ) / 1024.0 ) )" as NSString
        }
        else if bytes.uint64Value < ( 1024 * 1024 * 1024 * 1024 )
        {
            return "\( String( format: "%.2f GB", ( ( Double( bytes.uint64Value ) / 1024.0 ) / 1024.0 ) / 1024.0 ) )" as NSString
        }
        
        return "\( String( format: "%.2f TB", ( ( ( Double( bytes.uint64Value ) / 1024.0 ) / 1024.0 ) / 1024.0 ) / 1024.0 ) )" as NSString
    }
}
