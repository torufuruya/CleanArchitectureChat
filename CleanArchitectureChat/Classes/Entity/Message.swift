//
//  Message.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

enum MessageData {
    case text(String)
    case photo(UIImage)

    var text: String? {
        get {
            switch self {
            case .text(let text):
                return text
            default:
                return nil
            }
        }
    }
}

protocol MessageType {
    var sender: UserID { get set }
    var data: MessageData { get set }
    var isMine: Bool { get set }
}

struct Message: MessageType {
    var sender: UserID
    var data: MessageData
    var isMine: Bool
}
