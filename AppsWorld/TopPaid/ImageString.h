

#import <Foundation/Foundation.h>

@protocol ImageStringDelegate;
@interface ImageString : NSObject 
{
    id <ImageStringDelegate> delegate;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
- (void)startDownloadWithLink:(NSString *)url;
- (void)cancelDownload;
@end

@protocol ImageStringDelegate <NSObject>
- (void)imageStringDidLoad:(NSArray *)imageStrings;
@end
