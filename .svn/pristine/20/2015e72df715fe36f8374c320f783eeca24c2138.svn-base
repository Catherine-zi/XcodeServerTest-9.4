//
//  SWTabBarController.h
//  TestAddFramework
//
//  Created by Avazu Holding on 2018/6/14.
//  Copyright © 2018年 Avazu Holding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGNavigationController.h"

@interface SWTabBarController : UITabBarController

+ (void)logout;
+ (TGNavigationController *)loginNavigationController;
- (void)resetTabbarController;
+ (void)resetTelegramLanguage;
- (UIViewController *)resetChatsTab:(BOOL)isLogin;
+ (void)gotoChannel:(NSString *)link;//跳到Telegram的channel

@property (nonatomic,assign)BOOL allowRotation;
@end
