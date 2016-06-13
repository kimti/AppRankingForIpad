
#import "ParseOperation.h"
#import "AppRecord.h"

// string contants found in the RSS feed
static NSString *kEntryStr  = @"entry"; // marker for each app entry
static NSString *kIDStr     = @"id";
static NSString *kNameStr   = @"im:name";
static NSString *kImageStr  = @"im:image";
static NSString *kArtistStr = @"im:artist";

static NSString *kCategory = @"category";

static NSString *kPriceStr = @"im:price";
static NSString *kRightsStr = @"rights";
static NSString *kReleaseDateStr = @"im:releaseDate";
static NSString *kSummaryStr = @"summary";

@interface ParseOperation ()
@property (nonatomic, assign) id <ParseOperationDelegate> delegate;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) AppRecord *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@property (nonatomic, assign) NSString *trackingCategoryName;
@property (nonatomic, assign) NSString *trackingReleaseDate;
@property (nonatomic, assign) NSString *trackingArtistStr;
@property (nonatomic, assign) NSString *trackingCategory;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse,
            storingCharacterData, trackingCategoryName, trackingReleaseDate, trackingArtistStr, trackingCategory;

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:kIDStr, kNameStr, kImageStr, kArtistStr,
                                        kCategory,
                                        kPriceStr, kRightsStr, kReleaseDateStr, kSummaryStr, nil];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [workingArray release];
    [trackingCategoryName release];
    [trackingReleaseDate release];
    [trackingArtistStr release];
    [trackingCategory release];
    
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [NSMutableString string];

    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not
	// desirable because it gives less control over the network, particularly in responding to
	// connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataToParse];
	[parser setDelegate:self];
//    [parser setShouldProcessNamespaces:NO];
//	[parser setShouldReportNamespacePrefixes:NO];
//	[parser setShouldResolveExternalEntities:NO];
    [parser parse];
	
	if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
    self.trackingCategoryName = nil;
    self.trackingReleaseDate = nil;
    self.trackingArtistStr = nil;
    self.trackingCategory = nil;
    
    [parser release];

	[pool release];
}


#pragma mark -
#pragma mark RSS processing

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict
{
    // entry: { id (link), im:name (app name), im:image (variable height), im:price, rights, im:releaseDate, summary }
    //
    if ([elementName isEqualToString:kEntryStr])
	{
        self.workingEntry = [[[AppRecord alloc] init] autorelease];
    }
    if ([elementName isEqualToString:kReleaseDateStr])
    {
        self.trackingReleaseDate = [attributeDict objectForKey:@"label"];
    }
    if ([elementName isEqualToString:kArtistStr]) {
        self.trackingArtistStr = [attributeDict objectForKey:@"href"];
    }
    if ([elementName isEqualToString:kCategory]) {
        self.trackingCategory = [attributeDict objectForKey:@"label"];
    }
    if (self.workingEntry)
        storingCharacterData = [elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName
{
    if (self.workingEntry)
	{
        if (storingCharacterData)
        {
            NSString *trimmedString = [workingPropertyString stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            NSLog(@"%@",trimmedString);
            [workingPropertyString setString:@""];  // clear the string for next time
            if ([elementName isEqualToString:kIDStr])
            {
                self.workingEntry.appURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kNameStr])
            {        
                self.workingEntry.appName = trimmedString;
            }
            else if ([elementName isEqualToString:kImageStr])
            {
                self.workingEntry.imageURLString = trimmedString;
            }
            else if ([elementName isEqualToString:kArtistStr])
            {
                self.workingEntry.artist = trimmedString;
                self.workingEntry.downloadLink = trackingArtistStr;
            }
            else if ([elementName isEqualToString:kPriceStr])
            {
                self.workingEntry.price = trimmedString;
            }
            else if ([elementName isEqualToString:kRightsStr])
            {
                self.workingEntry.rights = trimmedString;
            }
            else if ([elementName isEqualToString:kReleaseDateStr])
            {
//                self.workingEntry.releaseDate = self.trackingReleaseDate;
                self.workingEntry.releaseDate = [trimmedString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            }
            else if ([elementName isEqualToString:kSummaryStr])
            {
                self.workingEntry.summary = trimmedString;
            }      
            else if ([elementName isEqualToString:kCategory])
            {
                self.workingEntry.category = self.trackingCategory;
//                NSLog(@"workingEntry.category: %@",self.workingEntry.category);
            }
        }
        else if ([elementName isEqualToString:kEntryStr])
        {
//            NSLog(@"%@", self.workingEntry);
            // we are at the end of an entry
            [self.workingArray addObject:self.workingEntry];  
            self.workingEntry = nil;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingCharacterData)
    {
        [workingPropertyString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate parseErrorOccurred:parseError];
}

@end
