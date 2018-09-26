//
//  SPAESEncrypt.m
//  SwiftPhoto
//
//  Created by victor on 2017/6/21.
//  Copyright © 2017年 DotC United. All rights reserved.
//

#import "SPAESEncrypt.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

NSString *const        SP_AESCryptorVersion    = @"1";
NSString *const        SP_AESEncryptKey        = @"EncryptKey";
NSString *const        SP_AESDynamicKey        = @"DynamicKey";

const NSInteger       SP_DynamicKeyLength     = 8;

static NSString *const SP_kAESAllLetters       = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//static NSString *const SP_kServerSolidKey      = @"8vA6au9Z";
static NSString *const SP_kServerSolidKey      = @"8dotc69Z";
static NSString *const SP_OriginalVector       = @"0x0000000000000000"; //16位16进制初始向量，可以自行修改

@implementation SPAESEncrypt

NSString* generateRandomLettersForSpecificLength(NSUInteger length)
{
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        [result appendFormat:@"%C", [SP_kAESAllLetters characterAtIndex:arc4random() % SP_kAESAllLetters.length]];
    }
    
    return [result copy];
}

+ (NSDictionary *)generateEncryptDynamicKeyDictionary {
    NSString *dynamicKey = generateRandomLettersForSpecificLength(8);
    NSString *encryptKey = [dynamicKey stringByAppendingString:SP_kServerSolidKey];
    return @{
             SP_AESDynamicKey: dynamicKey,
             SP_AESEncryptKey: encryptKey
             };
}

+ (NSString *)generateDecryptKeyFromDynamicKey:(NSString *)dynamicKey {
    return [dynamicKey stringByAppendingString:SP_kServerSolidKey];
}

+ (NSString *)SP_AES128EncryptText:(NSString *)plainText withEncryptKey:(NSString *)encryptKey {
    // MD5加密算法处理密钥
    const char * keyPtr = [encryptKey UTF8String];
    unsigned char md5[16] = {0};
    CC_MD5(keyPtr, (unsigned int)strlen(keyPtr), md5);
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    if (SP_OriginalVector) {
        [SP_OriginalVector getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,  //CBC模式，PKCS7Padding
                                          md5,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted
                                          );
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return [GTMBase64 stringByEncodingData:resultData];
    } else {
        free(buffer);
        return nil;
    }
}

+ (NSString *)SP_AES128DecryptText:(NSString *)encryptText withDecryptKey:(NSString *)decryptKey {
    // MD5加密算法处理Key
    const char *keyPtr = [decryptKey UTF8String];
    unsigned char md5[16] = {0};
    CC_MD5(keyPtr, (unsigned int)strlen(keyPtr), md5);
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    if (SP_OriginalVector) {
        [SP_OriginalVector getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
                                          kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,  //CBC模式，PKCS7Padding
                                          md5,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted
                                          );
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    } else {
        free(buffer);
        return nil;
    }
}

+ (NSString *)SP_MD5EncryptText:(NSString *)plainText {
    const char *cStr = [plainText UTF8String];
    unsigned char result[16] = {0};
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    NSMutableString *resultText = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultText appendFormat:@"%02x", result[i]];  // 16进制处理（输出32位16进制字符串）
    }
    
    return [resultText copy];
}

@end
