

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject 
{
    id <ImageDownloaderDelegate> delegate;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    
    UIImage *modifiedImage;
    UIImage *originImage;
    NSInteger index;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) UIImage *modifiedImage;
@property (nonatomic, retain) UIImage *originImage;
@property (nonatomic, assign) NSInteger index;

- (void)startDownloadWithLink:(NSString *)url;
@end

@protocol ImageDownloaderDelegate <NSObject>

- (void)imageDidLoad:(NSInteger)index;
@end
