//
//  SchoolearnModule.m
//  SchoolearnModule
//
//  Created by lixl on 24.06.2017.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "SchoolearnModule.h"
#import <React/RCTEventDispatcher.h>

#import <objc/runtime.h>

#import "Definition.h"

#import "SchoolearnDialog.h"

#pragma mark - const values

NSString* const KCIseHideBtnTitle=@"隐藏";

NSString* const KCTextCNSyllable=@"text_cn_syllable";
NSString* const KCTextCNWord=@"text_cn_word";
NSString* const KCTextCNSentence=@"text_cn_sentence";
NSString* const KCTextENWord=@"text_en_word";
NSString* const KCTextENSentence=@"text_en_sentence";

NSString* const KCResultNotify1=@"请点击“开始评测”按钮";
NSString* const KCResultNotify2=@"请朗读以上内容";
NSString* const KCResultNotify3=@"停止评测，结果等待中...";


#pragma mark -

@interface SchoolearnModule () <>

@property(nonatomic,strong)SchoolearnDialog *pick;
@property(nonatomic,assign)float height;
@property(nonatomic,weak)UIWindow * window;

@property (nonatomic, strong) NSString* resultText;

@property (nonatomic, strong) PopupView *popupView;

@property (nonatomic, assign) BOOL isSessionResultAppear;
@property (nonatomic, assign) BOOL isSessionEnd;

@property (nonatomic, assign) BOOL isValidInput;
@property (nonatomic, assign) BOOL isDidset;

@property (nonatomic,assign) BOOL isBeginOfSpeech;//是否已经返回BeginOfSpeech回调


@end


@implementation SchoolearnModule

@synthesize bridge = _bridge;

//NSString *resultView = nil;
//NSString *resultText = nil;

NSString *selfVoice = nil;

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





#pragma mark - keyboard

+ (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    
    //id classObject = objc_getClass([@"ISEResult" UTF8String]);
    NSString* objClassName = NSStringFromClass([obj class]);
    id classObject = objc_getClass([objClassName UTF8String]);
    
    //objc_property_t *props = class_copyPropertyList([obj class], &propsCount);//获得属性列表 由 @property 修饰的变量
    objc_property_t *props = class_copyPropertyList(classObject, &propsCount);
    //Ivar *props = class_copyIvarList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称
        id value = [obj valueForKey:propName];//kvc读值
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];//自定义处理数组，字典，其他类
        }
        [dic setObject:value forKey:propName];
    }
    free(props);
    return dic;
}

+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

@end
