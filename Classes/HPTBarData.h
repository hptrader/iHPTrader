//
//  HPTBarData.h
//  iHPTrader
//
//  Created by hugo on 13年5月31日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	HPT_Daily,
	HPT_Weekly,
	HPT_Monthly
}HPTTimeframe;


@interface HPTBarData : NSObject <NSCoding>{
	HPTTimeframe timeframeType;
	NSDate *date;
	int time;
	double open;
	double high;
	double low;
	double close;
	long long int volume;
	
	//for analysts
	int numBuy;
	int numOutperform;
	int numHold;
	int numUnderperform;
	int numSell;
	double meanRating;
	double meanRating1m;
	double meanRating2m;
	double meanRating3m;
	
	//NSDateFormatter *df;
	//NSNumberFormatter *nf;
}

@property (nonatomic)HPTTimeframe timeframeType;
@property (nonatomic, copy)NSDate *date;
@property (nonatomic)int time;
@property (nonatomic)double open;
@property (nonatomic)double high;
@property (nonatomic)double low;
@property (nonatomic)double close;
@property (nonatomic)long long int volume;

- (id)initWithDate:(NSDate *)aDate withOpen:(double)openPrice withHigh:(double)highPrice 
		   withLow:(double)lowPrice withClose:(double)closePrice withVolume:(long long int)aVolume;


@end
