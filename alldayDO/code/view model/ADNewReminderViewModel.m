//
//  ADNewReminderViewModel.m
//  alldayDO
//
//  Created by Fábio Nogueira  on 14/06/14.
//  Copyright (c) 2014 Fábio Nogueira . All rights reserved.
//

#import "ADNewReminderViewModel.h"

#import "ADModel.h"
#import "ADLembrete+ADToolkitAdditions.h"

typedef enum {
    ADCycleTypeDay,
    ADCycleTypeWeek,
    ADCycleTypeMonth,
    ADCycleTypeYear,
} ADCycleType;

@implementation ADNewReminderViewModel

#pragma mark - Public Methods -

- (void)saveChanges {
    ADLembrete *lembrete = [NSEntityDescription insertNewObjectForEntityADLembrete];
    lembrete.descricao = self.descricao;
    lembrete.periodo = self.periodo;
    lembrete.data = self.data;
    lembrete.dataInicial = self.dataInicial;
    lembrete.imagem = self.imagem;
    
    [[ADModel sharedInstance] saveChanges];
    
    UILocalNotification *newNotification = [UILocalNotification defaultLocalNotificationWith:lembrete];
    [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
}

- (NSString *)textForCycleType:(NSInteger)cycleType {
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

- (NSInteger)numberOfRowsInPickerView {
   return sizeof(ADCycleType);
}

@end