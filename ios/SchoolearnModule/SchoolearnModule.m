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
#import <AVFoundation/AVCaptureDevice.h>
#import <CoreLocation/CLLocationManager.h>  //定位库
#import <Photos/PHPhotoLibrary.h>

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

RCT_EXPORT_METHOD(checkPermissionCamera: (RCTResponseSenderBlock)callback){
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        //无权限
        [output setValue:@(FALSE) forKey:@"is_success"];
    }else {
        [output setValue:@(TRUE) forKey:@"is_success"];
    }
    callback(@[output]);
}

RCT_EXPORT_METHOD(checkPermissionAlbum: (RCTResponseSenderBlock)callback){
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
    {
        //无权限
        [output setValue:@(FALSE) forKey:@"is_success"];
    }else {
        [output setValue:@(TRUE) forKey:@"is_success"];
    }
    callback(@[output]);
}

RCT_EXPORT_METHOD(checkPermissionMic: (RCTResponseSenderBlock)callback){
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        //无权限
        [output setValue:@(FALSE) forKey:@"is_success"];
    }else {
        [output setValue:@(TRUE) forKey:@"is_success"];
    }
    callback(@[output]);
}

//判断手机是否开启定位权限
RCT_EXPORT_METHOD(checkPermissionGeolocation: (RCTResponseSenderBlock)callback){
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    /*
     [CLLocationManager authorizationStatus]
     授权状态为枚举值：
    kCLAuthorizationStatusNotDetermined                  //用户尚未对该应用程序作出选择
    kCLAuthorizationStatusRestricted                     //应用程序的定位权限被限制
    kCLAuthorizationStatusAuthorizedAlways               //一直允许获取定位
    kCLAuthorizationStatusAuthorizedWhenInUse            //在使用时允许获取定位
    kCLAuthorizationStatusAuthorized                     //已废弃，相当于一直允许获取定位
    kCLAuthorizationStatusDenied                         //拒绝获取定位
    */
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        //定位功能可用
        [output setValue:@(TRUE) forKey:@"is_success"];
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        //定位不能用
        [output setValue:@(FALSE) forKey:@"is_success"];
    }
    callback(@[output]);
}


RCT_EXPORT_METHOD(openSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (@(UIApplicationOpenSettingsURLString != nil)) {
        
        NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
        id __block token = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                               object:nil
                                                queue:nil
                                           usingBlock:^(NSNotification *note) {
                                               [center removeObserver:token];
                                               resolve(@YES);
                                           }];
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

RCT_EXPORT_METHOD(getUuid: (RCTResponseSenderBlock)callback){
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"%@",deviceUUID);
    
    NSMutableDictionary *output = [[NSMutableDictionary alloc] init];
    [output setValue:deviceUUID forKey:@"uuid"];
    [output setValue:@"ios" forKey:@"system"];
    
    callback(@[output]);
}

@end
