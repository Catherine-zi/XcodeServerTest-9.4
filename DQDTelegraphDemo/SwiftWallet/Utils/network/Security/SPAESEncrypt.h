//
//  SPAESEncrypt.h
//  SwiftPhoto
//
//  Created by victor on 2017/6/21.
//  Copyright © 2017年 DotC United. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const  SP_AESEncryptKey;
extern NSString *const  SP_AESDynamicKey;
extern NSString *const  SP_AESCryptorVersion;
extern const NSInteger SP_DynamicKeyLength;

@interface SPAESEncrypt : NSObject

+ (NSDictionary *)generateEncryptDynamicKeyDictionary;
+ (NSString *)generateDecryptKeyFromDynamicKey:(NSString *)dynamicKey;
+ (nullable NSString *)SP_AES128EncryptText:(NSString *)plainText withEncryptKey:(NSString *)encryptKey;
+ (nullable NSString *)SP_AES128DecryptText:(NSString *)encryptText withDecryptKey:(NSString *)decryptKey;
+ (NSString *)SP_MD5EncryptText:(NSString *)plainText;

@end

NS_ASSUME_NONNULL_END
