//
//  main.m
//  DQDTelegraphDemo
//
//  Created by Avazu on 2018/5/30.
//  Copyright © 2018年 Avazu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGAppDelegate.h"
#import "TGApplication.h"
#import "TGDatabase.h"

int main(int argc, char * argv[]) {
    mainLaunchTimestamp = CFAbsoluteTimeGetCurrent();
    applicationStartupTimestamp = mainLaunchTimestamp;
    
    @autoreleasepool
    {
        [TGDatabase setDatabaseName:@"tgdata"];
        return UIApplicationMain(argc, argv, @"TGApplication", @"TGAppDelegate");
    }
}
