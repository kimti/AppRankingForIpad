

#import <UIKit/UIKit.h>
#import "Decrypt.h"

@protocol OptionViewDelegate;
@interface OptionView : UIView
{
    id <OptionViewDelegate> _delegate;
    NSString *_type;
    NSString *_title;
    BOOL _highlighted;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) BOOL highlighted;
@end

@protocol OptionViewDelegate <NSObject>

@required
- (void) optionViewDidPressed:(OptionView *)optionView;

@end
