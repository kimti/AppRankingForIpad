

#import "ImageView.h"


@implementation ImageView
@synthesize loadingAnimationView = _loadingAnimationView;
@synthesize originImage = _originImage;
@synthesize modifiedImage = _modifiedImage;

- (void) dealloc
{
    [_loadingAnimationView release];
    [_originImage release];
    [_modifiedImage release];
    
    [super dealloc];
}

@end
