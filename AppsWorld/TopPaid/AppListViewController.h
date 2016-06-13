
#import <UIKit/UIKit.h>
#import "IconDownloader.h"
#import "Cell.h"
#import "AppListView.h"
#import "CategoryView.h"
#import "ParseOperation.h"
#import "OptionView.h"
#import "CountryPannel.h"
#import "AppRecordDetail.h"
#import "AppRecordDetail.h"
#import "MaskView.h"
#import "DrawnBubbleView.h"

#import <iAd/iAd.h>

@class ContentController;
@interface AppListViewController : UIViewController <UIScrollViewDelegate, IconDownloaderDelegate, CategoryViewDelegate, ParseOperationDelegate, UITextFieldDelegate, OptionViewDelegate, MaskViewDelegate, ADBannerViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UIView *_adPlateView;
    ADBannerView *_iAdBanner;
    
    NSArray *_entries;
    NSMutableDictionary *_imageDownloadsInProgress;
    
    NSMutableArray *_cells;
    
    AppListView* _appListView;
    
    
    NSMutableArray          *_appRecords;
    
    NSOperationQueue		*_queue;
    
    NSURLConnection         *_appListFeedConnection;
    NSMutableData           *_appListData;
    
    UITextField             *_sizeField;
    UIButton                *_sizeButton;
    UITextField             *_searchField;
    
    NSString                *_feedFileName;
    
    OptionView              *_device;
    NSArray                 *_devices;
    OptionView              *_price;
    NSArray                 *_prices;
    OptionView              *_topOrNew;
    NSArray                 *_topOrNews;
    
    UIView                  *_loadingView;
    
    CategoryView            *_categoryView;
    
    UIView *_countryBGView;
    
    AppRecordDetail *_appRecordDetail;
    
    UIView *_flagView;
    MaskView *_maskView;
    DrawnBubbleView* _currentBubbleView;
}

- (void)appImageDidLoad:(NSInteger)index;
- (Cell *) cellForIndex:(int)index;
- (void) _getTopSaleWithGenre:(NSString *)genre;
@end
