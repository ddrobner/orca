//--------------------------------------------------------
// ORRGA300Controller
// Created by Mark  A. Howe on Tues Jan 4, 2012
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2012 CENPA, University of Washington. All rights reserved.
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

#import "ORRGA300Controller.h"
#import "ORRGA300Model.h"
#import "ORTimeLinePlot.h"
#import "ORCompositePlotView.h"
#import "ORTimeAxis.h"
#import "ORSerialPort.h"
#import "ORTimeRate.h"
#import "OHexFormatter.h"
#import "ORSerialPortController.h"

@implementation ORRGA300Controller

#pragma mark •••Initialization

- (id) init
{
	self = [super initWithWindowNibName:@"RGA300"];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void) awakeFromNib
{	
    [[plotter yAxis] setRngLow:0.0 withHigh:1000.];
	[[plotter yAxis] setRngLimitsLow:0.0 withHigh:1000000000 withMinRng:10];
	[plotter setUseGradient:YES];
	
    [[plotter xAxis] setRngLow:0.0 withHigh:10000];
	[[plotter xAxis] setRngLimitsLow:0.0 withHigh:200000. withMinRng:200];

	ORTimeLinePlot* aPlot = [[ORTimeLinePlot alloc] initWithTag:0 andDataSource:self];
	[plotter addPlot: aPlot];
	[(ORTimeAxis*)[plotter xAxis] setStartTime: [[NSDate date] timeIntervalSince1970]];
	[aPlot release];
	
	[super awakeFromNib];	
	//[model getPressure];
}

#pragma mark •••Notifications

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [super registerNotificationObservers];
	
    [notifyCenter addObserver : self
                     selector : @selector(pollTimeChanged:)
                         name : ORRGA300ModelPollTimeChanged
                       object : nil];
	
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRunStatusChangedNotification
                       object : nil];
    
    [notifyCenter addObserver : self
                     selector : @selector(lockChanged:)
                         name : ORRGA300Lock
                        object: nil];

    [notifyCenter addObserver : self
					 selector : @selector(scaleAction:)
						 name : ORAxisRangeChangedNotification
					   object : nil];
	
    [notifyCenter addObserver : self
					 selector : @selector(miscAttributesChanged:)
						 name : ORMiscAttributesChanged
					   object : model];
	
    [notifyCenter addObserver : self
					 selector : @selector(updateTimePlot:)
						 name : ORRateAverageChangedNotification
					   object : nil];

    [notifyCenter addObserver : self
                     selector : @selector(modelNumberChanged:)
                         name : ORRGA300ModelModelNumberChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(firmwareVersionChanged:)
                         name : ORRGA300ModelFirmwareVersionChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(serialNumberChanged:)
                         name : ORRGA300ModelSerialNumberChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(statusWordChanged:)
                         name : ORRGA300ModelStatusWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(psErrWordChanged:)
                         name : ORRGA300ModelPsErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(detErrWordChanged:)
                         name : ORRGA300ModelDetErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(qmfErrWordChanged:)
                         name : ORRGA300ModelQmfErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(cemErrWordChanged:)
                         name : ORRGA300ModelCemErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(filErrWordChanged:)
                         name : ORRGA300ModelFilErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(rs232ErrWordChanged:)
                         name : ORRGA300ModelRs232ErrWordChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionizerDegassTimeChanged:)
                         name : ORRGA300ModelIonizerDegassTimeChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionizerElectronEnergyChanged:)
                         name : ORRGA300ModelIonizerElectronEnergyChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionizerEmissionCurrentChanged:)
                         name : ORRGA300ModelIonizerEmissionCurrentChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionizerIonEnergyChanged:)
                         name : ORRGA300ModelIonizerIonEnergyChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(ionizerFocusPlateVoltageChanged:)
                         name : ORRGA300ModelIonizerFocusPlateVoltageChanged
						object: model];
    [notifyCenter addObserver : self
                     selector : @selector(elecMultHVBiasChanged:)
                         name : ORRGA300ModelElecMultHVBiasChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(noiseFloorSettingChanged:)
                         name : ORRGA300ModelNoiseFloorSettingChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(analogScanPointsChanged:)
                         name : ORRGA300ModelAnalogScanPointsChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(histoScanPointsChanged:)
                         name : ORRGA300ModelHistoScanPointsChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(finalMassChanged:)
                         name : ORRGA300ModelFinalMassChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(initialMassChanged:)
                         name : ORRGA300ModelInitialMassChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(singleMassChanged:)
                         name : ORRGA300ModelSingleMassChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(stepsPerAmuChanged:)
                         name : ORRGA300ModelStepsPerAmuChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(numberAnalogScansChanged:)
                         name : ORRGA300ModelNumberAnalogScansChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(measuredIonCurrentChanged:)
                         name : ORRGA300ModelMeasuredIonCurrentChanged
						object: model];

    [notifyCenter addObserver : self
                     selector : @selector(electronMultiOptionChanged:)
                         name : ORRGA300ModelElectronMultiOptionChanged
						object: model];

}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"DCU (%d)",[model uniqueIdNumber]]];
}

- (void) updateWindow
{
    [super updateWindow];
    [self lockChanged:nil];

	[self updateTimePlot:nil];
    [self miscAttributesChanged:nil];
	[self pollTimeChanged:nil];

	[self modelNumberChanged:nil];
	[self firmwareVersionChanged:nil];
	[self serialNumberChanged:nil];
	[self statusWordChanged:nil];
	[self psErrWordChanged:nil];
	[self detErrWordChanged:nil];
	[self qmfErrWordChanged:nil];
	[self cemErrWordChanged:nil];
	[self filErrWordChanged:nil];
	[self rs232ErrWordChanged:nil];
	[self ionizerDegassTimeChanged:nil];
	[self ionizerElectronEnergyChanged:nil];
	[self ionizerEmissionCurrentChanged:nil];
	[self ionizerIonEnergyChanged:nil];
	[self ionizerFocusPlateVoltageChanged:nil];
	[self elecMultHVBiasChanged:nil];
	[self noiseFloorSettingChanged:nil];
	[self analogScanPointsChanged:nil];
	[self histoScanPointsChanged:nil];
	[self finalMassChanged:nil];
	[self initialMassChanged:nil];
	[self singleMassChanged:nil];
	[self stepsPerAmuChanged:nil];
	[self numberAnalogScansChanged:nil];
	[self measuredIonCurrentChanged:nil];
	[self electronMultiOptionChanged:nil];
}

- (void) electronMultiOptionChanged:(NSNotification*)aNote
{
	[electronMultiOptionTextField setObjectValue: [model electronMultiOption]];
	[self updateButtons];
}

- (void) measuredIonCurrentChanged:(NSNotification*)aNote
{
	[measuredIonCurrentField setIntValue: [model measuredIonCurrent]];
}

- (void) numberAnalogScansChanged:(NSNotification*)aNote
{
	[numberAnalogScansField setIntValue: [model numberAnalogScans]];
}

- (void) stepsPerAmuChanged:(NSNotification*)aNote
{
	[stepsPerAmuField setIntValue: [model stepsPerAmu]];
}

- (void) singleMassChanged:(NSNotification*)aNote
{
	[singleMassField setIntValue: [model singleMass]];
}

- (void) initialMassChanged:(NSNotification*)aNote
{
	[initialMassField setIntValue: [model initialMass]];
}

- (void) finalMassChanged:(NSNotification*)aNote
{
	[finalMassField setIntValue: [model finalMass]];
}

- (void) histoScanPointsChanged:(NSNotification*)aNote
{
	[histoScanPointsField setIntValue: [model histoScanPoints]];
}

- (void) analogScanPointsChanged:(NSNotification*)aNote
{
	[analogScanPointsField setIntValue: [model analogScanPoints]];
}

- (void) noiseFloorSettingChanged:(NSNotification*)aNote
{
	[noiseFloorSettingField setIntValue: [model noiseFloorSetting]];
}

- (void) elecMultHVBiasChanged:(NSNotification*)aNote
{
	[elecMultHVBiasField setIntValue: [model elecMultHVBias]];
}

- (void) ionizerFocusPlateVoltageChanged:(NSNotification*)aNote
{
	[ionizerFocusPlateVoltageField setIntValue: [model ionizerFocusPlateVoltage]];
}

- (void) ionizerIonEnergyChanged:(NSNotification*)aNote
{
	[ionizerIonEnergyPU selectItemAtIndex: [model ionizerIonEnergy]];
}

- (void) ionizerEmissionCurrentChanged:(NSNotification*)aNote
{
	[ionizerEmissionCurrentField setIntValue: [model ionizerEmissionCurrent]];
}

- (void) ionizerElectronEnergyChanged:(NSNotification*)aNote
{
	[ionizerElectronEnergyField setIntValue: [model ionizerElectronEnergy]];
}

- (void) ionizerDegassTimeChanged:(NSNotification*)aNote
{
	[ionizerDegassTimeField setIntValue: [model ionizerDegassTime]];
}

- (void) rs232ErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
		
	int mask = [model rs232ErrWord];
	[[rs232ErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGABadCmd)			? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGABadParam)			? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:2 column:0] setStringValue:(mask & kRGACmdTooLong)		? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:3 column:0] setStringValue:(mask & kRGAOverWrite)		? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:4 column:0] setStringValue:(mask & kRGATransOverWrite)	? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:5 column:0] setStringValue:(mask & kRGAJumper)			? @"YES":@"NO"];
	[[rs232ErrWordMatrix cellAtRow:6 column:0] setStringValue:(mask & kRGAParamConflict)	? @"YES":@"NO"];
	
	[[rs232ErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGABadCmd)			? bad:good];
	[[rs232ErrWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGABadParam)		? bad:good];
	[[rs232ErrWordMatrix cellAtRow:2 column:0] setTextColor:(mask & kRGACmdTooLong)		? bad:good];
	[[rs232ErrWordMatrix cellAtRow:3 column:0] setTextColor:(mask & kRGAOverWrite)		? bad:good];
	[[rs232ErrWordMatrix cellAtRow:4 column:0] setTextColor:(mask & kRGATransOverWrite)	? bad:good];
	[[rs232ErrWordMatrix cellAtRow:5 column:0] setTextColor:(mask & kRGAJumper)			? bad:good];
	[[rs232ErrWordMatrix cellAtRow:6 column:0] setTextColor:(mask & kRGAParamConflict)	? bad:good];
}


- (void) filErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model filErrWord];
	[[filErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGAFILSingleFilament)		? @"YES":@"NO"];
	[[filErrWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGAFILPressureTooHigh)		? @"YES":@"NO"];
	[[filErrWordMatrix cellAtRow:2 column:0] setStringValue:(mask & kRGAFILCannotSetCurrent)	? @"YES":@"NO"];
	[[filErrWordMatrix cellAtRow:3 column:0] setStringValue:(mask & kRGAFILNoFilament)			? @"YES":@"NO"];
	
	[[filErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGAFILSingleFilament)		? bad:good];
	[[filErrWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGAFILPressureTooHigh)		? bad:good];
	[[filErrWordMatrix cellAtRow:2 column:0] setTextColor:(mask & kRGAFILCannotSetCurrent)		? bad:good];
	[[filErrWordMatrix cellAtRow:3 column:0] setTextColor:(mask & kRGAFILNoFilament)			? bad:good];
}



- (void) cemErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model cemErrWord];
	[[cemErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGACEMNoElecMultiOption)	? @"YES":@"NO"];
	
	[[cemErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGACEMNoElecMultiOption)		? bad:good];
}


- (void) qmfErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model qmfErrWord];
	[[qmfErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGAQMFCurrentLimited)	? @"YES":@"NO"];
	[[qmfErrWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGAQMFCurrentTooHigh)	? @"YES":@"NO"];
	[[qmfErrWordMatrix cellAtRow:2 column:0] setStringValue:(mask & kRGAQMFRF_CTTooHigh)	? @"YES":@"NO"];
	
	[[qmfErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGAQMFCurrentLimited)	? bad:good];
	[[qmfErrWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGAQMFCurrentTooHigh)	? bad:good];
	[[qmfErrWordMatrix cellAtRow:2 column:0] setTextColor:(mask & kRGAQMFRF_CTTooHigh)		? bad:good];	
}

- (void) detErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model detErrWord];
	[[detErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGADetOpAmpOffset)		? @"Failed":@"Passed"];
	[[detErrWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGADetCompNegInput)	? @"BAD":@"OK"];
	[[detErrWordMatrix cellAtRow:2 column:0] setStringValue:(mask & kRGADetCompPosInput)	? @"BAD":@"OK"];
	[[detErrWordMatrix cellAtRow:3 column:0] setStringValue:(mask & kRGADetDetNegInput)		? @"BAD":@"OK"];
	[[detErrWordMatrix cellAtRow:4 column:0] setStringValue:(mask & kRGADetDetPosInput)		? @"BAD":@"OK"];
	[[detErrWordMatrix cellAtRow:5 column:0] setStringValue:(mask & kRGADetAdcFailure)		? @"BAD":@"OK"];
	
	[[detErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGADetOpAmpOffset)		? bad:good];
	[[detErrWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGADetCompNegInput)		? bad:good];
	[[detErrWordMatrix cellAtRow:2 column:0] setTextColor:(mask & kRGADetCompPosInput)		? bad:good];
	[[detErrWordMatrix cellAtRow:3 column:0] setTextColor:(mask & kRGADetDetNegInput)		? bad:good];
	[[detErrWordMatrix cellAtRow:4 column:0] setTextColor:(mask & kRGADetDetPosInput)		? bad:good];
	[[detErrWordMatrix cellAtRow:5 column:0] setTextColor:(mask & kRGADetAdcFailure)		? bad:good];
}

- (void) psErrWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model qmfErrWord];
	[[psErrWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGAPSExtPowerTooLow)	? @"YES":@"NO"];
	[[psErrWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGAPSExtPowerTooHigh)	? @"YES":@"NO"];
	
	[[psErrWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGAPSExtPowerTooLow)	? bad:good];
	[[psErrWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGAPSExtPowerTooHigh)	? bad:good];
}


- (void) statusWordChanged:(NSNotification*)aNote
{
	NSColor* bad  = [NSColor colorWithDeviceRed:.75 green:0 blue:0 alpha:1];
	NSColor* good = [NSColor colorWithDeviceRed:0 green:.75 blue:0 alpha:1];
	
	int mask = [model statusWord];
	[[statusWordMatrix cellAtRow:0 column:0] setStringValue:(mask & kRGACommStatusMask)			 ? @"BAD":@"OK"];
	[[statusWordMatrix cellAtRow:1 column:0] setStringValue:(mask & kRGAFilamentStatusMask)		 ? @"BAD":@"OK"];
	[[statusWordMatrix cellAtRow:2 column:0] setStringValue:(mask & kRGAElectronMultiStatusMask) ? @"BAD":@"OK"];
	[[statusWordMatrix cellAtRow:3 column:0] setStringValue:(mask & kRGAQMFStatusMask)			 ? @"BAD":@"OK"];
	[[statusWordMatrix cellAtRow:4 column:0] setStringValue:(mask & kRGAElectrometerStatusMask)	 ? @"BAD":@"OK"];
	[[statusWordMatrix cellAtRow:5 column:0] setStringValue:(mask & kRGA24VStatusMask)			 ? @"BAD":@"OK"];

	[[statusWordMatrix cellAtRow:0 column:0] setTextColor:(mask & kRGACommStatusMask)			? bad:good];
	[[statusWordMatrix cellAtRow:1 column:0] setTextColor:(mask & kRGAFilamentStatusMask)		? bad:good];
	[[statusWordMatrix cellAtRow:2 column:0] setTextColor:(mask & kRGAElectronMultiStatusMask)	? bad:good];
	[[statusWordMatrix cellAtRow:3 column:0] setTextColor:(mask & kRGAQMFStatusMask)			? bad:good];
	[[statusWordMatrix cellAtRow:4 column:0] setTextColor:(mask & kRGAElectrometerStatusMask)	? bad:good];
	[[statusWordMatrix cellAtRow:5 column:0] setTextColor:(mask & kRGA24VStatusMask)			? bad:good];
	
}

- (void) serialNumberChanged:(NSNotification*)aNote
{
	[serialNumberField setIntValue: [model serialNumber]];
}

- (void) firmwareVersionChanged:(NSNotification*)aNote
{
	[firmwareVersionField setFloatValue: [model firmwareVersion]];
}

- (void) modelNumberChanged:(NSNotification*)aNote
{
	[modelNumberField setIntValue: [model modelNumber]];
}

- (void) scaleAction:(NSNotification*)aNotification
{
	if(aNotification == nil || [aNotification object] == [plotter xAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter xAxis]attributes] forKey:@"XAttributes0"];
	}
	
	if(aNotification == nil || [aNotification object] == [plotter yAxis]){
		[model setMiscAttributes:[(ORAxis*)[plotter yAxis]attributes] forKey:@"YAttributes0"];
	}
}

- (void) miscAttributesChanged:(NSNotification*)aNote
{
	
	NSString*				key = [[aNote userInfo] objectForKey:ORMiscAttributeKey];
	NSMutableDictionary* attrib = [model miscAttributesForKey:key];
	
	if(aNote == nil || [key isEqualToString:@"XAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"XAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter xAxis] setAttributes:attrib];
			[plotter setNeedsDisplay:YES];
			[[plotter xAxis] setNeedsDisplay:YES];
		}
	}
	if(aNote == nil || [key isEqualToString:@"YAttributes0"]){
		if(aNote==nil)attrib = [model miscAttributesForKey:@"YAttributes0"];
		if(attrib){
			[(ORAxis*)[plotter yAxis] setAttributes:attrib];
			[plotter setNeedsDisplay:YES];
			[[plotter yAxis] setNeedsDisplay:YES];
		}
	}
	
}

- (void) updateTimePlot:(NSNotification*)aNote
{
	if(!aNote || ([aNote object] == [model timeRate])){
		[plotter setNeedsDisplay:YES];
	}
}


- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORRGA300Lock to:secure];
    [lockButton setEnabled:secure];
}

- (void) lockChanged:(NSNotification*)aNotification
{
	[self updateButtons];
}

- (BOOL) portLocked
{
	return [gSecurity isLocked:ORRGA300Lock];;
}

- (void) updateButtons
{
    BOOL locked = [gSecurity isLocked:ORRGA300Lock];
	BOOL portOpen = [[model serialPort] isOpen];
    [lockButton setState: locked];
	[serialPortController updateButtons:locked];
    [updateButton setEnabled:portOpen];
    [pollTimePopup setEnabled:!locked && portOpen];
	[elecMultHVBiasField setEnabled:[model electronMultiOption]];
}

- (void) pollTimeChanged:(NSNotification*)aNotification
{
	[pollTimePopup selectItemWithTag:[model pollTime]];
}

#pragma mark •••Actions
- (IBAction) syncDialogAction:(id)sender				{ [model syncWithHW]; }

- (IBAction) numberAnalogScansAction:(id)sender			{ [model setNumberAnalogScans:	[sender intValue]]; }
- (IBAction) stepsPerAmuAction:(id)sender				{ [model setStepsPerAmu:		[sender intValue]]; }
- (IBAction) singleMassAction:(id)sender				{ [model setSingleMass:			[sender intValue]]; }
- (IBAction) initialMassAction:(id)sender				{ [model setInitialMass:		[sender intValue]]; }
- (IBAction) finalMassAction:(id)sender					{ [model setFinalMass:			[sender intValue]]; }
- (IBAction) noiseFloorSettingAction:(id)sender			{ [model setNoiseFloorSetting:	[sender intValue]]; }
- (IBAction) elecMultHVBiasAction:(id)sender			{ [model setElecMultHVBias:		[sender intValue]]; }
- (IBAction) ionizerDegassTimeAction:(id)sender			{ [model setIonizerDegassTime:	[sender intValue]]; }
- (IBAction) ionizerFocusPlateVoltageAction:(id)sender	{ [model setIonizerFocusPlateVoltage:	[sender intValue]]; }
- (IBAction) ionizerIonEnergyAction:(id)sender			{ [model setIonizerIonEnergy:			[sender indexOfSelectedItem]]; }
- (IBAction) ionizerEmissionCurrentAction:(id)sender	{ [model setIonizerEmissionCurrent:		[sender intValue]]; }
- (IBAction) ionizerElectronEnergyAction:(id)sender		{ [model setIonizerElectronEnergy:		[sender intValue]]; }


- (IBAction) lockAction:(id) sender						
{ 
	[gSecurity tryToSetLock:ORRGA300Lock to:[sender intValue] forWindow:[self window]]; 
}

- (IBAction) updateAllAction:(id)sender
{
	[model updateAll];
}

- (IBAction) pollTimeAction:(id)sender
{
	[model setPollTime:[[sender selectedItem] tag]];
}

- (IBAction) initAction:(id)sender
{
	[self endEditing];
	[model initUnit];
}

- (IBAction) resetAction:(id)sender
{
	[model sendReset];
}

- (IBAction) standByAction:(id)sender
{
	[model sendStandBy];
}

- (IBAction) degassAction:(id)sender
{
//	int activity = [model activityInProgress];
//	if(activity){
//		if(activity == kRGADegassInProgress)[model startDegassing];
//		[model stopDegassing];
//	}
}

#pragma mark •••Data Source
- (int) numberPointsInPlot:(id)aPlotter
{
	return [[model timeRate] count];
}

- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue
{
	int count = [[model timeRate] count];
	int index = count-i-1;
	*xValue = [[model timeRate] timeSampledAtIndex:index];
	*yValue = [[model timeRate] valueAtIndex:index];
}

@end

