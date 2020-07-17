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
}

protocol HomeViewModel {
    func connectTapped()
    func dashboardTapped()
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
}

