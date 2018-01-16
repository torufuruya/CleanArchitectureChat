//
//  ChatViewController.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextView!

    var presenter: ChatPresenter?
    var messages: [MessageType] = []
    var account: Account?
    var user: User?

    public func inject(presenter: ChatPresenter) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.user?.symbolicName
        self.registerReusableViews()
        self.tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.presenter?.loadConversation(chatID: user!.userID, onNext: { (messages) in
            self.messages = messages
            self.tableView.reloadData()
        }, onError: { (error) in
            //TODO error handling
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClickPostButton(_ sender: UIButton) {
        let inputMessage = inputText.text.trimmingCharacters(in: .whitespaces)
        if inputMessage.count > 0 {
            self.sendMessage(inputMessage: inputMessage)
        }
    }

}

private extension ChatViewController {
    func registerReusableViews() {
        self.tableView.register(UINib(nibName: "TextMessageCell", bundle: Bundle.main), forCellReuseIdentifier: "text-cell")
        self.tableView.register(UINib(nibName: "TextMessageLeftCell", bundle: Bundle.main), forCellReuseIdentifier: "text-cell-left")
    }

    func sendMessage(inputMessage: String) {
        let message = Message(sender: self.account!, data: MessageData.text(inputMessage), isMine: true)
        self.presenter?.sendMessage(for: user!.userID, message: message, onNext: { (message) in
            self.messages.insert(message, at: 0)
            DispatchQueue.main.async {
                self.inputText.text = ""
                self.tableView.reloadData()
            }
        }, onError: { (error) in
            //
        })
    }
}

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        switch message.data {
        case .text:
            //TODO refactor...
            if message.isMine {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text-cell", for: indexPath) as! TextMessageCell
                cell.configure(with: message)
                cell.layoutIfNeeded()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "text-cell-left", for: indexPath) as! TextMessageLeftCell
                cell.configure(with: message, and: self.user!)
                cell.layoutIfNeeded()
                return cell
            }
        case .photo:
            //TODO
            let cell = tableView.dequeueReusableCell(withIdentifier: "text-cell", for: indexPath) as! TextMessageCell
            cell.configure(with: message)
            return cell
        }
    }
}
