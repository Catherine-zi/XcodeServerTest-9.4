#import <Foundation/Foundation.h>

#import "LegacyComponents.h"

#import "TLMetaScheme.h"

@interface TGInstantPage (TG)

+ (TGInstantPage *)parse:(TLPage *)pageDescription;

@end
