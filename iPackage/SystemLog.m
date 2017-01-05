//
//  SystemLog.m
//  iPackage
//
//  Created by jsb-xiakj on 2016/12/30.
//  Copyright © 2016年 kjx. All rights reserved.
//

#import "SystemLog.h"

@implementation SystemLog
static SystemLog *_instance;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance->logMString=[[NSMutableString alloc] init];
    });
    return _instance;
}

- (void)addLog:(NSString *)log
{
    //[_instance->logMString appendFormat:@"%@",log];
    _instance->logMString=[log copy];
    if (_logBlock) {
        _logBlock(_instance->logMString);
    }
}

@end
