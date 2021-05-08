/*******************************************************************************
 * QEMU Manager
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
        
        public func execute( arguments: [ String ] ) throws -> ( out: String, err: String )?
        {
            guard let path = self.url?.path else
            {
                throw Error( title: "\( self.name ) not available", message: "The QEMU tool \( self.name ) was not found." )
            }
            
            let out                = Pipe()
            let err                = Pipe()
            let process            = Process()
            process.launchPath     = path
            process.arguments      = arguments
            process.standardOutput = out
            process.standardError  = err
            
            try ObjC.catchException { process.launch() }
            process.waitUntilExit()
            
            let dataOut = try? out.fileHandleForReading.readToEnd()
            let dataErr = try? err.fileHandleForReading.readToEnd()
            let strOut  = String( data: dataOut ?? Data(), encoding: .utf8 ) ?? ""
            let strErr  = String( data: dataErr ?? Data(), encoding: .utf8 ) ?? ""
            
            if process.terminationStatus != 0
            {
                var message = "Process exited with status code \( process.terminationStatus )."
                
                if strErr.count > 0
                {
                    message.append( "\n\( strErr )" )
                }
                
                throw Error( title: "Error executing \( self.name )", message: message )
            }
            
            
            return ( out: strOut, err: strErr )
        }
    }
    
    public class Img: Executable
    {
        public init()
        {
            super.init( tool: "qemu-img" )
        }
    }
    
    public class System: Executable
    {
        public init( architecture: Config.Architecture )
        {
            super.init( tool: "qemu-system-\( architecture.description )" )
        }
    }
}
