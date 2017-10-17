//--------------------------------------------------------
// ORHVcRIOController
// Created by Mark  A. Howe on Oct 17, 2017
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2017, University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//North Carolina sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORHVcRIOController.h"
#import "ORHVcRIOModel.h"
#import "ORValueBarGroupView.h"
#import "ORAxis.h"

@implementation ORHVcRIOController

#pragma mark ***Initialization
- (id) init
{
	self = [super initWithWindowNibName:@"HVcRIO"];
	return self;
}

- (void) awakeFromNib
{
    [[queueValueBar xAxis] setRngLimitsLow:0 withHigh:300 withMinRng:10];
    [[queueValueBar xAxis] setRngDefaultsLow:0 withHigh:300];
    
	[super awakeFromNib];
}

#pragma mark ***Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
		
    [notifyCenter addObserver : self
                     selector : @selector(ipAddressChanged:)
                         name : ORHVcRIOModelIpAddressChanged
						object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(isConnectedChanged:)
                         name : ORHVcRIOModelIsConnectedChanged
						object: model];
	   

    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORHVcRIOLock
                        object: nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(setPointChanged:)
                         name : ORHVcRIOModelSetPointChanged
                        object: model];
 
    [notifyCenter addObserver : self
                     selector : @selector(setPointFileChanged:)
                         name : ORHVcRIOModelSetPointFileChanged
                        object: model];

    [notifyCenter addObserver : self
                     selector : @selector(measuredValuesChanged:)
                         name : ORHVcRIOModelMeasuredValuesChanged
                        object: model];

    [notifyCenter addObserver : self
                     selector : @selector(setPointsReadBackChanged:)
                         name : ORHVcRIOModelReadBackChanged
						object: model];
    
    [notifyCenter addObserver : self
					 selector : @selector(queCountChanged:)
						 name : ORHVcRIOModelQueCountChanged
					   object : model];	

}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"HV-cRIO Control (Unit %lu)",[model uniqueIdNumber]]];
}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];
    [self setPointChanged:nil];
    [self setPointFileChanged:nil];
    
    [self measuredValuesChanged:nil];
	[self setPointsReadBackChanged:nil];
	[self queCountChanged:nil];
    
	[self ipAddressChanged:nil];
	[self isConnectedChanged:nil];
}

- (void) isConnectedChanged:(NSNotification*)aNote
{
	[ipConnectedTextField setStringValue: [model isConnected]?@"Connected":@"Not Connected"];
    [ipConnectButton setTitle:[model isConnected]?@"Disconnect":@"Connect"];
}

- (void) ipAddressChanged:(NSNotification*)aNote
{
	[ipAddressTextField setStringValue: [model ipAddress]];
	[[self window] setTitle:[model title]];
}

- (void) queCountChanged:(NSNotification*)aNotification
{
	[cmdQueCountField setIntValue:[model queCount]];
    [queueValueBar setNeedsDisplay:YES];
}

- (void) setPointChanged:(NSNotification*)aNote
{
	[setPointTableView reloadData];
}

- (void) setPointFileChanged:(NSNotification*)aNote
{
    [setPointFileField setStringValue:[model setPointFile]];
}

- (void) measuredValuesChanged:(NSNotification*)aNote
{
    [measuredValueTableView reloadData];
    
    [expertPCControlOnlyField setStringValue:[model expertPCControlOnly] ? @"Ony Expert PC Can Set Values":@""];
    [zeusHasControlField setStringValue:     [model zeusHasControl]      ? @"ZEUS has control":@""];
    [orcaHasControlField setStringValue:     [model orcaHasControl]      ? @"ORCA has control":@""];
}

- (void) setPointsReadBackChanged:(NSNotification*)aNote
{
	[setPointTableView reloadData];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORHVcRIOLock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{
    BOOL locked = [gSecurity isLocked:ORHVcRIOLock];
    [lockButton setState: locked];
    [readSetPointFileButton setEnabled:!locked];
    [writeAllSetPointsButton setEnabled:!locked];
    [setPointTableView setEnabled:!locked];
}

#pragma mark ***Actions
- (IBAction) writeSetpointsAction:(id)sender
{
    [model writeSetpoints];
    [self lockChanged:nil];
}

- (IBAction) readBackSetpointsAction:(id)sender
{
    [model readBackSetpoints];
    [self lockChanged:nil];
}

- (IBAction) readMeasuredValuesAction:(id)sender
{
    [model readMeasuredValues];
    [self lockChanged:nil];
}

- (IBAction) lockAction:(id) sender
{
    [gSecurity tryToSetLock:ORHVcRIOLock to:[sender intValue] forWindow:[self window]];
}

- (void) ipAddressFieldAction:(id)sender
{
	[model setIpAddress:[sender stringValue]];
}

- (IBAction) connectAction: (id) aSender
{
    [self endEditing];
    [model connect];
}

#pragma mark ***Table Data Source
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex
{
    if(setPointTableView == aTableView){
        if([[aTableColumn identifier] isEqualToString:@"index"]){
            return  [NSNumber numberWithInt:rowIndex];
        }
        else return [model setPointItem:rowIndex forKey:[aTableColumn identifier]];
    }
    else if(measuredValueTableView == aTableView){

        if([[aTableColumn identifier] isEqualToString:@"index"]){
            return  [NSNumber numberWithInt:rowIndex];
        }
        else return [model measuredValueItem:rowIndex forKey:[aTableColumn identifier]];
    }

    else return nil;
}

// just returns the number of items we have.
- (int) numberOfRowsInTableView:(NSTableView *)aTableView
{
	if(setPointTableView == aTableView)return [model numSetPoints];
	else if(measuredValueTableView == aTableView)return [model numMeasuredValues];
	else return 0;
}

- (void) tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if(anObject == nil)return;
    
    if(setPointTableView == aTableView){
        if([[aTableColumn identifier] isEqualToString:@"item"]) return;
        if([[aTableColumn identifier] isEqualToString:@"data"]) return;
        if([[aTableColumn identifier] isEqualToString:@"readback"]) return;
        if([[aTableColumn identifier] isEqualToString:@"setPoint"]){
            [model setSetPoint:rowIndex  withValue:[anObject floatValue]];
            return;
        }
    }
}


- (IBAction) readSetPointFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    NSString* startingDir;
	NSString* fullPath = [[model setPointFile] stringByExpandingTildeInPath];
    if(fullPath){
        startingDir = [fullPath stringByDeletingLastPathComponent];
    }
    else {
        startingDir = NSHomeDirectory();
    }
    
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:startingDir]];
    [openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton){
            [model readSetPointsFile:[[openPanel URL] path]];
        }
    }];
}

- (IBAction) flushQueueAction: (id) aSender
{
    [model flushQueue];
}

- (IBAction) saveSetPointFile:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setPrompt:@"Save As"];
    [savePanel setCanCreateDirectories:YES];
    
    NSString* startingDir;
    NSString* defaultFile;
    
	NSString* fullPath = [[model setPointFile] stringByExpandingTildeInPath];
    if(fullPath){
        startingDir = [fullPath stringByDeletingLastPathComponent];
        defaultFile = [fullPath lastPathComponent];
    }
    else {
        startingDir = NSHomeDirectory();
        defaultFile = [model setPointFile];
        
    }
    [savePanel setDirectoryURL:[NSURL fileURLWithPath:startingDir]];
    [savePanel setNameFieldLabel:defaultFile];
    [savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton){
            [model saveSetPointsFile:[[savePanel URL]path]];
        }
    }];
}

#pragma  mark ***Delegate Responsiblities
- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
	return YES;
}
@end
