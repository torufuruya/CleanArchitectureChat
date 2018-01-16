//
//  ChatBuilder.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

class ChatBuilder: NSObject {
    private let user: User
    private let account: Account

    init(user: User, account: Account) {
        self.user = user
        self.account = account
    }

    func build() -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Chat") as! ChatViewController

        let presenter = ChatPresenterImpl(
            chatUseCase: ChatUseCaseImpl(
                repository: MessageRepositoryImpl(
                    dataStore: MessageDataStoreImpl(),
                    dataStoreAPI: MessageDataStoreAPIImpl()
                )
            )
        )

        viewController.inject(presenter: presenter)
        viewController.user = self.user
        viewController.account = self.account

        return viewController
    }

}
