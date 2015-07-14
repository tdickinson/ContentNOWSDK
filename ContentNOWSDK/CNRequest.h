//
//  CNRequest.h
//  ContentNOWSandbox
//
//  Created by Ted Dickinson on 5/5/15.
//  Copyright (c) 2015 Ted Dickinson. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^CNResponseBlock)(NSArray *responseObjects, NSError *error);

typedef NS_ENUM(NSInteger, CNSearchType) {
    freeTextSearch,
    categoryCode,
    advancedSearch
};

@interface CNRequest : NSObject

@property CNSearchType searchType;
@property NSString *searchQuery;
@property NSInteger searchRows;
@property double geoLocAccessLatd;
@property double geoLocAccessLong;
@property NSString *accessMdm;


+ (CNRequest *)sharedInstance;

/**
 * Do a free text search for the given term (puts a wildcard after the search term)
 * If the search is successful it will return the response as responseObjects, otherwise it will return an error
 */
- (void)search:(NSString*)searchTerm completion:(CNResponseBlock)completion;

/* Do a search for a specific UPC
 * If the search is successful it will return the response as responseObjects, otherwise it will return an error
*/
- (void)searchForUPC:(NSString*)searchUPC completion:(CNResponseBlock)completion;

/**
 * Get full details for the given item
 */
- (void)fetch:(NSString*)itemId completion:(CNResponseBlock)completion;

/**
 * Shows a standardized error based on the NSError parameter
 */
+ (void)showError:(NSError *)error;

@end
