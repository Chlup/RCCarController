//
//  DevicesListModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

protocol DevicesListModel {
    var devicesStream: Observable<[BTDevice]> { get }

    func start()
}

class DevicesListModelImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    let deps = Dependencies()

    init() { }
}

extension DevicesListModelImpl: DevicesListModel {
    var devicesStream: Observable<[BTDevice]> {
        return deps.btManager.devicesStream
            .map { $0.1 }
            .map { Array($0).sorted() }
    }

    func start() { deps.btManager.start() }
}
