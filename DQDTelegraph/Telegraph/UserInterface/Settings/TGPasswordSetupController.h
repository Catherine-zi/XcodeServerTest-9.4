#import "LegacyComponents.h"

#import "SSignalKit.h"

@interface TGPasswordSetupController : TGViewController

@property (nonatomic, copy) void (^completion)(NSString *);

- (instancetype)initWithSetupNew:(bool)setupNew;

@end
