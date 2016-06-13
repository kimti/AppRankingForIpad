
#import <QuartzCore/QuartzCore.h>
#import "Cell.h"
#define kEndWidth 20
#define kAppIconHeight 62

@implementation Cell
@synthesize delegate = _delegate;
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize priceLabel = _priceLabel;
@synthesize numberLabel = _numberLabel;
@synthesize selected = _selected;
@synthesize appRecord = _appRecord;

- (void) dealloc
{
    [_imageView release];
    [_textLabel release];
    [_detailTextLabel release];
    [_priceLabel release];
    [_numberLabel release];
    
    [_appRecord release];
    
    [super dealloc];
}

- (void) _setBgWithImageName:(NSString *)name
{
    UIImage *bg = [UIImage imageNamed:name];
    self.layer.contents = (id)bg.CGImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, (CGRectGetHeight(frame) - kAppIconHeight)/2, kAppIconHeight, kAppIconHeight)];
        self.imageView = imageView;
        [imageView release];
        [self addSubview:_imageView];
        
        _imageView.layer.cornerRadius = 10.0;
        _imageView.layer.masksToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAppIconHeight + 15, 10, CGRectGetWidth(frame) - 63 - kEndWidth, 22)];
        self.textLabel = textLabel;
        [textLabel release];
        [self addSubview:_textLabel];

        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:15];
        
        UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAppIconHeight + 15, 32, CGRectGetWidth(frame) - 63 - kEndWidth, 18)];
        self.detailTextLabel = detailTextLabel;
        [detailTextLabel release];
        [self addSubview:_detailTextLabel];

        _detailTextLabel.backgroundColor = [UIColor clearColor];
        _detailTextLabel.textColor = [UIColor whiteColor];
        _detailTextLabel.font = [UIFont italicSystemFontOfSize:12];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAppIconHeight + 15, 32 + 18, 50, 18)];
        self.priceLabel = priceLabel;
        [priceLabel release];
        [self addSubview:_priceLabel];
        
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor orangeColor];
        _priceLabel.font = [UIFont systemFontOfSize:12];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(198 - 30 - 3 - 3, 32 + 18 + 6, 30, 18)];
        self.numberLabel = numberLabel;
        [numberLabel release];
        [self addSubview:_numberLabel];
        
        _numberLabel.textAlignment = UITextAlignmentRight;
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:15];
        
        [self _setBgWithImageName:@"cell_bg1.png"];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _setBgWithImageName:@"cell_bg2.png"];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _setBgWithImageName:@"cell_bg1.png"];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, point)) 
    {
        if ([_delegate respondsToSelector:@selector(cellDidPressed:)]) 
        {
            [_delegate cellDidPressed:self];
        }
    }
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _setBgWithImageName:@"cell_bg1.png"];
}

@end
