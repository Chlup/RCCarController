//
//  DeviceCell.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit

class DeviceCell: UITableViewCell {

    struct Flow {
        let buttonTap: (BTDevice) -> Void
    }

    @IBOutlet var title: UILabel!
    @IBOutlet var button: UIButton!

    var device: BTDevice?
    var flow: Flow?

    @IBAction func buttonTap() {
        guard let device = self.device else { return }
        flow?.buttonTap(device)
    }
}
