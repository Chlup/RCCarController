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

    private var data = StatusData(status: [], hdop: 0)

    lazy var items: [StatusItem] = {
        return [
            StatusItem(title: "Accelerator setup error", mask: .accelerometerSetupError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "Accelerator read error", mask: .accelerometerReadError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "Storage setup error", mask: .storageSetupError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "GPS valid data", mask: .gpsHasValidData, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "Should Start GPS Sessions", mask: .shouldStartGPSSession, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "GPS session in progress", mask: .gpsSessionInProgress, okIfEnabled: true, isHDOP: false),
            StatusItem(title: "Store GPS Data Error", mask: .storeGPSDataError, okIfEnabled: false, isHDOP: false),
            StatusItem(title: "HDOP", mask: [], okIfEnabled: true, isHDOP: true)
        ]
    }()
    
    @IBOutlet var collectionView: UICollectionView!

    init(viewModel: StatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "StatusController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func subscribedToViewModel() {
        viewModel.statusStream
            .debug()
            .drive(
                onNext: { [weak self] statusData in self?.updateUI(with: statusData) }
            )
            .disposed(by: bag)
    }

    func updateUI(with statusData: StatusData) {
        data = statusData
        collectionView.reloadData()
    }

    func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let spacing: CGFloat = 10
        layout.itemSize = CGSize(width: (collectionView.frame.size.width / 3) - 2 * spacing, height: 60)
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
            switch data.hdop {
            case 0...100:
                postfix = "Ideal"
                color = .green

            case 101...200:
                postfix = "Excelent"
                color = .yellow

            case 201...500:
                postfix = "Good"
                color = .orange

            case 501...1000:
                postfix = "Moderate"
                color = .orange

            case 1001...2000:
                postfix = "Fair"
                color = .red

            default:
                postfix = "Poor"
                color = .red
            }

            let hdop = Double(data.hdop) / 100
            cell.title.text = "HDOP(\(hdop)) \(postfix)"
            cell.contentView.backgroundColor = color

        } else {
            var hasMask = data.status.contains(item.mask)
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
