

#import "ImageString.h"

@interface NSString (StringBetween)

-(NSString *)stringBetween:(NSString*)aString and:(NSString *)bString;

@end
@implementation NSString (StringBetween)

-(NSString *)stringBetween:(NSString *)aString and:(NSString *)bString
{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
    //Find the range of the first string
    NSRange aRange = [self rangeOfString:aString options:(NSCaseInsensitiveSearch)];
    
    if(aRange.length > 0){
        //Make a new range to search for the next string
        NSRange searchRange;
        searchRange.location = aRange.location;
        searchRange.length = [self length] - aRange.location;
        
        //Find the next string
        NSRange bRange = [self rangeOfString:bString options:(NSCaseInsensitiveSearch) range:searchRange];
        
        //NSLog(@"%d, %d", aRange.location, aRange.length);
        //NSLog(@"%d, %d", bRange.location, bRange.length);
        
        if(bRange.length > 0)
        {
            searchRange.location = aRange.location + aRange.length;
            searchRange.length = bRange.location - searchRange.location;
            
            return [self substringWithRange:searchRange];
        }
    }
    [autoreleasepool release];
    return @"";

}
@end



@implementation ImageString

@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

- (void)dealloc
{
    [activeDownload release];
    [imageConnection release];
    
    [super dealloc];
}

- (NSArray *) getImageString:(NSData *)data
{
    return nil;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

- (void)startDownloadWithLink:(NSString *)url
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:url]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableArray *imageStrings = [NSMutableArray array];
    
    NSString *originString = [[NSString alloc] initWithData:self.activeDownload encoding:NSUTF8StringEncoding];
    NSString *preS = @"swoosh lockup-container application large screenshots";
    NSString *suffS = @"/></div></div></div>";
    
    NSString *s1 = [originString stringBetween:preS and:suffS];
    [originString release];
    
    NSArray *a = [s1 componentsSeparatedByString:@"src=\""];
    for (int i = 0; i < [a count]; i++) 
    {
        if (i != 0) 
        {
            NSString *ss = [a objectAtIndex:i];             
            NSArray *a2 = [ss componentsSeparatedByString:@"\""];
            if ([a2 count] >= 2) 
            {
                [imageStrings addObject:[a2 objectAtIndex:0]];
//                NSLog(@"%@",[a2 objectAtIndex:0]);
            }
        }
    }
    
    BOOL has = [delegate respondsToSelector:@selector(imageStringDidLoad:)];
    if(delegate != nil && has){
        [delegate imageStringDidLoad:imageStrings];
    }
    
}



@end
