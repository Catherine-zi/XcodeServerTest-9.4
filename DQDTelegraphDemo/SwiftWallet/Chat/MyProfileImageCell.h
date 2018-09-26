//
//  MyProfileImageCell.h
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/19.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGLetteredAvatarView.h"

@interface MyProfileImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLB;
@property (strong, nonatomic)TGLetteredAvatarView *avartaView;
@property (weak, nonatomic) IBOutlet UIView *backV;

@end
