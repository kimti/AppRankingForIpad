

#import <QuartzCore/QuartzCore.h>
#import "Album.h"
#import "ImageDownloader.h"
#import "Config.h"
#import "ImageString.h"
#import "ImageView.h"

@implementation Album

- (void)dealloc
{
    [_imageViews release];
    [_imageDownloadsInProgress release];
    
    [super dealloc];
}

- (void) startImageDownload:(NSString *)link index:(NSInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    ImageDownloader *imageDownloader = [_imageDownloadsInProgress objectForKey:key];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.index = index;
        imageDownloader.delegate = self;
        [_imageDownloadsInProgress setObject:imageDownloader forKey:key];
        [imageDownloader startDownloadWithLink:link];
        [imageDownloader release];
    }
}

- (void)imageDidLoad:(NSInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    ImageDownloader *imageDownloader = [_imageDownloadsInProgress objectForKey:key];
    if (imageDownloader != nil) 
    {
        ImageView *imageView = [_imageViews objectAtIndex:index];
        imageView.image = imageDownloader.modifiedImage;
        imageView.modifiedImage = imageDownloader.modifiedImage;
        imageView.originImage = imageDownloader.originImage;
        [imageView.loadingAnimationView.layer removeAllAnimations];
        [imageView.loadingAnimationView removeFromSuperview];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
}

- (void) update:(NSArray *)imageStrs
{
    NSUInteger count = [imageStrs count];
    self.contentSize = CGSizeMake(20 + (kImageWight + 10) * count, CGRectGetHeight(self.bounds));
    _oldContenSize = CGSizeMake(20 + (kImageWight + 10) * count, kHeightSpace * 2 + kImageHeight);
    
    _imageDownloadsInProgress = [[NSMutableDictionary dictionaryWithCapacity:count] retain];
    _imageViews = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) 
    {
        CGRect rect = CGRectMake(i * (kImageWight + 10) + 10, (CGRectGetHeight(self.bounds) - kImageHeight)/2, kImageWight, kImageHeight);
        ImageView *imageView = [[ImageView alloc] initWithFrame:rect];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageViews addObject:imageView];
        [imageView release];
        [self addSubview:imageView];
        
        UIImage *loading = [UIImage imageNamed:@"loading.png"];
        CGRect loadingFrame = CGRectMake(0, 0, loading.size.width,loading.size.height);
        UIView *loadingAnimationView = [[UIView alloc] initWithFrame:loadingFrame];
        [imageView addSubview:loadingAnimationView];
        [loadingAnimationView release];
        
        imageView.loadingAnimationView = loadingAnimationView;
        
        loadingAnimationView.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2, CGRectGetHeight(imageView.bounds)/2); 
        loadingAnimationView.layer.contents = (id)loading.CGImage;
        
        CATransform3D trans = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue valueWithCATransform3D:trans];
        animation.duration = .5;
        animation.repeatCount = FLT_MAX;
        animation.delegate = self;
        [loadingAnimationView.layer addAnimation:animation forKey:@"Rotation"];
        
        [self startImageDownload:[imageStrs objectAtIndex:i] index:i];
    }
}

- (id)initWithFrame:(CGRect)frame imageStrings:(NSArray *)imageStrs
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _oldFrame = frame;
        _isScale = NO;
        
        UIImage *bg = [UIImage imageNamed:@"picview_bg.png"];
        self.layer.contents = (id)bg.CGImage;
//        self.backgroundColor = [UIColor colorWithPatternImage:bg];
        
        [self update:imageStrs];
    }
    return self;
}

+ (id)albumWithFrame:(CGRect)frame imageStrings:(NSArray *)imageStrings
{
    return [[[[self class] alloc] initWithFrame:frame imageStrings:imageStrings] autorelease];
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
    if (CGRectContainsPoint(self.bounds, point)) 
    {
        NSUInteger count = [_imageViews count];
        
        if (!_isScale) {
            _isScale = YES;
            self.contentSize = CGSizeMake(10 + (kImageWight * 2 + 10) * count, CGRectGetHeight(self.bounds));
            
            [UIView beginAnimations:nil context:nil];
            self.frame = CGRectMake(_oldFrame.origin.x, _oldFrame.origin.y - kImageHeight, CGRectGetWidth(_oldFrame), CGRectGetHeight(_oldFrame) + kImageHeight);
            for (int i = 0; i < count; i++) {
                ImageView *imageView = [_imageViews objectAtIndex:i];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                imageView.image = imageView.originImage;
                CGRect rect = CGRectMake(i * (kImageWight * 2 + 10) + 10, (CGRectGetHeight(self.bounds) - kImageHeight * 2)/2, kImageWight * 2, kImageHeight * 2);
                imageView.frame = rect;
            }
            [UIView commitAnimations];
        }else
        {
            _isScale = NO;
            self.contentSize = _oldContenSize;
            
            [UIView beginAnimations:nil context:nil];
            self.frame = _oldFrame;
            for (int i = 0; i < count; i++) {
                ImageView *imageView = [_imageViews objectAtIndex:i];
                imageView.image = imageView.modifiedImage;
                CGRect rect = CGRectMake(i * (kImageWight + 10) + 10, (CGRectGetHeight(self.bounds) - kImageHeight)/2, kImageWight, kImageHeight);
                imageView.frame = rect;
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
            [UIView commitAnimations];
        }
    }
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
