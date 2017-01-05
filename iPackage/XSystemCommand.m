//
//  XSystemCommand.m
//  iOS App Signer
//
//  Created by jsb-xiakj on 2016/12/23.
//  Copyright © 2016年 Daniel Radtke. All rights reserved.
//

#import "XSystemCommand.h"

@implementation XSystemCommand
static XSystemCommand *sysCommand;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sysCommand = [[self alloc] init];

    });
    return sysCommand;
}

-(void)shCommand:(NSString *)cmd
            path:(NSString *)path
{
    NSArray *arguments = [NSArray arrayWithObjects: @"-c",cmd, nil];
    XSystemCommand *sysCmd = [XSystemCommand sharedInstance];
    SHCommand *shCmd = sysCmd->shCommand;
    shCmd = [[SHCommand alloc] init];
    [shCmd setDelegate:sysCommand];
    [shCmd setArgumentsArray:arguments];
    [shCmd setExecutablePath: path];
    if ([shCmd isExecuting])
    {
        [shCmd stopExecuting];
    }
    [shCmd execute];
}

- (void) commandDidFinish:(SHCommand *)command
             withExitCode:(int)iExitCode
{
 
}

- (void) outputData:(NSData *)data
  providedByCommand:(SHCommand *)command
{
    NSString* szOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[SystemLog sharedInstance] addLog:szOutput];
    NSLog(@"szOutput=%@",szOutput);
}

- (void) errorData:(NSData*)data
 providedByCommand:(SHCommand*)command;
{
    NSString* szOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [[SystemLog sharedInstance] addLog:szOutput];
    NSLog(@"errorData=%@",szOutput);
}


+(NSString *)launchPath:(NSString *)path
                    cmd:(NSString *)cmd
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: path];
    
    NSArray *arguments = [NSArray arrayWithObjects: @"-c",cmd, nil];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task launch];
    [task waitUntilExit];

    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData       *data = [file readDataToEndOfFile];
    NSString   *string = [[NSString alloc] initWithData: data
                                               encoding: NSUTF8StringEncoding];
    
    NSLog (@"Pipe:%@", string);
    return string;
}

+(void)rystemCommand:(NSString *)cmd
{
    [[XSystemCommand sharedInstance] shCommand:cmd
                                          path:@"/bin/sh"];
    
//    NSString *cmdString = [XSystemCommand launchPath:@"/bin/sh"
//                                                 cmd:cmd];
//    [[SystemLog sharedInstance] addLog:cmdString];
}

+(void)podCommand:(NSString *)cmd
{
    [[XSystemCommand sharedInstance] shCommand:cmd
                                          path:@"/usr/local/bin/pod"];
    
//    NSString *cmdString =[XSystemCommand launchPath:@"/usr/local/bin/pod"
//                                                cmd:cmd];
//    [[SystemLog sharedInstance] addLog:cmdString];
}

+(NSString *)recursiveSearch:(NSString *)filePath
                    fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *haveFile = nil;
    BOOL isDictionary  = NO;
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:filePath
                                                          error:nil];
    for(int i=0 ; i < [fileArray count] ; i++)
    {
        NSString *fName = [fileArray objectAtIndex:i];
        NSString *fileString = [NSString stringWithFormat:@"%@/%@",filePath,fName];
        [fileManager fileExistsAtPath:fileString
                          isDirectory:&isDictionary];
        if (isDictionary) {
            NSString *dicPath = [XSystemCommand recursiveSearch:fileString
                                                       fileName:fileName];
            if (dicPath!=nil) {
                haveFile = [fileString copy];
            }
            if (fName!=nil&&[fName hasSuffix:fileName]) {
                haveFile = [fileString copy];
                NSLog(@"fName=%@,%@",fName,fileString);
                break;
            }
        }
    }
    //NSLog(@"filePath=%@,%@",filePath,haveFile);
    return haveFile==nil?@"":haveFile;
}


-(int )contentDataPath:(NSString *)dataPath
{
    NSData *data = [[NSData alloc]initWithContentsOfFile:dataPath];

    int char1 = 0 ,char2 =0 ; //必须这样初始化
    
    [data getBytes:&char1 range:NSMakeRange(0, 1)];
    
    [data getBytes:&char2 range:NSMakeRange(1, 1)];
    
    NSLog(@"data=======%d%d,%lu",char1,char2,(unsigned long)[data length]);
    
    return  [[NSString stringWithFormat:@"%i%i",char1,char2] intValue];
}

@end
