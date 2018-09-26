//
//  MarketsSearchResultCell.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/11.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

enum KeyType {
    case Coin
    case ExchangePairs
}
class MarketsSearchResultCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    private var keyType:KeyType = .Coin
    private var exchangePairModel: SearchExchangePairContentStruct?
    private var exchangeName: String? //点击收藏传参使用

	private var isLoading:Bool = false
	@IBOutlet weak var headImageV: UIImageView!
	@IBOutlet weak var titleLB: UILabel!
	
	@IBOutlet weak var descLB: UILabel!
	@IBOutlet weak var collectionBtn: UIButton!
    
	@IBAction func clickCollectionBtn(_ sender: UIButton) {
		
		if isLoading {
			return
		}
		isLoading = true
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_AddFavorites_SearchResultPage)

        if keyType == .Coin {
            self.favoritesRequest(symbol: titleLB.text!, exchange: "", pair: "", isFavorite: !sender.isSelected)
        } else {
            if let exchange = exchangeName, let pair = exchangePairModel?.pair {
                self.favoritesRequest(symbol: "", exchange: exchange, pair: pair, isFavorite: !sender.isSelected)

            }
        }
		self.collectionBtn.isSelected = !self.collectionBtn.isSelected
	}
    //填充搜索结果为币种的数据
    public func fillDataWithSearchMarketContentStruct(modelContentStruct: SearchMarketContentStruct) {
        self.keyType = .Coin
        titleLB.text = modelContentStruct.symbol
        
        modelContentStruct.favorite_status == 1 ? (collectionBtn.isSelected = true) : (collectionBtn.isSelected = false)
       
//        collectionBtn.isHidden = !(modelContentStruct.type == "1")
//        headImageV.isHidden = !(modelContentStruct.type == "1")
        
        if  let symbol = modelContentStruct.symbol,let image = UIImage.init(named: symbol) {
            headImageV.image = image
        }else {
            guard var urlStr = modelContentStruct.icon, urlStr.count > 0 else {
                return
            }
			urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
            self.headImageV.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
        }
        
    }
    //填充搜索结果为交易对的数据
    public func fillDataWithSearchExchangePairsContentStruct(model: SearchExchangePairContentStruct, exchange: String) {
        
        self.keyType = .ExchangePairs
        titleLB.text = model.pair
        exchangePairModel = model
        exchangeName = exchange
        
        model.favorite_status == 1 ? (collectionBtn.isSelected = true) : (collectionBtn.isSelected = false)
        
        //        collectionBtn.isHidden = !(modelContentStruct.type == "1")
        //        headImageV.isHidden = !(modelContentStruct.type == "1")
        
        if  let symbol = model.pair,let image = UIImage.init(named: symbol) {
            headImageV.image = image
        }else {
            guard var urlStr = model.icon, urlStr.count > 0 else {
                return
            }
            urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
            self.headImageV.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
        }
        
    }
    
    func favoritesRequest(symbol: String, exchange: String, pair: String, isFavorite: Bool) {
        MarketsAPIProvider.request(MarketsAPI.markets_currencyFavorite(symbol, exchange, pair, isFavorite)) { [weak self](result) in
            if case let .success(response) = result {
                
                if let strongSelf = self {
                    
                    strongSelf.isLoading = false
                    
                    let decryptedData = Data.init(decryptionResponseData: response.data)
                    let json = try? JSONDecoder().decode(SimpleStruct.self, from: decryptedData)
                    
                    if json?.code != 0 {
                        strongSelf.noticeOnlyText(String(describing: json ?? nil))
                        if strongSelf.collectionBtn != nil {
                            strongSelf.collectionBtn.isSelected = !(strongSelf.collectionBtn.isSelected)
                        }
                        return
                    }
                    
                    let msg: String = isFavorite == false ?  SWLocalizedString(key: "cancel_success") :  SWLocalizedString(key: "add_success")
                    strongSelf.noticeOnlyText(msg)
                }
                
            } else {
                
                if let strongSelf = self {
                    
                    strongSelf.isLoading = false
                    if strongSelf.collectionBtn != nil  {
                        strongSelf.collectionBtn.isSelected = !(strongSelf.collectionBtn.isSelected)
                    }
                }
            }
        }
    }
}
