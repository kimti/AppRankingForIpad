
#import <UIKit/UIKit.h>
#import "Decrypt.h"

@protocol CategoryViewDelegate;

@interface CategoryView : UIView
{
    id<CategoryViewDelegate> _delegate;
    UIImageView *_imageView;
    UILabel *_categoryLabel;
    NSString *_gener;
    BOOL _highlighted;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *categoryLabel;
@property (nonatomic, retain) NSString *gener;
@property (nonatomic, assign) BOOL highlighted;
@end

@protocol CategoryViewDelegate <NSObject>

@required
- (void) categoryViewDidPressed:(CategoryView *)category;

@end
