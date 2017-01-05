//
//  ViewController.m
//  iPackage
//
//  Created by jsb-xiakj on 2016/12/28.
//  Copyright © 2016年 kjx. All rights reserved.
//

#import "MainViewController.h"
#import "XSystemCommand.h"
@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _podBtn.bezelColor=[NSColor yellowColor];
    
 
    _logTextView.editable=NO;
    _processIndicator.style=NSProgressIndicatorSpinningStyle;
    _processIndicator.hidden=YES;
    [_processIndicator setControlTint:NSGraphiteControlTint];
    [_processIndicator setUsesThreadedAnimation:YES];
    [_processIndicator setIndeterminate:YES];
    _box.hidden=YES;
    workPath=nil;
    [SystemLog sharedInstance].logBlock=^(NSString *log){
        NSString *logString=[log copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            _logTextView.string=logString;
        });
    };
}

-(void)enableAllNO
{
    _downloadText.enabled=NO;
    _userNameText.enabled=NO;
    _pswText.enabled=NO;
    _selectText.enabled=NO;
    _downloadBtn.enabled=NO;
    _podBtn.enabled=NO;
    _selectBtn.enabled=NO;
    _packageBtn.enabled=NO;
    _trashBtn.enabled=NO;
    _pod1Btn.enabled=NO;
    _pack1Btn.enabled=NO;
    _box.hidden=NO;
    
}

-(void)enableAllYES
{
    _downloadText.enabled=YES;
    _userNameText.enabled=YES;
    _pswText.enabled=YES;
    _selectText.enabled=YES;
    _downloadBtn.enabled=YES;
    _podBtn.enabled=YES;
    _selectBtn.enabled=YES;
    _packageBtn.enabled=YES;
    _trashBtn.enabled=YES;
    _pod1Btn.enabled=YES;
    _pack1Btn.enabled=YES;
    _box.hidden=YES;
}

-(void)beginAnimate
{
    [_processIndicator startAnimation:nil];
    _processIndicator.hidden=NO;
    [self enableAllNO];
}

-(void)endAnimate
{
    [self enableAllYES];
    _processIndicator.hidden=YES;
    [_processIndicator stopAnimation:nil];
}

-(IBAction)beginDownload:(id)sender
{
    if (_selectText.stringValue.length==0) {
        [self selectFile:nil];
        return;
    }
    [self beginAnimate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *recomedString=[NSString stringWithFormat:@"cd %@ && svn checkout %@ --username %@ --password %@",_selectText.stringValue,_downloadText.stringValue,_userNameText.stringValue,_pswText.stringValue];
        [XSystemCommand rystemCommand:recomedString];
        NSLog(@"\n########################finish##########################\n");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endAnimate];
        });
    });
}

-(IBAction)podInstall:(id)sender
{
    if (_selectText.stringValue.length==0) {
        [self selectFile:nil];
        return;
    }
    [self beginAnimate];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *recString=[NSString stringWithFormat:@"export LC_ALL='en_US.UTF-8' && cd %@/%@ && /usr/local/bin/pod install",_selectText.stringValue,workPath];
        [XSystemCommand rystemCommand:recString];
        NSLog(@"\n########################finish##########################\n");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endAnimate];
        });
    });
}

-(IBAction)packageIpa:(id)sender
{
    if (_selectText.stringValue.length==0) {
        [self selectFile:nil];
        return;
    }
    [self beginAnimate];
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",_selectText.stringValue,workPath] error:nil];
    NSString *workSpace = nil;
    NSString *project   = nil;
    for(NSString *fileName in fileArray)
    {
        if ([fileName hasSuffix:@".xcworkspace"]) {
            workSpace=fileName;
        }
        if ([fileName hasSuffix:@".xcodeproj"]) {
            project = [fileName stringByReplacingOccurrencesOfString:@".xcodeproj"
                                                          withString:@""];
        }
    }
    if (workSpace==nil||project==nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endAnimate];
        });
        return;
    }
    NSLog(@"fileArray=%@",fileArray);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *pacString =[NSString stringWithFormat:@"cd %@/%@ && xcodebuild  -workspace  %@ -list && xcodebuild -workspace  %@ -scheme %@ -archivePath build/%@.xcarchive archive ",_selectText.stringValue,workPath,workSpace,workSpace,project,project];
        [XSystemCommand rystemCommand:pacString];
        
        NSString *pacString1 = [NSString stringWithFormat:@"cd %@/%@ && xcodebuild  -exportArchive -exportFormat IPA -archivePath build/%@.xcarchive -exportPath build/%@.ipa",_selectText.stringValue,workPath,project,project];
        [XSystemCommand rystemCommand:pacString1];

        [XSystemCommand rystemCommand:[NSString stringWithFormat:@"open %@/%@/build",_selectText.stringValue,workPath]];
        NSLog(@"\n########################finish##########################\n%@\n%@\n",pacString,pacString1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endAnimate];
        });
    });
}

- (IBAction)selectFile:(id)sender
{
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    openPanel.canChooseFiles = false;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = false;
    openPanel.allowsOtherFileTypes = false;
    //openPanel.allowedFileTypes = @[@""];
    long result = openPanel.runModal;
    if (result) {
        _selectText.stringValue=openPanel.URLs.firstObject.path;
        workPath=_downloadText.stringValue.lastPathComponent;
    }
    if (sender==nil) {
        [self beginDownload:nil];
    }
}

-(void)workPathGet
{
    NSString *recCommand   = [XSystemCommand recursiveSearch:_selectText.stringValue
                                                    fileName:@".xcodeproj"];
    NSString *pathCommand  = [recCommand stringByReplacingOccurrencesOfString:_selectText.stringValue
                                                                   withString:@""];
    
    NSLog(@"recCommand=\n%@\n%@\n%@\n%@\n",recCommand,pathCommand,pathCommand.stringByDeletingLastPathComponent,_selectText.stringValue);
    if (recCommand!=nil) {
        if ([pathCommand hasSuffix:@".xcodeproj"]) {
            workPath=[pathCommand.stringByDeletingLastPathComponent copy];
        }else{
            workPath=[pathCommand copy];
        }
        
    }
}

- (IBAction)trashFile:(id)sender
{
    NSString *pacString1 = [NSString stringWithFormat:@"cd %@ && rm -rf %@/",_selectText.stringValue,workPath];
    [XSystemCommand rystemCommand:pacString1];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
