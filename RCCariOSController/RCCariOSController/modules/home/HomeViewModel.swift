//
//  HomeViewModel.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

struct HomeFlow {
    let connectTapped: () -> Void
    let dashboardTapped: () -> Void
    let statusTapped: () -> Void
    let currentPositionTapped: () -> Void
    let gpsRecordingTapped: () -> Void
}

protocol HomeViewModel {
    func connectTapped()
    func dashboardTapped()
    func statusTapped()
    func currentPositionTapped()
    func gpsRecordingTapped()
}

class HomeViewModelImpl {

    let flow: HomeFlow

    init(flow: HomeFlow) {
        self.flow = flow
    }
}

extension HomeViewModelImpl: HomeViewModel {
    func connectTapped() { flow.connectTapped() }
    func dashboardTapped() { flow.dashboardTapped() }
    func statusTapped() { flow.statusTapped() }
    func currentPositionTapped() { flow.currentPositionTapped() }
    func gpsRecordingTapped() { flow.gpsRecordingTapped() }
}

