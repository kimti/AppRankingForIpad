
#import <QuartzCore/QuartzCore.h>
#import "AppRecordDetail.h"
#import "Config.h"

@implementation AppRecordDetail
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_album release];
    [_imageString release];
    
    [super dealloc];
}

- (void)imageStringDidLoad:(NSArray *)imageStrings
{
    [_album update:imageStrings];
}

#define tag 20
#define space 140
- (id)initWithFrame:(CGRect)frame appRecord:(AppRecord *)appRecord
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *bg = [UIImage imageNamed:@"detail_bg.png"];

        self.backgroundColor = [UIColor colorWithPatternImage:bg];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        
        UIImageView *appImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tag, 30, 100, 100)];
        [self addSubview:appImageView];
        [appImageView release];
        
        appImageView.image = appRecord.appOriginImage;
        appImageView.backgroundColor = [UIColor clearColor];
        appImageView.layer.cornerRadius = 10;
        appImageView.layer.masksToBounds = YES;
        
        UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, 10, 450, 44)];
        [self addSubview:appNameLabel];
        [appNameLabel release];
        appNameLabel.font = [UIFont boldSystemFontOfSize:22.0];
//        appNameLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:94.0/255.0 blue:32.0/255.0 alpha:1.0]; 
        appNameLabel.text = appRecord.appName;
        appNameLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, 54, 450, 21)];
        [self addSubview:categoryLabel];
        [categoryLabel release];
        categoryLabel.text = appRecord.category;
        categoryLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, 75, 450, 21)];
        [self addSubview:priceLabel];
        [priceLabel release];
        
        priceLabel.font = [UIFont boldSystemFontOfSize:18];
        priceLabel.text = appRecord.price;
        priceLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:94.0/255.0 blue:32.0/255.0 alpha:1.0];
        priceLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, 96, 450, 21)];
        [self addSubview:artistLabel];
        [artistLabel release];
        artistLabel.font = [UIFont systemFontOfSize:15];
        artistLabel.text = appRecord.artist;
        artistLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *releaseDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(space, 117, 450, 21)];
        [self addSubview:releaseDateLabel];
        [releaseDateLabel release];
        releaseDateLabel.font = [UIFont systemFontOfSize:15];
        releaseDateLabel.text = appRecord.releaseDate;
        releaseDateLabel.backgroundColor = [UIColor clearColor];
        
        UIImage *downloadImage = [UIImage imageNamed:@"Ipad_download01.png"];

        UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:download];
        [download addTarget:self action:@selector(_downLoadApp:) forControlEvents:UIControlEventTouchUpInside];
        [download setBackgroundImage:downloadImage forState:UIControlStateNormal];
        download.titleLabel.text = [appRecord.appURLString stringByReplacingOccurrencesOfString:@"http://" withString:@"itms-apps://"];
//        download.titleLabel.text = appRecord.downloadLink;
//        [download setTitle:@"Download" forState:UIControlStateNormal];
        
        download.frame = CGRectMake(505, 100, downloadImage.size.width, downloadImage.size.height);
        
        
//        UILabel *rightsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 236, CGRectGetWidth(self.bounds) - 120, 44)];
//        [self addSubview:rightsLabel];
//        [rightsLabel release];
//        
//        rightsLabel.text = [NSString stringWithFormat:@"©: %@", appRecord.rights];
//        rightsLabel.lineBreakMode = UILineBreakModeWordWrap; 
//        rightsLabel.numberOfLines = 0;
//        
//        CGRect rect = [rightsLabel textRectForBounds:CGRectMake(120, 236, CGRectGetWidth(self.bounds) - 120, FLT_MAX) 
//                        limitedToNumberOfLines:0];
//        rightsLabel.frame = rect;
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(tag * 2, CGRectGetMaxY(download.frame) , CGRectGetWidth(self.bounds) - tag * 2, 44)];
        [self addSubview:descriptionLabel];
        [descriptionLabel release];
        descriptionLabel.font = [UIFont boldSystemFontOfSize:16];
        descriptionLabel.text = @"Description:";
        descriptionLabel.backgroundColor = [UIColor clearColor];
        
        UITextView *summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(tag * 2, CGRectGetMaxY(descriptionLabel.frame), CGRectGetWidth(self.bounds) - tag * 2, 360)];
        [self addSubview:summaryTextView];
        [summaryTextView release];
        summaryTextView.editable = NO;
        summaryTextView.font = [UIFont systemFontOfSize:11];
        summaryTextView.text = appRecord.summary;
        summaryTextView.backgroundColor = [UIColor clearColor];
        
        CGRect albumRect = CGRectMake(0, CGRectGetMaxY(summaryTextView.frame) + kHeightSpace, CGRectGetWidth(self.bounds), kHeightSpace * 2 + kImageHeight);
        Album *album = [Album albumWithFrame:albumRect imageStrings:nil];
        [self addSubview:album];
        _album = [album retain];
        
        ImageString *imageString = [[ImageString alloc] init];
        _imageString = imageString;
        [imageString startDownloadWithLink:appRecord.appURLString];
        imageString.delegate = self;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:closeButton];
        UIImage *closeImage = [UIImage imageNamed:@"close.png"];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(_closeButtoonPressed:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = CGRectMake(600, 10, closeImage.size.width, closeImage.size.height);
        
    }
    return self;
}

- (void) _downLoadApp:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:sender.titleLabel.text];
    [[UIApplication sharedApplication] openURL:url]; 
}
- (void)_closeButtoonPressed:(UIButton *)sender
{
    [_imageString cancelDownload];
    
    if ([_delegate respondsToSelector:@selector(appRecordDetailDidPressedClossButton:)]) 
    {
        [_delegate appRecordDetailDidPressedClossButton:self];
    }
}

+ (id) appRecordDetailViewWithFrame:(CGRect)frame appRecord:(AppRecord *)appRecord
{
    return [[[[self class] alloc] initWithFrame:frame appRecord:appRecord] autorelease];
}

@end
