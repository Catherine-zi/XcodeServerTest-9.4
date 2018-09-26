#import <Foundation/Foundation.h>

#import "LegacyComponents.h"

#import "TGStickerPack.h"

@interface TGStickerPacksArchive : NSObject <PSCoding>

@property (nonatomic, strong) NSArray<TGStickerPack *> *packs;


@end
