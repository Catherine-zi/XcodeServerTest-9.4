//
//  AssetsDetailHeaderCollectionView.swift
//  SwiftWallet
//
//  Created by Jack on 2018/6/26.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

protocol AssetsDetailHeaderCollectionDelegate: class {
    func assetsCollection(collectionView: AssetsDetailHeaderCollectionView, didSelectedWallet assetModel: AssetsTokensModel)
}

class AssetsDetailHeaderCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var assetsDelegate: AssetsDetailHeaderCollectionDelegate?
    
    var collectionView: UICollectionView?
    private var assetsArray: [AssetsTokensModel] = []
    private var modifiedArray: [AssetsTokensModel] = []
    private var selectedAsset: AssetsTokensModel?
    private var selectedIndex: Int = 0
    var cellHeight: CGFloat = 48

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpViews()
    }
    
    private func setUpViews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.init(width: self.cellHeight, height: self.cellHeight)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.minimumLineSpacing = 4
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.collectionView!.backgroundColor = UIColor.white
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.bounces = false
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView!.register(AssetCell.classForCoder(), forCellWithReuseIdentifier: "AssetCell")
        self.addSubview(self.collectionView!)
        self.collectionView!.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func setData(assets: [AssetsTokensModel], index: Int) {
        self.assetsArray = assets
        self.selectedIndex = index
        self.selectedAsset = self.assetsArray[index]
        for asset in self.assetsArray {
            if asset.contractAddress != self.selectedAsset?.contractAddress {
                self.modifiedArray.append(asset)
            }
        }
    }
    
    private func reassembleAssets(index: Int) {
        let tempAsset = self.modifiedArray[index]
        self.modifiedArray.remove(at: index)
        if self.selectedAsset != nil {
            self.modifiedArray.append(self.selectedAsset!)
        }
        self.selectedAsset = tempAsset
        if self.collectionView != nil {
            self.collectionView!.reloadData()
            self.collectionView!.contentOffset = CGPoint.init(x: 0, y: 0)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.modifiedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AssetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as! AssetCell
//        cell.setContent(icon: self.modifiedArray[indexPath.row].symbol!)
        let model = self.modifiedArray[indexPath.row]
		
		if  let symbol = model.symbol,
            let image = UIImage.init(named: symbol)
        {
			cell.iconImgView.image = image
		}else {
            guard var urlStr = model.iconUrl, urlStr.count > 0 else {
                cell.iconImgView.image = UIImage.init(named: "placeholderIcon")
                return cell
            }
			urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
            cell.iconImgView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage.init(named: "placeholderIcon"), options: SDWebImageOptions.retryFailed, completed: nil)
		}

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.changeAssets(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == 0 && !collectionView.isDragging {
//            self.changeAssets(index: indexPath.row)
//        }
    }
    
    @objc private func changeAssets(index: Int) {
        var i = 0
        if index >= 0 {
            i = index
        }
        let assetModel = self.modifiedArray[i]
        self.assetsDelegate?.assetsCollection(collectionView: self, didSelectedWallet: assetModel)
        self.reassembleAssets(index: i)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            print("end")
            print(scrollView.contentOffset)
            print(decelerate)
            if scrollView.contentOffset.x > 0.5 * self.cellHeight {
                UIView.animate(withDuration: 0.3, animations: {
                    scrollView.contentOffset = CGPoint.init(x: self.cellHeight + 2, y: 0)
                }) { (_) in
                    self.changeAssets(index: 0)
                }
//                self.perform(#selector(changeAssets(index:)), with: nil, afterDelay: 0.3)
            } else {
                self.collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("decelerate")
        if scrollView.contentOffset.x > 0.5 * self.cellHeight {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.contentOffset = CGPoint.init(x: self.cellHeight + 2, y: 0)
            }) { (_) in
                self.changeAssets(index: 0)
            }
            //                self.perform(#selector(changeAssets(index:)), with: nil, afterDelay: 0.3)
        } else {
            self.collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: true)
        }
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print("end")
//        print(scrollView.contentOffset)
//        if scrollView.contentOffset.x > 0.5 * self.cellHeight {
//            UIView.animate(withDuration: 0.3, animations: {
//                scrollView.contentOffset = CGPoint.init(x: self.cellHeight + 2, y: 0)
//            }) { (_) in
//                self.changeAssets(index: 0)
//            }
//            //                self.perform(#selector(changeAssets(index:)), with: nil, afterDelay: 0.3)
//        } else {
//            self.collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0), at: .left, animated: true)
//        }
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            var offset: CGFloat = 0.0
            if change != nil {
                for (key, value) in change! {
                    if key.rawValue == "new" {
                        offset = (value as! CGPoint).x
    //                    print(offset)
                    }
                }
                if offset > self.cellHeight + 2 {
                    self.collectionView?.contentOffset = CGPoint.init(x: self.cellHeight + 2, y: 0)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }

}

fileprivate class AssetCell: UICollectionViewCell {
    let iconImgView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpViews()
    }
    
    private func setUpViews() {
        let back = UIView()
        let shadow = UIView()
        self.contentView.addSubview(shadow)
        shadow.addSubview(back)
        shadow.snp.makeConstraints { (make) in
            make.left.top.equalTo(3)
            make.right.bottom.equalTo(-3)
        }
        back.snp.makeConstraints { (make) in
            make.left.top.equalTo(3)
            make.right.bottom.equalTo(-3)
        }
        back.backgroundColor = UIColor.white
        back.layer.cornerRadius = 3
        shadow.layer.borderColor = UIColor.init(hexColor: "f1f1f1").cgColor
        shadow.layer.borderWidth = 1
        shadow.backgroundColor = UIColor.white
        shadow.layer.cornerRadius = 3
        shadow.layer.shadowRadius = 2
        shadow.layer.shadowColor = UIColor.init(hexColor: "EBEBEB").cgColor
        shadow.layer.shadowOffset = CGSize(width: 0, height: 5)
        shadow.layer.shadowOpacity = 0.7
        shadow.layer.masksToBounds = false
//        shadow.frame = CGRect(x: 0, y: 0, width: SWScreen_width - padding * 2 , height: 150)
        
//        shadow.layer.shadowColor = UIColor.red.cgColor
//        shadow.layer.shadowRadius = 2
//        shadow.layer.shadowOffset = CGSize.zero
//        shadow.layer.shadowOpacity = 1
//        shadow.layer.masksToBounds = true
        back.clipsToBounds = true
        back.addSubview(self.iconImgView)
        self.iconImgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(4)
            make.right.bottom.equalTo(-4)
        }
    }
    
}
