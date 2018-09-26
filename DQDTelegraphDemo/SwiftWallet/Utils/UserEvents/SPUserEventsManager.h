//
//  SPUserEventsManager.h
//  SwiftPhoto
//
//  Created by victor on 2017/9/15.
//  Copyright © 2017年 DotC United. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPUserEventsCollections.h"

extern NSString *SPUECTimeLabel;
extern NSString *SPUECEventCountLabel;

@interface SPUserEventsManager : NSObject

@property (class, nonatomic, readonly) SPUserEventsManager *sharedManager;

- (void)startTimer;
- (NSNumber *)endTimer;
- (void)startChildTimer;
- (NSNumber *)endChildTimer;
- (void)addCountForEvent:(NSString *)event;
- (NSDictionary<NSString *, NSNumber *> *)allEventsAndCount;
- (void)removeAllEventsAndCounts;

//+ (NSString *)retrieveCategoryForEvent:(NSString *)event;

- (void)trackEventAction:(NSString *)event_id eventPrame:(NSString *)prame;
    
- (BOOL)checkNeedUpdateToday:(NSString *)event_id;

@end
