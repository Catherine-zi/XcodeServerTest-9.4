//
//  DQDTelegraphManager.m
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/6/4.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import "DQDTelegraphManager.h"
#import "NSOutputStream+TL.h"
#import "TGAccountSignals.h"

NSString *TGDeviceProximityStateChangedNotification = @"TGDeviceProximityStateChangedNotification";

@implementation DQDTelegraphManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DQDTelegraphManager * __singletion;
    dispatch_once(&once,^{__singletion = [[DQDTelegraphManager alloc] init];});
    return __singletion;
}

- (void)dqd_saveLoginStateWithDate:(int)date
                       phoneNumber:(NSString *)phoneNumber
                         phoneCode:(NSString *)phoneCode
                     phoneCodeHash:(NSString *)phoneCodeHash
                codeSentToTelegram:(bool)codeSentToTelegram
                  codeSentViaPhone:(bool)codeSentViaPhone
                         firstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             photo:(NSData *)photo
                 resetAccountState:(TGResetAccountState *)resetAccountState
{
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os open];
    
    uint8_t version = 3;
    [os write:&version maxLength:1];
    
    [os writeInt32:date];
    
    [os writeString:phoneNumber];
    [os writeString:phoneCode];
    [os writeString:phoneCodeHash];
    [os writeString:firstName];
    [os writeString:lastName];
    [os writeBytes:photo];
    [os writeInt32:codeSentToTelegram ? 1 : 0];
    [os writeInt32:codeSentViaPhone ? 1 : 0];
    
    if (resetAccountState != nil) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resetAccountState];
        int32_t length = (int32_t)data.length;
        [os writeInt32:length];
        [os writeData:data];
    } else {
        [os writeInt32:0];
    }
    
    [os close];
    
    NSData *data = [os currentBytes];
    NSString *documentsDirectory = [DQDTelegraphManager dqd_documentsPath];
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"state.data"] atomically:true];
}

+ (NSString *)dqd_documentsPath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      NSString *groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
                      
                      NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
                      if (groupURL != nil) {
                          NSString *documentsPath = [[groupURL path] stringByAppendingPathComponent:@"Documents"];
                          
                          [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:true attributes:nil error:NULL];
                          
                          path = documentsPath;
                      }
                      else {
                          path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
                      }
                  });
    
    return path;
}

- (void)dqd_updatePushRegistration {
    if (_pushToken != nil) {
        NSString *token = [[_pushToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [[TGAccountSignals registerDeviceToken:token voip:false] startWithNext:nil];
    }
}

@end
