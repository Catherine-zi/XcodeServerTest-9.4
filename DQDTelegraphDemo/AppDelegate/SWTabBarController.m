//
//  SWTabBarController.m
//  TestAddFramework
//
//  Created by Avazu Holding on 2018/6/14.
//  Copyright © 2018年 Avazu Holding. All rights reserved.
//

#import "SWTabBarController.h"
#import "TGAppDelegate.h"
#import "TGRootController.h"
#import "DQDTelegraphDemo-Swift.h"

#import "ActionStage.h"
#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGLoginPhoneController.h"
#import "SwiftWalletNavViewController.h"
#import "OCLanguage.h"

#import "IQKeyboardManager.h"
#import "TGApplication.h"
@interface SWTabBarController ()
@property (nonatomic) NSInteger chatTag;

@end

@implementation SWTabBarController


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self addBeginningGuide];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.chatTag = 11;
    
	self.view.backgroundColor = [UIColor whiteColor];

	[self setUpAllChildViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTabbarController) name:@"SWcurrencySettingChange" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWalletSuccess) name:@"SWaddWalletSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteWalletSuccess) name:@"SWdeleteWalletSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMeBadge) name:@"SWchangeNotification" object:nil];
	
	
}
- (void)addBeginningGuide {
	
	//add beginning guide
	NSDictionary  *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
	if (![[NSString stringWithFormat:@"%@",config[@"isHiddenAssets"]] isEqualToString:@"yes"]) {
		if (BeginningGuideManager.shared.isNeedShow && self.tabBar.items.count > 3) {
	
			UIView *assetsItem = self.tabBar.subviews[3];
			
			GuideTabBarView *guideV = [[GuideTabBarView alloc]initWithFrame:self.view.bounds iconCenter:CGPointMake(assetsItem.center.x, 0)];
			
			
			guideV.clickBtnClosure = ^ {
				self.selectedIndex = 2;
				
				//add next guide
				if (self.viewControllers.count > 2) {
					UIViewController *vc = self.viewControllers[2];
					
					if ([vc isKindOfClass:[UINavigationController class]]) {
						UINavigationController *nav = (UINavigationController *)vc;
						
						UIViewController *topVc = nav.visibleViewController;
						if ([topVc isKindOfClass:CreateWalletViewController.class]) {//创建钱包
							
//							CreateWalletViewController *noAssetsVc = (CreateWalletViewController *)topVc;
							
							GuideNoAssetsView *noAssets = [[GuideNoAssetsView alloc] initWithFrame:self.view.bounds btnRect:CGRectMake(28, 323 + ([UIApplication sharedApplication].statusBarFrame.size.height), [UIApplication sharedApplication].keyWindow.bounds.size.width - 28 * 2, 51)];
							[self.view addSubview:noAssets];
						}else {
							//
							GuideAssetsView *assets = [[GuideAssetsView alloc] initWithFrame:self.view.bounds btnRect:CGRectZero];
							[self.view addSubview:assets];
						}
					}
					
				}
			};
			
			[self.view addSubview:guideV];
		}
	}
}
- (void)addWalletSuccess {
	NSMutableArray *arr = [self.viewControllers mutableCopy];
	
	UINavigationController *nav = arr[2];
	if ([nav isKindOfClass:[UINavigationController class]]) {
		
		if (![nav.viewControllers.firstObject isKindOfClass:[AssetstViewController class]]) {
			
			NSMutableArray *navArr = [NSMutableArray arrayWithArray:nav.viewControllers];
			AssetstViewController *twoVC = [[AssetstViewController alloc]init];
			navArr[0] = twoVC;
			
			nav.viewControllers = navArr.copy;
		}else {
			[self deleteWalletSuccess];
		}
	}
	
}
- (void)deleteWalletSuccess {
    //assets
    int count = (int)SwiftWalletManager.shared.walletCount;
    UINavigationController *assetNav;
    if (count == 0) {
        
        CreateWalletViewController *createVc = [[CreateWalletViewController alloc]init];
        assetNav = [self getOneChildViewController:createVc image:[UIImage imageNamed:@"assets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"assets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"assets"]];
		
//		[assetNav.tabBarItem set]
        NSMutableArray *arr = [self.viewControllers mutableCopy];
        arr[2] = assetNav;
        self.viewControllers = arr;
        
    }
}
- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
+ (void)logout {
	[TelegramUserInfo.shareInstance clearUserInfo];
	[ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/auth/logout/(%d)", TGTelegraphInstance.clientUserId] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"force"] watcher:TGTelegraphInstance];
}

+ (TGNavigationController *)loginNavigationController
{
	
	TGNavigationController *loginNavigationController;
		UIViewController *rootController = nil;
		//Avazu 20180608 修改
		//        rootController = [[RMIntroViewController alloc] init];
		rootController = [[TGLoginPhoneController alloc] init];
		
		loginNavigationController = [TGNavigationController navigationControllerWithControllers:@[rootController] navigationBarClass:[TGTransparentNavigationBar class]];
		loginNavigationController.restrictLandscape = !TGIsPad();
		loginNavigationController.disableInteractiveKeyboardTransition = true;
		
		//_loginNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	
	return loginNavigationController;
}

- (UIViewController *)resetChatsTab:(BOOL)isLogin{
	UIViewController *tgRoot;
	if (isLogin) {
		tgRoot = TGAppDelegateInstance.rootController;
	}else {
		ChatLoginViewController *vc = [[ChatLoginViewController alloc] init];
		tgRoot = [[UINavigationController alloc]initWithRootViewController:vc];
		vc.navigationController.navigationBar.hidden = true;
	}
	
	[self setUpTabBarItem:tgRoot image:[UIImage imageNamed:@"chat_tabbarIcon"] selectedImage:[UIImage imageNamed:@"chat_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"chat"]];
	tgRoot.tabBarItem.tag = self.chatTag;
	
	return tgRoot;
}
- (void)resetTabbarController {
    
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = [OCLanguage SWLocalizedString:@"wallet_done"];
    
    NSMutableArray *arr = [self.viewControllers mutableCopy];
	//market
    MarketsViewController *oneVC = [[MarketsViewController alloc]init];
    UINavigationController *first = [self getOneChildViewController:oneVC image:[UIImage imageNamed:@"markets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"markets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"markets"]];
    arr[0] = first;
	
    //chats
	
	UIViewController *tgRoot = [self resetChatsTab:[TelegramUserInfo.shareInstance.telegramLoginState isEqualToString:@"yes"]];
    arr[1] = tgRoot;
	
	int count = 3;
	NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
	if (![[NSString stringWithFormat:@"%@",config[@"isHiddenAssets"]] isEqualToString:@"yes"]) {
		//assets
		int count = (int)SwiftWalletManager.shared.walletCount;
		UINavigationController *assetNav;
		if (count == 0) {
			
			CreateWalletViewController *createVc = [[CreateWalletViewController alloc]init];
			assetNav = [self getOneChildViewController:createVc image:[UIImage imageNamed:@"assets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"assets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"assets"]];
			
		}else {
			AssetstViewController *twoVC = [[AssetstViewController alloc]init];
			assetNav = [self getOneChildViewController:twoVC image:[UIImage imageNamed:@"assets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"assets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"assets"]];
		}
		arr[2] = assetNav;
		count = 3;
	}else {
		count = 2;
	}
	
    //me
    MeViewController *meVc = [[MeViewController alloc]init];
     UINavigationController *meNav = [self getOneChildViewController:meVc image:[UIImage imageNamed:@"me_tabbarIcon"] selectedImage:[UIImage imageNamed:@"me_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"mine"]];
    arr[count] = meNav;
    NSUInteger badgeCount = SwiftNotificationManager.shared.notificationCount;
    meNav.tabBarItem.badgeValue = badgeCount == 0 ? nil : [NSString stringWithFormat:@"%zi", badgeCount];
    self.viewControllers = arr.copy;
   
}

- (void)setUpAllChildViewController{
    
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = [OCLanguage SWLocalizedString:@"wallet_done"];
    
	// 1.添加第一个控制器
	MarketsViewController *oneVC = [[MarketsViewController alloc]init];
    [self setUpOneChildViewController:oneVC image:[UIImage imageNamed:@"markets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"markets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"markets"]];

	// chat
	UIViewController *tgRoot = TGAppDelegateInstance.rootController;

	tgRoot.tabBarItem.tag = self.chatTag;
	[self addNormalChildViewController:tgRoot image:[UIImage imageNamed:@"chat_tabbarIcon"] selectedImage:[UIImage imageNamed:@"chat_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"chat"]];

	NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
	if (![[NSString stringWithFormat:@"%@",config[@"isHiddenAssets"]] isEqualToString:@"yes"]) {
		// assets
		int count = (int)SwiftWalletManager.shared.walletCount;
		if (count == 0) {
			
			CreateWalletViewController *createVc = [[CreateWalletViewController alloc]init];
			[self setUpOneChildViewController:createVc image:[UIImage imageNamed:@"assets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"assets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"assets"]];
			
		}else {
			AssetstViewController *twoVC = [[AssetstViewController alloc]init];
			[self setUpOneChildViewController:twoVC image:[UIImage imageNamed:@"assets_tabbarIcon"] selectedImage:[UIImage imageNamed:@"assets_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"assets"]];
		}
	}
	
	
	//me
	MeViewController *meVc = [[MeViewController alloc]init];
	[self setUpOneChildViewController:meVc image:[UIImage imageNamed:@"me_tabbarIcon"] selectedImage:[UIImage imageNamed:@"me_tabbarIcon_selected"] title:[OCLanguage SWLocalizedString:@"mine"]];
    NSUInteger badgeCount = SwiftNotificationManager.shared.notificationCount;
    meVc.navigationController.tabBarItem.badgeValue = badgeCount == 0 ? nil : [NSString stringWithFormat:@"%zi", badgeCount];
}

- (void)addNormalChildViewController:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{

	[self setUpTabBarItem:viewController image:image selectedImage:selectedImage title:title];
	
	[self addChildViewController:viewController];
}
/**
 *  添加一个Nav子控制器的方法
 */
- (void)setUpOneChildViewController:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{
	
	[self addChildViewController:[self getOneChildViewController:viewController image:image selectedImage:selectedImage title:title]];
}


- (UINavigationController *)getOneChildViewController:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{
    
    SwiftWalletNavViewController *navC = [[SwiftWalletNavViewController alloc]initWithRootViewController:viewController];
    navC.title = title;
	[self setUpTabBarItem:navC image:image selectedImage:selectedImage title:title];
    navC.navigationBar.hidden = true;
    viewController.navigationItem.title = title;
    
    return navC;
}

- (void)setUpTabBarItem:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{
	viewController.tabBarItem.image = image;
	viewController.tabBarItem.selectedImage = selectedImage;
	viewController.tabBarItem.title = title;
	[viewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]} forState:UIControlStateSelected];
	
}
    
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == self.chatTag) {
        IQKeyboardManager.sharedManager.enable = NO;
        IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
    } else {
        IQKeyboardManager.sharedManager.enable = YES;
        IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
    }
}

- (void)setMeBadge {
    if (self.viewControllers.count > 3) {
        if (SwiftNotificationManager.shared.notificationCount != 0) {
            self.viewControllers[3].tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",  (long)SwiftNotificationManager.shared.notificationCount];
        } else {
            self.viewControllers[3].tabBarItem.badgeValue = nil;
        }
    }
}

+ (void)resetTelegramLanguage{
	[TGAppDelegateInstance resetLocalization];
	[TGAppDelegateInstance updatePushRegistration];
}

+ (void)gotoChannel:(NSString *)link{
	[(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] forceNative:false keepStack:true];
}
@end
