//
//  ChatUseCase.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import Foundation

protocol ChatUseCase {
    func getMessageList(for chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ())

    func sendNewMessage(for chatID: String,
                        message: MessageType,
                        onNext: @escaping (MessageType) -> (),
                        onError: @escaping (AppError) -> ())
}

class ChatUseCaseImpl: ChatUseCase {

    let repository: MessageRepository

    init(repository: MessageRepository) {
        self.repository = repository
    }

    func getMessageList(for chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ()) {
        self.repository.getList(for: chatID, onNext: { (messages) in
            onNext(messages)
        }) { (error) in
            onError(error)
        }
    }

    func sendNewMessage(for chatID: String, message: MessageType, onNext: @escaping (MessageType) -> (), onError: @escaping (AppError) -> ()) {
        self.repository.sendNewMessage(for: chatID, message: message, onNext: onNext, onError: onError)

        //Dummy Specification:
        //The follower echoes a message sent by the user after a second.
        //The follower’s echo text repeats the user’s message twice, e.g. echo “Hi. Hi.” for message “Hi.”
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            var message = message
            message.data = MessageData.text("\(message.data.text!) \(message.data.text!)")
            message.isMine = false
            onNext(message)
        }
    }

}

