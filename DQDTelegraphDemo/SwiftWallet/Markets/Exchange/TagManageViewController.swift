//
//  TagManageViewController.swift
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/8/2.
//  Copyright © 2018年 Avazu. All rights reserved.
//

import UIKit

var movingTag: String?
enum MarketTagType: String, Codable {
    case pair = "pair"
    case exchange = "exchange"
}
let marketTagKeyPrefix: String = "marketTagKeyPrefix"



class TagManageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TagManageCellDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var myTagLbl: UILabel!
    @IBOutlet weak var moreTagLbl: UILabel!
    @IBOutlet weak var myContainerView: UIView!
    @IBOutlet weak var moreContainerView: UIView!
    
    typealias ReloadHeadTagBlock = (([String], [String])->())
    var reloadHeadTagBlock :ReloadHeadTagBlock?
    
    lazy var myTagCollectionView: UICollectionView = self.createCollectionView()
    lazy var moreTagCollectionView: UICollectionView = self.createCollectionView()
    
    var type: MarketTagType = .pair // default
    var myTagArray: [String] = []
    var moreTagArray: [String] = []
    var movingIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.type == .pair {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_PairTagMag_Page)
        } else {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_ExTagMag_page)
        }
//        self.getUserData()
        self.setUpViews()
    }
    
//    private func getUserData() {
//        if let tagArrayArray = UserDefaults.standard.value(forKey: marketTagKeyPrefix + self.type.rawValue) as? [[String]] {
//            if tagArrayArray.count == 2 {
//                self.myTagArray = tagArrayArray[0]
//                self.moreTagArray = tagArrayArray[1]
//            }
//        }
//    }
    
    private func setUpViews() {
        
        self.titleLbl.text = SWLocalizedString(key: "tag_management_title")
        self.myTagLbl.text = SWLocalizedString(key: "my_tags")
        self.moreTagLbl.text = SWLocalizedString(key: "press_to_add_more_tags")
        
        let attrs = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor : UIColor.init(hexColor: "1e59f5"),
            NSAttributedStringKey.underlineStyle : 1
            ] as [NSAttributedStringKey : Any]
        let editStr = NSMutableAttributedString.init(string: SWLocalizedString(key: "tag_management_edit"), attributes: attrs)
        let doneStr = NSMutableAttributedString.init(string: SWLocalizedString(key: "wallet_done"), attributes: attrs)
        self.editBtn.setAttributedTitle(editStr, for: .normal)
        self.editBtn.setAttributedTitle(doneStr, for: .selected)
        
        self.myContainerView.addSubview(self.myTagCollectionView)
        self.myTagCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
            make.height.equalTo(128)
        }
        self.moreContainerView.addSubview(self.moreTagCollectionView)
        self.moreTagCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
            make.height.equalTo(128)
        }
        
        let longGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handleDrag(gesture:)))
        self.myTagCollectionView.addGestureRecognizer(longGesture)
        
//        if self.type == .pair {
//            self.requestForPairTag()
//        } else if self.type == .exchange {
//            self.requestForExchangeTag()
//        }
        
    }
    
    private func requestForPairTag() {
        MarketsAPIProvider.request(MarketsAPI.markets_pairTag) { [weak self] (result) in
            switch result {
            case let .success(response):
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsPairTagModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                guard let pairArray = json?.data?.pair,
                    let moreArray = json?.data?.more_tags else
                {
                    print("nil tag array")
                    return
                }
                if self?.myTagArray.count == 0 {
                    self?.myTagArray = pairArray
                    self?.moreTagArray = moreArray
                    self?.myTagCollectionView.reloadData()
                    self?.moreTagCollectionView.reloadData()
                } else {
                    if let myTag = self?.myTagArray {
                        var allArray = pairArray + moreArray
                        for tag in myTag {
                            if let index = allArray.index(of: tag) {
                                allArray.remove(at: index)
                            }
                        }
                        self?.moreTagArray = allArray
                        self?.moreTagCollectionView.reloadData()
                    }
                }
            case let .failure(error):
                print("get pair tag error: \(error)")
            }
        }
    }
    
    private func requestForExchangeTag() {
        MarketsAPIProvider.request(MarketsAPI.markets_exchangeTag) { [weak self] (result) in
            switch result {
            case let .success(response):
                let decryptedData:Data = Data.init(decryptionResponseData: response.data)
                let json = try? JSONDecoder().decode(MarketsExchangeTagModel.self, from: decryptedData)
                if json?.code != 0 {
                    print("markets all response json: \(String(describing: json ?? nil))")
                    return
                }
                guard var exchangeArray = json?.data else {
                    print("nil tag array")
                    return
                }
                if self?.myTagArray.count == 0 {
                    self?.myTagArray = exchangeArray
                    self?.myTagCollectionView.reloadData()
                } else {
                    if let myTag = self?.myTagArray {
                        for tag in myTag {
                            if let index = exchangeArray.index(of: tag) {
                                exchangeArray.remove(at: index)
                            }
                        }
                        self?.moreTagArray = exchangeArray
                        self?.moreTagCollectionView.reloadData()
                    }
                }
            case let .failure(error):
                print("get pair tag error: \(error)")
            }
        }
    }
    
    private func createCollectionView() -> DynamicHeightAutoCollectionView {
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        alignedFlowLayout.minimumLineSpacing = 1
        alignedFlowLayout.minimumInteritemSpacing = 0
        alignedFlowLayout.itemSize = CGSize.init(width: 87.5, height: 52)
        alignedFlowLayout.scrollDirection = .vertical
        
        let collectionView = DynamicHeightAutoCollectionView.init(frame: CGRect.zero, collectionViewLayout: alignedFlowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "TagManageCell", bundle: nil), forCellWithReuseIdentifier: "TagManageCell")
        
        return collectionView
    }
    
    @objc private func handleDrag(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let index = self.myTagCollectionView.indexPathForItem(at: gesture.location(in: self.myTagCollectionView)) else {
                return
            }
            movingTag = (self.myTagCollectionView.cellForItem(at: index) as? TagManageCell)?.titleL.text
            self.myTagCollectionView.beginInteractiveMovementForItem(at: index)
        case .changed:
            self.myTagCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.myTagCollectionView))
        case .ended:
            movingTag = nil
            self.myTagCollectionView.endInteractiveMovement()
            self.myTagCollectionView.collectionViewLayout.invalidateLayout()
        default:
            movingTag = nil
            self.myTagCollectionView.cancelInteractiveMovement()
        }
    }
    
    func tagCellDidTappedDelete(cell: TagManageCell) {
        if let index = self.myTagCollectionView.indexPath(for: cell) {
            self.collectionView(self.myTagCollectionView, didSelectItemAt: index)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.myTagCollectionView {
            return self.myTagArray.count
        } else {
            return self.moreTagArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:TagManageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagManageCell", for: indexPath) as! TagManageCell
        if collectionView == self.myTagCollectionView {
            if indexPath.item < self.myTagArray.count {
                cell.titleL.text = myTagArray[indexPath.item]
                if cell.titleL.text?.lowercased() == "all" {
                    cell.deleteBtn.isHidden = true
                } else {
                    cell.deleteBtn.isHidden = !self.editBtn.isSelected
                }
                if cell.tagCellDelegate == nil {
                    cell.tagCellDelegate = self
                }
            }
        } else {
            if indexPath.item < self.moreTagArray.count {
                cell.titleL.text = moreTagArray[indexPath.item]
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagManageCell,
            let tag = cell.titleL.text
        {
            if collectionView == self.myTagCollectionView {
                if cell.titleL.text?.lowercased() == "all" {
                    return
                }
                if self.myTagArray.count > 1 {
                    if let index = self.myTagArray.index(of: tag) {
                        self.myTagArray.remove(at: index)
                        self.moreTagArray.append(tag)
                        self.noticeOnlyText(SWLocalizedString(key: "delete_success"))
                        if self.type == .pair {
                            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_DeleteSuccess_PairTagMag_Page)
                        } else {
                            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_DeleteSuccess_ExTagMag_Page)
                        }
                    }
                } else {
                    self.noticeOnlyText(SWLocalizedString(key: "keep_at_least_one_tags"))
                    SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_leastPrompt_ExTagMag_Page)
                }
            } else {
                if let index = self.moreTagArray.index(of: tag) {
                    self.moreTagArray.remove(at: index)
                    self.myTagArray.append(tag)
                    self.noticeOnlyText(SWLocalizedString(key: "add_success"))
                    if self.type == .pair {
                        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_AddSuccess_PairTagMag_Page)
                    } else {
                        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Show_AddSuccess_ExTagMag_Page)
                    }
                }
            }
        }
        self.myTagCollectionView.reloadData()
        self.moreTagCollectionView.reloadData()
    }
    
    //UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var title:String = ""
        if collectionView == self.myTagCollectionView {
            if (indexPath.item < self.myTagArray.count){
                title = self.myTagArray[indexPath.item]
            }
        } else {
            if (indexPath.item < self.moreTagArray.count){
                title = self.moreTagArray[indexPath.item]
            }
        }
        return calculateSize(title: title)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return self.editBtn.isSelected
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let tag = movingTag,
            let index = self.myTagArray.index(of: tag)
        {
            var tempArray = self.myTagArray
            tempArray.remove(at: index)
            tempArray.insert(tag, at: destinationIndexPath.item)
            self.myTagArray = tempArray
        }
    }
    
    @IBAction func editTapped(_ sender: Any) {
        self.editBtn.isSelected = !self.editBtn.isSelected
        if self.type == .pair {
            if self.editBtn.isSelected {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Edit_PairTagMag_Page)
            } else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Done_PairTagMag_Page)
            }
        } else {
            if self.editBtn.isSelected {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Edit_ExTagMag_page)
            } else {
                SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_Done_ExTagMag_page)
            }
        }
        self.myTagLbl.text = self.editBtn.isSelected ? SWLocalizedString(key: "long_press_to_sort") : SWLocalizedString(key: "my_tags")
        self.myTagCollectionView.reloadData()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    deinit {
        if self.type == .pair {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_PairTagMag_Page)
        } else {
            SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_ExTagMag_page)
        }
        if reloadHeadTagBlock != nil {
            reloadHeadTagBlock!(self.myTagArray, self.moreTagArray)
        }
        UserDefaults.standard.set([self.myTagArray, self.moreTagArray], forKey: marketTagKeyPrefix + self.type.rawValue)
    }

}

class DynamicHeightAutoCollectionView: UICollectionView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.bounds.height != self.collectionViewLayout.collectionViewContentSize.height {
            self.snp.updateConstraints { (make) in
                make.height.equalTo(self.collectionViewLayout.collectionViewContentSize.height)
            }
        }
    }
}

func calculateSize(title: String) -> CGSize {
    let str:NSString = title as NSString
    let size:CGSize = str.boundingRect(with: CGSize.init(width: 0, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor : UIColor.blue], context: nil).size
    
    return CGSize.init(width: size.width + 30 + 2 + 20, height: size.height + 20 + 14)
}
