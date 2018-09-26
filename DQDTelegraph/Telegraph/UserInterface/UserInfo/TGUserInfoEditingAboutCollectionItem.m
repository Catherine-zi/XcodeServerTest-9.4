#import "TGUserInfoEditingAboutCollectionItem.h"

#import "LegacyComponents.h"

#import "TGUserInfoEditingAboutCollectionItemView.h"

@implementation TGUserInfoEditingAboutCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        self.insets = UIEdgeInsetsMake(0.0f, 19.0f + TGScreenPixel, 0.0f, 0.0f);
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoEditingAboutCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize safeAreaInset:(UIEdgeInsets)safeAreaInset
{
    CGSize size = [super itemSizeForContainerSize:containerSize safeAreaInset:safeAreaInset];
    return CGSizeMake(size.width, MAX(size.height, 80.0f));
}

@end
