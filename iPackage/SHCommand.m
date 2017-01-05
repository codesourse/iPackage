//
//  SHCommand.m
//  SHCommandExample
//
//  Created by Stuart Howieson on 30/12/2014.
//  Copyright (c) 2014 Stuart Howieson. All rights reserved.
//

#import "SHCommand.h"

@implementation SHCommand

- (id) init
{
	self = [super init];
	
	if (self)
	{
		m_task = [[NSTask alloc] init];
		
		m_pipeIn = [[NSPipe alloc] init];
		m_pipeOut = [[NSPipe alloc] init];
		m_pipeError = [[NSPipe alloc] init];
		
		[m_task setStandardInput:m_pipeIn];
		[m_task setStandardOutput:m_pipeOut];
		[m_task setStandardError:m_pipeError];
		
		m_delegate = nil;
	}
	
	return self;
}

+ (SHCommand*) commandWithExecutablePath:(NSString*)szExecutablePath withArguments:(NSArray*)arrayArguments withDelegate:(id<SHCommandDelegate>)delegate
{
	SHCommand* command = [[SHCommand alloc] init];
	
	if (command)
	{
		[command setExecutablePath:szExecutablePath];
		[command setArgumentsArray:arrayArguments];
		[command setDelegate:delegate];
	}
	
	return command;
}

- (void) setExecutablePath:(NSString*)szExecutablePath
{
	[m_task setLaunchPath:szExecutablePath];
}

- (void) setArgumentsArray:(NSArray*)arrayArguments
{
	if (arrayArguments)
	{
		[m_task setArguments:arrayArguments];
	}
}

- (void) setDelegate:(id<SHCommandDelegate>)delegate
{
	m_delegate = delegate;
}

- (void) execute
{
	[[m_pipeOut fileHandleForReading] waitForDataInBackgroundAndNotify];
	[[m_pipeError fileHandleForReading] waitForDataInBackgroundAndNotify];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[m_pipeOut fileHandleForReading] queue:nil usingBlock:^(NSNotification* note)
	{
		NSData* data = [[m_pipeOut fileHandleForReading] availableData];
		if ([data length] > 0)
		{
			if (m_delegate)
			{
				if ([m_delegate respondsToSelector:@selector(outputData:providedByCommand:)])
				{
					[m_delegate outputData:data providedByCommand:self];
				}
			}
			
			[[m_pipeOut fileHandleForReading] waitForDataInBackgroundAndNotify];
		}
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[m_pipeError fileHandleForReading] queue:nil usingBlock:^(NSNotification* note)
	{
		NSData* data = [[m_pipeError fileHandleForReading] availableData];
		if ([data length] > 0)
		{
			if (m_delegate)
			{
				if ([m_delegate respondsToSelector:@selector(errorData:providedByCommand:)])
				{
					[m_delegate errorData:data providedByCommand:self];
				}
			}
			
			[[m_pipeError fileHandleForReading] waitForDataInBackgroundAndNotify];
		}
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NSTaskDidTerminateNotification object:m_task queue:nil usingBlock:^(NSNotification *note)
	{
		if (m_delegate)
		{
			if ([m_delegate respondsToSelector:@selector(commandDidFinish:withExitCode:)])
			{
				[m_delegate commandDidFinish:self withExitCode:[m_task terminationStatus]];
			}
		}
	}];

	[m_task launch];
    [m_task waitUntilExit];
}

- (BOOL) isExecuting
{
	return [m_task isRunning];
}

- (void) stopExecuting
{
	if ([m_task isRunning])
	{
		[m_task terminate];
	}
}

- (void) provideInputData:(NSData*)data
{
	[[m_pipeIn fileHandleForWriting] writeData:data];
}

@end
