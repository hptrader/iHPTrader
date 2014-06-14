//
//  HPTBarData.m
//  iHPTrader
//
//  Created by hugo on 13年5月31日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTBarData.h"

@implementation HPTBarData
@synthesize timeframeType;
@synthesize date;
@synthesize time;
@synthesize open;
@synthesize high;
@synthesize low;
@synthesize close;
@synthesize volume;


- (id)init{
	self=[super init];
	if (self) {
		self.timeframeType = HPT_Daily;
		//df = [[NSDateFormatter alloc] init];
		//[df setDateFormat:@"yyyyMMdd"];
		
		//nf = [[NSNumberFormatter alloc] init];
		//[nf setFormatWidth:6];
		//[nf setPaddingCharacter:@"0"];
	}
	return self;
}

- (void)dealloc {
	[date release];
	[super dealloc];
}

- (id)initWithDate:(NSDate *)aDate withOpen:(double)openPrice withHigh:(double)highPrice withLow:(double)lowPrice 
		 withClose:(double)closePrice withVolume:(long long int)aVolume{
	self=[super init];
	if (self) {
		self.timeframeType = HPT_Daily;
		self.date = aDate;
		self.open = openPrice;
		self.high = highPrice;
		self.low = lowPrice;
		self.close = closePrice;
		self.volume = aVolume;
		//df = [[NSDateFormatter alloc] init];
		//[df setDateFormat:@"yyyyMMdd"];
		
		//nf = [[NSNumberFormatter alloc] init];
		//[nf setFormatWidth:6];
		//[nf setPaddingCharacter:@"0"];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	self=[super init];
	if (self) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyyMMdd"];
		self.timeframeType = [aDecoder decodeIntForKey:@"HPT_timeframeType"];
		self.date = [df dateFromString:[aDecoder decodeObjectForKey:@"HPT_date"]];
		[df release];
		self.open = [aDecoder decodeDoubleForKey:@"HPT_open"];
		self.high = [aDecoder decodeDoubleForKey:@"HPT_high"];
		self.low = [aDecoder decodeDoubleForKey:@"HPT_low"];
		self.close = [aDecoder decodeDoubleForKey:@"HPT_close"];
		self.volume = [aDecoder decodeInt64ForKey:@"HPT_volume"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyyMMdd"];
	
	[aCoder encodeInt:self.timeframeType forKey:@"HPT_timeframeType"];
	[aCoder encodeObject:[df stringFromDate:self.date] forKey:@"HPT_date"];
	[df release];
	[aCoder encodeDouble:self.open forKey:@"HPT_open"];
	[aCoder encodeDouble:self.high forKey:@"HPT_high"];
	[aCoder encodeDouble:self.low forKey:@"HPT_low"];
	[aCoder encodeDouble:self.close forKey:@"HPT_close"];
	[aCoder encodeInt64:self.volume forKey:@"HPT_volume"];
}

//stringWithFormat: returns an autoreleased string; initWithFormat: 
//returns a string that must be released by the caller. 
//The former is a so-called "convenience" method that is useful for short-lived strings,
//so the caller doesn't have to remember to call release.
- (NSString *)description{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyyMMdd"];
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setFormatWidth:6];
	[nf setPaddingCharacter:@"0"];
	
	NSString *desc = [NSString stringWithFormat:@"BarData {Type= %i, date=%@, open=%g, high=%g, low=%g, close=%g, volume=%lli, time=%@}",
					  self.timeframeType, [df stringFromDate:self.date], self.open, self.high, self.low, self.close, self.volume, [nf stringFromNumber:[NSNumber numberWithInt:self.time]]];
	[df release];
	[nf release];
	return desc;
}
	  
@end