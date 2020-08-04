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

struct CurrentPositionFlow {
    let close: () -> Void
}

protocol CurrentPositionViewModel {
    var coordinatesStream: Driver<Coordinates> { get }

    func closeTapped()

    func start()
    func stop()
}

class CurrentPositionViewModelImpl {

    let model: CurrentPositionModel
    let flow: CurrentPositionFlow

    init(model: CurrentPositionModel, flow: CurrentPositionFlow) {
        self.model = model
        self.flow = flow
    }
}

extension CurrentPositionViewModelImpl: CurrentPositionViewModel {
    var coordinatesStream: Driver<Coordinates> {
        return model.coordinatesStream
            .asDriver(onErrorJustReturn: Coordinates(lon: 0, lat: 0))
            .throttle(.milliseconds(300))
    }

    func closeTapped() { flow.close() }
    
    func start() { model.start() }
    func stop() { model.stop() }
}
