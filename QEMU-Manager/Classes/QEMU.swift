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

public class QEMU
{
    public class Executable
    {
        public private( set ) var name: String
        public private( set ) var url:  URL?
        
        public init( tool: String )
        {
            self.name = tool
            
            if let resources = Bundle.main.resourceURL
            {
                self.url = resources.appendingPathComponent( "qemu" ).appendingPathComponent( "bin" ).appendingPathComponent( tool )
            }
        }
        
        public func execute( arguments: [ String ] ) throws
        {
            guard let path = self.url?.path else
            {
                throw Error( title: "\( self.name ) not available", message: "The QEMU tool \( self.name ) was not found." )
            }
            
            let process        = Process()
            process.launchPath = path
            process.arguments  = arguments
            
            process.launch()
            process.waitUntilExit()
            
            if process.terminationStatus != 0
            {
                throw Error( title: "Error executing \( self.name )", message: "Process exited with status code \( process.terminationStatus )" )
            }
        }
    }
    
    public class Img: Executable
    {
        public init()
        {
            super.init( tool: "qemu-img" )
        }
    }
}
