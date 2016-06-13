

#import "CountryPannel.h"
#import "Config.h"

@implementation CountryPannel
@synthesize countryPannelDelegate = _countryPannelDelegate;

- (void) dealloc
{
    [_countries release];
    [_countryViews release];
    [_currentCountryView release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.showsVerticalScrollIndicator = NO;
        {
//            NSString *countryPath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@""];
//            NSLog(@"%@",countryPath);
            NSData *decryptData = [Decrypt dataWithName:@"en"];
            NSString *countryString = [[[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding] autorelease];
//            NSString *countryString = [NSString stringWithContentsOfFile: encoding:NSUTF8StringEncoding error:nil];
            NSArray *countries = [[countryString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] sortedArrayUsingSelector:@selector(compare:)];
            NSInteger countryNumber = [countries count];
            NSMutableArray *countryViews = [NSMutableArray arrayWithCapacity:countryNumber];

            _countryViews = [countryViews retain];
            self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), kCountryRowHeight * countryNumber);
            
            for (int i = 0; i < countryNumber; i++) 
            {
                NSString *country = [countries objectAtIndex:i];
                NSArray *countryProperties = [country componentsSeparatedByString:@"="];
                
                CGRect rect = CGRectMake(0, kCountryRowHeight * i, CGRectGetWidth(self.bounds), kCountryRowHeight);
                CountryView *countryView = [[CountryView alloc] initWithFrame:rect];
                [_countryViews addObject:countryView];
                [countryView release];
                countryView.backgroundColor = [UIColor clearColor];
                
                [self addSubview:countryView];
                
                [countryView setCountryTitle:[countryProperties objectAtIndex:0]];
                [countryView setCountryCode:[countryProperties objectAtIndex:1]];
                countryView.delegate = self;
            }
        }
    }
    return self;
}

- (void) countryViewDidPressed:(CountryView *)countryView
{
    [_currentCountryView release];
    _currentCountryView = [countryView retain];
    
    if ([_countryPannelDelegate respondsToSelector:@selector(countryPannel:selectedCountryView:)])
    {
        [_countryPannelDelegate countryPannel:self selectedCountryView:countryView];
    }
    
}

@end
