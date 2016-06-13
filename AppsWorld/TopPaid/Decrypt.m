

#import "Decrypt.h"

@implementation Decrypt
+(NSData *)dencryptWithData:(NSData *)data
{
    NSString *hexString = @"ZHONGMEITECHNOLOGYDEVELOPMENT";
    NSData *iv = [FBEncryptorAES dataForHexString:hexString];
    return [FBEncryptorAES decryptData:data key:iv iv:iv];
}

+ (NSData *)dataWithName:(NSString *)imageName
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [Decrypt dencryptWithData:data];
}

@end
