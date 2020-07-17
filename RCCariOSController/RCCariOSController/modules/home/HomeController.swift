//
//  ViewController.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 12/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import UIKit
import RxSwift

class HomeController: UIViewController {

    struct Dependencies {
        let btManager = DI.getBTManager()
    }

    @IBOutlet var collectionView: UICollectionView!

    let deps = Dependencies()
    var bag = DisposeBag()
    let viewModel: HomeViewModel

    lazy var items: [HomeItem] = {
        return [
            HomeItem(title: "Dashboard", action: { [weak self] in self?.viewModel.dashboardTapped() }),
            HomeItem(title: "gps", action: { }),
            HomeItem(title: "settings", action: { }),
        ]
    }()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        collectionView.register(UINib(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: "HomeCell")
        updateRightBarButtonItem(device: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToBTManager()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func subscribeToBTManager() {
        deps.btManager.devicesStream
            .map { $0.0 }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] connectedDevice in self?.updateRightBarButtonItem(device: connectedDevice) }
            )
            .disposed(by: bag)
    }

    func updateRightBarButtonItem(device: BTDevice?) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: device == nil ? "Device" : device?.name,
            style: .plain,
            target: self,
            action: #selector(showConnect)
        )
    }

    @objc
    func showConnect() {
        viewModel.connectTapped()
    }
}

extension HomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        items[indexPath.row].action()
    }
}

extension HomeController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let item = items[indexPath.row]

        cell.title.text = item.title

        return cell
    }
}
