//
//  InlinationView.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit

class InclinationView: UIView {
    @IBOutlet var image: UIImageView!
    @IBOutlet var container: UIView!
    @IBOutlet var currentAngle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }

    func updateUI() {
        container.layer.cornerRadius = container.bounds.size.width / 2.0
        container.layer.masksToBounds = true
    }
}
