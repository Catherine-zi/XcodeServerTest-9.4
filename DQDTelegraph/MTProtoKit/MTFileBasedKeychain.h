#import <Foundation/Foundation.h>

#import "MTKeychain.h"

@interface MTFileBasedKeychain : NSObject <MTKeychain>

+ (instancetype)unencryptedKeychainWithName:(NSString *)name documentsPath:(NSString *)documentsPath;
+ (instancetype)keychainWithName:(NSString *)name documentsPath:(NSString *)documentsPath;

@end
