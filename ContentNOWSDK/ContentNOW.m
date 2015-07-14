//
//  ContentNOW.m
//  ContentNOWSandbox
//
//  Created by Ted Dickinson on 4/30/15.
//  Copyright (c) 2015 Ted Dickinson. All rights reserved.
//

#import "ContentNOW.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <RestKit.h>


@implementation ContentNOW

static ContentNOW *instance = nil;
+ (ContentNOW *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[ContentNOW alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    self = [super init];
    _applicationId = [[NSString alloc] init];
    _secretKey = [[NSString alloc] init];
    _baseURL = [[NSString alloc] init];

    return self;
}

- (void)setApplicationId:(NSString *)applicationId secretKey:(NSString *)secretKey baseURL:(NSString *)baseURL
{
    _applicationId = applicationId;
    _secretKey = secretKey;
    _baseURL = baseURL;
}

/**
 * Returns sha 256 encoded hash turned into base 64 encoded string. Also url encodes it then returns it
 */
- (NSString *)hashForURL:(NSString *)url {
    NSString *key = self.secretKey;
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [url cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self base64forData:hash];
}

- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    
    
    return [self URLEncodeStringFromString:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
    
}

- (NSString *)URLEncodeStringFromString:(NSString *)string
{
    static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
    CFStringRef str = (__bridge CFStringRef)string;
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}



-(NSString *)currentDateString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormat setTimeZone:timeZone];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    return [dateFormat stringFromDate:[NSDate date]];
    
}




@end
