//
//  MessageRepository.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

protocol MessageRepository {
    func getList(for chatID: String,
                 onNext: @escaping ([MessageType]) -> (),
                 onError: @escaping (AppError) -> ())

    func sendNewMessage(for chatID: String,
                        message: MessageType,
                        onNext: @escaping (MessageType) -> (),
                        onError: @escaping (AppError) -> ())
}

class MessageRepositoryImpl: MessageRepository {

    let dataStore: MessageDataStore
    let dataStoreAPI: MessageDataStore

    init(dataStore: MessageDataStore, dataStoreAPI: MessageDataStore) {
        self.dataStore = dataStore
        self.dataStoreAPI = dataStoreAPI
    }

    func getList(for chatID: String, onNext: @escaping ([MessageType]) -> (), onError: @escaping (AppError) -> ()) {
        self.dataStore.getList(for: chatID, onNext: { (messages) in
            onNext(messages)
        }) { (error) in
            self.dataStoreAPI.getList(for: chatID, onNext: { (messages) in
                onNext(messages)
            }, onError: { (error) in
                onError(error)
            })
        }
    }

    func sendNewMessage(for chatID: String, message: MessageType, onNext: @escaping (MessageType) -> (), onError: @escaping (AppError) -> ()) {
        //Post API
        self.dataStoreAPI.sendNewMessage(for: chatID, message: message, onNext: {_ in
            onNext(message)
            //Then store to local
            self.dataStore.sendNewMessage(for: chatID, message: message, onNext: { (message) in
                //Succeed to store to local
            }, onError: { (error) in
                //Failed to store locally...
            })
        }) { (error) in
            onError(error)
        }
    }
}
