#import <UIKit/UIKit.h>

#import "LegacyComponents.h"

#import "TGStickerPackPreviewView.h"

#import "TGStickerPack.h"

@interface TGStickerPackPreviewWindow : TGOverlayControllerWindow

@property (nonatomic, strong, readonly) TGStickerPackPreviewView *view;

- (instancetype)initWithManager:(id<LegacyComponentsOverlayWindowManager>)manager parentController:(TGViewController *)parentController stickerPack:(TGStickerPack *)stickerPack;

@end
