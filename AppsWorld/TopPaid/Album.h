

#import <UIKit/UIKit.h>
#import "Decrypt.h"

@interface Album : UIScrollView {
    NSMutableArray *_imageViews;
    NSMutableDictionary *_imageDownloadsInProgress;
    CGRect _oldFrame;
    CGSize _oldContenSize;
    BOOL _isScale;
}
- (void) update:(NSArray *)imageStrs;
+ (id)albumWithFrame:(CGRect)frame imageStrings:(NSArray *)imageStrings;
@end
