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

class StatusController: UIViewController {

    let viewModel: StatusViewModel
    var bag = DisposeBag()

    private var status: Statuses = []
    private var hdop: Int16 = 0

    lazy var items: [StatusItem] = {
        return [
            StatusItem(title: "GPS has valid data", mask: .gpsHasValidData, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "Error reading GPS data", mask: .errorReadingGPSData, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "HDOP", mask: [], okIfEnabled: true, isHDOP: true),
            StatusItem(title: "Accelerator setup error", mask: .accelerometerSetupError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "Accelerator read error", mask: .accelerometerReadError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "Storage setup error", mask: .storageSetupError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "Should Start GPS recording", mask: .shouldStartGPSSession, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "GPS recording in progress", mask: .gpsSessionInProgress, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "Store GPS data Error", mask: .storeGPSDataError, okIfEnabled: false, isHDOP: false)
        ]
    }()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var loader: UIActivityIndicatorView!

    init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "StatusController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "System status"
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        collectionView.register(UINib(nibName: "StatusCell", bundle: nil), forCellWithReuseIdentifier: "StatusCell")
        updateLayout()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }

    @objc
    private func close() {
        viewModel.closeTapped()
    }

    func subscribedToViewModel() {
        viewModel.statusStream
            .drive(
                onNext: { [weak self] statusData in self?.updateUI(with: statusData) }
            )
            .disposed(by: bag)
    }

    func updateUI(with statusData: StatusData) {
        switch statusData {
        case .loading:
            loader.startAnimating()
            collectionView.isHidden = true

        case let .loaded(status, hdop):
            loader.stopAnimating()
            collectionView.isHidden = false
            self.status = status
            self.hdop = hdop
            collectionView.reloadData()
        }
    }

    func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let spacing: CGFloat = 10
        layout.itemSize = CGSize(width: (collectionView.frame.size.width / 4) - 5 * spacing, height: 60)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}

extension StatusController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension StatusController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCell", for: indexPath) as! StatusCell
        let item = items[indexPath.row]

        cell.title.text = item.title

        if item.isHDOP {
            let postfix: String
            let color: UIColor
            switch hdop {
            case 0:
                postfix = ""
                color = .red

            case 1...100:
                postfix = "Best"
                color = .green

            case 101...200:
                postfix = "Still great"
                color = .green

            case 201...500:
                postfix = "Good"
                color = .yellow

            case 501...1000:
                postfix = "Moderate"
                color = .orange

            case 1001...2000:
                postfix = "Fair"
                color = .orange

            default:
                postfix = "Poor"
                color = .red
            }

            let hdop = Double(self.hdop) / 100
            cell.title.text = "HDOP(\(hdop)) \(postfix)"
            cell.contentView.backgroundColor = color

        } else {
            var hasMask = status.contains(item.mask)
            hasMask = item.okIfEnabled ? hasMask : !hasMask

            if hasMask {
                cell.contentView.backgroundColor = .green
            } else {
                cell.contentView.backgroundColor = .red
            }
        }

        return cell
    }
}
