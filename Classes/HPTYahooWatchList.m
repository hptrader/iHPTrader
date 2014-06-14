//
//  HPTYahooWatchList.m
//  iHPTrader
//
//  Created by hugo on 13年6月3日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTYahooWatchList.h"
#import "HPTSymbolProtocol.h"
#import "HPTYahooSymbol.h"


@implementation HPTYahooWatchList

- (id)init{
	self = [super init];
	if (self) {
		prioritySymbols = [[NSMutableArray alloc] init];
		otherSymbols = [[NSMutableArray alloc] init];
		
		//[prioritySymbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"0005"] autorelease]];
		//[prioritySymbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"1800"] autorelease]];
		//[prioritySymbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"6030"] autorelease]];
		[prioritySymbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"3333" withAreaCode:@".HK"]	autorelease]];
		[prioritySymbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"6881" withAreaCode:@".HK"]	autorelease]];
		
	}
	
	return self;
}
		 
- (NSMutableArray *)getPrioritySymbols{
	return prioritySymbols;
}

- (NSMutableArray *)getOtherSymbols{
	return otherSymbols;
}

- (void)dealloc{
	[prioritySymbols release];
	[otherSymbols release];
	[super dealloc];
}

@end
