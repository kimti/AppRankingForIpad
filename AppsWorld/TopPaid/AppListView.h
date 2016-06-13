
#import <UIKit/UIKit.h>
#import "Cell.h"

@interface AppListView : UIScrollView
{   
    NSInteger _number;
}
@property (nonatomic, assign) NSInteger number;

- (void) reloadData;
@end
