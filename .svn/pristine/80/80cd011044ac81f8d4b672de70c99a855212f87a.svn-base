#import <Foundation/Foundation.h>

#import "SSignalKit.h"

#import "TGShareContext.h"

@interface TGUnauthorizedShareContext : NSObject

@end

@interface TGEncryptedShareContext : NSObject

@property (nonatomic, readonly) bool simplePassword;
@property (nonatomic, readonly) bool allowTouchId;
@property (nonatomic, copy, readonly) bool (^verifyPassword)(NSString *);

@end

@interface TGShareContextSignal : NSObject

+ (SSignal *)shareContext;

@end
