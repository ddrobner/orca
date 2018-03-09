//--------------------------------------------------------
// ORSynClockModel
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, November 2017
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

#pragma mark ***Imported Files

#import "ORSynClockModel.h"
#import "ORRefClockModel.h"

#pragma mark ***External Strings
NSString* ORSynClockModelTrackModeChanged	    = @"ORSynClockModelTrackModeChanged";
NSString* ORSynClockModelSyncChanged	        = @"ORSynClockModelSyncChanged";
NSString* ORSynClockModelAlarmWindowChanged	    = @"ORSynClockModelAlarmWindowChanged";
NSString* ORSynClockModelStatusChanged          = @"ORSynClockModelStatusChanged";
NSString* ORSynClockModelStatusPollChanged      = @"ORSynClockModelStatusPollChanged";
NSString* ORSynClockModelStatusOutputChanged    = @"ORSynClockModelStatusOutputChanged";
NSString* ORSynClockModelResetChanged           = @"ORSynClockModelResetChanged";
NSString* ORSynClockStatusUpdated               = @"ORSynClockStatusUpdated";

//#define maxReTx 3  // above this number, stop trying to
// retransmit and place an Error.

@interface ORSynClockModel (private)
- (void) updatePoll;
- (void) updateStatusHistory;
@end

@implementation ORSynClockModel
- (ORSynClockModel*) init
{
    self = [super init];
    previousStatusMessages = [[NSMutableArray arrayWithCapacity:nLastMsgs]init];
    [previousStatusMessages retain];  // todo: clean on exit
    for (int i = 0; i < nLastMsgs; ++i){
        [previousStatusMessages addObject:[[NSString alloc]init]];
    }
    return self;
}

- (void) dealloc
{
    [previousStatusMessages dealloc];
	[super dealloc];
}

- (void) setRefClock:(ORRefClockModel*)aRefClock
{
    refClock  = aRefClock; //this is a delegate... don't retain or release
}

- (NSString*) helpURL
{
	return @"RS232/SynClock.html";
}

#pragma mark ***Accessors
- (BOOL) statusPoll
{
    return statusPoll;
}

- (void) setStatusPoll:(BOOL)aStatusPoll
{
    [[[self undoManager] prepareWithInvocationTarget:self] setStatusPoll:statusPoll];
    statusPoll = aStatusPoll;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSynClockModelStatusPollChanged object:self];
    [self updatePoll];
}

- (void) requestStatus
{
    [self writeData:[self statusCommand]];
}

- (NSString*) statusMessages
{
    NSMutableString* messages = [[NSMutableString alloc] init];
    int i;
    for(i = 0; i < nLastMsgs; ++i){
        if(i == 1){
            [messages appendString:@"***previous messages:*** \n "];
        }
        if(previousStatusMessages[i])[messages appendString:previousStatusMessages[i]];
        [messages appendString:@"\n "];
    }
    if([messages length]==0)return @"";
    else return messages;
}

- (int) trackMode
{
    return trackMode;
}

- (void) setTrackMode:(int)aMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setTrackMode:trackMode];
    trackMode = aMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSynClockModelTrackModeChanged object:self];
    [self updatePoll];
}

- (int) syncMode
{
    return syncMode;
}

- (void) setSyncMode:(int)aMode
{
    [[[self undoManager] prepareWithInvocationTarget:self] setSyncMode:syncMode];
    syncMode = aMode;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSynClockModelSyncChanged object:self];
    [self updatePoll];
}

- (unsigned long) alarmWindow
{
    if(alarmWindow<50)          return 50;
    else if(alarmWindow>12650)  return 12650;
    else                        return alarmWindow;
}

- (void) setAlarmWindow:(unsigned long)aValue
{
    if(aValue<50)           aValue = 50;
    else if(aValue>127050)  aValue = 12750;
    
    [[[self undoManager] prepareWithInvocationTarget:self] setAlarmWindow:alarmWindow];
    alarmWindow = aValue;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORSynClockModelAlarmWindowChanged object:self];
}

//put our parameters into any run header
- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [NSMutableDictionary dictionary];
    [objDictionary setObject:NSStringFromClass([self class]) forKey:@"Class Name"];

	return objDictionary;
}

- (BOOL) portIsOpen
{
    return [refClock portIsOpen];
}
#pragma mark *** Commands

- (void) writeData:(NSDictionary*)aDictionary
{
    [refClock addCmdToQueue:aDictionary];
}

- (void) processResponse:(NSData*)receivedData;
{
    //receivedData should have been processed by refClockModel to be the full response.
    //Here is where the data is decoded into something meaningful for this object
    
    //use [refClock lastRequest] to get the orginal command
    
    if([refClock verbose]) NSLog(@"received synClock response\n");
    
    ///MAH -- I didn't attempt to do anything to the old processing code below since I don't know the format
    //\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
    //BOOL done = NO;
    
    //if(!inComingData)inComingData = [[NSMutableData data] retain];
    //  [inComingData appendData:[[note userInfo] objectForKey:@"data"]];
    
    //while (((char*)[inComingData mutableBytes])[0] != 'X' && [inComingData length] > 0){  //  remove possible error bytes at beginning until 'X';
    // this can occur when the device has sent faulty data.
    //NSRange range = NSMakeRange(0, 1);
    //[inComingData replaceBytesInRange:range withBytes:NULL length:0];
    //if([refClock verbose]){
    //  NSLog(@"removed wrong starting Byte! \n");
    //}
    //}
    unsigned short nBytes = [receivedData length];
    unsigned char * bytes = (unsigned char *)[receivedData bytes];
    //if([inComingData length] >= 7) {
    if(bytes[nBytes - 1] == '\n') { // check for trailing \n (LF)
        //NSLog(@"lastRequest contains %d bytes", [lastRequest length]);
        // char* lastCmd;
        // if([lastRequest length] > 7)  // waveform was sent...
        // {
        //   if([refClock verbose]){
        //     NSLog(@"respond after set waveform: %@, length: %d \n", inComingData, [inComingData length]);
        //   }
        //   NSRange range = NSMakeRange([lastRequest length] - 7, 7);
        //   lastCmd = (char*) [[lastRequest subdataWithRange:range]bytes];
        //   if([refClock verbose]){
        //     NSLog(@"last command (waveform): %7s \n", lastCmd);
        //   }
        // }
        // else{
        //lastCmd = (char*)[lastRequest bytes];
        //}
        
        if([refClock verbose]){
            //NSLog(@"last command: %s (synClock dataAvailable) \n", lastCmd);
            NSLog(@"Data received: %s ; size: %d \n", bytes, nBytes);
        }
        switch(bytes[0]){
            case '0': statusMessage = @"0: warming up"; break;
            case '1': statusMessage = @"1: tracking set-up"; break;
            case '2': statusMessage = @"2: track to PPSREF"; break;
            case '3': statusMessage = @"3: sync to PPSREF"; break;
            case '4': statusMessage = @"4: Free Run. Track OFF"; break;
            case '5': statusMessage = @"5: PSREF unstable (Hold over)"; break;
            case '6': statusMessage = @"6: No PSREF (Hold over)"; break;
            case '7': statusMessage = @"7: factory used"; break;
            case '8': statusMessage = @"8: factory used"; break;
            case '9': statusMessage = @"9: Fault"; break;
            default: statusMessage = @"warning: SynClock default message"; break;
        }
        [self updateStatusHistory];
        NSLog(@"notifying... \n");
        [[NSNotificationCenter defaultCenter] postNotificationName:ORSynClockStatusUpdated object:self];
        //displayStatus(bytes[0]);
    }
    else{
        NSLog(@"Warning (SynClockModel::dataAvailable): unsupported command \n");
    }
    //  switch (lastCmd[1]){
    //    case kWGRemoteCmd:
    //
    //      if([lastRequest isEqual: inComingData]){
    //        //NSLog(@"setRemote was successful: %@ \n", inComingData);
    //        reTxCount = 0;
    //      }else{
    //        reTxCount++;
    //        if([refClock verbose]){
    //          NSLog(@"setRemote (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount); //%@ \n", inComingData);
    //      }
    //        [cmdQueue enqueue:lastRequest];
    //      }
    //      done = YES;
    //      break;
    //    case kWGFreqCmd:
    //     if(![lastRequest isEqual: inComingData]){
    //       reTxCount++;
    //       if([refClock verbose]){
    //         NSLog(@"setFrequency (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount); //received wrong acknowledge: %@ \n", inComingData);
    //       }
    //       [cmdQueue enqueue:lastRequest];
    //     }else {
    //       //NSLog(@"setFrequency was successful: %@ \n", inComingData);
    //       reTxCount = 0;
    //     }
    //     done = YES;
    //    break;
    //   case kWGAttCmd:
    //
    //     if([lastRequest isEqual: inComingData]){
    //       reTxCount = 0;
    //     }else{
    //       reTxCount++;
    //       if([refClock verbose]){
    //         NSLog(@"setAmplitude (Attenuation) (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount); //%@ \n", inComingData);
    //       }
    //       [cmdQueue enqueue:lastRequest];
    //     }
    //     done = YES;
    //     break;
    //   case kWGAmpltCmd:
    //     if([lastRequest isEqual: inComingData]){
    //       reTxCount = 0;
    //     }else{
    //       reTxCount++;
    //       if([refClock verbose]){
    //         NSLog(@"setAmplitude (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount); //%@ \n", inComingData);
    //       }
    //       [cmdQueue enqueue:lastRequest];
    //     }
    //     done = YES;
    //     break;
    //  case kWGDutyCCmd:
    //   if([lastRequest isEqual: inComingData]){
    //     reTxCount = 0;
    //   }else{
    //     reTxCount++;
    //     if([refClock verbose]){
    //       NSLog(@"setDutyCycle (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount);
    //     }
    //     [cmdQueue enqueue:lastRequest];
    //   }
    //   done = YES;
    //   break;
    // case kWGFormCmd:
    //   if([lastRequest isEqual: inComingData]){
    //     reTxCount = 0;
    //   }else{
    //     reTxCount++;
    //     if([refClock verbose]){
    //       NSLog(@"setSignalForm (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount); //%@ \n", inComingData);
    //       NSLog(@"sent Data: %@ \n", lastRequest);
    //       NSLog(@"incoming Data: %@ \n", inComingData);
    //     }
    //     [cmdQueue enqueue:lastRequest];
    //   }
    //   done = YES;
    //   break;
    //
    //   case kWGProgModCmd:
    //   if([refClock verbose]){
    //     NSLog(@"kWGProgModCmd: incoming Data: %@ \n", inComingData);
    //   }
    //   if(! [[self progModeCmdReturned] isEqual: inComingData]){
    //     reTxCount++;
    //     [cmdQueue enqueue:lastRequest];
    //   }else{
    //     reTxCount = 0;
    //   }
    //   done = YES;
    //   break;
    //   case kWGStartProgCmd:
    //   if([refClock verbose]){
    //     NSLog(@"kWGStartProgCmd:incoming Data: %@ \n", inComingData);
    //   }
    //   if([lastRequest isEqual: inComingData]){
    //     reTxCount = 0;
    //   }else{
    //     reTxCount++;
    //     if([refClock verbose]){
    //       NSLog(@"start Programming (SynClock): wrong data: trying(%d) to retransmit \n", reTxCount);
    //     }
    //     [cmdQueue enqueue:lastRequest];
    //   }
    //   done = YES;
    //   break;
    //
    //   case kWGRdyPrgrmCmd:
    //   if([refClock verbose]){
    //     NSLog(@"kWGRdyPrgrmCmd: incoming Data: %@ \n", inComingData);
    //   }
    //   if(! [[self isReadyForProgReturned] isEqual: inComingData]){
    //     reTxCount++;
    //     [cmdQueue enqueue:lastRequest];
    //     if([refClock verbose]){
    //       NSLog(@"kWGRdyPrgrmCmd not successful. repeating.. \n");
    //     }
    //     usleep(1000000);
    //   }else{
    //     reTxCount = 0;
    //     if([refClock verbose]){
    //       NSLog(@"kWGRdyPrgrmCmd successful \n");
    //     }
    //   }
    //   done = YES;
    //   break;
    //   case kWGStopPrgrmCmd:
    //   if([refClock verbose]){
    //     NSLog(@"kWGStopPrgrmCmd: incoming Data: %@ \n", inComingData);
    //   }
    //   NSData* expectedReturn = [NSData dataWithBytes:lastCmd length:7];
    //   if([expectedReturn isEqual: inComingData]){
    //     if([refClock verbose]){
    //       NSLog(@"kWGStopPrgrmCmd: incoming Data OK \n");
    //     }
    //     reTxCount = 0;
    //   }else{
    //     //reTxCount++;
    //     if([refClock verbose]){
    //       NSLog(@"ERROR: stop Programming (SynClock): wrong data; expected: %@  \n", expectedReturn);
    //     }
    //     //[cmdQueue enqueue:lastRequest];
    //   }
    //   done = YES;
    //   break;
    //   case kWGFinPrgrmCmd:
    //   if([refClock verbose]){
    //     NSLog(@"kWGFinPrgrmCmd: incoming Data: %@ \n", inComingData);
    //   }
    //   if(! [[self isStoppedProgReturned] isEqual: inComingData]){
    //     reTxCount++; // = 1;
    //     [cmdQueue enqueue:lastRequest];
    //     if([refClock verbose]){
    //       NSLog(@"kWGFinPrgrmCmd not successful. repeating.. \n");
    //     }
    //     usleep(1000000);
    //   }else{
    //     reTxCount = 0;
    //     if([refClock verbose]){
    //       NSLog(@"kWGFinPrgrmCmd successful \n");
    //     }
    //   }
    //   usleep(1000000);
    //   done = YES;
    //   break;
    //
    //   }
    
    //if(done){
    //      [inComingData release];
    //    inComingData = nil;
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    //[self setLastRequest:nil];             //clear the last request
    //[self processOneCommandFromQueue];     //do the next command in the queue
    //}
    
    //}
}

- (NSDictionary*) alarmWindowCommand
{
    unsigned char cmdData[0];
    NSDictionary * commandDict = @{
                                   @"data"      : [NSData dataWithBytes:cmdData length:0],
                                   @"device"    : @"SynClock",
                                   @"replySize" : @7
                                   };
    return commandDict;
}

- (NSDictionary*) statusCommand
{
    unsigned char cmdData[4];
    cmdData[0] = 'S';
    cmdData[1] = 'T';
    cmdData[2] = '\r';
    cmdData[3] = '\n';
    
    NSDictionary * commandDict = @{
        @"data"      : [NSData dataWithBytes:cmdData length:4],
        @"device"    : ORSynClock,
        @"replySize" : @3
    };
    NSLog(@"SynClockModel::statusCommand! \n");
    
    return commandDict;
}

- (NSUndoManager*) undoManager
{
    return [refClock undoManager];
}

#pragma mark ***Archival
- (id) initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    [[self undoManager] disableUndoRegistration];
    [self setTrackMode:  [decoder decodeIntForKey:  @"trackMode"]];
    [self setSyncMode:   [decoder decodeIntForKey:  @"syncMode"]];
    [self setAlarmWindow:[decoder decodeInt32ForKey:@"alarmWindow"]];
    [[self undoManager] enableUndoRegistration];

    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeInt:  trackMode   forKey:@"trackMode"];
    [encoder encodeInt:  syncMode    forKey:@"syncMode"];
    [encoder encodeInt32:alarmWindow forKey:@"alarmWindow"];
}
@end

@implementation ORSynClockModel (private)
- (void) updatePoll
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePoll) object:nil];
    float delay = 1.0; // Seconds
    if(statusPoll && [refClock portIsOpen]) {
        [self requestStatus];
        [self performSelector:@selector(updatePoll) withObject:nil afterDelay:delay];
    }
}

- (void) updateStatusHistory
{
    for(int i = nLastMsgs; i > 1 ; i--){  // insert new statusMessage at top; last message in array drops out
        int j = i-2;
        int k = i-1;
        //previousStatusMessages[i-1] = previousStatusMessages[i-2];
        [previousStatusMessages exchangeObjectAtIndex:k withObjectAtIndex:j]; //withObject:[previousStatusMessages objectAtIndex:i-2]];
    }
    previousStatusMessages[0] = statusMessage;
}

@end
