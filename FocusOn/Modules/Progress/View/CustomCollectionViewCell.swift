//
//  CustomCollectionViewCell.swift
//  FocusOn
//
//  Created by Rafal Padberg on 02.05.19.
//  Copyright © 2019 Rafal Padberg. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
//        customView.layer.cornerRadius = 5.0
    }
    
    func setTitile(to text: String) {
        customLabel.text = text
    }
}
