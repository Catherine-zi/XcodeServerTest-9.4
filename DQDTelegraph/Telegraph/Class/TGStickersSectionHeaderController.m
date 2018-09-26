#import "TGStickersSectionHeaderController.h"

NSString *const TGStickersSectionHeaderIdentifier = @"TGStickersSectionHeader";

@implementation TGStickersSectionHeaderController

- (NSString *)title
{
    //Avazu 20180607
//    return self.titleLabel.text;
    return @"";
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

+ (NSString *)identifier
{
    return TGStickersSectionHeaderIdentifier;
}

@end
