

#import <QuartzCore/QuartzCore.h>
#import "OptionView.h"

@implementation OptionView

@synthesize delegate = _delegate;
@synthesize type = _type;
@synthesize title = _title;
@synthesize highlighted = _highlighted;

- (void) dealloc
{
    [_type release];
    [_title release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *bg = [UIImage imageNamed:@"option.png"];

        self.layer.contents = (id)bg.CGImage;
    }
    return self;
}

- (void) setTitle:(NSString *)title
{
    [_title release];
    _title = [title retain];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:label];
    [label release];
    
    label.text = title;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
}

- (void) setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (highlighted) 
    {
        UIImage *bg = [UIImage imageNamed:@"option_highlight.png"];
        self.layer.contents = (id)bg.CGImage;
    }else
    {
        UIImage *bg = [UIImage imageNamed:@"option.png"];
        self.layer.contents = (id)bg.CGImage;
    }
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        [_delegate optionViewDidPressed:self];
    }

}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
@end
