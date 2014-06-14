//
//  HPTThreeLineFlowerBuySig.m
//  iHPTrader
//
//  Created by hugo on 13年6月16日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTThreeLineFlowerBuySig.h"


@implementation HPTThreeLineFlowerBuySig


- (id)initWithStore:(id<HPTMarketDataStoreProtocol>)store{
	self = [super init];
	if (self) {
		_store = [store retain];
		_core = [[TACore alloc] init];
		_isBuy = NO;
		_isSell = NO;
		_rank = HPT_NO_RANK;
		
		_sma1 = 30;
		_sma2 = 60;
		_sma3 = 240;
	}
	return self;
}

- (void)dealloc {
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

// key / value 
// "SMA1" / NSNumber
// "SMA2" / NSNumber
// "SMA3" / NSNumber
- (void)setParam:(NSDictionary *)paramSet{
	if (paramSet) {
		NSNumber *sma1 = [paramSet objectForKey:@"SMA1"];
		if (sma1 && [sma1 intValue] > 0) {
			_sma1 = [sma1 intValue];
		}else {
			_sma1 = 30;
		}
		
		NSNumber *sma2 = [paramSet objectForKey:@"SMA2"];
		if (sma2 && [sma2 intValue] > _sma1) {
			_sma2 = [sma2 intValue];
		}else {
			_sma2 = 60;
		}
		
		NSNumber *sma3 = [paramSet objectForKey:@"SMA3"];
		if (sma3 && [sma3 intValue] > _sma2) {
			_sma3 = [sma3 intValue];
		}else {
			_sma3 = 240;
		}
	}else {
		_sma1 = 30;
		_sma2 = 60;
		_sma3 = 240;
	}
}

- (void)deriveData{
	//reset
	_isBuy = YES;
	_isSell = NO;
	_rank = HPT_NO_RANK;
	
	if (_store && _symbol && _core) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		//TAMAType optInMAType = TASma;
		
		TAMInteger *outBegIdxVOLSMA20 = [[TAMInteger alloc] init];
		TAMInteger *outNBElementVOLSMA20 = [[TAMInteger alloc] init];
		
		TAMInteger *outBegIdxSMA30 = [[TAMInteger alloc] init];
		TAMInteger *outNBElementSMA30 = [[TAMInteger alloc] init];
		
		TAMInteger *outBegIdxSMA60 = [[TAMInteger alloc] init];
		TAMInteger *outNBElementSMA60 = [[TAMInteger alloc] init];
		
		TAMInteger *outBegIdxSMA240 = [[TAMInteger alloc] init];
		TAMInteger *outNBElementSMA240 = [[TAMInteger alloc] init];
		
		[_store loadSymbol:_symbol];
		NSMutableDictionary *bars = [_store getBars:_symbol];
		
		int size = [bars count];
		NSMutableArray *open=nil, *high=nil, *low=nil, *close=nil, *volume=nil, 
						*outSMA30=nil, *outSMA60=nil, *outSMA240=nil, *outVOLSMA20=nil;
		//NSLog(@"size=%i",size);
		if (size > 250) {
			//NSLog(@"i am here");
			open = [[NSMutableArray alloc] initWithCapacity:size];
			high = [[NSMutableArray alloc] initWithCapacity:size];
			low = [[NSMutableArray alloc] initWithCapacity:size];
			close = [[NSMutableArray alloc] initWithCapacity:size];
			volume = [[NSMutableArray alloc] initWithCapacity:size];
			outSMA30 = [[NSMutableArray alloc] initWithCapacity:size];
			outSMA60 = [[NSMutableArray alloc] initWithCapacity:size];
			outSMA240 = [[NSMutableArray alloc] initWithCapacity:size];
			outVOLSMA20 = [[NSMutableArray alloc] initWithCapacity:size];
			
			NSArray *keys = [bars allKeys];
			NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
			
			for (int i=0; i<size; i++) {
				HPTBarData *bar = [bars objectForKey:[sortedKeys objectAtIndex:i]];
				[open addObject:[NSNumber numberWithDouble:bar.open]];
				[high addObject:[NSNumber numberWithDouble:bar.high]];
				[low addObject:[NSNumber numberWithDouble:bar.low]];
				[close addObject:[NSNumber numberWithDouble:bar.close]];
				[volume addObject:[NSNumber numberWithLongLong:bar.volume]];
			}
			
			[_core sma:0 withEndIdx:size-1 withInClose:close withOptInTimePeriod:_sma1 withOutBegIdx:outBegIdxSMA30 withOutNBElement:outNBElementSMA30 withOutSMA:outSMA30];
			[_core sma:0 withEndIdx:size-1 withInClose:close withOptInTimePeriod:_sma2 withOutBegIdx:outBegIdxSMA60 withOutNBElement:outNBElementSMA60 withOutSMA:outSMA60];
			[_core sma:0 withEndIdx:size-1 withInClose:close withOptInTimePeriod:_sma3 withOutBegIdx:outBegIdxSMA240 withOutNBElement:outNBElementSMA240 withOutSMA:outSMA240];
			[_core sma:0 withEndIdx:size-1 withInClose:volume withOptInTimePeriod:20 withOutBegIdx:outBegIdxVOLSMA20 withOutNBElement:outNBElementVOLSMA20 withOutSMA:outVOLSMA20];
			
			/* for debug on SMA result
			if ([[_symbol getSymbol] isEqualToString:@"1893"] ) {
				NSLog(@"size of[%@] =%i", _symbol, size);
				NSLog(@"last close = %@", [close objectAtIndex:size-1]);
				NSLog(@"SMA30 for [%@] size=%i", _symbol, [outSMA30 count]);
				NSLog(@"SMA30 for [%@] = %@", _symbol, [outSMA30 objectAtIndex:size-1]);
				NSLog(@"SMA60 for [%@] = %@", _symbol, [outSMA60 objectAtIndex:size-1]);
				NSLog(@"SMA240 for [%@] size=%i", _symbol, [outSMA240 count]);
				NSLog(@"SMA240 for [%@] = %@", _symbol, [outSMA240 objectAtIndex:size-1]);
				NSLog(@"VOLSMA20 for [%@] = %@", _symbol, [outVOLSMA20 objectAtIndex:size-1]);
			}
			*/
			//...........
			
			
			double sma_30 = [(NSNumber *)[outSMA30 objectAtIndex:size-1] doubleValue];
			double sma_60 = [(NSNumber *)[outSMA60 objectAtIndex:size-1] doubleValue];
			double sma_240 = [(NSNumber *)[outSMA240 objectAtIndex:size-1] doubleValue];
			double sma_vol = [(NSNumber *)[outVOLSMA20 objectAtIndex:size-1] doubleValue];
			double last_close = [(NSNumber *)[close objectAtIndex:size-1] doubleValue];
			//double last_vol = [(NSNumber *)[volume objectAtIndex:size-1] doubleValue];
			
			if(sma_240 > 0 && last_close >= sma_30 && last_close > sma_60 && last_close > sma_240){
				_isBuy = YES;
				if (last_close >= sma_30 && sma_30 >= sma_60 && sma_60 >= sma_240) {
					_rank = HPT_SIGNAL_RANK;
				
					double brustDiff = last_close*(double)0.03;
					if ( (sma_60 + brustDiff) >= sma_30 && (sma_240 + brustDiff) >= sma_60 ) {
						_rank = HPT_RECOMMAND_RANK;
					
						for (int dayBefore=0; dayBefore<=10; dayBefore++) {
							double temp_vol = [(NSNumber *)[volume objectAtIndex:size-1-dayBefore] doubleValue];
							if (temp_vol > sma_vol*(double)3) {
								_rank = HPT_HIGHLY_RANK;
								break;
							}
						
						}
					}
				
				
				
					for(int dayBefore=1; dayBefore<=5; dayBefore++){
						
						double temp_sma_30 = [(NSNumber *)[outSMA30 objectAtIndex:size-1-dayBefore] doubleValue];
						double temp_sma_60 = [(NSNumber *)[outSMA60 objectAtIndex:size-1-dayBefore] doubleValue];
						double temp_sma_240 = [(NSNumber *)[outSMA240 objectAtIndex:size-1-dayBefore] doubleValue];
						double temp_close = [(NSNumber *)[close objectAtIndex:size-1-dayBefore] doubleValue];
					
					
						if ( (temp_sma_30 <= temp_sma_60 || temp_sma_60 <= temp_sma_240) && 
							((temp_close+brustDiff) >= temp_sma_30 && temp_close <= temp_sma_30) ) {
							_rank = HPT_HIGHLY_RANK;
							break;
						}
					}
				}
				
				for(int dayBefore=0; dayBefore<=5; dayBefore++){
					double brustDiff = last_close*(double)0.05;
					double temp_sma_30 = [(NSNumber *)[outSMA30 objectAtIndex:size-1-dayBefore] doubleValue];
					double temp_sma_60 = [(NSNumber *)[outSMA60 objectAtIndex:size-1-dayBefore] doubleValue];
					double temp_sma_240 = [(NSNumber *)[outSMA240 objectAtIndex:size-1-dayBefore] doubleValue];
					double temp_close = [(NSNumber *)[close objectAtIndex:size-1-dayBefore] doubleValue];
					double temp_low = [(NSNumber *)[low	objectAtIndex:size-1-dayBefore] doubleValue];
					double temp_vol = [(NSNumber *)[volume objectAtIndex:size-1-dayBefore] doubleValue];
					
					
					double max_sma = fmax(temp_sma_30, fmax(temp_sma_60, temp_sma_240));
					double min_sma = fmin(temp_sma_30, fmin(temp_sma_60, temp_sma_240));
					
					if (temp_close > max_sma && (temp_low+brustDiff) > min_sma &&
						( (temp_sma_30+brustDiff)>=max_sma || (temp_sma_60+brustDiff)>=max_sma || (temp_sma_240+brustDiff)>=max_sma ) &&
						temp_vol > sma_vol*3 ) {
						_rank = HPT_HIGHLY_RANK;
						break;

					}
					
				}
				
				
			}
			
		}
		
		[outBegIdxSMA30 release];
		[outNBElementSMA30 release];
		[outBegIdxSMA60	release];
		[outNBElementSMA60 release];
		[outBegIdxSMA240 release];
		[outNBElementSMA240 release];
		
		[open release];
		[high release];
		[low release];
		[close release];
		[volume release];
		
		[outSMA30 release];
		[outSMA60 release];
		[outSMA240 release];
		
		[_store removeSymbol:_symbol];
		
		[pool drain];
	}
}


@end
