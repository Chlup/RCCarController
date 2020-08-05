//
//  StatusController.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import MapKit

class GPSRecordingController: UIViewController {

    let viewModel: GPSRecordingViewModel
    var bag = DisposeBag()

    var status = GPSRecordingStatus(requested: false, inProgress: false)

    @IBOutlet var button: UIButton!

    init(viewModel: GPSRecordingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "GPSRecordingController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "GPS Recording"
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        updateUI(with: GPSRecordingStatus(requested: false, inProgress: false))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribedToViewModel()
        viewModel.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stop()
        bag = DisposeBag()
    }

    @objc
    private func close() {
        viewModel.closeTapped()
    }

    @IBAction func buttonTap() {
        if status.inProgress {
            let alert = UIAlertController(title: "", message: "Do you really want to stop GPS recording?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in self?.viewModel.stopGPSRecording() }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in }))
            present(alert, animated: true, completion: nil)
        } else {
            viewModel.startGPSRecording()
        }
    }

    func subscribedToViewModel() {
        viewModel.statusStream
            .debug()
            .drive(
                onNext: { [weak self] status in self?.updateUI(with: status) }
            )
            .disposed(by: bag)
    }

    func updateUI(with status: GPSRecordingStatus) {
        self.status = status
        switch (status.requested, status.inProgress) {
        case (false, false):
            button.isEnabled = true
            button.backgroundColor = .green
            button.setTitle("Start recording", for: .normal)

        case (true, false):
            button.isEnabled = false
            button.backgroundColor = .gray
            button.setTitle("Recording starting", for: .normal)

        case (_, true):
            button.isEnabled = true
            button.backgroundColor = .red
            button.setTitle("Stop recording", for: .normal)
        }

        button.setTitleColor(.black, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.size.width / 2.0
    }
}
