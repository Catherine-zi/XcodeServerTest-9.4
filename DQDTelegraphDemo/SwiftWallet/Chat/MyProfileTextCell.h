//
//  MyProfileTextCell.h
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/19.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLB;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleRightContent;
@end
