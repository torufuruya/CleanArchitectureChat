//
//  TwitterAccountDataStore.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/01.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

protocol TwitterAccountDataStore {
    func getAccountData(onNext: @escaping (Account) -> (),
                        onError: @escaping (AppError) -> ())

    func updateAccountData(account: Account) -> Bool
}

class TwitterAccountDataStoreImpl: TwitterAccountDataStore {

    let userDefaultsKeyAccount = "tlc_user_defaults_key_account"

    func getAccountData(onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        guard let archived = UserDefaults.standard.object(forKey: userDefaultsKeyAccount) as? NSData, let account = NSKeyedUnarchiver.unarchiveObject(with: archived as Data) as? Account else {
            return onError(AppError.notAuthorized)
        }
        onNext(account)
    }

    func updateAccountData(account: Account) -> Bool {
        //FIXME not to use UserDefaults... e.g. file system
        let archive = NSKeyedArchiver.archivedData(withRootObject: account)
        UserDefaults.standard.set(archive, forKey: userDefaultsKeyAccount)
        return UserDefaults.standard.synchronize()
    }

}

class TwitterAccountDataStoreAPIImpl: TwitterAccountDataStore {

    let manager = TwitterRequestManager()

    func getAccountData(onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        self.requestToken(onNext: { (authURL) in
            //Succeed to get request token
            self.showTwitterAuthView(authURL: authURL, onNext: { (callbackURL) in
                //Succeed to get authorization
                self.getAccessToken(url: callbackURL, onNext: { (account) in
                    //Finally, succeed to get access token
                    onNext(account)
                }, onError: { (error) in
                    //Failed to get access token
                    onError(error)
                })
            }, onError: { (error) in
                //Failed to get authorization
                onError(error)
            })
        }, onError: { (error) in
            //Failed to get request token
            onError(error)
        })
    }

    func updateAccountData(account: Account) -> Bool {
        return true
    }

}

extension TwitterAccountDataStoreAPIImpl {

    private func requestToken(onNext: @escaping (URL) -> (), onError: @escaping (AppError) -> ()) {
        self.manager.requestToken(onNext: { (url) in
            onNext(url)
        }) { (error) in
            onError(error)
        }
    }

    private func showTwitterAuthView(authURL: URL, onNext: @escaping (URL) -> (), onError: @escaping (AppError) -> ()) {
        DispatchQueue.main.async {
            let webView = TwitterAuthWebView()
            webView.callback = { (url: URL) in
                onNext(url)
            }
            UIApplication.shared.keyWindow?.rootViewController?.present(webView, animated: true, completion: {
                webView.loadURL(url: authURL)
            })
        }
    }

    private func getAccessToken(url: URL, onNext: @escaping (Account) -> (), onError: @escaping (AppError) -> ()) {
        self.manager.getAccessToken(callbackURL: url, onNext: { (account) in
            onNext(account)
        }) { (error) in
            onError(AppError.notAuthorized)
        }
    }
}
