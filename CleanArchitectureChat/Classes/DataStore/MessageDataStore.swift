//
//  MessageDataStore.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import Foundation

protocol MessageDataStore {
    func getList(for chatID: String,
                 onNext: @escaping ([MessageType]) -> (),
                 onError: @escaping (AppError) -> ())


    func sendNewMessage(for chatID: String,
                        message: MessageType,
                        onNext: @escaping (MessageType) -> (),
                        onError: @escaping (AppError) -> ())
}

class MessageDataStoreImpl: MessageDataStore {

    func getList(for chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ()) {
        //Get from local storage e.g. file system
        //mock
        var messages: [MessageType] = []
        for _ in 0..<10 {
            let isMine: Bool = (arc4random() % 2 == 0) ? true : false
            let sender = User(userID: "userID", screenName: "screen name", name: "name", profileImageUrl: "", userDescription: "user description")
            let message = Message(sender: sender, data: MessageData.text(self.getRandomMessage()), isMine: isMine)
            messages.append(message)
        }
        onNext(messages)
    }

    func sendNewMessage(for chatID: String, message: MessageType, onNext: @escaping (MessageType) -> (), onError: @escaping (AppError) -> ()) {
        //store local
    }

}

class MessageDataStoreAPIImpl: MessageDataStore {

    func getList(for chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ()) {
        //Get from API
        onError(AppError.generic)
    }

    func sendNewMessage(for chatID: String, message: MessageType, onNext: @escaping (MessageType) -> (), onError: @escaping (AppError) -> ()) {
        //mock
        DispatchQueue.global().async {
            onNext(message)
        }
    }

}

private extension MessageDataStoreImpl {
    func getRandomMessage() -> String {
        let letters: NSString = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789あいうえおかきくけこさしすせそなにぬねのはひふへほまみむめもらりるれろわをん"
        let len = UInt32(letters.length)
        var randomString: String = ""

        let finish = arc4random_uniform(100) + 1
        for _ in 0..<finish {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
