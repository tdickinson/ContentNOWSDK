//
//  ContentNOW.h
//  ContentNOWSandbox
//
//  Created by Ted Dickinson on 4/30/15.
//  Copyright (c) 2015 Ted Dickinson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentNOW : NSObject

@property (nonatomic, strong, readonly) NSString *secretKey;
@property (nonatomic, strong, readonly) NSString *applicationId;
@property (nonatomic, strong, readonly) NSString *baseURL;

+ (ContentNOW *) instance;

- (void)setApplicationId:(NSString *)applicationId secretKey:(NSString *)secretKey baseURL:(NSString *)baseURL;

- (NSString *)hashForURL:(NSString *)url;

- (NSString *)currentDateString;


@end
