#import <Foundation/Foundation.h>

#import "LegacyComponents.h"

#import "TLMetaScheme.h"

@interface TGChannelAdminRights (TG)

- (instancetype)initWithTL:(TLChannelAdminRights *)rights;
- (TLChannelAdminRights *)tlRights;

@end
