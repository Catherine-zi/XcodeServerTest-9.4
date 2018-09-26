#import "TGModernConversationAssociatedInputPanel.h"

#import "SSignalKit.h"

@class TGUser;

@interface TGModernConversationMentionsAssociatedPanel : TGModernConversationAssociatedInputPanel

@property (nonatomic) bool inverted;

@property (nonatomic, copy) void (^userSelected)(TGUser *);

- (void)setUserListSignal:(SSignal *)userListSignal;

@end
