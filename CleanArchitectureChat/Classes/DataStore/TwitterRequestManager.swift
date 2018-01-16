//
//  TwitterRequestManager.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit
import CommonCrypto

protocol TwitterRequestManagerProtocol {
    func requestToken(onNext: @escaping (URL) -> (),
                      onError: @escaping (AppError) -> ())

    func getAccessToken(callbackURL: URL,
                        onNext: @escaping (Account) -> (),
                        onError: @escaping (AppError) -> ())

    func getFollowersList(account: Account,
                          onNext: @escaping ([User]) -> (),
                          onError: @escaping (AppError) -> ())
}

class TwitterRequestManager: TwitterRequestManagerProtocol {

    //Rreplace with your app data
    let consumerKey = "*****"
    let consumerSecret = "*****"

    var twitterAuthData: SocialAccountAuthData?

    func requestToken(onNext: @escaping (URL) -> (), onError: @escaping (AppError) -> ()) {
        let url = URL(string: "https://api.twitter.com/oauth/request_token")!
        let authenticateUrl = "https://api.twitter.com/oauth/authenticate"
        let request = URLRequest(url: url)
        let params = [String: String]()

        self.postRequest(request, params: params, success: { (data) in
            guard let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                return onError(AppError.generic)
            }
            let divideParam = responseString.components(separatedBy: "&")
            let oauthToken = divideParam[0].components(separatedBy: "=")[1]
            let queryURL = URL(string: authenticateUrl + "?oauth_token=\(oauthToken)")
            onNext(queryURL!)
        }) { (error) in
            onError(error)
        }
    }

    func getAccessToken(callbackURL: URL, onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        let url = URL(string: "https://api.twitter.com/oauth/access_token")!
        let request = URLRequest(url: url)
        var params = [String: String]()
        for paramStr in callbackURL.query!.components(separatedBy: "&") {
            var splitParam = paramStr.components(separatedBy: "=")
            params[splitParam[0]] = splitParam[1]
        }

        self.postRequest(request, params: params, success: { (data) in
            guard let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                return onError(AppError.generic)
            }
            let map = self.parseResponseStringToMap(responseString: responseString as String)
            //oauth_token = access token, oauth_token_secret = access token secret
            guard let accessToken = map["oauth_token"], let accessTokenSecret = map["oauth_token_secret"], let userID = map["user_id"], let screenName = map["screen_name"] else {
                return onError(AppError.notAuthorized)
            }
            let authData = SocialAccountAuthData(accessToken: accessToken, accessTokenSecret: accessTokenSecret)
            let account = Account(userID: userID, screenName: screenName, auth: authData)
            onNext(account)
        }) { (error) in
            onError(error)
        }
    }

    func getFollowersList(account: Account, onNext: @escaping ([User]) -> (), onError: @escaping (AppError) -> ()) {
        self.twitterAuthData = account.auth
        let url = URL(string: "https://api.twitter.com/1.1/followers/list.json")!
        let request = URLRequest(url: url)
        var params = [String: String]()
        params["oauth_token"] = account.auth.accessToken

        self.getRequest(request, params: params, success: { (data) in
            do {
                let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                let json = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8.rawValue)!, options: .allowFragments)
                let dictionary: [String: Any] = json as! [String: Any]
                let usersArray: [[String: Any]] = dictionary["users"] as! [[String: Any]]
                var users = [User]()
                for user: [String: Any] in usersArray {
                    users.append(User(userID: user["id_str"] as! String,
                                      screenName: user["screen_name"] as! String,
                                      name: user["name"] as! String,
                                      profileImageUrl: user["profile_image_url_https"] as! String,
                                      userDescription: user["description"] as! String))
                }
                onNext(users)
            } catch {
                print(error.localizedDescription)
                onError(AppError.generic)
            }
        }) { (error) in
            onError(error)
        }
    }
}

extension TwitterRequestManager {
    func getRequest(_ request: URLRequest,
                     params: [String: String],
                     success: @escaping (Data) -> (),
                     failure: @escaping (AppError) -> ()) {
        var request = request
        request.httpMethod = "GET"
        self.sendRequest(request, params: params, success: success, failure: failure)
    }

    func postRequest(_ request: URLRequest,
                    params: [String: String],
                    success: @escaping (Data) -> (),
                    failure: @escaping (AppError) -> ()) {
        var request = request
        request.httpMethod = "POST"
        self.sendRequest(request, params: params, success: success, failure: failure)
    }

    func sendRequest(_ request: URLRequest,
                     params: [String: String],
                     success: @escaping (Data) -> (),
                     failure: @escaping (AppError) -> ()) {

        let params = self.createRequestParams(params, with: request)
        let request = self.setupAuthHeader(request: request, params: params)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response: HTTPURLResponse = response as? HTTPURLResponse {
                if response.statusCode == 401 {
                    return failure(AppError.notAuthorized)
                } else if response.statusCode != 200 {
                    return failure(AppError.generic)
                }
            }
            if let error = error {
                print(error.localizedDescription)
                return failure(AppError.generic)
            }
            guard let data = data else {
                return failure(AppError.generic)
            }
            success(data)
            }.resume()
    }

    func createRequestParams(_ params: [String: String], with request: URLRequest) -> [String: String] {
        var params = params
        if let accessToken = self.twitterAuthData?.accessToken {
            params["oauth_token"] = accessToken
        }
        params["oauth_version"] = "1.0"
        params["oauth_signature_method"] = "HMAC-SHA1"
        params["oauth_consumer_key"] = consumerKey
        params["oauth_timestamp"] = String(Int64(NSDate().timeIntervalSince1970))
        params["oauth_nonce"] = (NSUUID().uuidString as NSString).substring(to: 8)
        params["oauth_callback"] = "tlc-app://"
        params["oauth_signature"] = self.oauthSignatureForMethod(
            method: request.httpMethod!,
            url: request.url!,
            parameters: params)

        return params
    }

    func setupAuthHeader(request: URLRequest, params: [String: String]) -> URLRequest {
        var request = request
        var authorizationParameterComponents = urlEncodedQueryStringWithEncoding(params: params).components(separatedBy: "&")
        authorizationParameterComponents.sort { $0 < $1 }

        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=") as [String]
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }

        let authHeader: String = "OAuth \(headerComponents.joined(separator: ", "))"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        return request
    }

    func oauthSignatureForMethod(method: String, url: URL, parameters: Dictionary<String, String>) -> String {
        let signingKey : String = "\(consumerSecret)&\(self.twitterAuthData?.accessTokenSecret ?? "")"
        var parameterComponents = urlEncodedQueryStringWithEncoding(params: parameters).components(separatedBy: "&") as [String]
        parameterComponents.sort { $0 < $1 }
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = urlEncodedStringWithEncoding(str: parameterString)
        let encodedURL = urlEncodedStringWithEncoding(str: url.absoluteString)
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"
        return SHA1DigestWithKey(base: signatureBaseString, key: signingKey).base64EncodedString(options: .lineLength64Characters)
    }

    func urlEncodedQueryStringWithEncoding(params:Dictionary<String, String>) -> String {
        var parts = [String]()

        for (key, value) in params {
            let keyString = urlEncodedStringWithEncoding(str: key)
            let valueString = urlEncodedStringWithEncoding(str: value)
            let query = "\(keyString)=\(valueString)" as String
            parts.append(query)
        }

        return parts.joined(separator: "&")
    }

    func urlEncodedStringWithEncoding(str: String) -> String {
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: "-._~")
        let result = str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        return result!
    }

    func SHA1DigestWithKey(base: String, key: String) -> NSData {
        let str = base.cString(using: String.Encoding.utf8)
        let strLen = UInt(base.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = UInt(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keyStr!, Int(keyLen), str!, Int(strLen), result)

        return NSData(bytes: result, length: digestLen)
    }

    func parseResponseStringToMap(responseString: String) -> [String: String] {
        var map = [String: String]()
        responseString.components(separatedBy: "&").forEach { (string) in
            let components = string.components(separatedBy: "=")
            map[components[0]] = components[1]
        }
        return map
    }
}
