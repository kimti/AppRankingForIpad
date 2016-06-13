
#import "TopSaleAppDelegate.h"

@implementation TopSaleAppDelegate

@synthesize window = _window;

- (void) dealloc
{   
    [_window release];
    [_appListViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    [_appListViewController release];
    _appListViewController = [[AppListViewController alloc] init];
    
    self.window.rootViewController = _appListViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (NSString *)appKey
{
    return @"44f4269a95270153354000004";
}

@end
