//
//  TextMessageLeftCell.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

class TextMessageLeftCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var senderIconImageView: AsyncImageView!
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with message: MessageType, and user: User) {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

        switch message.data {
        case .text(let text):
            self.messageText.text = text
            if let iconURL = URL(string: user.profileImageUrl) {
                self.senderIconImageView.loadImage(url: iconURL)
            }
            break
        default:
            break
        }
    }

}

class AsyncImageView: UIImageView {

    func loadImage(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                self.clipsToBounds = true
                self.layer.cornerRadius = self.bounds.size.width * 0.5
                self.image = UIImage(data: data)
            }
        }.resume()
    }

}
