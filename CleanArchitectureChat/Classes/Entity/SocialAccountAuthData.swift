//
//  SocialAccountAuthData.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

struct SerializeKeyAuth {
    static let accessToken = "SerializeKey.accessToken"
    static let accessTokenSecret = "SerializeKey.accessTokenSecret"
}

class SocialAccountAuthData: NSObject, NSCoding  {
    let accessToken: String
    let accessTokenSecret: String

    init(accessToken: String, accessTokenSecret: String) {
        self.accessToken = accessToken;
        self.accessTokenSecret = accessTokenSecret
    }

    required init?(coder aDecoder: NSCoder) {
        self.accessToken = aDecoder.decodeObject(forKey: SerializeKeyAuth.accessToken) as! String
        self.accessTokenSecret = aDecoder.decodeObject(forKey: SerializeKeyAuth.accessTokenSecret) as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.accessToken, forKey: SerializeKeyAuth.accessToken)
        aCoder.encode(self.accessTokenSecret, forKey: SerializeKeyAuth.accessTokenSecret)
    }

}
