//
//  DUDataReport.m
//  GoGoBuy
//
//  Created by QianGuoqiang on 16/10/14.
//  Copyright © 2016年 GoGoBuy. All rights reserved.
//

#import "DUDataReport.h"
#import <Security/Security.h>
#import "DUDBManager.h"
#import <sqlite3.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "DUReachability.h"

//
//  FLAESEncrypt.h
//  SwiftLive
//
//  Created by 查俊松 on 16/3/23.
//  Copyright © 2016年 DotC_United. All rights reserved.
//

@interface DUAESEncrypt : NSObject

// 获取加密版本信息
+ (NSString *)cryptorVersion;
// AES128加密
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey;
// AES128解密
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey;

@end

#define gIv @"0x0000000000000000" //16位16进制初始向量，可以自行修改
#define kCryptorVersion @"1"  //加密版本信息

@implementation DUAESEncrypt

#pragma mark 获取加密版本信息
+ (NSString *)cryptorVersion
{
    return kCryptorVersion;
}

#pragma mark AES128加密
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey
{
    // MD5加密算法处理key
    const char *keyPtr = [gkey UTF8String];
    unsigned char md5[16] = {0};
    CC_MD5(keyPtr, (unsigned int)strlen(keyPtr), md5);
    
    /**
     char keyPtr[kCCKeySizeAES128+1];
     memset(keyPtr, 0, sizeof(keyPtr));
     [gkey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     */
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    if (gIv) {
        [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,  //CBC模式，PKCS7Padding
                                          md5,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        
        return [resultData base64EncodedStringWithOptions:0];
    }
    free(buffer);
    return nil;
}

#pragma mark AES128解密
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey
{
    // MD5加密算法处理key
    const char *keyPtr = [gkey UTF8String];
    unsigned char md5[16] = {0};
    CC_MD5(keyPtr, (unsigned int)strlen(keyPtr), md5);
    
    /**
     char keyPtr[kCCKeySizeAES128+1];
     memset(keyPtr, 0, sizeof(keyPtr));
     [gkey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
     */
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    if (gIv) {
        [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:encryptText options:0];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,  //CBC模式，PKCS7Padding
                                          md5,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

@end

//
//  KeychainWrapper.h
//  Apple's Keychain Services Programming Guide
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

@interface DUKeychainWrapper : NSObject

- (void)mySetObject:(id)inObject forKey:(id)key;
- (id)myObjectForKey:(id)key;
- (void)writeToKeychain;

@end

//Unique string used to identify the keychain item:
static const UInt8 kKeychainItemIdentifier[]    = "ios.du.datareport\0";

@interface DUKeychainWrapper ()

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

@end

@interface DUKeychainWrapper (PrivateMethods)

//The following two methods translate dictionaries between the format used by
// the view controller (NSString *) and the Keychain Services API:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
// Method used to write data to the keychain:
- (void)writeToKeychain;

@end


@implementation DUKeychainWrapper

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        
        OSStatus keychainErr = noErr;
        // Set up the keychain search dictionary:
        _genericPasswordQuery = [[NSMutableDictionary alloc] init];
        
        // This keychain item is a generic password.
        [_genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword
                                  forKey:(__bridge id)kSecClass];
        
        // The kSecAttrGeneric attribute is used to store a unique string that is used
        // to easily identify and find this keychain item. The string is first
        // converted to an NSData object:
        NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier
                                                length:strlen((const char *)kKeychainItemIdentifier)];
        [_genericPasswordQuery setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
        
        // Return the attributes of the first match only:
        [_genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        
        // Return the attributes of the keychain item (the password is
        //  acquired in the secItemFormatToDictionary: method):
        [_genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue
                                  forKey:(__bridge id)kSecReturnAttributes];
        
        //Initialize the dictionary used to hold return data from the keychain:
        CFMutableDictionaryRef outDictionary = nil;
        // If the keychain item exists, return the attributes of the item:
        keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                                          (CFTypeRef *)&outDictionary);
        
        if (keychainErr == noErr) {
            // Convert the data dictionary into the format used by the view controller:
            self.keychainData = [self secItemFormatToDictionary:(__bridge_transfer NSMutableDictionary *)outDictionary];
        } else if (keychainErr == errSecItemNotFound) {
            // Put default values into the keychain if no matching
            // keychain item is found:
            [self resetKeychainItem];
            if (outDictionary) CFRelease(outDictionary);
        } else {
            // Any other error is unexpected.
            NSAssert(NO, @"Serious error.\n");
            if (outDictionary) CFRelease(outDictionary);
        }
    }
    
    return self;
}

// Implement the mySetObject:forKey method, which writes attributes to the keychain:
- (void)mySetObject:(id)inObject forKey:(id)key
{
    if (inObject == nil) return;
    id currentObject = [_keychainData objectForKey:key];
    if (![currentObject isEqual:inObject])
    {
        [_keychainData setObject:inObject forKey:key];
        [self writeToKeychain];
    }
}

// Implement the myObjectForKey: method, which reads an attribute value from a dictionary:
- (id)myObjectForKey:(id)key
{
    return [_keychainData objectForKey:key];
}

// Reset the values in the keychain item, or create a new item if it
// doesn't already exist:

- (void)resetKeychainItem
{
    if (!_keychainData) //Allocate the keychainData dictionary if it doesn't exist yet.
    {
        self.keychainData = [[NSMutableDictionary alloc] init];
    }
    else if (_keychainData)
    {
        // Format the data in the keychainData dictionary into the format needed for a query
        //  and put it into tmpDictionary:
        NSMutableDictionary *tmpDictionary =
        [self dictionaryToSecItemFormat:_keychainData];
        // Delete the keychain item in preparation for resetting the values:
        OSStatus errorcode = SecItemDelete((__bridge CFDictionaryRef)tmpDictionary);
        NSAssert(errorcode == noErr, @"Problem deleting current keychain item." );
    }
    
    // Default generic data for Keychain Item:
    [_keychainData setObject:@"Item label" forKey:(__bridge id)kSecAttrLabel];
    [_keychainData setObject:@"Item description" forKey:(__bridge id)kSecAttrDescription];
    [_keychainData setObject:@"Account" forKey:(__bridge id)kSecAttrAccount];
    [_keychainData setObject:@"Service" forKey:(__bridge id)kSecAttrService];
    [_keychainData setObject:@"Your comment here." forKey:(__bridge id)kSecAttrComment];
    [_keychainData setObject:@"" forKey:(__bridge id)kSecValueData];
}


// Implement the dictionaryToSecItemFormat: method, which takes the attributes that
// you want to add to the keychain item and sets up a dictionary in the format
// needed by Keychain Services:
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for a keychain item search.
    
    // Create the return dictionary:
    NSMutableDictionary *returnDictionary =
    [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the keychain item class and the generic attribute:
    NSData *keychainItemID = [NSData dataWithBytes:kKeychainItemIdentifier
                                            length:strlen((const char *)kKeychainItemIdentifier)];
    [returnDictionary setObject:keychainItemID forKey:(__bridge id)kSecAttrGeneric];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Convert the password NSString to NSData to fit the API paradigm:
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding]
                         forKey:(__bridge id)kSecValueData];
    return returnDictionary;
}

// Implement the secItemFormatToDictionary: method, which takes the attribute dictionary
//  obtained from the keychain item, acquires the password from the keychain, and
//  adds it to the attribute dictionary:
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
    // This method must be called with a properly populated dictionary
    // containing all the right key/value pairs for the keychain item.
    
    // Create a return dictionary populated with the attributes:
    NSMutableDictionary *returnDictionary = [NSMutableDictionary
                                             dictionaryWithDictionary:dictionaryToConvert];
    
    // To acquire the password data from the keychain item,
    // first add the search key and class attribute required to obtain the password:
    [returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Then call Keychain Services to get the password:
    CFDataRef passwordData = NULL;
    OSStatus keychainError = noErr; //
    keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary,
                                        (CFTypeRef *)&passwordData);
    if (keychainError == noErr)
    {
        // Remove the kSecReturnData key; we don't need it anymore:
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
        
        // Convert the password to an NSString and add it to the return dictionary:
        NSString *password = [[NSString alloc] initWithBytes:[(__bridge_transfer NSData *)passwordData bytes]
                                                      length:[(__bridge NSData *)passwordData length] encoding:NSUTF8StringEncoding];
        [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
    }
    // Don't do anything if nothing is found.
    else if (keychainError == errSecItemNotFound) {
        NSAssert(NO, @"Nothing was found in the keychain.\n");
        if (passwordData) CFRelease(passwordData);
    }
    // Any other error is unexpected.
    else
    {
        NSAssert(NO, @"Serious error.\n");
        if (passwordData) CFRelease(passwordData);
    }
    
    return returnDictionary;
}

// could be in a class
- (void)writeToKeychain {
    
    CFDictionaryRef attributes = nil;
    NSMutableDictionary *updateItem = nil;
    
    // If the keychain item already exists, modify it:
    if (SecItemCopyMatching((__bridge CFDictionaryRef)_genericPasswordQuery,
                            (CFTypeRef *)&attributes) == noErr)
    {
        // First, get the attributes returned from the keychain and add them to the
        // dictionary that controls the update:
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary *)attributes];
        
        // Second, get the class value from the generic password query dictionary and
        // add it to the updateItem dictionary:
        [updateItem setObject:[_genericPasswordQuery objectForKey:(__bridge id)kSecClass]
                       forKey:(__bridge id)kSecClass];
        
        // Finally, set up the dictionary that contains new values for the attributes:
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:_keychainData];
        //Remove the class--it's not a keychain attribute:
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
        
        // You can update only a single keychain item at a time.
        OSStatus errorcode = SecItemUpdate(
                                           (__bridge CFDictionaryRef)updateItem,
                                           (__bridge CFDictionaryRef)tempCheck);
        NSAssert(errorcode == noErr, @"Couldn't update the Keychain Item." );
    }
    else
    {
        // No previous item found; add the new item.
        // The new value was added to the keychainData dictionary in the mySetObject routine,
        // and the other values were added to the keychainData dictionary previously.
        // No pointer to the newly-added items is needed, so pass NULL for the second parameter:
        OSStatus errorcode = SecItemAdd(
                                        (__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:_keychainData],
                                        NULL);
        NSAssert(errorcode == noErr, @"Couldn't add the Keychain Item." );
        if (attributes) CFRelease(attributes);
    }
    
}


@end

@protocol ModelSQL <NSObject>

- (NSString *)saveSQL;

@end

@interface DUPage : NSObject <ModelSQL>

@property (nonatomic, copy) NSString *pageName;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

- (instancetype)initWithPageName:(NSString *)pageName;

@end

@implementation DUPage

- (instancetype)initWithPageName:(NSString *)pageName
{
    self = [super init];
    
    if (self) {
        self.pageName = pageName;
        self.startDate = [NSDate date];
    }
    
    return self;
}

- (NSString *)saveSQL
{
    NSNumber *start = @([self.startDate timeIntervalSince1970] * 1000);
    NSNumber *end = @([self.endDate timeIntervalSince1970] * 1000);
    
    return [NSString stringWithFormat:@"INSERT INTO \"page\"  (name, start_date, end_date) VALUES ('%@', %llu, %llu);", self.pageName, [start unsignedLongLongValue], [end unsignedLongLongValue]];
}

@end

@interface DUSession : NSObject <ModelSQL>

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@end

@implementation DUSession

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.startDate = [NSDate date];
    }
    
    return self;
}

- (NSString *)saveSQL
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *date = [dateFormatter stringFromDate:self.startDate];
    
    NSNumber *interval = @([self.endDate timeIntervalSinceDate:self.startDate] * 1000);
    
    return [NSString stringWithFormat:@"INSERT INTO \"usage\"  (date, time_long) VALUES ('%@', %llu);", date, [interval unsignedLongLongValue]];
}

@end

@interface DUEvent : NSObject <ModelSQL>

@property (nonatomic, copy) NSString *act;
@property (nonatomic, copy) NSString *cat;
@property (nonatomic, copy) NSString *lab;
@property (nonatomic, copy) NSString *val;
@property (nonatomic, copy) NSDictionary *extra;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) NSInteger cnt;
@property (nonatomic, copy) NSString *eid;

- (NSString *)eventKey;
+ (instancetype)eventWithAction:(NSString *)action category:(NSString *)category label:(NSString *)label val:(NSString *)val extra:(NSDictionary *)extra count:(NSInteger)count eid:(NSString *)eid;

@end

@implementation DUEvent

+ (instancetype)eventWithAction:(NSString *)action category:(NSString *)category label:(NSString *)label val:(NSString *)val extra:(NSDictionary *)extra count:(NSInteger)count eid:(NSString *)eid
{
    DUEvent *event = [DUEvent new];
    
    event.act = action ? : @"";
    event.cat = category ? : @"";
    event.lab = label ? : @"";
    event.extra = extra ? : @{};
    event.startDate = [NSDate date];
    event.cnt = count;
    event.eid = eid ? : @"";
    event.val = val ? : @"";
    
    return event;
    
}

- (NSString *)eventKey
{
    return [NSString stringWithFormat:@"%@_%@_%@", self.cat , self.act, self.lab];
}

- (NSString *)saveSQL
{
    if (self.cnt > 0) {
        // 更新
        
    } else {
        // 插入
        
        NSString *extra = @"";
        
        if (self.extra) {
            NSData *extraData = [NSJSONSerialization dataWithJSONObject:self.extra options:0 error:nil];
            
            if (extraData) {
                extra = [[NSString alloc] initWithData:extraData encoding:4];
            }
        }
        
        NSNumber *createDate = @([self.startDate timeIntervalSince1970] * 1000);
        
        return [NSString stringWithFormat:@"INSERT INTO \"event\"  (act, cat, extra, lab, create_date, cnt, event_key, eid, val) VALUES ('%@', '%@', '%@', '%@', %llu, %@, '%@', '%@', '%@');", self.act, self.cat, extra, self.lab, [createDate unsignedLongLongValue], @(self.cnt), self.eventKey, self.eid, self.val];
    }
    
    return nil;
}


@end

static NSString * const DUDataReportUserDefaultKey = @"DUDataReportUserDefaultKey";

/**
 *  活跃的上报时间
 */
static NSString * const DUDataReportLatestActiveDateKey = @"DUDataReportLatestActiveDateKey";
static NSString * const DUDataReportLatestActiveEventKey = @"DUDataReportLatestActiveEventKey";

/**
 *  时长的最后上报时间
 */
static NSString * const DUDataReportLatestUseTimeLongDateKey = @"DUDataReportLatestUseTimeLongDateKey";

/**
 *  事件最后上报的时间
 */
static NSString * const DUDataReportLatestEventDateKey = @"DUDataReportLatestEventDateKey";

/**
 *  页面时长最后上报的时间
 */
static NSString * const DUDataReportLatestPageEventDateKey = @"DUDataReportLatestPageEventDateKey";

/**
 *  App安装时间
 */
static NSString * const DUDataReportInstallDateKey = @"DUDataReportInstallDateKey";

@interface DUDataReport ()

@property (nonatomic, strong) DUKeychainWrapper *keychainWrapper;

@property (nonatomic, copy) NSString *accessKey;
@property (nonatomic, copy) NSString *tunnelID;

@property (nonatomic, copy) NSString *adid;

@property (nonatomic) BOOL debug;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *bid;
@property (nonatomic, strong) NSNumber *firstInstallTime;

@property (nonatomic, copy) NSString *lati;
@property (nonatomic, copy) NSString *longi;

@property (nonatomic, strong) NSURL *serverURL;

@property (nonatomic, strong) DUPage *trackingPage;

@property (nonatomic, strong) DUSession *session;

@property (nonatomic, strong) DUDBManager *dbManager;

@property (nonatomic, strong) DUReachability *reachability;

/**
 *  SQLite运行队列
 */
@property (nonatomic, strong) dispatch_queue_t sqlQueue;

@property (nonatomic) BOOL isNewUser;

@end

@implementation DUDataReport


#pragma mark - Public API

+ (void)sendContent:(id)content toURL:(NSURL *)url completion:(void (^)(void))completion
{
    [[self sharedInstance] sendContent:content toURL:url completion:completion];
}

+ (void)sendDailyActive
{
    [[self sharedInstance] sendActiveWithType:0];
}

+ (void)sendRealActive
{
    [[self sharedInstance] sendActiveWithType:1];
}

+ (void)countableEventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab count:(NSInteger)count
{
//    DUEvent *event = [DUEvent eventWithAction:act category:cat label:lab extra:nil count:count];
    
    [[self sharedInstance] log:@"No implement"];
}

+ (void)eventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab extra:(NSDictionary *)extra eid:(NSString *)eid
{
    [self eventWithCat:cat act:act lab:lab val:nil extra:extra eid:eid];
}

+ (void)eventWithCat:(NSString *)cat act:(NSString *)act lab:(NSString *)lab val:(NSString *)val extra:(NSDictionary *)extra eid:(NSString *)eid
{
    DUEvent *event = [DUEvent eventWithAction:act category:cat label:lab val:val extra:extra count:0 eid:eid];
    
    // 插入到数据库
    [[self sharedInstance] insertModelSQLObject:event];
    
    [[self sharedInstance] sendEvent];
}

+ (void)trackEventWithCategory:(NSString *)cat action:(NSString *)act label:(NSString *)lab value:(NSString *)val {
    if (val && (val.length > 0)) {
        [self eventWithCat:cat act:act lab:lab val:val extra:nil eid:nil];
    } else {
        [self eventWithCat:cat act:act lab:lab extra:nil eid:nil];
    }
}

+ (void)pageBeginWithName:(NSString *)pageName ext:(NSDictionary *)ext
{
    [self sharedInstance].trackingPage = [[DUPage alloc] initWithPageName:pageName];
}

+ (void)pageEndWithName:(NSString *)pageName
{
    if ([[self sharedInstance].trackingPage.pageName isEqualToString:pageName]) {
        [self sharedInstance].trackingPage.endDate = [NSDate date];
        
        // 插入到数据库
        [[self sharedInstance] insertModelSQLObject:[self sharedInstance].trackingPage];
        
    } else {
        // 丢弃错误数据
        [self sharedInstance].trackingPage = nil;
    }
}

+ (void)setPropertyWithName:(NSString *)name value:(NSString *)value
{
    [self setPropertysWithDictionary:@{name : value}];
}

+ (void)setPropertysWithDictionary:(NSDictionary<NSString *, NSString *> *)dictionary
{
    NSDictionary *properties = @{@"g_properties" : dictionary};
    
    [[self sharedInstance] sendContent:properties toPath:@"nw/np" completion:nil];
}

+ (void)setServerURL:(NSURL *)serverURL
{
    NSParameterAssert(serverURL != nil);
    
    [self sharedInstance].serverURL = serverURL;
}

+ (void)setAccessKey:(NSString *)accessKey
{
    NSParameterAssert(accessKey != nil);
    
    [self sharedInstance].accessKey = accessKey;
}

+ (void)setTunnelID:(NSString *)tunnelID
{
    NSParameterAssert(tunnelID != nil);
    
    [self sharedInstance].tunnelID = tunnelID;
}

+ (void)setDebug:(BOOL)debug
{
    [self sharedInstance].debug = debug;
}

+ (void)setDeviceID:(NSString *)deviceID
{
    NSParameterAssert(deviceID != nil);
    
    [self sharedInstance].deviceID = deviceID;
}

+ (void)setLati:(NSString *)lati longi:(NSString *)longi
{
    NSParameterAssert(lati != nil);
    NSParameterAssert(longi != nil);
    
    [self sharedInstance].lati = lati;
    [self sharedInstance].longi = longi;
}

+ (void)setADID:(NSString *)adid
{
    NSParameterAssert(adid != nil);
    
    [self sharedInstance].adid = adid;
}

+ (NSString *)deviceID
{
    return [[self sharedInstance] deviceID];
}

+ (NSString *)bid
{
    return [[self sharedInstance] bid];
}

#pragma mark - System

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        // 获取持久参数
        DUKeychainWrapper *key = [[DUKeychainWrapper alloc] init];
        
        NSString *rel = [key myObjectForKey:(__bridge id)kSecValueData];
        
        if (rel.length != 0) {
            NSData *data = [rel dataUsingEncoding:4];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.bid = dic[@"bid"];
            
            self.deviceID = dic[@"deviceID"];
            
            self.firstInstallTime = dic[@"firstInstallTime"];
        } else {
            NSDate *now = [NSDate date];
            
            self.bid = @(arc4random_uniform(100)).stringValue;
            self.deviceID = [NSUUID UUID].UUIDString;
            self.firstInstallTime = @((unsigned long long)([now timeIntervalSince1970] * 1000));
            
            NSDictionary *info = @{@"bid" : self.bid,
                                   @"deviceID" : self.deviceID,
                                   @"firstInstallTime" : self.firstInstallTime};
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:info options:0 error:nil];
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:4];
            
            DUKeychainWrapper *key = [[DUKeychainWrapper alloc] init];
            [key mySetObject:dataStr forKey:(__bridge id)kSecValueData];
            
            self.isNewUser = YES;
        }
        
        self.longi = @"";
        self.lati = @"";
        self.tunnelID = @"";
        self.accessKey = @"0DNm0loY2qrkLUvNpU";
        self.adid = @"";
//        if (DEBUG) {
//            self.serverURL = [NSURL URLWithString:@"http://192.168.5.222:11011"]; // 测试环境
//        } else {
//
//        }
		self.serverURL = [NSURL URLWithString:@"http://stt.cryptohubapp.info"]; // 线上环境

        self.sqlQueue = dispatch_queue_create("datareport.SQLiteQueue", NULL);
        
        self.reachability = [DUReachability reachabilityForInternetConnection];
        
        // 准备数据库
        [self prepareDatabase];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

+ (void)didFinishLaunching:(NSNotification *)noti
{
    NSLog(@"%@",noti.description);
    [[self sharedInstance] enterApp];
}

+ (void)willTerminate:(NSNotification *)noti
{
    NSLog(@"%@",noti.description);
    [[self sharedInstance] exitApp];
}

+ (void)willEnterForeground:(NSNotification *)noti
{
    NSLog(@"%@",noti.description);
    [[self sharedInstance] enterApp];
}

+ (void)didEnterBackground:(NSNotification *)noti
{
    NSLog(@"%@",noti.description);
    [[self sharedInstance] exitApp];
}

/**
 *  统计App当天使用时长和次数
 */
- (void)enterApp
{
    self.session = [[DUSession alloc] init];
    
    // 设置安装时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:DUDataReportInstallDateKey] == nil) {
        [userDefaults setObject:[NSDate date] forKey:DUDataReportInstallDateKey];
        [userDefaults synchronize];
    }
    
    // 上报新用户
    if (self.isNewUser == YES) {
        [self sendNewUser];
    }
    
    [self sendEvent];
    
    [self sendUseTimeLong];
    
    [self sendPageEvent];
    
}

- (void)exitApp
{
    // 更新使用的时间
    self.session.endDate = [NSDate date];
    
    // 保存使用时长
    [self insertModelSQLObject:self.session];
}


+ (DUDataReport *)sharedInstance {
    static dispatch_once_t onceToken;
    static DUDataReport *_sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}


- (void)log:(NSString *)log
{
//    NSLog(@"%@: %@", NSStringFromClass([self class]), log);
}

- (void)prepareDatabase
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *reportDB = @"datareport.sqlite";
    
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:reportDB];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // 创建数据库
        
        sqlite3 *db;
        
        if (sqlite3_open([destinationPath UTF8String], &db) == SQLITE_OK) {
            
            NSString *sql = @"CREATE TABLE IF NOT EXISTS \"page\" (\"id\" INTEGER PRIMARY KEY  NOT NULL ,\"name\" TEXT NOT NULL ,\"start_date\" INTEGER NOT NULL  DEFAULT (0) ,\"end_date\" INTEGER NOT NULL  DEFAULT (0) )";
            
            char *err;
            
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                [self log:@"create page table fail"];
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS \"usage\" (\"id\" INTEGER PRIMARY KEY  NOT NULL , \"date\" TEXT NOT NULL , \"time_long\" INTEGER NOT NULL  DEFAULT 0)";
            
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                [self log:@"create usage table fail"];
            }
            
            sql = @"CREATE TABLE IF NOT EXISTS \"event\" (\"id\" INTEGER PRIMARY KEY  NOT NULL ,\"act\" TEXT NOT NULL ,\"cat\" TEXT NOT NULL ,\"extra\" TEXT NOT NULL ,\"lab\" TEXT NOT NULL ,\"create_date\" INTEGER NOT NULL  DEFAULT (0) ,\"cnt\" INTEGER NOT NULL  DEFAULT (1) ,\"event_key\" TEXT NOT NULL, \"eid\" TEXT NOT NULL, \"val\" TEXT NOT NULL )";
            
            if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                [self log:@"create event table fail"];
            }
            
            sqlite3_close(db);
        } else {
            [self log:@"open db fail"];
        }
    }
    
    // 升级数据库
    [self upgradeTableview];
    
    self.dbManager = [[DUDBManager alloc] initWithDatabaseFilename:reportDB];
    
}

- (NSString *)destinationDBPath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *reportDB = @"datareport.sqlite";
    
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:reportDB];
    
    return destinationPath;
}

- (void)upgradeTableview
{
    NSString *upgradeSQL = @"select val from event";
    
    sqlite3 *db;
    
    if (sqlite3_open([[self destinationDBPath] UTF8String], &db) == SQLITE_OK) {
        sqlite3_stmt *selectStmt;
        
        if (sqlite3_prepare_v2(db, [upgradeSQL UTF8String], -1, &selectStmt, NULL) == SQLITE_ERROR) {
            
            upgradeSQL = @"ALTER TABLE event ADD COLUMN val TEXT NOT NULL DEFAULT ''";
            
            char *err;
            
            if (sqlite3_exec(db, [upgradeSQL UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                [self log:@"create usage table fail"];
            }
        }
    }
}


- (NSDictionary *)commonInfo
{
    NSInteger version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSArray *localeInfo = [localeIdentifier componentsSeparatedByString:@"_"];
    
    NSDate *installDate = [[NSUserDefaults standardUserDefaults] objectForKey:DUDataReportInstallDateKey];
    
    return @{
             @"g_adid" : self.adid,
             @"g_app_inst_ts" : @([installDate timeIntervalSince1970]),
             @"g_app_pkg_name" : identifier,
             @"g_app_ver_code" : build,
             @"g_app_ver_name" : @(version).stringValue,
             @"g_channel" : @"AppStore",
             @"g_dpi" : @([[UIScreen mainScreen] scale]),
             @"g_dvc_brnd" : @"Apple",
             @"g_dvc_id" : self.deviceID,
             @"g_dvc_mdl" : [[UIDevice currentDevice] model],
             @"g_imsi" : @"",
             @"g_imei" : @"",
             @"g_installchannel" : @"AppStore",
             @"g_lang" : [localeInfo firstObject],
             @"g_os_ver" : [[UIDevice currentDevice] systemVersion],
             @"g_mac" : @"",
             @"g_net_t" : @"",
             @"g_ns_p" : @"",
             @"g_first_install" : self.firstInstallTime,
             @"g_last_update" : @"",
             @"g_tid" : @"",
             @"g_lati" : self.lati,
             @"g_longi" : self.longi,
             @"g_fb" : @"",
             @"g_scrn_h" : @([[UIScreen mainScreen] bounds].size.height),
             @"g_scrn_w" : @([[UIScreen mainScreen] bounds].size.width),
             @"g_source" : @"",
             @"g_gp" : @NO,
             @"g_atrack_id": self.deviceID,
             };
}

- (NSDictionary *)header
{
    NSInteger version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] integerValue];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    return @{@"sdk-accesskey" : self.accessKey,
             @"sdk-apiver" : @"2",
             @"sdk-appver" : @(version).stringValue,
             @"sdk-deviceid" : self.deviceID,
             @"sdk-ismi" : @"",
             @"sdk-packagename" : identifier,
             @"sdk-signature" : @"",
             @"sdk-tid" : self.tunnelID,
             @"sdk-bid" : self.bid};
}

- (void)insertModelSQLObject:(id <ModelSQL>)model
{
    dispatch_async(self.sqlQueue, ^{
        [self.dbManager executeQuery:[model saveSQL]];
    });
}

#pragma mark -

- (void)sendContent:(id)content toURL:(NSURL *)url completion:(void (^)(void))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置Header
    NSDictionary *header = [self header];
    
    for (NSString *key in header) {
        [request setValue:header[key] forHTTPHeaderField:key];
    }
    
    // 设置Content
    NSData *data = [NSJSONSerialization dataWithJSONObject:content options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:4];
    
    NSString *key = [NSString stringWithFormat:@"%@kRJCSN1RAo6TFOY4FV", self.deviceID];
    
    NSString *base64EncBody = [DUAESEncrypt AES128Encrypt:jsonString key:key];
    
    request.HTTPBody = [base64EncBody dataUsingEncoding:NSUTF8StringEncoding];
    
    [self log:request.URL.absoluteString];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *responseString = [[NSString alloc] initWithData:data encoding:4];
        
        NSString *req = [DUAESEncrypt AES128Decrypt:responseString key:@"0DNm0loY2qrkLUvNpUJORsciTuZ0gIEwunX9"];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[req dataUsingEncoding:4] options:0 error:nil];
        
        if (dic && [dic[@"code"] integerValue] == 0) {
            
            [self log:@"send success"];
            
            if (completion) {
                completion();
            }
            
        } else {
            [self log:[NSString stringWithFormat:@"error msg: %@", dic[@"msg"]]];
        }
        
    }];
    
    [task resume];
}

- (void)sendContent:(id)content toPath:(NSString *)path completion:(void (^)(void))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%@", [self.serverURL absoluteString], path];
    
    [self sendContent:content
                toURL:[NSURL URLWithString:url]
           completion:completion];
}

- (void)sendActiveWithType:(NSInteger)type
{
    // 没有网络时跳过上报
    if (![self hasNetwork]) {
        return;
    }
    
    NSString *typeString = nil;
    
    if (type == 0) {
        typeString = @"daily_active";
    } else {
        typeString = @"real_active";
    }
    
    // 检测上次上报的信息
    
    if ([self needSendReportWithKey:DUDataReportLatestActiveDateKey] == NO) {
        return;
    }
    
    NSDate *now = [NSDate date];
    
    // 上报数据
    NSArray *event = @[@{@"g_ts" : @((unsigned long long)([now timeIntervalSince1970] * 1000)), @"g_act" : typeString}];
    
    NSDictionary *content = @{@"g_event" : event, @"g_info" : [self commonInfo]};
    
    [self sendContent:content toPath:@"nw/nx" completion:nil];
    
    // 更新时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:now forKey:DUDataReportLatestActiveDateKey];
    [userDefaults synchronize];
    
}

- (void)sendNewUser
{
    // 没有网络时跳过上报
    if (![self hasNetwork]) {
        return;
    }
    
    NSDate *now = [NSDate date];
    
    NSDictionary *ts = @{@"g_ts" : @((unsigned long long)([now timeIntervalSince1970] * 1000))};
    
    NSDictionary *content = @{@"g_event" : @[ts], @"g_info" : [self commonInfo]};
    
    [self sendContent:content toPath:@"nw/nn" completion:nil];
}

- (void)sendEvent
{
    // 没有网络时跳过上报
    if (![self hasNetwork]) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *now = [NSDate date];
    
    if (self.debug == NO) {
        // 抽样
        
        // 检测上次上报的信息
        NSDate *latestDate = [userDefaults objectForKey:DUDataReportLatestEventDateKey];
        
        if (latestDate != nil) {
            // 至少间隔1小时上报数据
            if ([now timeIntervalSinceDate:latestDate] < 3600) {
                return;
            }
        }
    }
    
    // 查询数据
    dispatch_async(self.sqlQueue, ^{
        NSString *sql = @"SELECT * FROM event";
        
        NSArray *rel = [self.dbManager loadDataFromDB:sql];
        
        if ([rel count] == 0) {
            return;
        }
        
        NSMutableArray *events = [NSMutableArray array];
        
        NSMutableArray *ids = [NSMutableArray array];
        
        // 提交数据
        for (NSArray *row in rel) {
            [ids addObject:row[0]];
            
            NSDictionary *item = nil;
            
            if ([row[6] integerValue] > 0) {
                item = @{@"g_act" : row[1],
                         @"g_cat" : row[2],
                         @"g_lab" : row[4],
                         @"g_ts" : row[5],
                         @"g_cnt" : row[6],
                         @"g_extra" : row[3],
                         @"g_eid" : row[8],
                         @"g_val" : row[9]};
            } else {
                item = @{@"g_act" : row[1],
                         @"g_cat" : row[2],
                         @"g_lab" : row[4],
                         @"g_ts" : row[5],
                         @"g_extra" : row[3],
                         @"g_eid" : row[8],
                         @"g_val" : row[9]};
            }
            
            [events addObject:item];
        }
        
        NSDictionary *content = @{@"g_event" : events};
        
        [self sendContent:content toPath:@"nw/ne" completion:^{
            // 删除记录
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM event WHERE id IN (%@)", [ids componentsJoinedByString:@", "]];
            
            [self.dbManager executeQuery:sql];
        
        }];
        
        // 更新时间
        [userDefaults setObject:now forKey:DUDataReportLatestEventDateKey];
        [userDefaults synchronize];
    });
    
}


- (void)sendUseTimeLong
{
    // 没有网络时跳过上报
    if (![self hasNetwork]) {
        return;
    }
    
    if ([self needSendReportWithKey:DUDataReportLatestUseTimeLongDateKey] == NO) {
        return;
    }
    
    dispatch_async(self.sqlQueue, ^{
        // 查询数据
        
        NSString *sql = @"SELECT date, sum(time_long) as sum, count(*) as count FROM usage group by date";
        
        NSArray *rel = [self.dbManager loadDataFromDB:sql];
        
        if ([rel count] == 0) {
            return;
        }
        
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSArray *row in rel) {
            NSDictionary *item = @{@"g_date" : row[0],
                                   @"g_time" : row[1],
                                   @"g_launch" : row[2]};
            
            [items addObject:item];
        }
        
        [self sendContent:items toPath:@"ap/rt" completion:^{
            // 删除记录
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM usage"];
            
            [self.dbManager executeQuery:sql];
        }];
        
        // 更新时间
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:DUDataReportLatestUseTimeLongDateKey];
        [userDefaults synchronize];
    });
}


- (void)sendPageEvent
{
    // 没有网络时跳过上报
    if (![self hasNetwork]) {
        return;
    }
    
    if ([self needSendReportWithKey:DUDataReportLatestPageEventDateKey] == NO) {
        return;
    }
    
    dispatch_async(self.sqlQueue, ^{
        // 查询数据
        
        NSString *sql = @"SELECT * FROM page";
        
        NSArray *rel = [self.dbManager loadDataFromDB:sql];
        
        if ([rel count] == 0) {
            return;
        }
        
        NSMutableArray *events = [NSMutableArray array];
        
        NSMutableArray *ids = [NSMutableArray array];
        
        // 提交数据
        for (NSArray *row in rel) {
            [ids addObject:row[0]];
            
            NSDictionary *item = @{@"act" : row[1],
                                   @"st" : row[2],
                                   @"et" : row[3]};
            
            [events addObject:item];
        }
        
        NSDictionary *content = @{@"events" : events};
        
        [self sendContent:content toPath:@"ac/rt" completion:^{
            // 删除记录
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM page WHERE id IN (%@)", [ids componentsJoinedByString:@", "]];
        
            [self.dbManager executeQuery:sql];
        }];
        
        // 更新时间
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSDate date] forKey:DUDataReportLatestPageEventDateKey];
        [userDefaults synchronize];
    });
    
}

#pragma mark - Utils

- (BOOL)hasNetwork
{
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    
    return YES;
}

/**
 *  查询今天是否有上报，有上报直接返回
 *
 */
- (BOOL)needSendReportWithKey:(NSString *)key
{
    if (self.debug) {
        return YES;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 检测上次上报的信息
    NSDate *latestDate = [userDefaults objectForKey:key];
    
    NSDate *now = [NSDate date];
    
    if (latestDate != nil) {
        // 查询今天是否有上报，有上报直接返回
        static NSDateFormatter *dateFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
        });
        
        if ([[dateFormatter stringFromDate:latestDate] isEqualToString:[dateFormatter stringFromDate:now]]) {
            return NO;
        }
    }
    
    return YES;
}

@end
