//
//  SchoolearnModule.m
//  SchoolearnModule
//
//  Created by lixl on 24.06.2017.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SchoolearnModule.h"
#import <React/RCTEventDispatcher.h>
#import <AVFoundation/AVFoundation.h>

#import <objc/runtime.h>

#import "SchoolearnDialog.h"

#pragma mark - const values

#pragma mark -

@interface SchoolearnModule (){
    NSTimer *_timer; //定时器
    NSInteger countDown;  //倒计时
}

@property(nonatomic,strong)SchoolearnDialog *pick;


@end


@implementation SchoolearnModule

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

//测试用  弹出 对话框
RCT_EXPORT_METHOD(alert:(NSString *)message){
        //alert
    
    NSString *title = NSLocalizedString(@"", nil);
    NSString *message2 = NSLocalizedString(message, nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message2 preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    //[self presentViewController:alertController animated:YES completion:nil];
    [self.class presentViewController:alertController animated:YES completion:nil];
}

@end
