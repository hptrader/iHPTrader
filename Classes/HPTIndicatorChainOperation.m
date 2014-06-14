//
//  HPTIndicatorChainOperation.m
//  iHPTrader
//
//  Created by hugo on 14年5月5日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HPTIndicatorChainOperation.h"

/*
 * a obj-c style on define private methods
 * other class still can call the private method
 * but get a warning when calling it
 */
@interface HPTIndicatorChainOperation(private)
- (void)scan;
@end


@implementation HPTIndicatorChainOperation
@synthesize dictionary = _dictionary;

- (void)addIndicator:(id<HPTIndicatorProtocol>)indicator{
	if (!_indicators) {
		_indicators = [[NSMutableArray alloc] initWithCapacity:3];
	}
	
	if (_indicators && indicator) {
		[_indicators addObject:indicator];
	}
}

//NSOperation
- (void)main{
	if (_indicators != nil && _dictionary != nil) {
		[_dictionary initSymbols];
		[self scan];
	}
}

@end

#pragma mark -
#pragma mark private methods:

@implementation HPTIndicatorChainOperation(private)

- (void)scan{
	
	
	NSMutableArray *resultSymbols = [[NSMutableArray alloc] initWithCapacity:10];
	NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:1000];
	[temp addObjectsFromArray:[_dictionary getSymbols]];
	for (id<HPTSymbolProtocol> aSymbol in temp) {
		HPTRankSymbol *rankSymbol = [[HPTRankSymbol alloc] init];
		rankSymbol.symbol = aSymbol;
		rankSymbol.rank = HPT_NO_RANK;
		[resultSymbols addObject:rankSymbol];
		[rankSymbol release];
	}
	[temp release];
	
	for (id<HPTIndicatorProtocol> indicator in _indicators) {
		if (indicator && [resultSymbols count]>0) {
			NSMutableArray *tempSymbols = [[NSMutableArray alloc] initWithCapacity:[resultSymbols count]];
			[tempSymbols addObjectsFromArray:resultSymbols];
			[resultSymbols removeAllObjects];
			
			for (HPTRankSymbol *aSymbol in tempSymbols) {
				[indicator setSymbol:aSymbol.symbol];
				[indicator deriveData];
				//NSLog(@"rank on [%@] is %i", aSymbol, [_indicator getRank]);
				if ([indicator getRank] > HPT_NO_RANK) {
					aSymbol.rank = [indicator getRank];
					[resultSymbols addObject:aSymbol];
				}
			}
			
			[tempSymbols release];
		}
	}
	
	for (HPTRankSymbol *aSymbol in resultSymbols) {
		if (aSymbol.rank == HPT_HIGHLY_RANK) {
			NSLog(@"HIGH RANK on [%@]", aSymbol.symbol);
		}
		if (aSymbol.rank == HPT_RECOMMAND_RANK) {
			NSLog(@"RECOMMAND RANK on [%@]", aSymbol.symbol);
		}
		
		
		//NSLog(@"result symbol [%@] with rank %i ", aSymbol.symbol, aSymbol.rank);
	}
	
	[resultSymbols release];
}

@end



