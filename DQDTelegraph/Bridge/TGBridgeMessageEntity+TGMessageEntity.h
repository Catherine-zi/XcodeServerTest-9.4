#import "TGBridgeMessageEntities.h"

#import "LegacyComponents.h"

@interface TGBridgeMessageEntity (TGMessageEntity)

+ (TGBridgeMessageEntity *)entityWithTGMessageEntity:(TGMessageEntity *)entity;

@end
