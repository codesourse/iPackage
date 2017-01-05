//
//  ViewController.h
//  iPackage
//
//  Created by jsb-xiakj on 2016/12/28.
//  Copyright © 2016年 kjx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SHCommand.h"
@interface MainViewController : NSViewController
{
    NSString *workPath;
}
@property(nonatomic,weak)IBOutlet NSButton    *downloadBtn;
@property(nonatomic,weak)IBOutlet NSButton    *selectBtn;
@property(nonatomic,weak)IBOutlet NSButton    *podBtn;
@property(nonatomic,weak)IBOutlet NSButton    *packageBtn;
@property(nonatomic,weak)IBOutlet NSButton    *trashBtn;
@property(nonatomic,weak)IBOutlet NSButton    *pod1Btn;
@property(nonatomic,weak)IBOutlet NSButton    *pack1Btn;
@property(nonatomic,weak)IBOutlet NSBox       *box;

@property(nonatomic,weak)IBOutlet NSTextField *downloadText;
@property(nonatomic,weak)IBOutlet NSTextField *selectText;
@property(nonatomic,weak)IBOutlet NSTextField *userNameText;
@property(nonatomic,weak)IBOutlet NSTextField *pswText;
@property(nonatomic,assign)IBOutlet NSTextView  *logTextView;
@property(nonatomic,weak)IBOutlet NSProgressIndicator *processIndicator;
- (IBAction)selectFile:(id)sender;
- (IBAction)beginDownload:(id)sender;
- (IBAction)podInstall:(id)sender;
- (IBAction)packageIpa:(id)sender;
@end

