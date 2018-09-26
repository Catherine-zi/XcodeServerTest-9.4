//
//  GenerateMnemonicViewController.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/4/2.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import UIKit

class GenerateMnemonicViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

   

    var mnemonic:[String]?
    var walletModel:SwiftWalletModel? {
        didSet {
            if mnemonic == nil {
                self.loadMnemonic()
            }
        }
    }
	
//	private let data:Array<String> = ["1238837","2hfr","34rjr","4uufnv","555","387784","28938","92923","f2ru","8934ji","83289j","jfi3wi","jfier","gjnhiue","hn4fiue","nihao","practice","good","revolution","just"]
   
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
	@IBOutlet weak var tipLabel: UILabel!
	
	private var collectionView:DynamicHeightCollectionView?
	override func viewDidLoad() {
        super.viewDidLoad()
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Enter_BackupMnemonic_Page)
        self.navTitleLabel.text = SWLocalizedString(key: "wallet_buckup_title")
        self.tipLabel.text = SWLocalizedString(key: "wallet_backup_word_message")
        self.nextBtn.setTitle(SWLocalizedString(key: "wallet_next_setp"), for: .normal)
        if mnemonic == nil {
            self.loadMnemonic()
        }
		setUpViews()
    }

	private func setUpViews() {
		
		let flowlayout:UICollectionViewLeftFlowLayout = UICollectionViewLeftFlowLayout.init()
		flowlayout.minimumLineSpacing = 15
		flowlayout.minimumInteritemSpacing = 25
		flowlayout.scrollDirection = .vertical
		
		
		let collection:DynamicHeightCollectionView = DynamicHeightCollectionView.init(frame: CGRect.init(x: 16, y: (self.tipLabel.frame.origin.y + self.tipLabel.frame.size.height + 16), width: SWScreen_width - 32, height: 1), collectionViewLayout: flowlayout)
	
		collection.dataSource = self
		collection.delegate = self
		collection.register(UINib.init(nibName: "CreateMnemonicMCell", bundle: nil), forCellWithReuseIdentifier: "CreateMnemonicMCell")
		collection.layer.cornerRadius = 5
		collection.layer.masksToBounds = true
		collection.backgroundColor = UIColor.white
		collection.isScrollEnabled = false
		
		collectionView = collection
		self.view.addSubview(collection)
	}
    
    private func loadMnemonic() {
        if let encryptData = self.walletModel?.mnemonic,
            let encryptPassword = self.walletModel?.password,
            let password = SwiftWalletManager.shared.normalDecrypt(string: encryptPassword),
            let decryptData = SwiftWalletManager.shared.customDecrypt(data: encryptData, key: password),
            let mnemonic = try? JSONDecoder().decode([String].self, from: decryptData)
        {
            self.mnemonic = mnemonic
        }
    }
    
	@IBAction func clickBackBtn(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Back_BackupMnemonic_Page)
		self.navigationController?.popViewController(animated: true)
	}
	@IBAction func clickNextBtn(_ sender: Any) {
        SPUserEventsManager.shared.addCount(forEvent: SWUEC_Click_NextStep_BackupMnemonic_Page)
		let vc:VerifyMnemonicViewController = VerifyMnemonicViewController()
//        vc.mnemonic = walletModel?.mnemonic
        vc.walletModel = self.walletModel
		vc.topCollectionH = CGFloat((self.collectionView?.collectionViewLayout.collectionViewContentSize.height)!)
		self.navigationController?.pushViewController(vc, animated: true)

	}
	
	//UICollectionViewDataSource & ..
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mnemonic == nil ? 0 : self.mnemonic!.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell:CreateMnemonicMCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateMnemonicMCell", for: indexPath) as! CreateMnemonicMCell
		
		guard let data = self.mnemonic else {
			return cell
		}
		if indexPath.item < data.count {
			cell.titleL.text = data[indexPath.item]
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		guard let data = self.mnemonic else {
			return CGSize.zero
		}
		if (indexPath.item < data.count){
			let title:String = data[indexPath.item]
			print("\(calculateSize(title: title))")
			return calculateSize(title: title)
		}
		return CGSize.zero

	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.init(top: 20, left: 16, bottom: 20, right: 16)
	}
	
	func calculateSize(title:String) -> CGSize {
		
		let str:NSString = title as NSString
		let size:CGSize = str.boundingRect(with: CGSize.init(width: 0, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),NSAttributedStringKey.foregroundColor : UIColor.blue], context: nil).size
		
		return CGSize.init(width: size.width + 2, height: size.height)
	}
}


