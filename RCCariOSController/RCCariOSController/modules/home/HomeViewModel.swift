//
//  HomeViewModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

struct HomeFlow {
    let dashboardTapped: () -> Void
    let statusTapped: () -> Void
    let currentPositionTapped: () -> Void
    let gpsRecordingTapped: () -> Void
}

protocol HomeViewModel {
    func disconnect()
    func dashboardTapped()
    func statusTapped()
    func currentPositionTapped()
    func gpsRecordingTapped()
}

class HomeViewModelImpl {

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    let flow: HomeFlow
    private let deps = Dependencies()

    init(flow: HomeFlow) {
        self.flow = flow
    }
}

extension HomeViewModelImpl: HomeViewModel {
    func disconnect() { deps.btManager.disconnect() }
    func dashboardTapped() { flow.dashboardTapped() }
    func statusTapped() { flow.statusTapped() }
    func currentPositionTapped() { flow.currentPositionTapped() }
    func gpsRecordingTapped() { flow.gpsRecordingTapped() }
}

