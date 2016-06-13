
#import <QuartzCore/QuartzCore.h>
#import "CategoryView.h"
#define kImageWidth 32
#define kcategoryLabelWidth 66
@implementation CategoryView
@synthesize delegate = _delegate;
@synthesize imageView = _imageView;
@synthesize categoryLabel = _categoryLabel;
@synthesize gener = _gener;
@synthesize highlighted = _highlighted;

- (void) dealloc
{
    [_imageView release];
    [_categoryLabel release];
    [_gener release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(15, 10, kImageWidth, kImageWidth);
        _imageView = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:_imageView];
        
        _imageView.backgroundColor = [UIColor clearColor];
        
        CGRect categoryLabelRect = CGRectMake(0, 48-4, kcategoryLabelWidth, 18);
        _categoryLabel = [[UILabel alloc] initWithFrame:categoryLabelRect];
        [self addSubview:_categoryLabel];
        
        _categoryLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:10];
//        _categoryLabel.font = [UIFont systemFontOfSize:10];
        _categoryLabel.backgroundColor = [UIColor clearColor];
        _categoryLabel.textAlignment = UITextAlignmentCenter;
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (highlighted) 
    {
        UIImage *bg = [UIImage imageNamed:@"category_l2.png"];

        self.layer.contents = (id)bg.CGImage;
    }else
    {
        UIImage *bg = [UIImage imageNamed:@"category_l1.png"];
        self.layer.contents = (id)bg.CGImage;
    }
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        [_delegate categoryViewDidPressed:self];
    }
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{}

@end
