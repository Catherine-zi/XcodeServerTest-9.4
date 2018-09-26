#import "TGModernViewModel.h"

#import "SSignalKit.h"

@interface TGInlineVideoModel : TGModernViewModel

@property (nonatomic, strong) SSignal *videoPathSignal;

@end
