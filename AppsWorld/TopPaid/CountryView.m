
#import <QuartzCore/QuartzCore.h>
#import "CountryView.h"
#import "Config.h"

@implementation CountryView
@synthesize delegate = _delegate;
@synthesize countryTitle = _countryTitle;
@synthesize countryCode = _countryCode;
- (void)dealloc
{
    [_countryTitle release];
    [_countryCode release];
    [_titleLabel release];
    [_countryIcon release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *bg = [UIImage imageNamed:@"cell-shadow.png"];

        self.layer.contents = (id)bg.CGImage;
        CGRect rect = CGRectMake(kCountryRowHeight, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void) setCountryCode:(NSString *)countryCode
{
    [_countryCode release];
    _countryCode = [countryCode retain];
    
    [_countryIcon release];
    [_countryIcon removeFromSuperview];
    
    UIImage *countryIcon = [UIImage imageNamed:[NSString stringWithFormat:@"%@_big.png",countryCode]];

    CGRect rect = CGRectMake((kCountryRowHeight - kCountryFlagWidth)/2, 
                             (kCountryRowHeight - kCountryFlagWidth)/2, 
                             kCountryFlagWidth, 
                             kCountryFlagWidth);
    
    _countryIcon = [[UIView alloc] initWithFrame:rect];
    [self addSubview:_countryIcon];

    _countryIcon.layer.contents = (id) countryIcon.CGImage;
    _countryIcon.backgroundColor = [UIColor clearColor];

}
- (void)setCountryTitle:(NSString *)title
{
    [_countryTitle release];
    _countryTitle = [title retain];
    
    _titleLabel.text = title;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImage *bg = [UIImage imageNamed:@"appList_bg.png"];
    self.layer.contents = (id)bg.CGImage;
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImage *bg = [UIImage imageNamed:@"cell-shadow.png"];

    self.layer.contents = (id)bg.CGImage;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) 
    {
        if ([_delegate respondsToSelector:@selector(countryViewDidPressed:)]) 
        {
            [_delegate countryViewDidPressed:self];
        }
    }
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIImage *bg = [UIImage imageNamed:@"cell-shadow.png"];
    self.layer.contents = (id)bg.CGImage;
}

@end
