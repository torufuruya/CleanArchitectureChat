//
//  FollowerListBuilder.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

struct FollowerListBuilder {

    func build() -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowerList") as! FollowerListViewController

        let useCase = FollowerListUseCase(
            followerListRepository: FollowerListRepository(
                followerListDataStoreAPI: FollowerListDataStoreAPI()
            ),
            socialAccountAuthDataRepository: TwitterAccountRepository(
                dataStore: TwitterAccountDataStoreImpl(),
                dataStoreAPI: TwitterAccountDataStoreAPIImpl()
            )
        )
        let wireframe = FollowerListWireframeImpl()
        wireframe.viewController = viewController

        let presenter = FollowerListPresenter(useCase: useCase, view: viewController, wireframe: wireframe)

        viewController.inject(presenter: presenter)

        return viewController
    }
}
