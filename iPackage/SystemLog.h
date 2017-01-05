//
//  SystemLog.h
//  iPackage
//
//  Created by jsb-xiakj on 2016/12/30.
//  Copyright © 2016年 kjx. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^LogBlock ) (NSString *log);
@interface SystemLog : NSObject
{
    NSMutableString *logMString;
}
@property(nonatomic,strong)LogBlock logBlock;
+ (instancetype)sharedInstance;
- (void)addLog:(NSString *)log;
@end
