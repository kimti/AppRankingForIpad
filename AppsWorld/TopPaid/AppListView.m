
#import <QuartzCore/QuartzCore.h>
#import "AppListView.h"
#import "Cell.h"
#import "AppListViewController.h"
#import "Config.h"

@interface AppListView()
- (void) _loadData;
@end

@implementation AppListView
@synthesize number = _number;

- (id)initWithFrame:(CGRect)frame
{   
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *bg = [UIImage imageNamed:@"appList_bg.png"];
        self.layer.contents = (id)bg.CGImage;
        
        [self _loadData];
    }
    return self;
}

- (void) setNumber:(NSInteger)number
{
    _number = number;
//    NSLog(@"%Lf",ceill(number/3.0));
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), ceill(number/3.0) * (76 + kHeightSpace));
}

- (void) _loadData
{
    for (int i = 0; i < _number; i++)
    {
        if ([self.delegate isKindOfClass:[AppListViewController class]]) 
        {
            AppListViewController *applistViewController = (AppListViewController *)self.delegate;
            Cell *cell = [applistViewController cellForIndex:i];
            
            CGFloat x = i % 3 * (CGRectGetWidth(cell.bounds) + kWidthSpace) + kWidthSpace;
            CGFloat y = i/3 * (CGRectGetHeight(cell.bounds) + kHeightSpace) + kHeightSpace;
            
            cell.frame = CGRectMake(x, y, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds));
            [self addSubview:cell];
        }
    }
}

- (void) reloadData
{
    [self _loadData];
}

@end
