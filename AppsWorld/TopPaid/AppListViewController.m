

#import <QuartzCore/QuartzCore.h>
#import "AppListViewController.h"
#import "TopSaleAppDelegate.h"
#import "Config.h"
#import "CountryView.h"

static NSString *const TopPaidAppsFeed =
@"http://itunes.apple.com/%@/rss/%@%@%@applications/%@/%@/xml";

typedef struct 
{
    NSString* name;
    NSString* value;
} RankingData;

static int RANKING_DATA_SIZE = 4;

RankingData rankingData[4]={
    {@"Top 50",  @"50"},
    {@"Top 100", @"100"},
    {@"Top 150", @"150"},
    {@"Top 200", @"200"},
};

NSString *AppDataDownloadCompleted = @"AppDataDownloadCompleted";

@interface AppListViewController ()

- (void) startIconDownload:(AppRecord *)appRecord forIndex:(NSInteger)index;
@end

@implementation AppListViewController

- (void) dealloc
{
    
    
    [_adPlateView release];
    
    [_entries release];
    [_imageDownloadsInProgress release];
    [_cells release];
    [_appListView release];
    
    [_appRecords release];
    
    [_queue release];
    
    [_appListFeedConnection release];
    [_appListData release];
    
    [_sizeField release];
    [_sizeButton release];
    [_feedFileName release];
    
    [_device release];
    [_devices release];
    [_price release];
    [_prices release];
    [_topOrNew release];
    [_topOrNews release];
    
    [_loadingView release];
    [_categoryView release];
    [_countryBGView release];
    
    [_appRecordDetail release];
    
    [_flagView release];
    
    [_maskView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

////////////////////////////////////////////////////
//for Test

- (void) _reloadAdView
{
}



#define kOriginX 775
#define kOriginY 380

- (void) _adPlateView
{
    _adPlateView = [[[UIView alloc] initWithFrame:CGRectMake(kOriginX, kOriginY,1024 - kOriginX - 40, 768 - kOriginY - 100)] autorelease];
    [self.view addSubview:_adPlateView];
    
    UIImage* topPaidBg = [UIImage imageNamed:@"topPaidBg.png"];
    UIButton* topPaidButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [topPaidButton setBackgroundImage:topPaidBg forState:UIControlStateNormal];
    topPaidButton.frame = CGRectMake(kOriginX, CGRectGetMaxY(_adPlateView.frame), CGRectGetWidth(_adPlateView.frame), 100);
    NSLog(@"%@", NSStringFromCGRect(topPaidButton.frame));
//    [topPaidButton setTitle:@"remove AD" forState:UIControlStateNormal];
    [self.view addSubview:topPaidButton];
    [topPaidButton addTarget:self action:@selector(topPaid:) forControlEvents:UIControlEventTouchDown];
}

- (void) topPaid:(UIButton*)sender
{
    NSString* topPaidLink = @"itms-apps://itunes.apple.com/us/app/top-sale/id477054638?ls=1&mt=8";
    NSURL *url = [NSURL URLWithString:topPaidLink];
    [[UIApplication sharedApplication] openURL:url]; 
}


////////////////////////////////////////////////////

- (void) _saveValue:(id)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) _getValueFromUserDefaultsForKey:(id)key
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void) _configAppListView
{
    [_appListView release];
    [_appListView removeFromSuperview];
    
    AppListView* appListView = [[AppListView alloc] initWithFrame:CGRectMake(0, 0, kAppListViewWidth, kAppListViewAvailableHeight)];
    _appListView = [appListView retain];
    [appListView release];
    _appListView.delegate = self;
    
    [self.view insertSubview:_appListView belowSubview:_sizeField.superview];
//    [self.view addSubview:_appListView];
    
    _appListView.showsVerticalScrollIndicator = NO;
    
    [_cells release];
    _cells = [[NSMutableArray array] retain];
    
    [_imageDownloadsInProgress release];
    _imageDownloadsInProgress = [[NSMutableDictionary dictionary] retain];
    
}

- (NSString *) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)_todayString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    return date;
}

- (UIView *)_loadingView
{
    UIImage *loading = [UIImage imageNamed:@"loading.png"];
    CGRect loadingFrame = CGRectMake(0, 0, CGRectGetWidth(_appListView.frame), CGRectGetHeight(_appListView.frame));
//    NSLog(@"%@",NSStringFromCGRect(loadingFrame));
    UIView *loadingView = [[[UIView alloc] initWithFrame:loadingFrame] autorelease];
    
    loadingView.userInteractionEnabled = YES;
    
    loadingView.backgroundColor = [UIColor blackColor];
    loadingView.alpha = 0.5;
    loadingFrame.size = CGSizeMake(loading.size.width, loading.size.height);
    UIView *loadingAnimationView = [[UIView alloc] initWithFrame:loadingFrame];
    [loadingView addSubview:loadingAnimationView];
    [loadingAnimationView release];
    
    loadingAnimationView.center = CGPointMake(CGRectGetWidth(_appListView.bounds)/2, 350); 
    
    loadingAnimationView.layer.contents = (id)loading.CGImage;
    
    CATransform3D trans = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:trans];
    animation.duration = .5;
    animation.repeatCount = FLT_MAX;
//    animation.delegate = self;
    [loadingAnimationView.layer addAnimation:animation forKey:@"Rotation"];
    
    return loadingView;
}

- (void)_parseWithData:(NSData *)data
{
    [_queue release];
    _queue = [[NSOperationQueue alloc] init];
    ParseOperation *parser = [[ParseOperation alloc] initWithData:data delegate:self];
    [_queue addOperation:parser];
    [parser release];
}

- (void) _removeAppRecordDetail
{
    [_appRecordDetail release];
    [_appRecordDetail removeFromSuperview];
    _appRecordDetail = nil;
}

- (void) _searchForName:(NSString *)appName
{
    [self _removeAppRecordDetail];
    if ([_appRecords count] > 0 && ![appName isEqualToString:@""]) {
        NSMutableArray *appRecords = [NSMutableArray array];
        
        for (AppRecord *apprecord in _appRecords) 
        {
            if ([[apprecord.appName uppercaseString] rangeOfString:[appName uppercaseString]].length > 0)
            {
                [appRecords addObject:apprecord];
            }
        }
        
        _searchField.text = @"";
        _searchField.placeholder = [NSString stringWithFormat:@"%d",[appRecords count]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDataDownloadCompleted object:appRecords];
    }
    
    if ([_appRecords count] > 0 && [appName isEqualToString:@""]) {
        _searchField.placeholder = @"App Name";
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDataDownloadCompleted object:_appRecords];
    }
}

- (void) _getTopSaleWithGenre:(NSString *)genre
{
    
    [self _removeAppRecordDetail];
    
    [_loadingView removeFromSuperview];
    [_loadingView release];
    _loadingView = [[self _loadingView] retain];
    [self.view addSubview:_loadingView];
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.5;
    [_loadingView.layer addAnimation:transition forKey:nil];
    
    [_appListData release];
    _appListData = nil;
    
    [_appRecords release];
    _appRecords = nil;
    
    _appRecords = [[NSMutableArray array] retain];
    NSString *genreString = [NSString stringWithFormat:@"genre=%d",6000 + [genre intValue]];
    if ([genre isEqualToString:@""]) {
        genreString = @"";
    }
    NSString *limit = [NSString stringWithFormat:@"limit=%@",[self _getValueFromUserDefaultsForKey:kSize]];
    NSString *country = [self _getValueFromUserDefaultsForKey:kCountry];
    NSString *device = [self _getValueFromUserDefaultsForKey:kDevice];
    if ([device isEqualToString:@"iphone"]) {
        device = @"";
    }
    NSString *price = [self _getValueFromUserDefaultsForKey:kPrice];
    NSString *topOrNew = [self _getValueFromUserDefaultsForKey:kTopOrNew];
    if ([topOrNew isEqualToString:@"new"]) {
        device = @"";
        if ([price isEqualToString:@"grossing"]) {
            price = @"";
        }
    }
    
    [_feedFileName release];
    _feedFileName = [[NSString stringWithFormat:@"%@%@%@%@%@%@_%@",country, topOrNew, price, device, limit, genreString,[self _todayString]] retain];
//    NSLog(@"%@",_feedFileName);
//    NSString *feedFilePath = [[self documentsDirectory] stringByAppendingPathComponent:_feedFileName];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:feedFilePath]) 
    {
        NSString *appsFeed = [NSString stringWithFormat:TopPaidAppsFeed, country, topOrNew, price, device, limit, genreString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:appsFeed]];
        
        //    [urlRequest setTimeoutInterval:10];
        
        [_appListFeedConnection cancel];
        [_appListFeedConnection release];
        
        _appListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        NSAssert(_appListFeedConnection != nil, @"Failure to create URL connection.");
        
        // show in the status bar that network activity is starting
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
//    else
//    {
//        NSData *data = [NSData dataWithContentsOfFile:feedFilePath];
//        [self _parseWithData:data];
//    }
}

- (void) _handleLoadedApps:(NSArray *)loadedApps
{
//    [_appRecords addObjectsFromArray:loadedApps];
    
    for (int i = 0; i < [loadedApps count]; i++) {
        AppRecord *appRecord = [loadedApps objectAtIndex:i];
        appRecord.index = [NSString stringWithFormat:@"%d",i+1];
        [_appRecords addObject:appRecord];
    }
    
    // tell our interested view controller reload its data, now that parsing has completed
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDataDownloadCompleted object:loadedApps];
}

- (void) _removeLoadingView
{
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.5;
    [_loadingView.layer addAnimation:transition forKey:nil];
    [_loadingView removeFromSuperview];
}

- (void) _saveFeedData
{
    NSString *feedFilePath = [[self documentsDirectory] stringByAppendingPathComponent:_feedFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:feedFilePath]) 
    {
        [_appListData writeToFile:feedFilePath atomically:YES];
        [_appListData release];
        _appListData = nil;
    }
}

- (void)didFinishParsing:(NSArray *)appList
{
    [self _removeLoadingView];
    
//    [self _saveFeedData];
    
    [self performSelectorOnMainThread:@selector(_handleLoadedApps:) withObject:appList waitUntilDone:NO];
    
    [_queue release];
    _queue = nil;
}

- (void)parseErrorOccurred:(NSError *)error
{
    [_queue cancelAllOperations];
    
    [self performSelectorOnMainThread:@selector(_handleError:) withObject:error waitUntilDone:NO];
}

- (void) _handleError:(NSError *)error
{
    [self _removeLoadingView];
    
    [_appListData release];
    _appListData = nil;
    
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Sale Apps"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_appListData release];
    _appListData = nil;
    _appListData = [[NSMutableData data] retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_appListData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) 
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error" 
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain 
                                                         code:kCFURLErrorNotConnectedToInternet 
                                                     userInfo:userInfo];
        [self _handleError:noConnectionError];
    }
    else
    {
        [self _handleError:error];
    }
    
    [_appListFeedConnection release];
    _appListFeedConnection = nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_appListFeedConnection release];
    _appListFeedConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    NSString *dataString = [[[NSString alloc] initWithData:_appListData encoding:NSUTF8StringEncoding] autorelease];
    
//    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    
//    [_appListData writeToFile:[[self documentsDirectory] stringByAppendingPathComponent:_feedFileName] atomically:YES];

    [self _parseWithData:_appListData];
    
//    [_appListData release];
//    _appListData = nil;
}

- (void) _category
{
    UIImage *bg = [UIImage imageNamed:@"category_l1.png"];
    UIScrollView *categoryPanel = [[UIScrollView alloc] initWithFrame:CGRectMake(kAppListViewWidth, 0, bg.size.width, kAppListViewAvailableHeight)];
    [self.view addSubview:categoryPanel];
    [categoryPanel release];
    
//    NSString *categoryPath = [[NSBundle mainBundle] pathForResource:@"category_en" ofType:@"plist"];
    NSData *decryptData = [Decrypt dataWithName:@"category_en"];
    NSString *error;
    NSPropertyListFormat format;
    NSDictionary* categoryDictionary = [NSPropertyListSerialization propertyListFromData:decryptData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
  
//    NSDictionary *categoryDictionary = [NSDictionary dictionaryWithContentsOfFile:categoryPath];
    NSArray *categories = [categoryDictionary objectForKey:@"category"];
    
    categoryPanel.contentSize = CGSizeMake(bg.size.width, [categories count] * bg.size.height);
    categoryPanel.showsVerticalScrollIndicator = NO;
    
    for (int i = 0; i < [categories count]; i++)
    {
        
        NSDictionary *category = [categories objectAtIndex:i];
        CGFloat xID = [[category valueForKey:@"id"] floatValue];
        UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [category valueForKey:@"icon"]]];
        NSString *name = [category valueForKey:@"name"];
        NSString *gener = [category valueForKey:@"gener"];
        
        CGRect frame = CGRectMake(0, xID*bg.size.height, bg.size.width, bg.size.height);
        CategoryView *categoryView = [[CategoryView alloc] initWithFrame:frame];
        [categoryPanel addSubview:categoryView];
        [categoryView release];
        
        categoryView.layer.contents = (id)bg.CGImage;
        categoryView.delegate = self;
        categoryView.imageView.image = icon;
        categoryView.categoryLabel.text = name;
        categoryView.gener = gener;
        if ([gener isEqualToString:@""]) {
            [_categoryView release];
            _categoryView = categoryView;
        }
        
    }
}

#define space 776

- (void) _search
{
    UIImage *bg = [UIImage imageNamed:@"searchbarbg.png"];

    CGRect frame = CGRectMake(space, 200 - bg.size.height, bg.size.width - 20, bg.size.height);
    UIView *searchView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:searchView];
    [searchView release];
//    searchView.backgroundColor = [UIColor blueColor];
    searchView.layer.contents = (id)bg.CGImage;
    
    frame.origin.x = 18;
    frame.origin.y = 6;
    frame.size.width = 190 - 20;
    frame.size.height = 28;
    _searchField = [[UITextField alloc] initWithFrame:frame];
    [searchView addSubview:_searchField];
    _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    _searchField.textColor = [UIColor whiteColor];
    _searchField.textAlignment = UITextAlignmentCenter;
    _searchField.font = [UIFont systemFontOfSize:22];
    
    _searchField.placeholder = @"App Name";
    _searchField.enabled = NO;
    _searchField.delegate = self;
}

- (void) _size
{
    UIImage *bg = [UIImage imageNamed:@"sizebg.png"];
    CGRect frame = CGRectMake(space, 200, bg.size.width - 20, bg.size.height);
    UIView *sizeView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:sizeView];
    [sizeView release];
    sizeView.backgroundColor = [UIColor clearColor];
//    sizeView.layer.contents = (id)bg.CGImage;
    
    frame.origin.x = 18;
    frame.origin.y = 6;
    frame.size.width = 190 - 20;
    frame.size.height = 28;
    _sizeField = [[UITextField alloc] initWithFrame:frame];
    [sizeView addSubview:_sizeField];
    _sizeField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    _sizeField.backgroundColor = [UIColor redColor];
    
    _sizeField.textColor = [UIColor whiteColor];
    _sizeField.textAlignment = UITextAlignmentCenter;
    _sizeField.font = [UIFont systemFontOfSize:26];
    _sizeField.keyboardType = UIKeyboardTypeNumberPad;
    
    _sizeField.hidden = YES;
    
    _sizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sizeButton.frame = sizeView.bounds;
    _sizeButton.backgroundColor = [UIColor clearColor];
    [_sizeButton setBackgroundImage:bg forState:UIControlStateNormal];
//    [_sizeButton setBackgroundImage:bg forState:UIControlStateHighlighted];
    [_sizeButton addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
    [sizeView addSubview:_sizeButton];
    
    if (![self _getValueFromUserDefaultsForKey:kSize]) 
    {
        [self _saveValue:@"100" forKey:kSize];
    }
    
    NSString *size = [self _getValueFromUserDefaultsForKey:kSize];
    for (int i = 0; i < RANKING_DATA_SIZE; i++)
    {
        if ([size isEqualToString:rankingData[i].value]) 
        {
            [_sizeButton setTitle:rankingData[i].name forState:UIControlStateNormal];
        }
    }
    
    _sizeField.placeholder = [self _getValueFromUserDefaultsForKey:kSize];
    
    _sizeField.delegate = self;
}

- (void) removeMaskView
{
    [_maskView removeFromSuperview];
    [_maskView release];
    _maskView = nil;
}

- (void) removeBubbleView
{
    [_currentBubbleView removeFromSuperview];
    [_currentBubbleView release];
    _currentBubbleView = nil;
}

- (void)showBubbleViewWithActivationFrame:(CGRect)activationFrame
{
    if (_currentBubbleView) {
        return;
    }
    
    [self removeBubbleView];
    CGRect rect = CGRectMake(780, 225, 200, 200);
    
    _currentBubbleView = [[DrawnBubbleView alloc] initWithFrame:rect activationFrame:activationFrame];
    _currentBubbleView.layer.masksToBounds = true;
    _currentBubbleView.alpha = 0.0;
    [self.view addSubview:_currentBubbleView];
    
    CGRect frame = CGRectMake(15, 30, 170, 200);
    UITableView* tableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain] autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    UIView *v = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [tableView setTableFooterView:v];
    [_currentBubbleView addSubview:tableView];

    [self removeMaskView];
    MaskView *maskView = [[MaskView alloc]initWithFrame:self.view.bounds];
    _maskView = maskView;
    _maskView.delegate = self;
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.0;
    [self.view insertSubview:_maskView belowSubview:_currentBubbleView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _currentBubbleView.alpha = 1;
                         _maskView.alpha = 0.3;
                     }
     ];
}


- (void) backgroundTap: (id)sender
{
    [_sizeField resignFirstResponder];
    [self removeBubbleView];
}

//////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return RANKING_DATA_SIZE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIddentifier=@"SimpleTableIndentifier";//table 标志符
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIddentifier];
    
    if(cell==nil){
        cell=[[[UITableViewCell alloc]
               initWithStyle: UITableViewCellStyleDefault        //table 风格
               reuseIdentifier:SimpleTableIddentifier           //table 标志符
               ] autorelease];
    }
    
    NSUInteger row=[indexPath row];
    NSString* name = rankingData[row].name;
    cell.textLabel.text = name;
    
    UILabel* cellLabel = [cell textLabel];
    cellLabel.textAlignment = UITextAlignmentCenter;
    [cellLabel setTextColor:[UIColor blackColor]];
    [cellLabel setBackgroundColor:[UIColor clearColor]];
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString* title = rankingData[row].name;
    
    if (![_sizeButton.titleLabel.text isEqualToString:title]) 
    {
        NSString* value = rankingData[row].value;
        [_sizeButton setTitle:title forState:UIControlStateNormal];

        [self _saveValue:value forKey:kSize];
        [self _getTopSaleWithGenre:_categoryView.gener];
    }




    [self removeBubbleView];
    [self removeMaskView];
}
//////////////////////////////////////////////////////////////////////

- (void) selectSize:(UIButton*)b
{
    CGRect rect = CGRectMake(0, 0, 200, 200);
    
    [self showBubbleViewWithActivationFrame:rect];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_sizeField resignFirstResponder];
    [_searchField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{ 
    if (textField == _sizeField) {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
    }    
    return YES;
}

- (void) maskViewDidTouched:(MaskView *)maskView
{
    [_sizeField resignFirstResponder];
    [_searchField resignFirstResponder];
    
    [self removeBubbleView];
    [self removeMaskView];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{

    if (textField == _sizeField) 
    {
        [self.view insertSubview:_searchField.superview belowSubview:_sizeField.superview ];
    }if (textField == _searchField) 
    {
        [self.view insertSubview:_sizeField.superview belowSubview:_searchField.superview];
    }
    
    [self removeMaskView];
    MaskView *maskView = [[MaskView alloc]initWithFrame:self.view.bounds];
    _maskView = maskView;
    _maskView.delegate = self;
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.5;
    [self.view insertSubview:_maskView belowSubview:textField.superview];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{  
    if (textField == _sizeField) {
        if ([textField.text intValue]>200)
        {
            textField.text = @"200";
        }
        if ([textField.text intValue] <=0) 
        {
            textField.text = [self _getValueFromUserDefaultsForKey:kSize];
        }
        if ([[self _getValueFromUserDefaultsForKey:kSize] isEqualToString:textField.text]||[textField.text isEqualToString:@""]) 
        {
            return;
        }
        
        [self _saveValue:textField.text forKey:kSize];
        [self _getTopSaleWithGenre:_categoryView.gener];
    }if (textField == _searchField) 
    {
        [self _searchForName:_searchField.text];
    }
    [self removeMaskView];
}

- (OptionView *) _optionViewWithRect:(CGRect)rect type:(NSString *)type title:(NSString *) title
{
    OptionView *optionView = [[OptionView alloc] initWithFrame:rect];
    optionView.delegate = self;
    optionView.title = title;
    optionView.type = type;
    return [optionView autorelease];
}

- (void) _device
{
    
    CGRect rect = CGRectMake(space, 200+44, 80, 44);
    OptionView *ipad = [self _optionViewWithRect:rect type:kDevice title:@"ipad"];
    [self.view addSubview:ipad];
    
    rect.origin.x += rect.size.width;
    rect.size.width = 128;
    OptionView *iphone = [self _optionViewWithRect:rect type:kDevice title:@"iphone"];
    [self.view addSubview:iphone];
    
    _devices = [[NSArray arrayWithObjects:ipad, iphone, nil] retain];
    
    if (![self _getValueFromUserDefaultsForKey:kDevice]) 
    {
        [self _saveValue:@"ipad" forKey:kDevice];
        
        [_device release];
        _device = ipad;
        _device.highlighted = YES;
    }else
    {
        for (OptionView *device in _devices) 
        {
            if ([[self _getValueFromUserDefaultsForKey:kDevice] isEqualToString:device.title]) 
            {
                device.highlighted = YES;
                _device = device;
            }
        }
    }
}

- (void) _price
{   
    CGRect rect = CGRectMake(space, 244+44, 80, 44);
    
    OptionView *grossing = [self _optionViewWithRect:rect type:kPrice title:@"grossing"];
    [self.view addSubview:grossing];
    
    rect.origin.x += rect.size.width;
    rect.size.width = 64;
    OptionView *free = [self _optionViewWithRect:rect type:kPrice title:@"free"];
    [self.view addSubview:free];
    
    rect.origin.x += rect.size.width;
    OptionView *paid = [self _optionViewWithRect:rect type:kPrice title:@"paid"];
    [self.view addSubview:paid];
    
    _prices = [[NSArray arrayWithObjects:grossing, free, paid, nil] retain];
    
    if (![self _getValueFromUserDefaultsForKey:kPrice]) 
    {
        [self _saveValue:@"grossing" forKey:kPrice];
        
        [_price release];
        _price = grossing;
        _price.highlighted = YES;
    }else
    {
        for (OptionView *price in _prices) 
        {         
            if ([[self _getValueFromUserDefaultsForKey:kPrice] isEqualToString:price.title]) 
            {
                price.highlighted = YES;
                _price = price;
            }
        }
    }
}

- (void) _topOrNew
{
    CGRect rect = CGRectMake(space, 288+44, 80, 44);
    OptionView *top = [self _optionViewWithRect:rect type:kTopOrNew title:@"top"];
    [self.view addSubview:top];
    
    rect.origin.x += rect.size.width;
    rect.size.width = 128;
    OptionView *new = [self _optionViewWithRect:rect type:kTopOrNew title:@"new"];
    [self.view addSubview:new];
    
    _topOrNews = [[NSArray arrayWithObjects:top, new, nil] retain];
    
    if (![self _getValueFromUserDefaultsForKey:kTopOrNew]) 
    {
        [self _saveValue:@"top" forKey:kTopOrNew];
        
        [_topOrNew release];
        _topOrNew = top;
        _topOrNew.highlighted = YES;
    }else
    {
        for (OptionView *topOrNew in _topOrNews) 
        {
            if ([[self _getValueFromUserDefaultsForKey:kTopOrNew] isEqualToString:topOrNew.title]) 
            {
                topOrNew.highlighted = YES;
                _topOrNew = topOrNew;
            }
        }
    }
}

- (void) _setFlag:(NSString *)countryCode
{
    UIImage *flag = [UIImage imageNamed:[NSString stringWithFormat:@"%@_big.png",countryCode]];
    _flagView.layer.contents = (id)flag.CGImage;
}
- (void) _flag
{
    CGRect rect = CGRectMake(space + 65, 40, 80, 80);
    _flagView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:_flagView];
    
    NSString *countryCode = [self _getValueFromUserDefaultsForKey:kCountry];
    [self _setFlag:countryCode];
}

- (void) countryPannel:(CountryPannel *)countryPannel selectedCountryView:(CountryView *)countryView
{
    [self _saveValue:countryView.countryCode forKey:kCountry];
    [self _getTopSaleWithGenre:_categoryView.gener];
    
    NSString *countryCode = [self _getValueFromUserDefaultsForKey:kCountry];
    [self _setFlag:countryCode];
    
}

- (void) _country
{
//    NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    
    CGRect rect = CGRectMake(1024 - kCountryRowHeight, 0, 250, 768);
    UIView *countryBGView = [[UIView alloc] initWithFrame:rect];
    _countryBGView = countryBGView;
    [self.view addSubview:_countryBGView];
    UIImage *bg = [UIImage imageNamed:@"dotted-pattern@2x.png"];
    _countryBGView.backgroundColor = [UIColor colorWithPatternImage:bg];
    
    rect.origin.x = 0;
    CountryPannel *countryPannel = [[CountryPannel alloc] initWithFrame:rect];
    [_countryBGView addSubview:countryPannel];
    [countryPannel release];
    
    countryPannel.countryPannelDelegate = self;
    
    if (![self _getValueFromUserDefaultsForKey:kCountry]) 
    {
//        NSString *country = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
        [self _saveValue:@"US" forKey:kCountry];
    }
    
    [self _setFlag:@"US"];
}


- (void) optionViewDidPressed:(OptionView *)optionView
{
    if ([optionView.type isEqualToString:kDevice]) 
    {
        if (optionView != _device) {
            _device.highlighted = NO;
            _device = optionView;
            _device.highlighted = YES;
        }
    }
    if ([optionView.type isEqualToString:kPrice]) 
    {
        if (optionView != _price) 
        {
            _price.highlighted = NO;
            _price = optionView;
            _price.highlighted = YES;
        }
    }
    if ([optionView.type isEqualToString:kTopOrNew]) 
    {
        if (optionView != _topOrNew) 
        {
            _topOrNew.highlighted = NO;
            _topOrNew = optionView;
            _topOrNew.highlighted = YES;
        }
    }
    
    [self _saveValue:optionView.title forKey:optionView.type];
    
    [self _getTopSaleWithGenre:_categoryView.gener];
}

- (void) _removeOldData
{
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsDirectory] error:nil];
    for (NSString *fileName in fileList) 
    {
        if (![fileName hasSuffix:[self _todayString]]) 
        {
            [[NSFileManager defaultManager] removeItemAtPath:[[self documentsDirectory] stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void) _panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateRecognized) 
    {
        CGFloat translation = [gestureRecognizer translationInView:self.view].x;
        
        if (translation < 0) 
        {
            [UIView beginAnimations:nil context:nil];
            _countryBGView.center = CGPointMake(1024 - CGRectGetWidth(_countryBGView.frame)/2, _countryBGView.center.y);
            [UIView commitAnimations];
        }else
        {
            [UIView beginAnimations:nil context:nil];
            _countryBGView.frame = CGRectMake(1024 - kCountryRowHeight, _countryBGView.frame.origin.y, CGRectGetWidth(_countryBGView.frame) , CGRectGetHeight(_countryBGView.frame));
            [UIView commitAnimations];
        }
    }
}

- (void) _gesture
{
   
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
    [panRecognizer release];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _gesture];

    [self _removeOldData];
    
    UIImage *bg = [UIImage imageNamed:@"hash-background.png"];
//    self.view.layer.contents = (id)bg.CGImage;
    self.view.backgroundColor = [UIColor colorWithPatternImage:bg];
    [self.view setOpaque:NO];
    [self.view.layer setOpaque:NO];

    [self _country];
    
    [self _category];
    
    [self _flag];
    
    [self _device];
    
    [self _price];
    
    [self _topOrNew];
    
    [self _size];
    
    [self _search];
    
    [self _configAppListView];
    
    [self _getTopSaleWithGenre:_categoryView.gener];
    _categoryView.highlighted = YES;
    
    [self.view bringSubviewToFront:_countryBGView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_downloadCompleted:) 
                                                 name:AppDataDownloadCompleted 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:AppDataDownloadCompleted
                                                  object:nil];
}

- (NSInteger)numberOfEntries
{
    NSInteger count = [_entries count];
    if (count == 0) {
        count = kCustomRowCount;
    }
    
    return count;
}

- (void) appRecordDetailDidPressedClossButton:(AppRecordDetail *)apprecordDetail
{
    
    [_appRecordDetail removeFromSuperview];
    [_appRecordDetail release];
    _appRecordDetail = nil;
}

- (void) cellDidPressed:(Cell *)cell
{
//    NSLog(@"%@",cell.appRecord);
    CGRect frame = CGRectMake(kWidthSpace, 0, kAppListViewWidth - kWidthSpace * 2, kAppListViewAvailableHeight - 0);
    AppRecordDetail *appRecordDetail = [AppRecordDetail appRecordDetailViewWithFrame:frame appRecord:cell.appRecord];
    _appRecordDetail = [appRecordDetail retain];
    _appRecordDetail.delegate = self;
    [self.view addSubview:appRecordDetail];
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView commitAnimations];
}

- (Cell *) cellForIndex:(int)index
{
    CGRect rect = CGRectMake(0, 0, 198, 76);
    Cell *cell = [[[Cell alloc] initWithFrame:rect] autorelease];

    cell.delegate = self;
    
    AppRecord *appRecord = [_entries objectAtIndex:index];
    
    cell.appRecord = appRecord;
    cell.textLabel.text = appRecord.appName;
    cell.detailTextLabel.text = appRecord.artist;
    cell.priceLabel.text = appRecord.price;
    cell.numberLabel.text = appRecord.index;
    NSInteger row = ceill((_appListView.contentOffset.y + 768 + kHeightSpace) / (76 + kHeightSpace));
    
    if (!appRecord.appIcon) 
    {
        if (index < (row * 3)) 
        {
            [self startIconDownload:appRecord forIndex:index];
        }else
        {
            cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        }
    }
    else
    {
        cell.imageView.image = appRecord.appIcon;
    }
    
    [_cells addObject:cell];
    
    
    return cell;
}


- (void) startIconDownload:(AppRecord *)appRecord forIndex:(NSInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey: key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.index = index;
        iconDownloader.delegate = self;
        [_imageDownloadsInProgress setObject:iconDownloader forKey: key];
        [iconDownloader startDownload];
        [iconDownloader release];
    }
}

- (void) loadImagesForOnscreenRows
{
    if ([_entries count] > 0) 
    {
        NSInteger row = ceill((_appListView.contentOffset.y + 768.0 + kHeightSpace) / (76.0 + kHeightSpace));
        
        NSInteger visibleRow = ceill(768.0 + kHeightSpace)/(76.0 + kHeightSpace);
        
        for (int i = row - visibleRow - 1; i <= row; i++) 
        {
            for (int j = 0; j < 3 && (i * 3 + j) < [_entries count] && (i * 3 + j) >= 0; j++) {
                AppRecord *appRecord = [_entries objectAtIndex:(i * 3 + j)];
                if (!appRecord.appIcon) {
                    [self startIconDownload:appRecord forIndex:i * 3 + j];
                }
            }
        }
    }
}

- (void)appImageDidLoad:(NSInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:key];
    if (iconDownloader != nil) 
    {
        Cell *cell = [_cells objectAtIndex:index];
        cell.imageView.image = iconDownloader.appRecord.appIcon;
    }
}

- (void)_downloadCompleted:(NSNotification *)notification
{
    [self _configAppListView];
    
    [_entries release];
    _entries = [[notification object] retain];
    
    _appListView.number = [_entries count];
    [_appListView reloadData];
    
    _searchField.enabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void) categoryViewDidPressed:(CategoryView *)category
{
    _categoryView.highlighted = NO;
    _categoryView = category;
    _categoryView.highlighted = YES;
//    [self _getTopSaleWithGenre:category.gener];
    
    [self performSelectorOnMainThread:@selector(_getTopSaleWithGenre:) withObject:category.gener waitUntilDone:NO];
}



@end
