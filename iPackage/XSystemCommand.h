//
//  XSystemCommand.h
//  iOS App Signer
//
//  Created by jsb-xiakj on 2016/12/23.
//  Copyright © 2016年 Daniel Radtke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHCommand.h"
#import "SystemLog.h"
@interface XSystemCommand : NSObject<SHCommandDelegate>
{
    SHCommand *shCommand;
}
+(void)rystemCommand:(NSString *)cmd;
+(void)podCommand:(NSString *)cmd;
-(int )contentDataPath:(NSString *)dataPath;
+(NSString *)recursiveSearch:(NSString *)filePath
                    fileName:(NSString *)fileName;
-(void)shCommand:(NSString *)cmd
            path:(NSString *)path;
@end
