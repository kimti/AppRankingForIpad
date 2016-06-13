
#import <UIKit/UIKit.h>
#import "AppListViewController.h"


@class AppListViewController;

@interface TopSaleAppDelegate : NSObject <UIApplicationDelegate>
{
    AppListViewController *_appListViewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
