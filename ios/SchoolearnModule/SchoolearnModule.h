//
//  RNNetworkingManager.h
//  RNNetworking
//
//  Created by Admin on 2.02.2018.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
#import <UIKit/UIKit.h>

@class ISEParams;

@protocol ISESettingDelegate <NSObject>

- (void)onParamsChanged:(ISEParams *)params;

@end

@interface SchoolearnModule : NSObject <RCTBridgeModule>

@property (nonatomic, strong) ISEParams *iseParams;

@property NSString *selfVoiceDir;

@end
