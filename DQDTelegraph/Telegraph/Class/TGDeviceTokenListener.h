//
//  TGDeviceTokenListener.h
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/6/7.
//  Copyright © 2018年 Avazu. All rights reserved.
//

@protocol TGDeviceTokenListener <NSObject>

@required

- (void)deviceTokenRequestCompleted:(NSString *)deviceToken;

@end
