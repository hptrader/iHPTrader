//
//  HPTYahooSymbol.m
//  iHPTrader
//
//  Created by hugo on 13年5月28日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTYahooSymbol.h"


@implementation HPTYahooSymbol

- (id)initWithString:(NSString *)symbol withAreaCode:(NSString *)areaCode{
	self = [super init];
	if (self) {
		_symbolString = [symbol copy];
		_areaCode = [areaCode copy];
	}
	return self;
}

- (void)dealloc{
	[_symbolString release];
	_symbolString = nil;
	[_areaCode release];
	_areaCode = nil;
	[super dealloc];
}


- (NSString *)getSymbol{
	return	_symbolString;
}

- (NSString *)getAreaCode{
	return _areaCode;
}


- (HPTSymbolType)getType{
	return HPT_YAHOO_CODE;
}

//***required for HPTYahooSymbol to store in NSDictionary as KEY***
- (BOOL)isEqual:(id)object{
	if (self == object) {
		return YES;
	}else {
		//if ([object isKindOfClass:[HPTYahooSymbol class]]) {
			if ([[(HPTYahooSymbol *)object getSymbol] isEqual:[self getSymbol]]) {
				return YES;
			}
		//}
	}
	return NO;
}

//***required for HPTYahooSymbol to store in NSDictionary as KEY***
- (NSUInteger)hash{
	return [_symbolString hash];
}

//same as toString() in java
- (NSString *)description{
	return [self getSymbol];
}

//***required for HPTYahooSymbol to store in NSDictionary as KEY***
- (id)copyWithZone:(NSZone *)zone{
	HPTYahooSymbol *newSymbol = [[[self class] allocWithZone:zone] initWithString:[self getSymbol] withAreaCode:[self getAreaCode]];	
	return newSymbol;
}



@end
