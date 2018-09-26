#import "TGCheckImageStoredActor.h"

#import "ActionStage.h"

#import "TGRemoteImageView.h"

#import "TGDatabase.h"

#import "TGMediaAssetsUtils.h"

@implementation TGCheckImageStoredActor

+ (NSString *)genericPath
{
    return @"/tg/checkImageStored/@";
}

- (void)execute:(NSDictionary *)options
{
    NSString *url = [options objectForKey:@"url"];
    NSData *fileData = [options objectForKey:@"data"];
    
    [TGDatabaseInstance() checkIfAssetIsStored:url completion:^(bool stored)
    {
        if (!stored)
        {
            NSData *data = fileData;
            
            if (data == nil)
            {
                NSString *path = [[TGRemoteImageView sharedCache] pathForCachedData:url];
                if (path != nil)
                {
                    data = [[NSData alloc] initWithContentsOfFile:path];
                }
            }
            
            if (data != nil)
            {
                [TGMediaAssetsSaveToCameraRoll saveImageWithData:data silentlyFail:true completionBlock:^(bool succeed)
                {
                    [ActionStageInstance() dispatchOnStageQueue:^
                    {
                        if (succeed)
                            [TGDatabaseInstance() setAssetIsStored:url];
                        
                        [ActionStageInstance() actionCompleted:self.path result:nil];
                    }];
                }];
            }
        }
        else
        {
            [ActionStageInstance() actionCompleted:self.path result:nil];
        }
    }];
}



@end
