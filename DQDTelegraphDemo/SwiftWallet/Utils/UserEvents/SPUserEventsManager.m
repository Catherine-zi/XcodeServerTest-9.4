//
//  SPUserEventsManager.m
//  SwiftPhoto
//
//  Created by victor on 2017/9/15.
//  Copyright © 2017年 DotC United. All rights reserved.
//

#import "SPUserEventsManager.h"
#import "DUDataReport.h"
#import "MTA.h"
#import "MTAConfig.h"

NSString *SPUECTimeLabel = @"timeInterval";
NSString *SPUECEventCountLabel = @"eventCounts";

@interface SPUserEventsManager ()

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *startChildDate;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *eventCountDictionary;
@property (nonatomic, strong) dispatch_queue_t workerQueue;

@end

@implementation SPUserEventsManager

+ (SPUserEventsManager *)sharedManager {
    static SPUserEventsManager *_sManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sManager = [[SPUserEventsManager alloc] init];
    });
    return _sManager;
}

- (instancetype)init {
    self = [super init];
    if (!self) { return nil; }
    
    self.workerQueue = dispatch_queue_create("com.cryptohubapp.info", DISPATCH_QUEUE_CONCURRENT);
    self.eventCountDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    
    return self;
}

#pragma mark - Public Method
- (void)startTimer {
    dispatch_barrier_async(self.workerQueue, ^{
        self.startDate = [NSDate date];
    });
}

- (NSNumber *)endTimer {
    __block NSNumber *timeInterval = nil;
    dispatch_sync(self.workerQueue, ^{
        timeInterval = [NSNumber numberWithDouble:ABS([self.startDate timeIntervalSinceNow])];
    });
    return timeInterval;
}

- (void)startChildTimer {
    dispatch_barrier_async(self.workerQueue, ^{
        self.startChildDate = [NSDate date];
    });
}

- (NSNumber *)endChildTimer {
    __block NSNumber *timeInterval = nil;
    dispatch_sync(self.workerQueue, ^{
        timeInterval = [NSNumber numberWithDouble:ABS([self.startChildDate timeIntervalSinceNow])];
    });
    return timeInterval;
}

//- (void)addCountForEvent:(NSString *)event {
//    if (![[self allEventsInDictionary] containsObject:event]) {
//        [self setCount:1 forEvent:event];
//    } else {
//        NSUInteger newCount = [self eventCountForSpecialEvent:event] + 1;
//        [self setCount:newCount forEvent:event];
//    }
//    [MTA trackCustomKeyValueEvent:event props:nil];
//}

- (NSDictionary<NSString *, NSNumber *> *)allEventsAndCount {
    __block NSDictionary *dict = nil;
    dispatch_sync(self.workerQueue, ^{
        dict = [NSDictionary dictionaryWithDictionary:self.eventCountDictionary];
    });
    return dict;
}

- (void)removeAllEventsAndCounts {
    dispatch_barrier_async(self.workerQueue, ^{
       [self.eventCountDictionary removeAllObjects];
    });
}

//+ (NSString *)retrieveCategoryForEvent:(NSString *)event {

//}

#pragma mark - Private Method
- (NSArray<NSString *> *)allEventsInDictionary {
    __block NSArray<NSString *> *allEvents = nil;
    dispatch_sync(self.workerQueue, ^{
        allEvents = self.eventCountDictionary.allKeys;
    });
    return allEvents;
}

- (NSUInteger)eventCountForSpecialEvent:(NSString *)event {
    __block NSNumber *eventCount = nil;
    dispatch_sync(self.workerQueue, ^{
        eventCount = self.eventCountDictionary[event];
    });
    return eventCount.unsignedIntegerValue;
}

- (void)setCount:(NSUInteger)eventCount forEvent:(NSString *)event {
    dispatch_barrier_async(self.workerQueue, ^{
        self.eventCountDictionary[event] = @(eventCount);
    });
}

//=====================

- (void)addCountForEvent:(NSString *)event {
    [MTA trackCustomKeyValueEvent:event props:nil];

    [DUDataReport eventWithCat:@"UI"
                           act:event
                           lab:nil
                         extra:nil
                           eid:nil];
}
//带参数的埋点
- (void)trackEventAction:(NSString *)event_id eventPrame:(NSString *)prame {
   
    [MTA trackCustomKeyValueEvent:event_id
                            props:[NSDictionary dictionaryWithObjectsAndKeys: prame, @"label", nil]];
 
    [DUDataReport eventWithCat:@"UI"
                           act:event_id
                           lab:nil
                         extra:[NSDictionary dictionaryWithObjectsAndKeys: prame, @"label", nil]
                           eid:nil];
}
    
- (BOOL)checkNeedUpdateToday:(NSString *)event_id {
    NSDate *lastDate = NSDate.date;
    id temp = [[NSUserDefaults standardUserDefaults] objectForKey:event_id];
    if ([temp isKindOfClass:[NSDate class]]) {
        lastDate = (NSDate *)temp;
        NSCalendar *calendar = NSCalendar.currentCalendar;
        if ([calendar isDateInToday:lastDate]) {
            return false;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:NSDate.date forKey:event_id];
    return true;
}

@end
