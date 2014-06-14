//
//  HPTStandardIndicator.m
//  iHPTrader
//
//  Created by hugo on 14年5月19日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HPTStandardIndicator.h"


@implementation HPTStandardIndicator

- (id)initWithStore:(id <HPTMarketDataStoreProtocol>)store{
	self = [super init];
	if (self) {
		_store = [store retain];
		_core = [[TACore alloc] init];
		
		_isBuy = NO;
		_isSell = NO;
		_rank = HPT_NO_RANK;
	}
	
	return self;
}

- (void)dealloc{
	[_store release];
	[_core release];
	[_symbol release];
	[super dealloc];
}


- (BOOL)isBuy{
	return _isBuy;
}

- (BOOL)isSell{
	return _isSell;
}

- (HPTIndicatorRank)getRank{
	return _rank;
}

- (void)setSymbol:(id <HPTSymbolProtocol>)aSymbol{
	if (_symbol) {
		[_symbol release];
	}
	_symbol = [aSymbol retain];
}

- (void)setParam:(NSDictionary *)paramSet{
//overridden by subclass	
}

- (void)deriveData{
//overridden by subclass
}

- (int)loadSymbolBarsWithClose:(NSMutableArray *)closeBar withOpen:(NSMutableArray *)openBar 
					  withHigh:(NSMutableArray *)highBar withLow:(NSMutableArray *)lowBar 
					withVolume:(NSMutableArray *)volumeBar{
	
	int size = 0;
	if (_store && _symbol && _core) {
		[_store loadSymbol:_symbol];
		NSMutableDictionary *bars = [_store getBars:_symbol];
		
		size = [bars count];
		if (size > 0) {
			NSArray *keys = [bars allKeys];
			NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
			
			for (int i=0; i<size; i++) {
				HPTBarData *bar = [bars objectForKey:[sortedKeys objectAtIndex:i]];
				
				if (closeBar) {
					[closeBar addObject:[NSNumber numberWithDouble:bar.close]];
				}
				
				if (openBar) {
					[openBar addObject:[NSNumber numberWithDouble:bar.open]];
				}
				
				if (highBar) {
					[highBar addObject:[NSNumber numberWithDouble:bar.high]];
				}
				
				if (lowBar) {
					[lowBar addObject:[NSNumber numberWithDouble:bar.low]];
				}
				
				if (volumeBar) {
					[volumeBar addObject:[NSNumber numberWithLongLong:bar.volume]];
				}
				
			}
		}
		[_store removeSymbol:_symbol];
		
	}
	
	return size;
}

- (NSArray *)getSMA:(NSArray *)input withTimePeriod:(int)inTimePeriod{
	NSMutableArray *output = nil;
	
	if (_core && input && inTimePeriod >1) {
		TAMInteger *outBegIdxSMA = [[[TAMInteger alloc] init] autorelease];
		TAMInteger *outNBElementSMA = [[[TAMInteger alloc] init] autorelease];
		int size = [input count];
		
		if (size>0) {
			output = [[[NSMutableArray alloc] initWithCapacity:size] autorelease];
			
			[_core sma:0 withEndIdx:size-1 withInClose:input withOptInTimePeriod:inTimePeriod withOutBegIdx:outBegIdxSMA withOutNBElement:outNBElementSMA withOutSMA:output];
		}
		
	}
	
	return output;
}



@end
