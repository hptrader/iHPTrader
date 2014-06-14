//
//  HPTInMemoryMarketDataStore.m
//  iHPTrader
//
//  Created by hugo on 13年6月8日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTInMemoryMarketDataStore.h"


@implementation HPTInMemoryMarketDataStore

- (id)init{
	self = [super init];
	if(self){
		_data = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc{
	[_data release];
	[super dealloc];
}

//return YES if aSymbol is included in the _dada (NSMutableDictionary)
- (BOOL)isContainsSymbol:(id<HPTSymbolProtocol>)aSymbol{
	NSMutableDictionary *symbolData = [_data objectForKey:aSymbol];
	if (symbolData != nil) {
		//NSLog(@"isContainsSymbol, retain count=%i",[symbolData retainCount]);
		return YES;
	}else {
		return NO;
	}
}

//if aSymbol is not included in the _data (NSMutableDictionary)
//create a new (NSMutableDictionary) for the aSymbol
- (NSMutableDictionary *)getBars:(id<HPTSymbolProtocol>)aSymbol{
	NSMutableDictionary *symbolData = [_data objectForKey:aSymbol];
	if (symbolData == nil) {
		//NSLog(@"create a empty NSDic");
		NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
		[_data setObject:newDic forKey:aSymbol];
		[newDic release];
		
	}
	return [_data objectForKey:aSymbol];
}

//
- (void)flushSymbol:(id<HPTSymbolProtocol>)aSymbol{
	//debug purpose
	/*
	NSMutableDictionary *bars = [self getBars:aSymbol];
	NSLog(@"in flush %@ bar size=%i, bar reatin = %i",[aSymbol getSymbol], [bars count], [bars retainCount]);
	NSArray *keys = [bars allKeys];
	id tempKey = [keys objectAtIndex:0];
	_testDate = &tempKey;
	for (id key in keys) {
		id bar = [bars objectForKey:key];
		NSLog(@"in flush %@ bar=%@, reatin = %i, key=%@, reatin = %i",[aSymbol getSymbol], bar, [bar retainCount], key, [key retainCount]);
	}
	*/
	//NSLog(@"_data count b4 flush=%i", [_data count]);
	[_data removeObjectForKey:aSymbol];
	//NSLog(@"in flush %@ key=%@, reatin = %i",[aSymbol getSymbol], tempKey, [tempKey retainCount]);
	//NSLog(@"_data count %i", [_data count]);
}

//
- (void)flushAll{	
	[_data removeAllObjects];
}

- (HPTBarData *)getFirstBar:(id<HPTSymbolProtocol>)aSymbol{
	HPTBarData *firstBar = nil;
	if ([self isContainsSymbol:aSymbol]) {
		NSMutableDictionary *bars = [self getBars:aSymbol];
		if ([bars count] > 0) {
			NSArray *keys = [bars allKeys];
			NSArray *sorted = [keys sortedArrayUsingSelector:@selector(compare:)];
			firstBar = [bars objectForKey:[sorted objectAtIndex:0]];
		}
		
	}
	return firstBar;	
}

- (HPTBarData *)getLastBar:(id<HPTSymbolProtocol>)aSymbol{
	HPTBarData *lastBar = nil;
	if ([self isContainsSymbol:aSymbol]) {
		NSMutableDictionary *bars = [self getBars:aSymbol];
		if ([bars count] > 0) {
			NSArray *keys = [bars allKeys];
			NSArray *sorted = [keys sortedArrayUsingSelector:@selector(compare:)];
			lastBar = [bars objectForKey:[sorted objectAtIndex:[keys count]-1]];
			if (keys == sorted) {
				NSLog(@"same array");
			}
		}
		
	}
	return lastBar;	
}

- (void)addOrUpdate:(id<HPTSymbolProtocol>)aSymbol withBarData:(HPTBarData *)aBar{
	
	if (aBar) {
		//NSLog(@"bar in [ %@ ], %@",[aSymbol getSymbol], aBar);
		NSMutableDictionary *bars = [self getBars:aSymbol];
		if (bars == nil) {
			NSLog(@"nil bars in [ %@ ] addorupdate",[aSymbol getSymbol]);
		}
		if ([bars count] == 0) {
			//NSLog(@"zero bars in [ %@ ] addorupdate, retaincount=%i",[aSymbol getSymbol], [bars retainCount]);
			//oldBar = [bars objectForKey:aBar.date];
		}
		if ([bars count] > 0) {
			//NSLog(@"has bars in [ %@ ] addorupdate size=%i, retaincount=%i",[aSymbol getSymbol], [bars count],[bars retainCount] );
			//oldBar = [bars objectForKey:aBar.date];
		}
		if (aBar.date == nil) {
			NSLog(@"nil date in [ %@ ], %@",[aSymbol getSymbol], aBar);
		}else
			[bars setObject:aBar forKey:aBar.date];
	}
}

- (void)append:(id<HPTSymbolProtocol>)aSymbol withBarDatas:(NSDictionary *)bars{
	if (bars) {
		NSMutableDictionary *currentBars = [self getBars:aSymbol];
		if ([bars count] > 0) {
			NSArray *keys = [bars allKeys];
			for (NSDate *date in keys) {
				[currentBars setObject:[bars objectForKey:date] forKey:date];
			}
		}
	}
}

- (void)removeLastBar:(id<HPTSymbolProtocol>)aSymbol{
	if ([self isContainsSymbol:aSymbol]) {
		HPTBarData *lastBar = [self getLastBar:aSymbol];
		NSMutableDictionary *bars = [self getBars:aSymbol];
		[bars removeObjectForKey:lastBar.date];
	}
}

- (void)removeSymbol:(id<HPTSymbolProtocol>)aSymbol{
	[_data removeObjectForKey:aSymbol];
}

- (void)loadSymbol:(id<HPTSymbolProtocol>)aSymbol{
	//for file system subclass
}

- (void)loadAll{
	NSArray *symbols = [_data allKeys];
	if (symbols != nil && [symbols count]>0) {
		for (id<HPTSymbolProtocol> symbol in symbols) {
			[self loadSymbol:symbol];
		}
	}
}

- (void)unloadSymbol:(id<HPTSymbolProtocol>)aSymbol{
	[_data removeObjectForKey:aSymbol];
}

- (void)unloadAll{
	[_data removeAllObjects];
}

- (NSDate **)getTestDate{
	return _testDate;
}


//for test purpose
- (void)loadTestData:(id<HPTSymbolProtocol>)aSymbol{
	if (aSymbol) {
		NSMutableDictionary *testData = [[NSMutableDictionary alloc] initWithCapacity:5];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd"];
		NSDate *date1 = [df dateFromString:@"2013-05-01"];
		HPTBarData *bar1 = [[HPTBarData alloc] initWithDate:date1 withOpen:100.00 withHigh:102.00 withLow:99.99 withClose:100.00 withVolume:123456789];
		NSDate *date2 = [df dateFromString:@"2013-05-02"];
		HPTBarData *bar2 = [[HPTBarData alloc] initWithDate:date2 withOpen:101.00 withHigh:102.00 withLow:99.99 withClose:101.00 withVolume:123456789];
		NSDate *date3 = [df dateFromString:@"2013-05-03"];
		HPTBarData *bar3 = [[HPTBarData alloc] initWithDate:date3 withOpen:102.00 withHigh:103.00 withLow:99.99 withClose:102.00 withVolume:123456789];
		NSDate *date4 = [df dateFromString:@"2013-05-04"];
		HPTBarData *bar4 = [[HPTBarData alloc] initWithDate:date4 withOpen:103.00 withHigh:104.00 withLow:99.99 withClose:103.00 withVolume:123456789];
		NSDate *date5 = [df dateFromString:@"2013-05-05"];
		HPTBarData *bar5 = [[HPTBarData alloc] initWithDate:date5 withOpen:104.00 withHigh:105.00 withLow:99.99 withClose:104.00 withVolume:123456789];
		
		[testData setObject:bar1 forKey:bar1.date];
		[testData setObject:bar2 forKey:bar2.date];
		[testData setObject:bar3 forKey:bar3.date];
		[testData setObject:bar4 forKey:bar4.date];
		[testData setObject:bar5 forKey:bar5.date];
		
		if (_data) {
			NSLog(@"in loadTestData, _data is init");
		}
		//[_data setObject:testData forKey:[aSymbol getSymbol]];
		[self append:aSymbol withBarDatas:testData];
		NSLog(@"loadtestData, retain count1111=%i", [bar5 retainCount]);
		[self append:aSymbol withBarDatas:testData];
		[testData release];
		NSDate *date6 = [df dateFromString:@"2013-05-01"];
		HPTBarData *bar6 = [[HPTBarData alloc] initWithDate:date6 withOpen:99.00 withHigh:102.00 withLow:99.99 withClose:99.00 withVolume:123456789];
		[self addOrUpdate:aSymbol withBarData:bar6];
		NSLog(@"now data size =%i",[[self getBars:aSymbol] count]);
		[df release];
		[bar1 release];
		[bar2 release];
		[bar3 release];
		[bar4 release];
		NSLog(@"loadtestData, retain count2222=%i", [bar5 retainCount]);
		[bar5 release];
		NSLog(@"loadtestData, retain count3333=%i", [bar5 retainCount]);
		[bar6 release];
	}
}


@end
