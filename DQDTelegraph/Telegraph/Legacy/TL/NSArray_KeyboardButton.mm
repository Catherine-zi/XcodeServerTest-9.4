#import "NSArray_KeyboardButton.h"
#import "TGCommon.h"
#import "NSInputStream+TL.h"
#import "NSOutputStream+TL.h"


@implementation NSArray_KeyboardButton


- (int32_t)TLconstructorSignature
{
    return (int32_t)0x651d9050;
}

- (int32_t)TLconstructorName
{
    TGLog(@"constructorName is not implemented for base type");
    return 0;
}

- (id<TLObject>)TLbuildFromMetaObject:(std::shared_ptr<TLMetaObject>)__unused metaObject
{
    TGLog(@"TLbuildFromMetaObject is not implemented for base type");
    return nil;
}

- (void)TLfillFieldsWithValues:(std::map<int32_t, TLConstructedValue> *)__unused values
{
    TGLog(@"TLfillFieldsWithValues is not implemented for base type");
}

- (id)TLvectorConstruct
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array TLtagConstructorName:(int32_t)0x651d9050];
    return array;
}


@end
