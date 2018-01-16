//
//  FollowerListWireframe.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol FollowerListWireframe {
    weak var viewController: FollowerListViewController? { get set }
    func showChat(with user: User, and account: Account)
}

class FollowerListWireframeImpl: FollowerListWireframe {
    weak var viewController: FollowerListViewController?

    func showChat(with user: User, and account: Account) {
        let nextViewController = ChatBuilder(user: user, account: account).build()
        viewController?.navigationController?.pushViewController(nextViewController, animated: true)
    }

}
