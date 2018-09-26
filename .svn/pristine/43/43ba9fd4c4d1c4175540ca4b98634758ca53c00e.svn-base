//
//  RecGroupsViewController.m
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/6/25.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import "RecGroupsViewController.h"
#import "RecGroupsTableViewCell.h"
#import "TGModernConversationController.h"
#import "TGAppDelegate.h"
#import "TGInterfaceManager.h"
#import "DQDTelegraphDemo-Swift.h"
#import "OCLanguage.h"
#import "SPUserEventsManager.h"
#import "TGDatabase.h"
#import "TGPresentation.h"
#import "TGChannelConversationCompanion.h"
#import "TGTelegraph.h"
#import "TGApplication.h"
@interface RecGroupsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tab;

@property (nonatomic, strong)NSMutableArray *dataArr;
@end

@implementation RecGroupsViewController

-(NSMutableArray *)dataArr {
	if (_dataArr == nil) {
		_dataArr = [NSMutableArray array];
	}
	return _dataArr;
}
-(UITableView *)tab {
	if (_tab == nil) {
		_tab = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		_tab.delegate = self;
		_tab.dataSource = self;
		_tab.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
		[_tab registerNib:[UINib nibWithNibName:@"RecGroupsTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecGroupsTableViewCell"];
		_tab.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		_tab.tableFooterView = nil;
	}
	return _tab;
}
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.tab];
//	self.navigationController.title = @"热门群组";
	self.title = [OCLanguage SWLocalizedString:@"recommended_title"];
	if (TelegramUserInfo.shareInstance.recGroups == nil) {
		[self loadData];
	}else {
		[self reloadData:TelegramUserInfo.shareInstance.recGroups];
	}
	
	
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addAssets_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]];
	
	[[SPUserEventsManager sharedManager] addCountForEvent:SWUEC_Enter_RecommendedGroup_Page];
	
}
- (void)back{
	[[SPUserEventsManager sharedManager] addCountForEvent:SWUEC_Back_RecommendedGroup_Page];
	[self.navigationController popViewControllerAnimated:YES];
}
- (void)loadData {
	__weak RecGroupsViewController *weakSelf = self;
	
	[TelegramUserInfo.shareInstance getFirstRecUrlWithBlock:^(NSString * link) {
		
	} dataBlock:^(NSData * data) {
		[weakSelf reloadData:data];
	}];
}
- (void)reloadData:(NSData *)data{
	NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	if (resultDic[@"code"] && [[NSString stringWithFormat:@"%@",resultDic[@"code"]] isEqualToString:@"0"]) {
		[self.dataArr removeAllObjects];
		[self.dataArr addObjectsFromArray:resultDic[@"data"]];
		[self.tab reloadData];
	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	RecGroupsTableViewCell *cell = (RecGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RecGroupsTableViewCell"];
	if (indexPath.section < self.dataArr.count) {
		cell.modelDic = self.dataArr[indexPath.section];
		
		__weak RecGroupsViewController *weakSelf = self;
		cell.block = ^(NSString *link) {

//			TGModernConversationController *vc = [[TGModernConversationController alloc]init];
//			vc.companion = [[TGModernConversationCompanion alloc]init];
			
			[weakSelf gotoChannel:link];
			
		};
	}
	
	return  cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 160;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIView *view = [UIView new];
	view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
	view.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 15);
	return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIView *view = [UIView new];
	view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
	view.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.bounds.size.width, 1);
	return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section < self.dataArr.count) {
		NSDictionary *modelDic = self.dataArr[indexPath.section];
		NSString *url = [NSString stringWithFormat:@"%@",modelDic[@"link"]];
		
		[[SPUserEventsManager sharedManager] trackEventAction:SWUEC_Click_ViewGroup eventPrame:[NSString stringWithFormat:@"%@",modelDic[@"group_name"]]];
		
		[self gotoChannel:url];
	}
}
	
- (void)gotoChannel:(NSString *)link{
	
	[(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] forceNative:false keepStack:true];
}

-(void)dealloc{
	
}
@end
