//
//  FollowerListRepository.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit
import CommonCrypto

protocol FollowerListRepositoryProtocol {
    func getList(account: Account,
                 onNext: @escaping ([User]) -> (),
                 onError: @escaping (AppError) -> ())
}

class FollowerListRepository: FollowerListRepositoryProtocol {

    let followerListDataStoreAPI: FollowerListDataStoreProtocol

    init(followerListDataStoreAPI: FollowerListDataStoreProtocol) {
        self.followerListDataStoreAPI = followerListDataStoreAPI
    }

    func getList(account: Account, onNext: @escaping ([User]) -> (), onError: @escaping (AppError) -> ()) {
        //API only
        self.followerListDataStoreAPI.getFollowersList(account: account, onNext: onNext, onError: onError)
    }
}
