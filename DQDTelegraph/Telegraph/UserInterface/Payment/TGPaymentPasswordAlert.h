#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TGPaymentPasswordAlert : UIAlertController

+ (UIAlertController *)alertWithText:(NSString *)text result:(void (^)(NSString *))result;

@end
