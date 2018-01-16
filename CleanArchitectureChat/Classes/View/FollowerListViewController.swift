//
//  FollowerListViewController.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol FollowerListViewProtocol: class {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func reloadWithFollowers(followers: [User])
    func reloadWithoutFollowers()
}

class FollowerListViewController: UIViewController {

    var presenter: FollowerListPresenterProtocol?

    @IBOutlet weak var tableView: UITableView!
    let loadingIndicator = UIActivityIndicatorView()
    var followers: [User] = []

    public func inject(presenter: FollowerListPresenterProtocol) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Follower List"

        self.loadingIndicator.color = .blue
        self.view.addSubview(self.loadingIndicator)

        self.presenter?.loadFollowerList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension FollowerListViewController: FollowerListViewProtocol {

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.loadingIndicator)
            self.loadingIndicator.center = self.view.center
            self.loadingIndicator.startAnimating()
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }

    func reloadWithFollowers(followers: [User]) {
        self.followers = followers
        self.tableView.reloadData()
    }

    func reloadWithoutFollowers() {
        self.followers = []
        self.tableView.reloadData()
    }

}

extension FollowerListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let follower = self.followers[indexPath.row]
        self.presenter?.selectFollower(user: follower)
    }
}

extension FollowerListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerListViewCell", for: indexPath) as! FollowerListViewCell

        let follower: User = self.followers[indexPath.row]
        cell.updateCell(follower)

        return cell
    }
}
