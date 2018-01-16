//
//  TextMessageCell.swift
//  CleanArchitectureChat
//
//  Created by Toru Furuya on 2017/12/02.
//  Copyright © 2017年 toru.furuya. All rights reserved.
//

import UIKit

class TextMessageCell: UITableViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var messageText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with message: MessageType) {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

        switch message.data {
        case .text(let text):
            self.messageText.text = text
            break
        default:
            break
        }
    }
    
}
