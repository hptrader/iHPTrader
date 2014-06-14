//
//  HPTPriceFilterIndicator.m
//  iHPTrader
//
//  Created by hugo on 13年6月23日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTPriceFilterIndicator.h"


@implementation HPTPriceFilterIndicator

- (id)initWithStore:(id<HPTMarketDataStoreProtocol>)store{
	self = [super init];
	if (self) {
		_store = [store retain];
		_core = [[TACore alloc] init];
		_isBuy = NO;
		_isSell = NO;
		_rank = HPT_NO_RANK;
		
		_lowLimit = 0.01f;
		_highLimit = 1000.00f;
		
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
// "LOW" / NSNumber
// "HIGH" / NSNumber
- (void)setParam:(NSDictionary *)paramSet{
	if (paramSet) {
		NSNumber *low = [paramSet objectForKey:@"LOW"];
		if (low && [low doubleValue] > 0) {
			_lowLimit = [low doubleValue];
		}else {
			_lowLimit = 0.01f;
		}
		
		NSNumber *high = [paramSet objectForKey:@"HIGH"];
		if (high && [high doubleValue] > _lowLimit) {
			_highLimit = [high doubleValue];
		}else {
			_highLimit = 1000.00f;
		}
		
	}else {
		_lowLimit = 0.01f;
		_highLimit = 1000.00f;
	}
}

- (void)deriveData{
	//reset
	_isBuy = NO;
	_isSell = NO;
	_rank = HPT_NO_RANK;
	
	if (_store && _symbol && _core) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		HPTBarData *lastBar = [_store getLastBar:_symbol];
		if (lastBar) {
			if (lastBar.close >= _lowLimit && lastBar.close <= _highLimit) {
				_rank = HPT_HIGHLY_RANK;
				_isBuy = YES;
			}
		}
		
		[pool drain];
	}

}



@end
