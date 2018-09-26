#import "TGBridgeDocumentMediaAttachment.h"

#import "LegacyComponents.h"

@interface TGBridgeDocumentMediaAttachment (TGDocumentMediaAttachment)

+ (TGBridgeDocumentMediaAttachment *)attachmentWithTGDocumentMediaAttachment:(TGDocumentMediaAttachment *)attachment;

+ (TGDocumentMediaAttachment *)tgDocumentMediaAttachmentWithBridgeDocumentMediaAttachment:(TGBridgeDocumentMediaAttachment *)bridgeAttachment;

@end
