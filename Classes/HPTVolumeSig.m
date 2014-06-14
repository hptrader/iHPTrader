//
//  HPTVolumeSig.m
//  iHPTrader
//
//  Created by hugo on 14年5月16日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HPTVolumeSig.h"


@implementation HPTVolumeSig



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
		
		//at least have 100 trading day data to be valid
		if (size > 100) {
			NSArray *volSMA = [self getSMA:vol withTimePeriod:20];
			for (int dayBefore =0; dayBefore <=5; dayBefore++) {
				double lastVolume = [(NSNumber *)[vol objectAtIndex:size-1-dayBefore] doubleValue];
				double lastVolSMA = [(NSNumber *)[volSMA objectAtIndex:size-1-dayBefore] doubleValue];
				double lastOpen = [(NSNumber *)[open objectAtIndex:size-1-dayBefore] doubleValue];
				double lastClose = [(NSNumber *)[close objectAtIndex:size-1-dayBefore] doubleValue];
				double lastHigh = [(NSNumber *)[high objectAtIndex:size-1-dayBefore] doubleValue];
				double lastLow = [(NSNumber *)[low objectAtIndex:size-1-dayBefore] doubleValue];
				
				if (lastVolume >= lastVolSMA*3 && _rank <HPT_SIGNAL_RANK) {
					if ((lastClose - lastOpen) > 0 && (lastClose - lastOpen) > (lastHigh - lastLow)/2 ) {
						_isBuy = YES;
						_rank = HPT_SIGNAL_RANK;	
					}
				}
				
				if (lastVolume >= lastVolSMA*5 && _rank < HPT_RECOMMAND_RANK) {
					if ((lastClose - lastOpen) > 0 && (lastClose - lastOpen) > (lastHigh - lastLow)/2 ) {
						_isBuy = YES;
						_rank = HPT_RECOMMAND_RANK;
					}
				}
				
				if (lastVolume >= lastVolSMA*7 && _rank < HPT_HIGHLY_RANK) {
					if ((lastClose - lastOpen) > 0 && (lastClose - lastOpen) > (lastHigh - lastLow)/2 ) {
						_isBuy = YES;
						_rank = HPT_HIGHLY_RANK;
					}
				}
				
			}
		}
		
		[pool drain];
	}
}

@end
