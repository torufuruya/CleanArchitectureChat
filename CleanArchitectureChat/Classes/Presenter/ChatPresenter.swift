//
//  ChatPresenter.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol ChatPresenter {
    func loadConversation(chatID: String,
                          onNext: @escaping ([MessageType]) -> (),
                          onError: @escaping (AppError) -> ())

    func sendMessage(for chatID: String,
                     message: MessageType,
                     onNext: @escaping (MessageType) -> (),
                     onError: @escaping (AppError) -> ())
}

class ChatPresenterImpl: ChatPresenter {

    let chatUseCase: ChatUseCase

    init(chatUseCase: ChatUseCase) {
        self.chatUseCase = chatUseCase
    }

    func loadConversation(chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ()) {
        self.chatUseCase.getMessageList(for: chatID, onNext: onNext, onError: onError)
    }

    func sendMessage(for chatID: String, message: MessageType, onNext: @escaping (MessageType) -> (), onError: @escaping (AppError) -> ()) {
        self.chatUseCase.sendNewMessage(for: chatID, message: message, onNext: onNext, onError: onError)
    }

}
