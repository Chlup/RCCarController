//
//  DevicesListController.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DevicesListController: UIViewController {

    let viewModel: DevicesListViewModel
    var bag = DisposeBag()

    var devices: [BTDevice] = []

    @IBOutlet var table: UITableView!

    init(viewModel: DevicesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "DevicesListController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCell")
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        navigationItem.title = "Devices"
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToViewModel()
        viewModel.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bag = DisposeBag()
    }

    @objc
    private func close() {
        viewModel.close()
    }

    @objc
    private func refresh() {
        viewModel.tapOnRefresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.table.refreshControl?.endRefreshing() }
    }

    private func subscribeToViewModel() {
        viewModel.devicesStream
            .drive(onNext: { [weak self] devices in self?.updateUI(with: devices) })
            .disposed(by: bag)
    }

    private func updateUI(with devices: [BTDevice]) {
        self.devices = devices
        table.reloadData()
    }
}

extension DevicesListController: UITableViewDelegate {
}

extension DevicesListController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        let device = devices[indexPath.row]
        cell.title.text = "\(device.name)\n\(device.identifier)"
        cell.button.setTitle(device.isConnected ? "Disconnect" : "Connect", for: .normal)

        let flow = DeviceCell.Flow(
            buttonTap: { [weak self] device in
                self?.viewModel.tapOnConnectButton(with: device)
                self?.table.reloadData()
            }
        )
        cell.flow = flow
        cell.device = device

        return cell
    }
}
