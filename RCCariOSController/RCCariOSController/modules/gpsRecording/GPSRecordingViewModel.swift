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

struct GPSRecordingFlow {
    let close: () -> Void
}

protocol GPSRecordingViewModel {
    var statusStream: Driver<GPSRecordingStatus> { get }

    func closeTapped()

    func start()
    func stop()

    func startGPSRecording()
    func stopGPSRecording()
}

class GPSRecordingViewModelImpl {

    let model: GPSRecordingModel
    let flow: GPSRecordingFlow

    init(model: GPSRecordingModel, flow: GPSRecordingFlow) {
        self.model = model
        self.flow = flow
    }
}

extension GPSRecordingViewModelImpl: GPSRecordingViewModel {
    var statusStream: Driver<GPSRecordingStatus> {
        return model.statusStream
            .asDriver(onErrorJustReturn: GPSRecordingStatus(requested: false, inProgress: false))
    }

    func closeTapped() { flow.close() }

    func start() { model.start() }
    func stop() { model.stop() }
    
    func startGPSRecording() { model.startGPSRecording() }
    func stopGPSRecording() { model.stopGPSRecording() }
}
