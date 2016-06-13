

#import <UIKit/UIKit.h>
#import "AppRecord.h"
#import "Album.h"
#import "ImageString.h"

@protocol AppRecordDetailDelegate;
@interface AppRecordDetail : UIView {
    id <AppRecordDetailDelegate, ImageStringDelegate> _delegate;
    Album *_album;
    ImageString *_imageString;
}
@property (nonatomic, assign) id delegate;
+ (id) appRecordDetailViewWithFrame:(CGRect)frame appRecord:(AppRecord *)appRecord;
@end

@protocol AppRecordDetailDelegate <NSObject>

- (void) appRecordDetailDidPressedClossButton:(AppRecordDetail *)apprecordDetail;

@end