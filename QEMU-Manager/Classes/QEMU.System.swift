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

extension QEMU.System
{
    public static func start( vm: VirtualMachine ) throws
    {
        var arguments: [ String ] = []
        
        /*
        arguments.append( "-m" )
        arguments.append( "\( vm.config.memory )" )
        */
        
        if vm.config.boot.count > 0
        {
            arguments.append( "-boot" )
            arguments.append( vm.config.boot )
        }
        
        if let machine = vm.config.machine, machine.count > 0
        {
            arguments.append( "-M" )
            arguments.append( machine )
        }
        
        if let cpu = vm.config.cpu, cpu.count > 0
        {
            arguments.append( "-cpu" )
            arguments.append( cpu )
        }
        
        if let cd = vm.config.cdImage, FileManager.default.fileExists( atPath: cd.path )
        {
            arguments.append( "-drive" )
            arguments.append( "file=\( cd.path ),format=raw,media=cdrom" )
        }
        
        vm.disks.forEach
        {
            arguments.append( "-drive" )
            arguments.append( "file=\( $0.url.path ),format=\( $0.disk.format ),media=disk" )
        }
        
        let _ = try QEMU.System( architecture: vm.config.architecture ).execute( arguments: arguments )
    }
    
    public static func machines( for architecture: Config.Architecture ) -> [ ( String, String ) ]
    {
        do
        {
            let res = try QEMU.System( architecture: architecture ).execute( arguments: [ "-machine", "help" ] )
            
            guard let lines = res?.out.components( separatedBy: .newlines ) else
            {
                return []
            }
            
            var machines: [ ( String, String ) ] = []
            
            for var line in lines
            {
                line = line.trimmingCharacters( in: .whitespaces )
                
                if line == "Supported machines are:"
                {
                    continue
                }
                
                if line.count == 0
                {
                    if machines.isEmpty
                    {
                        continue
                    }
                    else
                    {
                        break
                    }
                }
                
                do
                {
                    let regex = try NSRegularExpression( pattern: #"([^\s]+)\s+(.*)"#, options: [] )
                    
                    guard let match = regex.matches( in: line, options: [], range: NSRange( location: 0, length: line.count ) ).first else
                    {
                        break
                    }
                    
                    if match.numberOfRanges != 3
                    {
                        break;
                    }
                    
                    let s1 = ( line as NSString ).substring( with: match.range( at: 1 ) )
                    let s2 = ( line as NSString ).substring( with: match.range( at: 2 ) )
                    
                    machines.append( ( s1, s2 ) )
                }
                catch
                {
                    break
                }
            }
            
            return machines
        }
        catch
        {
            return []
        }
    }
    
    public static func cpus( for architecture: Config.Architecture ) -> [ ( String, String ) ]
    {
        do
        {
            let res = try QEMU.System( architecture: architecture ).execute( arguments: [ "-cpu", "help" ] )
            
            guard let lines = res?.out.components( separatedBy: .newlines ) else
            {
                return []
            }
            
            var cpus: [ ( String, String ) ] = []
            
            for var line in lines
            {
                line = line.trimmingCharacters( in: .whitespaces )
                
                if line == "Available CPUs:"
                {
                    continue
                }
                
                if line.count == 0
                {
                    if cpus.isEmpty
                    {
                        continue
                    }
                    else
                    {
                        break
                    }
                }
                
                let prefixes = [ "x86 ", "PowerPC " ]
                
                prefixes.forEach
                {
                    if line.hasPrefix( $0 )
                    {
                        line = String( line.dropFirst( $0.count ) )
                    }
                }
                
                do
                {
                    let regex = try NSRegularExpression( pattern: #"([^\s]+)\s+(.*)"#, options: [] )
                    
                    guard let match = regex.matches( in: line, options: [], range: NSRange( location: 0, length: line.count ) ).first else
                    {
                        cpus.append( ( line, line ) )
                        
                        continue
                    }
                    
                    if match.numberOfRanges != 3
                    {
                        break;
                    }
                    
                    let s1 = ( line as NSString ).substring( with: match.range( at: 1 ) )
                    let s2 = ( line as NSString ).substring( with: match.range( at: 2 ) )
                    
                    cpus.append( ( s1, s2 ) )
                }
                catch
                {
                    break
                }
            }
            
            return cpus
        }
        catch
        {
            return []
        }
    }
}
