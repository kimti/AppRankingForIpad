

#import "MaskView.h"


@implementation MaskView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_delegate maskViewDidTouched:self];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
