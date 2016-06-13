

#import <UIKit/UIKit.h>
#import "AppRecord.h"
#import "Decrypt.h"

@protocol CellDelegate;

@interface Cell : UIView
{
    id <CellDelegate> _delegate;
    
    UIImageView *_imageView;
    UILabel *_textLabel;
    UILabel *_detailTextLabel;
    UILabel *_priceLabel;
    UILabel *_numberLabel;
    BOOL _selected;
    
    AppRecord *_appRecord;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UILabel *detailTextLabel;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) UILabel *numberLabel;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) AppRecord *appRecord;
@end

@protocol CellDelegate <NSObject>

- (void) cellDidPressed:(Cell *)cell;
@end
