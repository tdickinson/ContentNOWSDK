//
//  CNNutritionInfoView.h
//  ContentNOWSandbox
//
//  Created by Ted Dickinson on 5/12/15.
//  Copyright (c) 2015 Ted Dickinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWSItem.h"


@interface CNNutritionInfoView : UIView

/**
 * Shows the nutrition info for the given item
 */
- (void)showItem:(OWSItem *)item;

@end
