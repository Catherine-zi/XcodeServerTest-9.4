#import <Foundation/Foundation.h>

#import "MTContext.h"
#import "MTProto.h"
#import "MTRequestMessageService.h"
#import "SSignalKit.h"

#import "SSignalKit.h"
#import "ApiLayer73.h"

#import "TGModernCache.h"
#import "TGMemoryImageCache.h"
#import "TGMemoryCache.h"

#import "TGDatacenterConnectionContext.h"

@class TGLegacyDatabase;

@interface TGShareContext : NSObject

@property (nonatomic, strong, readonly) NSURL *containerUrl;

@property (nonatomic, readonly) int32_t clientUserId;

@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;
@property (nonatomic, strong, readonly) TGLegacyDatabase *legacyDatabase;

@property (nonatomic, strong, readonly) TGModernCache *persistentCache;
@property (nonatomic, strong, readonly) TGMemoryImageCache *memoryImageCache;
@property (nonatomic, strong, readonly) TGMemoryCache *memoryCache;
@property (nonatomic, strong, readonly) SThreadPool *sharedThreadPool;

- (instancetype)initWithContainerUrl:(NSURL *)containerUrl mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService clientUserId:(int32_t)clientUserId legacyDatabase:(TGLegacyDatabase *)legacyDatabase;

- (SSignal *)function:(Api73_FunctionContext *)functionContext;
- (SSignal *)datacenter:(NSInteger)datacenterId function:(Api73_FunctionContext *)functionContext;

- (SSignal *)connectionContextForDatacenter:(NSInteger)datacenterId;

@end
