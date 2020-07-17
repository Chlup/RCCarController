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

    @IBOutlet var xRotationImage: UIImageView!
    @IBOutlet var yRotationImage: UIImageView!

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

    func subscribeToViewModel() {
        viewModel.accelerometerDataStream
            .drive(
                onNext: { [weak self] angleX, angleY in
                    guard let self = self else { return }
                    self.update(imageView: self.xRotationImage, angle: angleX)
                    self.update(imageView: self.yRotationImage, angle: angleY)
                }
            )
            .disposed(by: bag)
    }

    func update(imageView: UIImageView, angle: Int) {
        imageView.transform = CGAffineTransform(rotationAngle: deg2rad(number: CGFloat(angle)))
    }

    func deg2rad(number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
}
