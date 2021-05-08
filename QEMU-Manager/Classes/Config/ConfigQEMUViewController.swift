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

public class ConfigQEMUViewController: ConfigViewController, NSTableViewDataSource
{
    private static let pasteboardType = NSPasteboard.PasteboardType( rawValue: "qemu.argument" )
    
    @IBOutlet private var arguments: NSArrayController!
    @IBOutlet private var tableView: NSTableView!
    
    @objc private dynamic var vm: VirtualMachine
    
    public init( vm: VirtualMachine, sorting: Int )
    {
        self.vm = vm
        
        super.init( title: "QEMU", icon: NSImage( named: "TerminalTemplate" ), sorting: sorting )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    deinit
    {
        if let args = self.arguments.content as? [ Argument ]
        {
            args.forEach { $0.removeObserver( self, forKeyPath: "value" ) }
        }
    }
    
    public override var nibName: NSNib.Name?
    {
        "ConfigQEMUViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let args = self.vm.config.arguments.map { Argument( value: $0 ) }
        
        self.arguments.add( contentsOf: args )
        args.forEach { $0.addObserver( self, forKeyPath: "value", options: .new, context: nil ) }
        
        self.tableView.registerForDraggedTypes( [ ConfigQEMUViewController.pasteboardType ] )
    }
    
    @IBAction private func addRemoveArgument( _ sender: Any? )
    {
        guard let button = sender as? NSSegmentedControl else
        {
            NSSound.beep()
            
            return
        }
        
        switch button.selectedSegment
        {
            case 0:  self.addArgument( sender )
            case 1:  self.removeArgument( sender )
            default: NSSound.beep()
        }
    }
    
    @IBAction private func addArgument( _ sender: Any? )
    {
        let arg = Argument()
        
        arg.addObserver( self, forKeyPath: "value", options: .new, context: nil )
        self.arguments.addObject( arg )
        self.save()
    }
    
    @IBAction private func removeArgument( _ sender: Any? )
    {
        guard let arg = self.arguments.selectedObjects.first as? Argument else
        {
            NSSound.beep()
            
            return
        }
        
        arg.removeObserver( self, forKeyPath: "value" )
        self.arguments.remove( arg )
        self.save()
    }
    
    private func save()
    {
        let args = self.arguments.content as? [ Argument ] ?? []
        
        self.vm.config.arguments = args.map { $0.value }
    }
    
    public override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey : Any ]?, context: UnsafeMutableRawPointer? )
    {
        if let _ = object as? Argument, keyPath == "value"
        {
            self.save()
        }
        else
        {
            super.observeValue( forKeyPath: keyPath, of: object, change: change, context: context )
        }
    }
    
    public func tableView( _ tableView: NSTableView, pasteboardWriterForRow row: Int ) -> NSPasteboardWriting?
    {
        guard let arranged = self.arguments.arrangedObjects as? [ Argument ] else
        {
            return nil
        }
        
        if row < 0 || row >= arranged.count
        {
            return nil
        }
        
        let item = NSPasteboardItem()
        
        item.setPropertyList( row, forType: ConfigQEMUViewController.pasteboardType )
        
        return item
    }
    
    public func tableView( _ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation ) -> NSDragOperation
    {
        if dropOperation == .above
        {
            return .move
        }
        else
        {
            return []
        }
    }
    
    public func tableView( _ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool
    {
        guard let item     = info.draggingPasteboard.pasteboardItems?.first,
              let moved    = item.propertyList( forType: ConfigQEMUViewController.pasteboardType ) as? Int,
              let arranged = self.arguments.arrangedObjects as? [ Argument ]
        else
        {
            return false
        }
        
        if moved < 0 || moved >= arranged.count
        {
            return false
        }
        
        let new = moved < row ? row - 1 : row
        let arg = arranged[ moved ]
        
        self.arguments.remove( atArrangedObjectIndex: moved )
        self.arguments.insert( arg, atArrangedObjectIndex: new )
        
        return true
    }
}
