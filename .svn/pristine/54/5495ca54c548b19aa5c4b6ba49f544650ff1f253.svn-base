#import <Foundation/Foundation.h>
#import "WKInterface+TGInterface.h"
#import "TGWatchColor.h"

#define TGTick   NSDate *startTime = [NSDate date]
#define TGTock   NSLog(@"%s Time: %f", __func__, -[startTime timeIntervalSinceNow])

#define TGLog(s) NSLog(s)

#ifdef __cplusplus
extern "C" {
#endif
    
extern int TGLocalizedStaticVersionWatch;  //Avazu 20180608 重命名为TGLocalizedStaticVersionWatch
    
void TGSetLocalizationFromFileURL(NSURL *fileUrl);  //Avazu 20180607 重命名
bool TGIsCustomLocalizationActive();
void TGResetLocalization();
//Avazu 20180608 Use TGCommon
//NSString *TGLocalized(NSString *s);
//Avazu 20180607 注释
//static inline void TGDispatchOnMainThread(dispatch_block_t block)
//{
//    if ([NSThread isMainThread])
//        block();
//    else
//        dispatch_async(dispatch_get_main_queue(), block);
//}
//Avazu 20180607 注释
//static inline void TGDispatchAfter(double delay, dispatch_queue_t queue, dispatch_block_t block)
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay) * NSEC_PER_SEC)), queue, block);
//}

void TGSwizzleMethodImplementation(Class clazz, SEL originalMethod, SEL modifiedMethod);

CGSize TGWatchScreenSize();

typedef NS_ENUM(NSUInteger, TGScreenType)
{
    TGScreenType38mm,
    TGScreenType42mm
};
    
TGScreenType TGWatchScreenType();
    
#ifdef __cplusplus
}
#endif

@interface NSNumber (IntegerTypes)

- (int32_t)int32Value;
- (int64_t)int64Value;

@end
