//
//  RecGroupsTableViewCell.m
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/6/25.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import "RecGroupsTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "OCLanguage.h"
@interface RecGroupsTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLB;
@property (weak, nonatomic) IBOutlet UILabel *descLB;
@property (weak, nonatomic) IBOutlet UIButton *addGroupBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation RecGroupsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
	
	self.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
	self.backView.layer.cornerRadius = 5.0;
	self.backView.layer.masksToBounds = YES;
	
	[self.addGroupBtn setTitle:[NSString stringWithFormat:@"%@%@",[OCLanguage SWLocalizedString:@"view_group"],@">>>"] forState:UIControlStateNormal];
	self.addGroupBtn.enabled = NO;
}
-(void)setModelDic:(NSDictionary *)modelDic {
	_modelDic = modelDic;
	[self.iconIv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",modelDic[@"icon"]]]];
	self.descLB.text = [NSString stringWithFormat:@"%@",modelDic[@"description"]];
	self.nameLB.text = [NSString stringWithFormat:@"%@",modelDic[@"group_name"]];
}
- (IBAction)clickAddGroupBtn:(UIButton *)sender {
	if (self.block) {
		self.block([NSString stringWithFormat:@"%@",self.modelDic[@"link"]]);
	}
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	
    // Configure the view for the selected state
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
	[super setHighlighted:highlighted animated:animated];
	self.backView.backgroundColor = UIColor.whiteColor;
	
}

@end
