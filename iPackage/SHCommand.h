//
//  SHCommand.h
//  SHCommandExample
//
//  Created by Stuart Howieson on 30/12/2014.
//  Copyright (c) 2014 Stuart Howieson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHCommandDelegate;

@interface SHCommand : NSObject
{
	NSTask*			m_task;
	
	NSPipe*			m_pipeIn;
	NSPipe*			m_pipeOut;
	NSPipe*			m_pipeError;
	
	id<SHCommandDelegate>	m_delegate;
}

+ (SHCommand*) commandWithExecutablePath:(NSString*)szExecutablePath withArguments:(NSArray*)arrayArguments withDelegate:(id<SHCommandDelegate>)delegate;

- (void) setExecutablePath:(NSString*)szExecutablePath;
- (void) setArgumentsArray:(NSArray*)arrayArguments;
- (void) setDelegate:(id<SHCommandDelegate>)delegate;

- (void) execute;
- (BOOL) isExecuting;
- (void) stopExecuting;

- (void) provideInputData:(NSData*)data;

@end

@protocol SHCommandDelegate <NSObject>

- (void) commandDidFinish:(SHCommand*)command withExitCode:(int)iExitCode;

- (void) outputData:(NSData*)data providedByCommand:(SHCommand*)command;
- (void) errorData:(NSData*)data providedByCommand:(SHCommand*)command;

@end
