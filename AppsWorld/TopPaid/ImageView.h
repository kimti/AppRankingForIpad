

#import <UIKit/UIKit.h>


@interface ImageView : UIImageView {
    UIView *_loadingAnimationView;
    UIImage *_originImage;
    UIImage *_modifiedImage;
}

@property (nonatomic, retain) UIView *loadingAnimationView;
@property (nonatomic, retain) UIImage *originImage;
@property (nonatomic, retain) UIImage *modifiedImage;
@end
