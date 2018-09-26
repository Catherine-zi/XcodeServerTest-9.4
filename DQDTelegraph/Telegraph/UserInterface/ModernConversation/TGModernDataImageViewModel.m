#import "TGModernDataImageViewModel.h"
#import "TGCommon.h"
#import "TGModernDataImageView.h"

@interface TGModernDataImageViewModel ()
{
    NSString *_uri;
    NSDictionary *_options;
}

@end

@implementation TGModernDataImageViewModel

- (instancetype)initWithUri:(NSString *)uri options:(NSDictionary *)options
{
    self = [super init];
    if (self != nil)
    {
        _uri = uri;
        _options = options;
        _contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernDataImageView class];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGModernDataImageView *view = (TGModernDataImageView *)[self boundView];
    [view loadUri:_uri withOptions:_options];
    
    view.contentMode = _contentMode;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    _contentMode = contentMode;
    ((TGModernDataImageView *)self.boundView).contentMode = _contentMode;
}

- (void)setUri:(NSString *)uri options:(NSDictionary *)options
{
    _uri = uri;
    _options = options;
    
    if (!TGStringCompare(_uri, uri))
        [(TGModernDataImageView *)[self boundView] loadUri:_uri withOptions:_options];
}

@end
