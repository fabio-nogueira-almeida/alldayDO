//
//  UIViewController+MALazykit.h
//  MALazykit
//
//  Created by Marlon Andrade on 01/04/13.
//  Copyright (c) 2013 Marlon Andrade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MALazykit)

+ (instancetype)viewController;
+ (instancetype)viewControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;

@end
