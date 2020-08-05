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
    let deviceName: String?

    lazy var items: [HomeItem] = {
        return [
            HomeItem(title: "Dashboard", action: { [weak self] in self?.viewModel.dashboardTapped() }),
            HomeItem(title: "GPS recording", action: { [weak self] in self?.viewModel.gpsRecordingTapped() }),
            HomeItem(title: "Car's position", action: { [weak self] in self?.viewModel.currentPositionTapped() }),
            HomeItem(title: "Status", action: { [weak self] in self?.viewModel.statusTapped() })
        ]
    }()

    init(viewModel: HomeViewModel, deviceName: String?) {
        self.viewModel = viewModel
        self.deviceName = deviceName
        super.init(nibName: "HomeController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = deviceName
        collectionView.register(UINib(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: "HomeCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .done, target: self, action: #selector(disconnect))
        navigationItem.hidesBackButton = true
        updateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }

    func updateLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let spacing: CGFloat = 10
        let width = (collectionView.frame.size.width / 4) - 5 * spacing
        layout.itemSize = CGSize(width: width, height: 70)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }

    @objc
    func disconnect() {
        viewModel.disconnect()
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
