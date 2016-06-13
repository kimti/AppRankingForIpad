

#import <UIKit/UIKit.h>

@protocol MaskViewDelegate;
@interface MaskView : UIView {
    id <MaskViewDelegate> _delegate;
}
@property (nonatomic, assign) id delegate;
@end

@protocol MaskViewDelegate <NSObject>

@required
- (void) maskViewDidTouched:(MaskView *)maskView;

@end