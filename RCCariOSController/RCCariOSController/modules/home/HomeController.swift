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

    private var connectionStatus: BTConnectionStatus = .default

    lazy var items: [HomeItem] = {
        return [
            HomeItem(
                title: "Dashboard",
                enabledForBTStates: [.disconnected, .connected],
                action: { [weak self] in self?.viewModel.dashboardTapped() }
            ),
            HomeItem(title: "Car's position", enabledForBTStates: [.connected], action: { [weak self] in self?.viewModel.currentPositionTapped() }),
            HomeItem(
                title: "Status",
                enabledForBTStates: [.connected],
                action: { [weak self] in self?.viewModel.statusTapped() }
            )
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
        updateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToBTManager()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }

    func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let spacing: CGFloat = 10
        let width = collectionView.bounds.size.width / 5
        layout.itemSize = CGSize(width: width, height: 70)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func subscribeToBTManager() {
        deps.btManager.bluetoothConnectionStream
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] connectionStatus in
                    self?.updateRightBarButtonItem(device: connectionStatus.connectedDevice)
                    self?.updateUI(with: connectionStatus)
                }
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

    func updateUI(with connectionStatus: BTConnectionStatus) {
        self.connectionStatus = connectionStatus
        collectionView.reloadData()
    }

    @objc
    func showConnect() {
        viewModel.connectTapped()
    }
}

extension HomeController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if item.enabledForBTStates.contains(connectionStatus.state) {
            item.action()
        }
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

        if item.enabledForBTStates.contains(connectionStatus.state) {
            cell.title.textColor = .black
        } else {
            cell.title.textColor = .darkGray
        }

        return cell
    }
}
