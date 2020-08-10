//
//  TagCollectionViewCell.swift
//  DropDownMenuDemo
//
//  Created by 顾钱想 on 2020/8/10.
//  Copyright © 2020 顾钱想. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    var textLab = UILabel()
    override init(frame: CGRect) {
      super.init(frame: frame)
      self.makeUI()
    }

    func makeUI() {
        textLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        textLab.textAlignment = .center;
        textLab.adjustsFontSizeToFitWidth = true
        textLab.layer.cornerRadius = 5
        textLab.layer.masksToBounds = true
        textLab.minimumScaleFactor = 0.2;
        self.addSubview(textLab)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
