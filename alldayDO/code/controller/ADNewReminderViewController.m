//
//  ADNewReminderViewController.m
//  alldayDO
//
//  Created by Fábio Nogueira  on 18/05/14.
//  Copyright (c) 2014 Fábio Nogueira . All rights reserved.
//

#import "ADNewReminderViewController.h"

#import <JVFloatLabeledTextField.h>
#import <JCRBlurView.h>

#import "ADLembrete.h"
#import "ADModel.h"
#import "ADNotification.h"
#import "ADBadgeCell.h"

typedef enum {
    ADCycleTypeDay,
    ADCycleTypeWeek,
    ADCycleTypeMonth,
    ADCycleTypeYear,
} ADCycleType;

#define PADDING 10.f
#define ACTIVE_COLOR [UIColor sam_colorWithHex:@"#A459C1"];
#define DEFAULT_COLOR [UIColor sam_colorWithHex:@"#655BB3"];

#define NUMBER_OF_ICONS 42


@interface ADNewReminderViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) JVFloatLabeledTextField *descriptionTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *periodoTextField;
@property (nonatomic, strong) JVFloatLabeledTextField *dataTextField;

@property (nonatomic, strong) UIDatePicker *dataPicker;
@property (nonatomic, strong) UIPickerView *periodoPickerView;

@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UIButton *cancelarButton;
@property (nonatomic, strong) UIButton *salvarButton;

@property (nonatomic, strong) UIToolbar *toolbarKeyboard;

@property (nonatomic, strong) UIView *badgeView;
@property (nonatomic, strong) UICollectionView *badgeCollectionView;
@property (nonatomic, strong) UIImageView *badgeImageView;
@property (nonatomic, strong) UIImageView *badgeIconImageView;

@property (nonatomic, strong) NSMutableArray *icons;

- (void)_addBlurView;
- (void)_addReminderTouched;
- (void)_addGesturesRecognizer;
- (void)_addInputViewForTextField;
- (void)_addSubViews;
- (void)_cancelarTouched;
- (void)_dismissKeyboard;
- (void)_refreshTimeLabel:(UIDatePicker*)datePicker;
- (NSString *)_textForCycleType:(NSInteger)cycleType;

- (void)_displayBadgeView;

@end

@implementation ADNewReminderViewController

#pragma mark - UIViewController Methods -

- (id)init {
    self = [super init];
    if (self) {
        self.view.frame = CGRectMake(0, 0, 300, 400);
        
        [self _addBlurView];
        [self _addGesturesRecognizer];
        [self _addInputViewForTextField];
        [self _addSubViews];
    }
    return self;
}

#pragma mark - Getter Methods -

- (JVFloatLabeledTextField *)descriptionTextField {
    if (!_descriptionTextField) {
        _descriptionTextField = [[JVFloatLabeledTextField alloc] init];
        _descriptionTextField.delegate = self;
        _descriptionTextField.returnKeyType = UIReturnKeyNext;
        _descriptionTextField.floatingLabelActiveTextColor = ACTIVE_COLOR;
        _descriptionTextField.floatingLabelTextColor = DEFAULT_COLOR;
        _descriptionTextField.frame = CGRectMake(PADDING, PADDING, self.view.width - PADDING, 44.f);
        [_descriptionTextField setPlaceholder:@"O que precisamos te lembrar?"
                            floatingTitle:@"Você não pode esquecer de"];
        _descriptionTextField.inputAccessoryView = self.toolbarKeyboard;
    }
    return _descriptionTextField;
}

- (JVFloatLabeledTextField *)periodoTextField {
    if (!_periodoTextField) {
        _periodoTextField = [[JVFloatLabeledTextField alloc] init];
        _periodoTextField.delegate = self;
        _periodoTextField.frame = CGRectMake(PADDING, self.descriptionTextField.maxY, self.view.width, 44.f);
        _periodoTextField.floatingLabelActiveTextColor = ACTIVE_COLOR;
        _periodoTextField.floatingLabelTextColor = DEFAULT_COLOR;
        [_periodoTextField setPlaceholder:@"Quando?"
                            floatingTitle:@"No periodo de"];
        _periodoTextField.inputAccessoryView = self.toolbarKeyboard;
    }
    return _periodoTextField;
}

- (JVFloatLabeledTextField *)dataTextField {
    if (!_dataTextField) {
        _dataTextField = [[JVFloatLabeledTextField alloc] init];
        _dataTextField.delegate = self;
        _dataTextField.frame = CGRectMake(PADDING, self.periodoTextField.maxY, self.view.width, 44.f);
        _dataTextField.floatingLabelActiveTextColor = ACTIVE_COLOR;
        _dataTextField.floatingLabelTextColor = DEFAULT_COLOR;
        [_dataTextField setPlaceholder:@"Que horas?"
                            floatingTitle:@"às"];
        _dataTextField.inputAccessoryView = self.toolbarKeyboard;
    }
    return _dataTextField;
}

- (UIDatePicker *)dataPicker {
    if (!_dataPicker) {
        _dataPicker = [[UIDatePicker alloc] init];
        _dataPicker.datePickerMode = UIDatePickerModeTime;
        _dataPicker.backgroundColor = [UIColor whiteColor];
        [_dataPicker addTarget:self
                       action:@selector(_refreshTimeLabel:)
             forControlEvents:UIControlEventAllEvents];
    }
    return _dataPicker;
}

- (UIPickerView *)periodoPickerView {
    if (!_periodoPickerView) {
        _periodoPickerView = [[UIPickerView alloc] init];
        _periodoPickerView.dataSource = self;
        _periodoPickerView.delegate = self;
        _periodoPickerView.backgroundColor = [UIColor whiteColor];
    }
    return _periodoPickerView;
}

- (UIView *)iconView {
    if (!_iconView) {
        _iconView = [UIView viewWithFrame:CGRectMake(0.f, 0.f, 90.f, 90.f)];
        _iconView.center = self.view.center;
        [_iconView setY:(self.salvarButton.y - self.dataTextField.maxY) - PADDING];
        UITapGestureRecognizer *iconGestureRecognizer = [UITapGestureRecognizer gestureRecognizerWithTarget:self
                                                                                                     action:@selector(_displayBadgeView)];
        [_iconView addGestureRecognizer:iconGestureRecognizer];
        
        
        self.badgeImageView = [UIImageView imageViewWithImage:[UIImage imageNamed:@"newHexacon"]];
        [_iconView addSubview:self.badgeImageView];
        
        self.badgeIconImageView.center = self.badgeImageView.center;
        [_iconView addSubview:self.badgeIconImageView];
    }
    return _iconView;
}

- (UIButton *)cancelarButton {
    if (!_cancelarButton) {
        _cancelarButton = [UIButton buttonWithCustomTypeAndFrame:CGRectMake(self.salvarButton.maxX,
                                                                            self.view.maxY - 60.f,
                                                                            self.view.width / 2,
                                                                            60.f)];
        [_cancelarButton setTitle:@"Cancelar" forState:UIControlStateNormal];
        [_cancelarButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_cancelarButton addTarget:self action:@selector(_cancelarTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelarButton;
}

- (UIButton *)salvarButton {
    if (!_salvarButton) {
        _salvarButton = [UIButton buttonWithCustomTypeAndFrame:CGRectMake(0,
                                                                          self.view.maxY - 60.f,
                                                                          self.view.width / 2,
                                                                          60.f)];
        [_salvarButton setTitle:@"Salvar" forState:UIControlStateNormal];
        [_salvarButton setTitleColor:[UIColor colorWithRed:0.29 green:0.13 blue:0.38 alpha:1] forState:UIControlStateNormal];
        [_salvarButton addTarget:self action:@selector(_dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _salvarButton;
}

- (UIToolbar *)toolbarKeyboard {
    if (!_toolbarKeyboard) {
        _toolbarKeyboard = [[UIToolbar alloc] init];
        [_toolbarKeyboard setW:self.view.width andH:38.f];
        UIBarButtonItem *flexibleButton = [UIBarButtonItem barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                         target:self
                                                                                         action:nil];
        UIBarButtonItem *nextButton = [UIBarButtonItem barButtonItemWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(_dismissKeyboard)];
        nextButton.tintColor = ACTIVE_COLOR;
        _toolbarKeyboard.items = @[flexibleButton, nextButton];
    }
    return _toolbarKeyboard;
}

- (UIView *)badgeView {
    if (!_badgeView) {
        _badgeView = [UIView viewWithFrame:self.view.bounds];
        _badgeView.layer.cornerRadius = 6.f;
        _badgeView.alpha = 0.f;
    }
    return _badgeView;
}

- (UICollectionView *)badgeCollectionView {
    if (!_badgeCollectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        collectionViewLayout.itemSize = CGSizeMake(40.f, 40.f);
        collectionViewLayout.sectionInset = UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f);
        _badgeCollectionView = [UICollectionView collectionViewWithFrame:self.badgeView.bounds
                                                                  layout:collectionViewLayout];
        _badgeCollectionView.dataSource = self;
        _badgeCollectionView.delegate = self;
        _badgeCollectionView.layer.cornerRadius = 6.f;
        _badgeCollectionView.backgroundColor = [UIColor whiteColor];
        _badgeCollectionView.allowsSelection = YES;
    }
    return _badgeCollectionView;
}

- (UIImageView *)badgeIconImageView {
    if (!_badgeIconImageView) {
        _badgeIconImageView = [[UIImageView alloc] init];
        _badgeIconImageView.frame = CGRectMake(0.f, 0.f, 32.f, 32.f);
    }
    return _badgeIconImageView;
}

- (NSMutableArray *)icons {
    if (!_icons) {
        _icons = [NSMutableArray array];
        
        for (int i = 1; i <= NUMBER_OF_ICONS; i++) {
            [_icons addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%i.png", i]]];
        }
    }
    return _icons;
}

#pragma mark - UIViewController Methods -

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self _dismissKeyboard];
}

#pragma mark - Private Methods -

- (void)_addBlurView {
    JCRBlurView *blurView = [JCRBlurView new];
    blurView.frame = self.view.frame;
    blurView.layer.cornerRadius = 6.f;
    [self.view addSubview:blurView];
}

- (void)_addReminderTouched {
        if (![self.descriptionTextField.text isEqual:@""]) {
        ADLembrete *lembrete = [NSEntityDescription insertNewObjectForEntityADLembrete];
        lembrete.descricao = self.descriptionTextField.text;
        lembrete.periodo = [NSNumber numberWithInteger:[self.periodoPickerView selectedRowInComponent:0]];
        lembrete.data = self.dataPicker.date;
        
        [[ADModel sharedInstance] saveChanges];
        
        UILocalNotification *newNotification = [UILocalNotification defaultLocalNotificationWith:lembrete];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)_addGesturesRecognizer {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}

- (void)_addInputViewForTextField {
    self.dataTextField.inputView = self.dataPicker;
    self.periodoTextField.inputView = self.periodoPickerView;
}

- (void)_addSubViews {
    [self.view addSubview:self.descriptionTextField];
    [self.view addSubview:self.periodoTextField];
    [self.view addSubview:self.dataTextField];
    [self.view addSubview:self.iconView];
    [self.view addSubview:self.salvarButton];
    [self.view addSubview:self.cancelarButton];
    [self.view addSubview:self.badgeView];
    [self.badgeView addSubview:self.badgeCollectionView];
}

- (void)_cancelarTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)_refreshTimeLabel:(UIDatePicker*)datePicker {
    NSDate *date = [NSDate date];
    
    if (datePicker) {
        date = datePicker.date;
    }
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:@"hh"];
    NSString *horaFormated = [NSString stringWithFormat:@"%@",[outputFormatter stringFromDate:date]];
    
    [outputFormatter setDateFormat:@"mm"];
    NSString *minutosFormated = [NSString stringWithFormat:@"%@",[outputFormatter stringFromDate:date]];

    [outputFormatter setDateFormat:@"a"];
    NSString *periodoFormated = [NSString stringWithFormat:@"%@",[outputFormatter stringFromDate:date]];
    
    self.dataTextField.text = [NSString stringWithFormat:@"%@:%@ %@", horaFormated, minutosFormated, periodoFormated];
}

- (NSString *)_textForCycleType:(NSInteger)cycleType {
    NSString *text;
    
    switch (cycleType) {
        case ADCycleTypeDay:
            text = @"Diáriamente";
            break;
        case ADCycleTypeWeek:
            text = @"Semanalmente";
            break;
        case ADCycleTypeMonth:
            text = @"Mensalmente";
            break;
        case ADCycleTypeYear:
            text = @"Anualmente";
            break;
    }
    
    return text;
}

- (void)_displayBadgeView {
    [self _dismissKeyboard];
    [UIView animateWithDuration:0.4f animations:^{
        self.badgeView.alpha = 1.f;
        [self.badgeCollectionView reloadData];
    }];
}

#pragma mark - UITextFieldDelegate Methods -

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.periodoTextField) {
        self.periodoTextField.text = [self _textForCycleType:0];
    } else if (textField == self.dataTextField) {
        [self _refreshTimeLabel:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL edited = NO;
    
    if (textField == self.descriptionTextField) {
        edited = YES;
    }
    
    return edited;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.descriptionTextField) {
        [self.periodoTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIPickerViewDataSource Methods -


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return sizeof(ADCycleType);
}

#pragma mark - UIPickerViewDelegate Methods -

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self _textForCycleType:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.periodoTextField.text = [self _textForCycleType:row];
}


#pragma mark - UICollectionViewDataSource Methods -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NUMBER_OF_ICONS;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"badgeCell-%@", indexPath];
    
    [collectionView registerClass:[ADBadgeCell class] forCellWithReuseIdentifier:identifier];
    
    ADBadgeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.iconImageView.image = [self.icons objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:0.4f animations:^{
        self.badgeView.alpha = 0.0f;
    }];

    self.badgeImageView.image = [[UIImage imageNamed:@"Hexacon"] tintedImageWithColor:[UIColor sam_colorWithHex:@"#655BB3"]];
    self.badgeIconImageView.image = [[self.icons objectAtIndex:indexPath.row] tintedImageWithColor:[UIColor whiteColor]];
}

@end