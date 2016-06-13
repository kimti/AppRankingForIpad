

#import "ImageDownloader.h"
#import "Config.h"

@implementation ImageDownloader
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize modifiedImage;
@synthesize originImage;
@synthesize index;
@synthesize delegate;

- (void)dealloc
{
    [activeDownload release];
    [imageConnection release];
    [modifiedImage release];
    [originImage release];
    
    [super dealloc];
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
    // Set appIcon and clear temporary data/image
    UIImage *image = [[[UIImage alloc] initWithData:self.activeDownload] autorelease];
    self.originImage = image;
    self.self.modifiedImage = image;
//    CGSize itemSize = CGSizeMake(kImageWight, kImageHeight);
//    UIGraphicsBeginImageContext(itemSize);
//    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//    [image drawInRect:imageRect];
//    self.modifiedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    if ([_delegate respondsToSelector:@selector(cellDidPressed:)])
//    {
    
    BOOL has = [delegate respondsToSelector:@selector(imageDidLoad:)];
    if (delegate != nil && has) {
        [delegate imageDidLoad:self.index];
    }

}

@end
