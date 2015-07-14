//
//  CNRequest.m
//  ContentNOWSandbox
//
//  Created by Ted Dickinson on 5/5/15.
//  Copyright (c) 2015 Ted Dickinson. All rights reserved.
//

#import "CNRequest.h"
#import "ContentNOW.h"
#import "OWSItem.h"
#import <RestKit/RestKit.h>
#import "OWSSearchResult.h"
#import "OWSRKDynamicMapping.h"



@implementation CNRequest

+ (CNRequest *)sharedInstance {
    static CNRequest *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CNRequest alloc] init];
        
        NSURL *baseURL = [NSURL URLWithString:[ContentNOW instance].baseURL];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        // initialize RestKit
        RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
        
        //Create the response descriptor with the search result mapping
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OWSSearchResult mappingForClass]
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:nil
                                                                                               keyPath:@"searchResults"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        //Product details mapping
        RKResponseDescriptor *detailsDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[OWSItem mappingForClass]
                                                                                               method:RKRequestMethodAny
                                                                                          pathPattern:nil
                                                                                              keyPath:@"productDetails.item"
                                                                                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        
        //Error mapping
        RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
        [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"responseMessage" toKeyPath:@"errorMessage"]];
        
        NSMutableIndexSet *errorSets = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError).mutableCopy;
        [errorSets addIndexes:RKStatusCodeIndexSetForClass(RKStatusCodeClassServerError)];
        RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                             method:RKRequestMethodAny
                                                                                        pathPattern:nil
                                                                                            keyPath:nil
                                                                                        statusCodes:errorSets];
        
        [objectManager addResponseDescriptorsFromArray:@[responseDescriptor, detailsDescriptor, errorDescriptor]];
    });
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    _searchRows=10;
    _accessMdm = @"SMART_PHONE";
    _searchType = freeTextSearch;
    return self;
}



- (void)search:(NSString*)searchTerm completion:(CNResponseBlock)completion {
    
    NSString *selectedSearchType;
    
    switch (self.searchType)
    {
        case freeTextSearch:
            selectedSearchType = @"freeTextSearch";
            break;
        case categoryCode:
            selectedSearchType = @"categoryCode";
            break;
        case advancedSearch:
            selectedSearchType = @"advancedSearch";
            break;

    }
    
    //need to use the full path manually because it needs to be hashed
    NSMutableString *url = [NSMutableString stringWithFormat:@"/V1/products?searchType=%@&query=%@&geo_loc_access_latd=%f&geo_loc_access_long=%f&rows=%ld&access_mdm=%@&app_id=%@",selectedSearchType, searchTerm, self.geoLocAccessLatd, self.geoLocAccessLong,(long)self.searchRows,self.accessMdm ,[ContentNOW instance].applicationId];
        [url appendString:@"&TIMESTAMP="];
        [url appendString:[[ContentNOW instance] currentDateString]];
        NSString *hash = [[ContentNOW instance] hashForURL:url];
        [url appendString:@"&hash_code="];
        [url appendString:hash];
        
    //after the hash, can now url encode the search term
    [url replaceOccurrencesOfString:searchTerm withString:[searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, url.length)];
        
    [url insertString:[ContentNOW instance].baseURL atIndex:0];
    
    NSLog(@"URL: %@", url);
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                                                                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                             if (completion) {
                                                                                                                 completion(mappingResult.array, nil);
                                                                                                             }
                                                                                                         }
                                                                                                         failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                             if (completion) {
                                                                                                                 completion(nil, error);
                                                                                                             }
                                                                                                         }];
        
    [operation start];

    
}

- (void)searchForUPC:(NSString *)searchUPC completion:(CNResponseBlock)completion {
    
    NSString *selectedSearchType;
    NSString *updatedUPC = searchUPC;
    
    if (searchUPC.length == 13) {
        updatedUPC = [NSString stringWithFormat:@"0%@", searchUPC];
    }

    selectedSearchType = @"advancedSearch";
    
    //need to use the full path manually because it needs to be hashed
    NSMutableString *url = [NSMutableString stringWithFormat:@"/V1/products?searchType=%@&query=itemId:%@&geo_loc_access_latd=%f&geo_loc_access_long=%f&rows=%ld&access_mdm=%@&app_id=%@",selectedSearchType, updatedUPC, self.geoLocAccessLatd, self.geoLocAccessLong,(long)self.searchRows,self.accessMdm ,[ContentNOW instance].applicationId];
    [url appendString:@"&TIMESTAMP="];
    [url appendString:[[ContentNOW instance] currentDateString]];
    NSString *hash = [[ContentNOW instance] hashForURL:url];
    [url appendString:@"&hash_code="];
    [url appendString:hash];
    
    [url insertString:[ContentNOW instance].baseURL atIndex:0];
    
    NSLog(@"URL: %@", url);
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                                                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                         if (completion) {
                                                                                                             completion(mappingResult.array, nil);
                                                                                                         }
                                                                                                     }
                                                                                                     failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                         if (completion) {
                                                                                                             completion(nil, error);
                                                                                                         }
                                                                                                     }];
    
    [operation start];
    
    
}



- (void)fetch:(NSString*)itemId completion:(CNResponseBlock)completion {
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"/V1/products/%@?attrset=all&geo_loc_access_latd=%f&geo_loc_access_long=%f&access_mdm=%@&app_id=%@", itemId, self.geoLocAccessLatd, self.geoLocAccessLong,self.accessMdm , [ContentNOW instance].applicationId];
    [url appendString:@"&TIMESTAMP="];
    [url appendString:[[ContentNOW instance] currentDateString]];
    NSString *hash = [[ContentNOW instance] hashForURL:url];
    [url appendString:@"&hash_code="];
    [url appendString:hash];
        
    [url insertString:[ContentNOW instance].baseURL atIndex:0];
        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                                                                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                             if (completion) {
                                                                                                                 completion(mappingResult.array, nil);
                                                                                                             }
                                                                                                         }
                                                                                                         failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                             if (completion) {
                                                                                                                 completion(nil, error);
                                                                                                             }
                                                                                                         }];
        
        [operation start];

    }

+ (void)showError:(NSError *)error {
    NSString *message = error.localizedDescription;
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}




@end
