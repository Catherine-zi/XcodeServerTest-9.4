//
//  MyProfileImageCell.m
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/9/19.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import "MyProfileImageCell.h"

@implementation MyProfileImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
	
	
	self.backV.layer.cornerRadius = 4.0;
	self.backV.layer.masksToBounds = YES;
	
	CGFloat imageW = 41;
	CGFloat margin = 15;
	self.avartaView = [[TGLetteredAvatarView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - margin * 2 - margin * 2 - 18 - imageW, margin, imageW, imageW)];
	[self.avartaView setSingleFontSize:28.0f doubleFontSize:28.0f useBoldFont:false];
	self.avartaView.fadeTransition = true;
	
	
	self.avartaView.layer.cornerRadius = 4.0;
	self.avartaView.layer.masksToBounds = true;
	
	[self.backV addSubview:self.avartaView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
