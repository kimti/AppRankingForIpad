

#import <Foundation/Foundation.h>
#import "FBEncryptorAES.h"

@interface Decrypt : NSObject
+ (NSData *)dencryptWithData:(NSData *)data;
+ (NSData *)dataWithName:(NSString *)imageName;
@end
