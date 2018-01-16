//
//  TwitterAccountRepository.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit
import CommonCrypto

class TwitterAccountRepository: SocialAccountRepository {

    let dataStore: TwitterAccountDataStore
    let dataStoreAPI: TwitterAccountDataStore

    init(dataStore: TwitterAccountDataStore,
         dataStoreAPI: TwitterAccountDataStore) {
        self.dataStore = dataStore
        self.dataStoreAPI = dataStoreAPI
    }

    func getAccountData(onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        self.dataStore.getAccountData(onNext: { (account) in
            onNext(account)
        }) { (error) in
            self.dataStoreAPI.getAccountData(onNext: { (account) in
                onNext(account)
                if (!self.dataStore.updateAccountData(account: account)) {
                    print("Failed to store auth data to local storage.")
                }
            }, onError: onError)
        }
    }

}
