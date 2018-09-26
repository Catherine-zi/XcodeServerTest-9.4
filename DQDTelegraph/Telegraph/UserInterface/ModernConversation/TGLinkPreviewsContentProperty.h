#import "LegacyComponents.h"

@interface TGLinkPreviewsContentProperty : NSObject <PSCoding>

@property (nonatomic, readonly) bool disableLinkPreviews;

- (instancetype)initWithDisableLinkPreviews:(bool)disableLinkPreviews;

@end
