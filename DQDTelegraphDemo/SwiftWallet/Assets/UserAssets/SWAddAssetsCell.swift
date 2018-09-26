//
//  SWAddAssetsCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/20.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit
//import SDWebImage
class SWAddAssetsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
		
		headImageV.layer.cornerRadius = 5
		headImageV.layer.masksToBounds = true
		headImageV.backgroundColor = UIColor.white
    }

	@IBOutlet weak var isSelectedBtn: UIButton!
	@IBOutlet weak var fullName: UILabel!
	@IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var contractAddrLbl: UILabel!
    @IBOutlet weak var headImageV: UIImageView!
	override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        print("cellSetSelected\(selected)")
    }
	
	typealias StatusBlock = (AssetsTokensModel) -> ()
	
	var changeSelectedBlock:StatusBlock?
    
	@IBAction func clickSelectBtn(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		
		model?.isSelected = sender.isSelected
		
		if changeSelectedBlock != nil {
			changeSelectedBlock!(model!)
		}
	}
	
	var model:AssetsTokensModel? {
		didSet {
			
			guard let model = model else {
				return
			}
			fullName.text = model.contractName
			coinName.text = model.symbol
            contractAddrLbl.text = model.contractAddress
			
			isSelectedBtn.isSelected = model.isSelected == nil ? false : model.isSelected!
			
			if  let symbol = model.symbol,let image = UIImage.init(named: symbol) {
				headImageV.image = image
			}else {

                guard var urlStr = model.iconUrl, urlStr.count > 0 else {
                    self.headImageV.image = UIImage.init(named: "placeholderIcon")
                    return
                }
				urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
                headImageV.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
			}
		
		}
	}
}
