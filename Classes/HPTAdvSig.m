//
//  HPTAdvSig.m
//  iHPTrader
//
//  Created by hugo on 14年5月26日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HPTAdvSig.h"


@implementation HPTAdvSig

//just for git commit
//
- (void)deriveData{
	_isBuy = NO;
	_isSell = NO;
	_rank = HPT_NO_RANK;
	
	if (_core && _symbol && _store) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
		
		NSMutableArray *open = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *close = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *high = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *low = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		NSMutableArray *vol = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];
		
		int size = [self loadSymbolBarsWithClose:close withOpen:open withHigh:high withLow:low withVolume:vol];
		
		if (size >100) {
			NSMutableArray *adv = [[NSMutableArray alloc] initWithCapacity:size];
			NSMutableArray *dmPlus = [[NSMutableArray alloc] initWithCapacity:size];
			NSMutableArray *dmMinus = [[NSMutableArray alloc] initWithCapacity:size];
			
			TAMInteger *outBegIdxAdv = [[[TAMInteger alloc] init] autorelease];
			TAMInteger *outNBElementAdv = [[[TAMInteger alloc] init] autorelease];
			
			[_core adx:0 withEndIdx:size-1 withInHigh:high withInLow:low withInClose:close withOptInTimePeriod:14 withOutBegIdx:outBegIdxAdv withOutNBElements:outNBElementAdv withOutADX:adv withOutDIPlus:dmPlus withOutDIMinus:dmMinus];
			if ([dmPlus count]>0) {
				//NSLog(@"symbol=%@",_symbol);
                //NSLog(@"size=%d",size);
                double maxADX, maxDMP, maxDMM;
                maxADX = maxDMP = maxDMM = 0.0f;
                
				for (int i=0; i<10; i++) {
					double lastDMP = [[dmPlus objectAtIndex:size-1-i] doubleValue];
					double lastDMM = [[dmMinus objectAtIndex:size-1-i] doubleValue];
                    double lastADX = [[adv objectAtIndex:size-1-i] doubleValue];
                    maxADX = maxADX > lastADX? maxADX: lastADX;
                    maxDMP = maxDMP > lastDMP? maxDMP: lastDMP;
                    maxDMM = maxDMM > lastDMM? maxDMM: lastDMM;
				}
                //NSLog(@"maxADX = %f",maxADX );
                //NSLog(@"maxDMP = %f",maxDMP );
                //NSLog(@"maxDMM = %f",maxDMM );
                if (maxDMM > 35) {
                    _isBuy = YES;
                    _rank = HPT_SIGNAL_RANK;
                    if (maxDMM > 40 && maxADX >40) {
                        _rank = HPT_RECOMMAND_RANK;
                    }
                    if (maxDMM > 48 && maxADX > 50) {
                        _rank = HPT_HIGHLY_RANK;
                    }
                }
                
			}
		}
		
		
		[pool drain];
	}
	



}

@end
