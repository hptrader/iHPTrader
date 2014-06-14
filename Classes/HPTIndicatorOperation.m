//
//  HPTIndicatorOperation.m
//  iHPTrader
//
//  Created by hugo on 13年6月18日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTIndicatorOperation.h"

/*
 * a obj-c style on define private methods
 * other class still can call the private method
 * but get a warning when calling it
 */
@interface HPTIndicatorOperation(private)
- (void)scan;
@end


@implementation HPTIndicatorOperation
@synthesize indicator = _indicator;
@synthesize dictionary = _dictionary;

//NSOperation
- (void)main{
	if (_indicator != nil && _dictionary != nil) {
		[self scan];
	}
	
}

@end

#pragma mark -
#pragma mark private methods:

@implementation HPTIndicatorOperation(private)

- (void)scan{
	NSMutableArray *allSymbols = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	[allSymbols addObjectsFromArray:[_dictionary getSymbols]];
	for (id<HPTSymbolProtocol> aSymbol in allSymbols) {
		[_indicator setSymbol:aSymbol];
		[_indicator deriveData];
		//NSLog(@"rank on [%@] is %i", aSymbol, [_indicator getRank]);
		if ([_indicator getRank] == HPT_HIGHLY_RANK) {
			NSLog(@"HIGH RANK on [%@]", aSymbol);
		}
		if ([_indicator getRank] == HPT_RECOMMAND_RANK) {
			NSLog(@"RECOMMAND RANK on [%@]", aSymbol);
		}
		
	}
}

@end


