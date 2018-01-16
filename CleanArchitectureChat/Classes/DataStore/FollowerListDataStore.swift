//
//  FollowerListDataStore.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol FollowerListDataStoreProtocol {
    func getFollowersList(account: Account,
                          onNext: @escaping ([User]) -> (),
                          onError: @escaping (AppError) -> ())
}

class FollowerListDataStoreAPI: FollowerListDataStoreProtocol {

    let manager = TwitterRequestManager()

    func getFollowersList(account: Account, onNext: @escaping ([User]) -> (), onError: @escaping (AppError) -> ()) {
        self.manager.getFollowersList(account: account, onNext: onNext, onError: onError)
    }
}
