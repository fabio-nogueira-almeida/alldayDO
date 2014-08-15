//
//  ADDetailReminderViewController.h
//  alldayDO
//
//  Created by Fábio Almeida on 8/13/14.
//  Copyright (c) 2014 Fábio Nogueira . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADLembrete.h"
#import "ADLembreteConfirmado.h"

@interface ADDetailReminderViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *monthContentView;
@property (strong, nonatomic) IBOutlet UIView *weekContentView;
@property (strong, nonatomic) IBOutlet UIView *borderContentView;

@property (strong, nonatomic) IBOutlet UIView *inLineContentView;
@property (strong, nonatomic) IBOutlet UIView *inLineBorderContentView;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) ADLembrete *lembrete;

- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)editButtonTouched:(id)sender;
- (IBAction)doneButtonTouched:(id)sender;

@end
