
@interface AppRecord : NSObject
{
    NSString *appName;
    UIImage *appIcon;
    NSString *imageURLString;
    NSString *artist;
    
    NSString *appURLString;
    NSString *price;
    NSString *rights;
    NSString *releaseDate;
    NSString *summary;
    
    UIImage *appOriginImage;
    NSString *downloadLink;
    NSString *category;
    NSString *index;
}

@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) UIImage *appIcon;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *imageURLString;

@property (nonatomic, retain) NSString *appURLString;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *rights;
@property (nonatomic, retain) NSString *releaseDate;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) UIImage *appOriginImage;
@property (nonatomic, retain) NSString *downloadLink;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *index;
@end