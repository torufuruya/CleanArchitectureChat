//
//  FollowerListPresenter.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol FollowerListPresenterProtocol {
    func loadFollowerList()
    func selectFollower(user: User)
}

class FollowerListPresenter: FollowerListPresenterProtocol {

    weak var view: FollowerListViewProtocol?
    let useCase: FollowerListUseCaseProtocol
    let wireframe: FollowerListWireframe

    init(useCase: FollowerListUseCaseProtocol, view: FollowerListViewProtocol, wireframe: FollowerListWireframe) {
        self.useCase = useCase
        self.view = view
        self.wireframe = wireframe
    }

    func loadFollowerList() {
        self.view?.showLoadingIndicator()
        self.useCase.getFollowerList(onNext: { (followers) in
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                self.view?.reloadWithFollowers(followers: followers)
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                self.view?.reloadWithoutFollowers()
            }
            self.errorHandling(error)
        }
    }

    func selectFollower(user: User) {
        self.useCase.getAccount(onNext: { (account) in
            self.wireframe.showChat(with: user, and: account)
        }) { (error) in
            self.errorHandling(error)
        }
    }

    func errorHandling(_ error: AppError) {
        //TODO
    }

}
