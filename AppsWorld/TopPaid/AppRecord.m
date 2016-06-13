#import "AppRecord.h"

@implementation AppRecord

@synthesize appName;
@synthesize appIcon;
@synthesize imageURLString;
@synthesize artist;

@synthesize appURLString;
@synthesize price;
@synthesize rights;
@synthesize releaseDate;
@synthesize summary;

@synthesize appOriginImage;
@synthesize downloadLink;
@synthesize category;
@synthesize index;

- (void)dealloc
{
    [appName release];
    [appIcon release];
    [imageURLString release];
	[artist release];
    
    [appURLString release];
    [price release];
    [rights release];
    [releaseDate release];
    [summary release];

    [appOriginImage release];
    [downloadLink release];
    [category release];
    
    [index release];
    
    [super dealloc];
}

- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"{\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n}",appName,imageURLString,artist,appURLString,price,rights,releaseDate,summary];
    
    return description;
}

@end

