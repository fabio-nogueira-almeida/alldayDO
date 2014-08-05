//
//  ADRemindersCollectionViewController.m
//  alldayDO
//
//  Created by Fábio Nogueira  on 05/06/14.
//  Copyright (c) 2014 Fábio Nogueira . All rights reserved.
//

#import "ADRemindersTableViewController.h"

#import "ADLembrete.h"
#import "ADModel.h"
#import "ADReminderCell.h"

#import "ADNewReminderViewController.h"
#import "ADNewReminderViewControllerDelegate.h"

#import "PresentingAnimator.h"
#import "DismissingAnimator.h"

@interface ADRemindersTableViewController () <UIViewControllerTransitioningDelegate, ADNewReminderViewControllerDelegate>

@property (nonatomic, strong) ADRemindersViewModel *viewModel;

@property (nonatomic, strong) UIView *blurView;

- (void)_addSubView;
- (void)_initStyle;
- (void)_presentNewReminderViewController;
- (void)_showBlurViewWithAnimation;

@end

@implementation ADRemindersTableViewController

#pragma mark - Getter Methods -

- (ADRemindersViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ADRemindersViewModel alloc] init];
    }
    return _viewModel;
}

- (UIView *)blurView {
    if (!_blurView) {
        _blurView = [UIView viewWithFrame:self.view.frame];
        _blurView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.300];
    }
    
    return _blurView;
}

#pragma mark - UIView Lifecycle Methods -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self _initStyle];
    [self _addSubView];
    
    [self.viewModel executeFetchRequest];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Private Methods -

- (void)_addSubView {
    [self.view addSubview:self.blurView];
    [self.view sendSubviewToBack:self.blurView];
}

- (void)_initStyle {
    [self.tableView setBackgroundColor:[UIColor sam_colorWithHex:@"#EFF2F5"]];
}

- (void)_presentNewReminderViewController {
    ADNewReminderViewController *newReminderViewController = [ADNewReminderViewController viewController];
    newReminderViewController.delegate = self;
    newReminderViewController.transitioningDelegate = self;
    newReminderViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self _showBlurViewWithAnimation];
    
    [self presentViewController:newReminderViewController animated:YES completion:NULL];
}

- (void)_showBlurViewWithAnimation {
    [self.view bringSubviewToFront:self.blurView];
    
    self.blurView.alpha = 0.0f;
    [UIView animateWithDuration:0.5f animations:^{
        self.blurView.alpha = 1.0f;
    }];
}

#pragma mark - UITableViewDataSource Methods -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfReminders = [self.viewModel numberOfItemsInSection:section];
    self.totalRemindersLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfReminders];
    return numberOfReminders;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell"];

#warning Criar metodo para definir estilo da celula
    cell.borderTimelineContentView.layer.cornerRadius = 5.f;
    cell.timelineContentView.layer.cornerRadius = 5.f;
    
    if ([tableView numberOfRowsInSection:indexPath.section] - 1 == indexPath.row) {
        cell.lineBottomView.hidden = YES;
    } else {
        cell.lineBottomView.hidden = NO;
    }
    
    [self.viewModel fetchObjectAtIndexPath:indexPath];
    
    cell.nomeLabel.text = self.viewModel.descricao;
    cell.nextReminderLabel.text = [NSString stringWithFormat:@"%@", [self.viewModel nextReminderFormated]];
    cell.badgeImageView.badgeIconImageView.image = self.viewModel.imagem;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel deleteRow:indexPath];
    [self.viewModel executeFetchRequest];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark - IBOutlet Methods -

- (IBAction)newReminderTouched:(id)sender {
    [self _presentNewReminderViewController];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods -

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [DismissingAnimator new];
}

#pragma mark - ADNewReminderViewControllerDelegate Methods -

- (void)newReminderViewController:(ADNewReminderViewController *)newReminderViewController
                  didSaveReminder:(ADLembrete *)reminder {
    [self.view sendSubviewToBack:self.blurView];
    [newReminderViewController dismissViewControllerAnimated:YES completion:^{
        [self.viewModel executeFetchRequest];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    }];
}

- (void)newReminderViewControllerDidCancelReminder:(ADNewReminderViewController *)newReminderViewController {
        [self.view sendSubviewToBack:self.blurView];
}

@end