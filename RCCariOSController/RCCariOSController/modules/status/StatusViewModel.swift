//
//  StatusViewModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct StatusFlow {
    let close: () -> Void
}

protocol StatusViewModel {
    var statusStream: Driver<StatusData> { get }

    func closeTapped()

    func start()
    func stop()
}

class StatusViewModelImpl {

    let model: StatusModel
    let flow: StatusFlow

    init(model: StatusModel, flow: StatusFlow) {
        self.model = model
        self.flow = flow
    }
}

extension StatusViewModelImpl: StatusViewModel {
    var statusStream: Driver<StatusData> {
        return model.statusStream.asDriver(onErrorJustReturn: .loading)
    }

    func closeTapped() { flow.close() }
    
    func start() { model.start() }
    func stop() { model.stop() }
}
