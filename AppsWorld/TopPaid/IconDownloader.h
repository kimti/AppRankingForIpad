
@class AppRecord;

@protocol IconDownloaderDelegate;

@interface IconDownloader : NSObject
{
    AppRecord *appRecord;
    NSInteger _index;
    id <IconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) AppRecord *appRecord;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol IconDownloaderDelegate 
- (void)appImageDidLoad:(NSInteger)index;
@end