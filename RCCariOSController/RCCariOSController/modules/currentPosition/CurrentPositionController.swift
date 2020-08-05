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

class CurrentPositionController: UIViewController {

    let viewModel: CurrentPositionViewModel
    var bag = DisposeBag()

    @IBOutlet var map: MKMapView!

    let locationManager: CLLocationManager

    init(viewModel: CurrentPositionViewModel) {
        self.viewModel = viewModel
        locationManager = CLLocationManager()
        super.init(nibName: "CurrentPositionController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Car's position"
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        locationManager.requestWhenInUseAuthorization()
        map.showsUserLocation = true
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

    func subscribedToViewModel() {
        viewModel.coordinatesStream
            .debug()
            .drive(
                onNext: { [weak self] coordinates in self?.updateUI(with: coordinates) }
            )
            .disposed(by: bag)
    }

    func updateUI(with coordinates: Coordinates) {
        map.removeAnnotations(map.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)
        map.addAnnotation(annotation)
    }
}
