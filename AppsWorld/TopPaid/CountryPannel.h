

#import <UIKit/UIKit.h>
#import "CountryView.h"

@protocol CountryPannelDelegate;

@interface CountryPannel : UIScrollView
{
    id <CountryPannelDelegate> _countryPannelDelegate;
    NSArray *_countries;
    NSMutableArray *_countryViews;
    
    CountryView *_currentCountryView;
}
@property (nonatomic, assign) id countryPannelDelegate;
@end

@protocol CountryPannelDelegate <NSObject>

- (void) countryPannel:(CountryPannel *)countryPannel selectedCountryView:(CountryView *)countryView;

@end

