//
//  DashboardController.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 17/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DashboardController: UIViewController {

    let viewModel: DashboardViewModel
    var bag = DisposeBag()

    var xInclinationView: InclinationView!
    var yInclinationView: InclinationView!

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "DashboardController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Dashboard"

        xInclinationView = Bundle.main.loadNibNamed("InclinationView", owner: self, options: nil)![0] as! InclinationView
        xInclinationView.image.image = UIImage(named: "car_rear")
        view.addSubview(xInclinationView)
        NSLayoutConstraint.activate(
            [
                xInclinationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                xInclinationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                xInclinationView.widthAnchor.constraint(equalToConstant: 300),
                xInclinationView.heightAnchor.constraint(equalToConstant: 300)
            ]
        )

        yInclinationView = Bundle.main.loadNibNamed("InclinationView", owner: self, options: nil)![0] as! InclinationView
        yInclinationView.image.image = UIImage(named: "car_side")
        view.addSubview(yInclinationView)
        NSLayoutConstraint.activate(
            [
                yInclinationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
                yInclinationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                yInclinationView.widthAnchor.constraint(equalToConstant: 300),
                yInclinationView.heightAnchor.constraint(equalToConstant: 300)
            ]
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
        subscribeToViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
        bag = DisposeBag()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        xInclinationView.updateUI()
        yInclinationView.updateUI()
    }

    func subscribeToViewModel() {
        viewModel.accelerometerDataStream
            .drive(
                onNext: { [weak self] angleX, angleY in
                    guard let self = self else { return }
                    self.update(inclinationView: self.xInclinationView, angle: angleX)
                    self.update(inclinationView: self.yInclinationView, angle: angleY)
                }
            )
            .disposed(by: bag)
    }

    func update(inclinationView: InclinationView, angle: Int) {
        inclinationView.container.transform = CGAffineTransform(rotationAngle: deg2rad(number: CGFloat(angle)))
        inclinationView.currentAngle.text = "\(angle)"
    }

    func deg2rad(number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
