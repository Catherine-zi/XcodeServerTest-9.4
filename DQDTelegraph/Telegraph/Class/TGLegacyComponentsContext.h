#import <Foundation/Foundation.h>

#import "LegacyComponents.h"

@interface TGLegacyComponentsContext : NSObject <LegacyComponentsContext>

+ (TGLegacyComponentsContext *)shared;

@end
