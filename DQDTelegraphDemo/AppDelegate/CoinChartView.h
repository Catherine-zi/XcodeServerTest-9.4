//
//  CoinChartView.h
//  DQDTelegraphDemo
//
//  Created by Avazu Holding on 2018/6/28.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAChartLoadFinished<NSObject>;

- (void)chartFinishedLoad;
@end

@interface CoinChartView : UIView

@property (nonatomic,weak)id<AAChartLoadFinished> delegate;
- (void)addOptions:(NSArray *)dataArr timeType:(NSInteger)timeType isBTC:(BOOL)isBTC;//1小时，1天 ，，，全部
@end
