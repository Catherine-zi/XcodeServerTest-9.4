//
//  DUDataReport.h
//  GoGoBuy
//
//  Created by QianGuoqiang on 16/10/14.
//  Copyright © 2016年 GoGoBuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DUDataReport : NSObject

/**
 *  使用前请先设置好上报的地址
 *
 */
+ (void)setServerURL:(NSURL *)serverURL;

// 配置
+ (void)setTunnelID:(NSString *)tunnelID;
+ (void)setDeviceID:(NSString *)deviceID;
+ (void)setLati:(NSString *)lati longi:(NSString *)longi;

/**
 *  设置ASIdentifierManager的advertisingIdentifier
 *
 */
+ (void)setADID:(NSString *)adid;

+ (void)setDebug:(BOOL)debug;

/**
 *  SDK会自动生成设备唯一ID, 如果App有自己的设备唯一ID，需要使用setDeviceID:覆盖SDK的设备唯一ID
 *
 */
+ (NSString *)deviceID;

+ (NSString *)bid;

// 文档接口
+ (void)sendDailyActive;
+ (void)sendRealActive;


+ (void)trackEventWithCategory:(NSString *)cat action:(NSString *)act label:(NSString *)lab value:(NSString *)val;
+ (void)eventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab extra:(NSDictionary *)extra eid:(NSString *)eid;
+ (void)eventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab val:(NSString *)val extra:(NSDictionary *)extra eid:(NSString *)eid;

+ (void)pageBeginWithName:(NSString *)pageName ext:(NSDictionary *)ext;
+ (void)pageEndWithName:(NSString *)pageName;

+ (void)setPropertyWithName:(NSString *)name value:(NSString *)value;
+ (void)setPropertysWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary;

/**
 *  发送特定内容到指定服务器
 *
 *  @param content    要发送的内容
 *  @param url        服务器URL
 *  @param completion 发送成功时的回调
 */
+ (void)sendContent:(id)content toURL:(NSURL *)url completion:(void (^)(void))completion;


@end
