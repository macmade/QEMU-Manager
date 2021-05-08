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

extension QEMU.System
{
    public static func start( vm: VirtualMachine ) throws
    {
        var arguments: [ String ] = []
        
        arguments.append( "-m" )
        arguments.append( SizeFormatter().string( from: NSNumber( value: vm.config.memory ), style: .qemu ) )
        
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
        
        if vm.config.cores > 0
        {
            arguments.append( "-smp" )
            arguments.append( "\( vm.config.cores )" )
        }
        else
        {
            arguments.append( "-smp" )
            arguments.append( "1" )
        }
        
        var boot = vm.config.boot
        
        if let cd = vm.config.cdImage, FileManager.default.fileExists( atPath: cd.path )
        {
            arguments.append( "-drive" )
            arguments.append( "file=\( cd.path ),format=raw,media=cdrom" )
        }
        else if boot == "d"
        {
            boot = "c"
        }
        
        arguments.append( "-boot" )
        arguments.append( boot )
            
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
