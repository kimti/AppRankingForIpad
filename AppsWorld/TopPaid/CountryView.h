

#import <UIKit/UIKit.h>
#import "Decrypt.h"

@protocol CountryViewDelegate;

@interface CountryView : UIView
{
    id <CountryViewDelegate> _delegate;
    NSString *_countryTitle;
    NSString *_countryCode;
    UILabel *_titleLabel;
    UIView *_countryIcon;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *countryTitle;
@property (nonatomic, retain) NSString *countryCode;
@end

@protocol CountryViewDelegate <NSObject>

- (void) countryViewDidPressed:(CountryView *)countryView;

@end