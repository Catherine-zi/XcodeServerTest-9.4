#import <Foundation/Foundation.h>

#import "MTContext.h"
#import "MTProto.h"
#import "MTRequestMessageService.h"
#import "SSignalKit.h"
#import "ApiLayer73.h"

@interface TGDatacenterConnectionContext : NSObject

@property (nonatomic, readonly) NSInteger datacenterId;
@property (nonatomic, strong, readonly) MTContext *mtContext;
@property (nonatomic, strong, readonly) MTProto *mtProto;
@property (nonatomic, strong, readonly) MTRequestMessageService *mtRequestService;

- (instancetype)initWithDatacenterId:(NSInteger)datacenterId mtContext:(MTContext *)mtContext mtProto:(MTProto *)mtProto mtRequestService:(MTRequestMessageService *)mtRequestService;

- (SSignal *)function:(Api73_FunctionContext *)functionContext;

@end

@interface TGPooledDatacenterConnectionContext : NSObject

@property (nonatomic, strong, readonly) TGDatacenterConnectionContext *context;
@property (nonatomic, copy, readonly) void (^returnContext)(TGDatacenterConnectionContext *);

- (instancetype)initWithDatacenterConnectionContext:(TGDatacenterConnectionContext *)context returnContext:(void (^)(TGDatacenterConnectionContext *))returnContext;

@end
