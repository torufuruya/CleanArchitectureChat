//
//  User.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol UserID {
    var userID: String { get set }
    var screenName: String { get set }
}

struct User: UserID {
    var userID: String
    var screenName: String
    var name: String
    var profileImageUrl: String
    var userDescription: String

    var symbolicName: String {
        get {
            return "@\(screenName)"
        }
    }
}

struct SerializeKeyAccount {
    static let userID = "SerializeKey.userID"
    static let screenName = "SerializeKey.screenName"
    static let auth = "SerializeKey.auth"
}

class Account: NSObject, NSCoding, UserID {
    var userID: String
    var screenName: String
    var auth: SocialAccountAuthData

    init(userID: String, screenName: String, auth: SocialAccountAuthData) {
        self.userID = userID
        self.screenName = screenName
        self.auth = auth
    }

    required init?(coder aDecoder: NSCoder) {
        self.userID = aDecoder.decodeObject(forKey: SerializeKeyAccount.userID) as! String
        self.screenName = aDecoder.decodeObject(forKey: SerializeKeyAccount.screenName) as! String
        self.auth = aDecoder.decodeObject(forKey: SerializeKeyAccount.auth) as! SocialAccountAuthData
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userID, forKey: SerializeKeyAccount.userID)
        aCoder.encode(self.screenName, forKey: SerializeKeyAccount.screenName)
        aCoder.encode(self.auth, forKey: SerializeKeyAccount.auth)
    }

}
