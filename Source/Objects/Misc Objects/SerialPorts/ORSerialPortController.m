//--------------------------------------------------------
// ORSerialPortController
// Created by Mark  A. Howe on Wed 4/15/2009
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
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

#pragma mark •••Imported Files

#import "ORSerialPortController.h"
#import "ORSerialPortList.h"
#import "ORSerialPort.h"
#import "ORSerialPortModel.h"

@interface ORSerialPortController (private)
- (void) populatePortListPopup;
@end

@implementation ORSerialPortController

#pragma mark •••Initialization
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [topLevelObjects release];

	[super dealloc];
}

- (void) awakeFromNib
{		
	if(!portControlsContent){
#if defined(MAC_OS_X_VERSION_10_8) && MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_8
        if ([NSBundle loadNibNamed:@"SerialPortControls" owner:self]){
#else
        if ([[NSBundle mainBundle] loadNibNamed:@"SerialPortControls" owner:self topLevelObjects:&topLevelObjects]){
#endif
            [topLevelObjects retain];
			[portControlsView setContentView:portControlsContent];
		}	
		else NSLog(@"Failed to load SerialPortControls.nib");
	}
    else {
		[self populatePortListPopup];	
	}
}

#pragma mark •••Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [notifyCenter addObserver : self
                     selector : @selector(portNameChanged:)
                         name : ORSerialPortModelPortNameChanged
                        object: nil];

    [notifyCenter addObserver : self
                     selector : @selector(portStateChanged:)
                         name : ORSerialPortStateChanged
                       object : nil];
                                              
	[self updateWindow];
}



- (void) updateWindow
{
    [self portNameChanged:nil];
    [self portStateChanged:nil];
}

- (void) updateButtons:(BOOL)locked
{
	BOOL portOpen = [[[owner model] serialPort] isOpen];
    [portListPopup setEnabled:!locked && !portOpen];
    [openPortButton setEnabled:!locked];
}

- (void) portStateChanged:(NSNotification*)aNotification
{
    if(aNotification == nil || [aNotification object] == [[owner model] serialPort]){
        if([[owner model] serialPort]){
            [openPortButton setEnabled:YES];
			
            if([[[owner model] serialPort] isOpen]){
                [openPortButton setTitle:@"Close"];
                [portStateField setTextColor:[NSColor colorWithCalibratedRed:0.0 green:.8 blue:0.0 alpha:1.0]];
                [portStateField setStringValue:@"Open"];
            }
            else {
                [openPortButton setTitle:@"Open"];
                [portStateField setStringValue:@"Closed"];
                [portStateField setTextColor:[NSColor redColor]];
            }
        }
        else {
            [openPortButton setEnabled:NO];
            [portStateField setTextColor:[NSColor blackColor]];
            [portStateField setStringValue:@"---"];
            [openPortButton setTitle:@"---"];
        }
		
		[self updateButtons:[owner portLocked]];
    }
}

- (void) portNameChanged:(NSNotification*)aNote
{
	if(aNote == nil || [aNote object] == [owner model]){
		NSString* portName = [[owner model] portName];
		
		NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
		ORSerialPort *aPort;

		[portListPopup selectItemAtIndex:0]; //the default
		while (aPort = [enumerator nextObject]) {
			if([portName isEqualToString:[aPort name]]){
				[portListPopup selectItemWithTitle:portName];
				break;
			}
		}  
		[self portStateChanged:nil];
	}
}

- (BOOL) portLocked
{
	//subclasses should override to reflect the locked state of the port controls
	return NO;
}

- (void) updateButtons;
{
	BOOL portOpen = [[[owner model] serialPort] isOpen];
	BOOL locked = [self portLocked];
    [portListPopup setEnabled:!locked && !portOpen];
    [openPortButton setEnabled:!locked];
}

#pragma mark •••Actions
- (IBAction) portListAction:(id) sender
{
    [[owner model] setPortName: [portListPopup titleOfSelectedItem]];
}

- (IBAction) openPortAction:(id)sender
{
    [[owner model] openPort:![[[owner model] serialPort] isOpen]];
}

@end

@implementation ORSerialPortController (private)
- (void) populatePortListPopup
{
	NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
	ORSerialPort *aPort;
    [portListPopup removeAllItems];
    [portListPopup addItemWithTitle:@"--"];

	while (aPort = [enumerator nextObject]) {
        [portListPopup addItemWithTitle:[aPort name]];
	}    
}
@end

