//
//  FollowerListUseCase.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol FollowerListUseCaseProtocol {
    func getFollowerList(onNext: @escaping ([User]) -> (),
                         onError: @escaping (AppError) -> ())

    func getAccount(onNext: @escaping (Account) -> (),
                    onError: @escaping (AppError) -> ())
}

class FollowerListUseCase: FollowerListUseCaseProtocol {

    let followerListRepository: FollowerListRepositoryProtocol
    let socialAccountRepository: SocialAccountRepository

    init(followerListRepository: FollowerListRepositoryProtocol,
         socialAccountAuthDataRepository: SocialAccountRepository) {
        self.followerListRepository = followerListRepository;
        self.socialAccountRepository = socialAccountAuthDataRepository
    }

    func getFollowerList(onNext: @escaping ([User]) -> (), onError: @escaping (AppError) -> ()) {
        self.socialAccountRepository.getAccountData(onNext: { (account) in
            self.followerListRepository.getList(account: account, onNext: onNext, onError: onError)
        }) { (error) in
            onError(error)
        }
    }

    func getAccount(onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        self.socialAccountRepository.getAccountData(onNext: onNext, onError: onError)
    }

}
