//
//  HaloController.m
//  Orca
//
//  Created by Mark Howe on Tue Jun 28 2005.
//  Copyright (c) 2002 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------


#pragma mark ���Imported Files
#import "HaloController.h"
#import "HaloModel.h"
#import "ORDetectorSegment.h"
#import "ORSegmentGroup.h"
#import "HaloSentry.h"

@implementation HaloController
#pragma mark ���Initialization
-(id)init
{
    self = [super initWithWindowNibName:@"Halo"];
    return self;
}

- (NSString*) defaultPrimaryMapFilePath
{
	return @"~/Halo";
}


-(void) awakeFromNib
{
	
	detectorSize		= NSMakeSize(620,595);
	detailsSize			= NSMakeSize(450,589);
	focalPlaneSize		= NSMakeSize(700,589);
	sentrySize          = NSMakeSize(700,589);
	
    blankView = [[NSView alloc] init];
    [self tabView:tabView didSelectTabViewItem:[tabView selectedTabViewItem]];

    [super awakeFromNib];
}


#pragma mark ���Notifications
- (void) registerNotificationObservers
{
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    
    [super registerNotificationObservers];

    [notifyCenter addObserver : self
                     selector : @selector(viewTypeChanged:)
                         name : HaloModelViewTypeChanged
						object: model];
    
    [notifyCenter addObserver : self
                     selector : @selector(registerNotificationObservers)
                         name : HaloModelHaloSentryChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ipNumberChanged:)
                         name : HaloSentryIpNumber1Changed
						object: [model haloSentry]];
    
    [notifyCenter addObserver : self
                     selector : @selector(ipNumberChanged:)
                         name : HaloSentryIpNumber2Changed
						object: [model haloSentry]];
 
    [notifyCenter addObserver : self
                     selector : @selector(sentryTypeChanged:)
                         name : HaloSentryTypeChanged
						object: [model haloSentry]];
    
    [notifyCenter addObserver : self
                     selector : @selector(stateChanged:)
                         name : HaloSentryStateChanged
						object: [model haloSentry]];

    [notifyCenter addObserver : self
                     selector : @selector(remoteStateChanged:)
                         name : HaloSentryRemoteStateChanged
						object: [model haloSentry]];

    [notifyCenter addObserver : self
                     selector : @selector(disabledChanged:)
                         name : HaloSentryDisabledChanged
						object: [model haloSentry]];
}

- (void) updateWindow
{
    [super updateWindow];
	[self viewTypeChanged:nil];
	[self stateChanged:nil];
	[self sentryTypeChanged:nil];
	[self ipNumberChanged:nil];
	[self remoteStateChanged:nil];
	[self disabledChanged:nil];
}

- (void) remoteStateChanged:(NSNotification*)aNote
{
    BOOL remoteMachine  = [[model haloSentry] remoteMachineRunning];
    BOOL remoteOrca     = [[model haloSentry] remoteORCARunning];
    BOOL remoteRun      = [[model haloSentry] remoteRunInProgress];
    if([[model haloSentry]state] != eIdle){
        [remoteMachineRunningField  setStringValue:remoteMachine ? @"Reachable":@"Unreachable"];
        [remoteOrcaRunningField     setStringValue:remoteMachine ? (remoteOrca ? @"Running":@"NOT Running"):@"?"];
        [remoteRunInProgressField   setStringValue:remoteMachine ? (remoteRun  ? @"YES":@"NO"):@"?"];
    }
    else {
        [remoteMachineRunningField  setStringValue:@"?"];
        [remoteOrcaRunningField     setStringValue:@"?"];
        [remoteRunInProgressField   setStringValue:@"?"];        
    }
}

- (void) sentryTypeChanged:(NSNotification*)aNote
{
    [sentryTypeField setStringValue:[[model haloSentry] sentryTypeName]];
}

- (void) stateChanged:(NSNotification*)aNote
{
    [stateField setStringValue:[[model haloSentry] stateName]];
}

- (void) ipNumberChanged:(NSNotification*)aNote
{
    [ip1Field setStringValue:[[model haloSentry] ipNumber1]];
    [ip2Field setStringValue:[[model haloSentry] ipNumber2]];
}

- (void) viewTypeChanged:(NSNotification*)aNote
{
	[viewTypePU selectItemAtIndex:[model viewType]];
	[detectorView setViewType:[model viewType]];
	[detectorView makeAllSegments];	
}

#pragma mark ���Interface Management

- (void) disabledChanged:(NSNotification*)aNote
{
	[disabledCB setIntValue: [[model haloSentry]  disabled]];
}

- (void) specialUpdate:(NSNotification*)aNote
{
	[super specialUpdate:aNote];
	[detectorView makeAllSegments];
}

- (void) setDetectorTitle
{	
	switch([model displayType]){
		case kDisplayRates:			[detectorTitle setStringValue:@"Detector Rate"];	break;
		case kDisplayThresholds:	[detectorTitle setStringValue:@"Thresholds"];		break;
		case kDisplayGains:			[detectorTitle setStringValue:@"Gains"];			break;
		case kDisplayTotalCounts:	[detectorTitle setStringValue:@"Total Counts"];		break;
		default: break;
	}
}

#pragma mark ���Actions
- (IBAction) disabledAction:(id)sender
{
	[[model haloSentry] setDisabled:[sender intValue]];
}

- (IBAction) viewTypeAction:(id)sender
{
	[model setViewType:[sender indexOfSelectedItem]];
}

- (IBAction) ip1Action:(id)sender
{
	[[model haloSentry] setIpNumber1:[sender stringValue]];
}
- (IBAction) ip2Action:(id)sender
{
	[[model haloSentry] setIpNumber2:[sender stringValue]];
}

- (IBAction) toggleSystems:(id)sender
{
    [[model haloSentry] toggleSystems];
}

#pragma mark ���Details Interface Management
- (void) detailsLockChanged:(NSNotification*)aNotification
{
	[super detailsLockChanged:aNotification];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:[model experimentDetailsLock]];
    BOOL locked = [gSecurity isLocked:[model experimentDetailsLock]];

	[detailsLockButton setState: locked];
    [initButton setEnabled: !lockedOrRunningMaintenance];

}

#pragma mark ���Table Data Source
- (void) tabView:(NSTabView*)aTabView didSelectTabViewItem:(NSTabViewItem*)tabViewItem
{
    if([tabView indexOfTabViewItem:tabViewItem] == 0){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:detectorSize];
		[[self window] setContentView:tabView];
    }
    else if([tabView indexOfTabViewItem:tabViewItem] == 1){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:detailsSize];
		[[self window] setContentView:tabView];
    }
    else if([tabView indexOfTabViewItem:tabViewItem] == 2){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:focalPlaneSize];
		[[self window] setContentView:tabView];
    }
    else if([tabView indexOfTabViewItem:tabViewItem] == 3){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:sentrySize];
		[[self window] setContentView:tabView];
    }

	int index = [tabView indexOfTabViewItem:tabViewItem];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"orca.HaloController.selectedtab"];
}

@end
