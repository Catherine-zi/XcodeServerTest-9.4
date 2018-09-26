#import <Foundation/Foundation.h>

#import "TLMetaScheme.h"

typedef enum {
    TGCallDiscardReasonUnknown,
    TGCallDiscardReasonMissed,
    TGCallDiscardReasonMissedTimeout,
    TGCallDiscardReasonDisconnect,
    TGCallDiscardReasonHangup,
    TGCallDiscardReasonRemoteHangup,
    TGCallDiscardReasonBusy
} TGCallDiscardReason;

@interface TGCallDiscardReasonAdapter : NSObject

+ (TGCallDiscardReason)reasonForTLObject:(TLPhoneCallDiscardReason *)object;
+ (TLPhoneCallDiscardReason *)TLObjectForReason:(TGCallDiscardReason)reason;

@end
