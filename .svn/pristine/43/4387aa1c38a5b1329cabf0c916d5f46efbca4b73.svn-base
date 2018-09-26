//
//  DQDTelegraphManager.h
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/6/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGResetAccountState.h"

extern NSString *TGDeviceProximityStateChangedNotification;

@interface DQDTelegraphManager : NSObject

@property (nonatomic, strong) NSString *pushToken;  //!<推送token

+ (instancetype)sharedInstance;

- (void)dqd_saveLoginStateWithDate:(int)date
                       phoneNumber:(NSString *)phoneNumber
                         phoneCode:(NSString *)phoneCode
                     phoneCodeHash:(NSString *)phoneCodeHash
                codeSentToTelegram:(bool)codeSentToTelegram
                  codeSentViaPhone:(bool)codeSentViaPhone
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             photo:(NSData *)photo
                 resetAccountState:(TGResetAccountState *)resetAccountState;

+ (NSString *)dqd_documentsPath;

- (void)dqd_updatePushRegistration;

@end
