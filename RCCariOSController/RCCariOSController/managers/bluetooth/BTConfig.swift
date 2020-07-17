//
//  BTConfig.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

struct BTConfig: OptionSet {
    typealias RawValue = Int32
    let rawValue: Int32
    static let sendAccelerometerData = BTConfig(rawValue: 1 << 0)

    var data: Data {
        var value = rawValue
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}
