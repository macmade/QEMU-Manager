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

public class ImageFormat: InfoValue
{
    public static var all: [ ImageFormat ] =
    {
        return [
            ImageFormat( name: "qcow2", title: "QCOW2 (KVM, Xen)", sorting: 0 ),
            ImageFormat( name: "qed",   title: "QED (KVM)",        sorting: 1 ),
            ImageFormat( name: "raw",   title: "Raw",              sorting: 2 ),
            ImageFormat( name: "vdi",   title: "VDI (VirtualBox)", sorting: 3 ),
            ImageFormat( name: "vpc",   title: "VHD (Hyper-V)",    sorting: 4 ),
            ImageFormat( name: "vmdk",  title: "VMDK (VMware)",    sorting: 5 ),
        ]
    }()
}
