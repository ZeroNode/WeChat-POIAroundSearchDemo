//
//  SelectLocationTableViewCell.swift
//  YuErBao
//
//  Created by mc on 12/12/2016.
//  Copyright © 2016 first mac. All rights reserved.
//

import UIKit

class SelectLocationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var shopNameLab:UILabel = UILabel()
    var descLab:UILabel = UILabel()
    var linelabel:UILabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.sd_addSubviews([shopNameLab,descLab,linelabel])
        
        shopNameLab.sd_layout()
            .leftSpaceToView(self.contentView,10)
            .rightSpaceToView(self.contentView,10)
            .topSpaceToView(self.contentView,10)
            .heightIs(30)
        
        descLab.sd_layout()
            .leftSpaceToView(self.contentView,10)
            .rightSpaceToView(self.contentView,10)
            .topSpaceToView(self.shopNameLab,0)
        
        shopNameLab.font = UIFont.systemFontOfSize(15)
        
        descLab.font = UIFont.systemFontOfSize(13)
        descLab.textColor = UIColor.grayColor()
        descLab.lineBreakMode = .ByTruncatingTail
        
        linelabel.backgroundColor = UIColor(red: 0.816, green: 0.816, blue: 0.816, alpha: 1)
        linelabel.sd_layout()
            .widthIs(UIScreen.mainScreen().bounds.width)
            .heightIs(1)
            .leftSpaceToView(self.contentView,0)
            .bottomSpaceToView(self.contentView,0)
        
        self.setupAutoHeightWithBottomViewsArray([shopNameLab,descLab], bottomMargin: 10)
        self.updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
