//
//  SocialAccountRepository.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol SocialAccountRepository {
    func getAccountData(onNext: @escaping (Account) -> (),
                        onError: @escaping (AppError) -> ())
}
