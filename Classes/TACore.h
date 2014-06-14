//
//  TACore.h
//  TA-LibOC
//
//  Created by hugo on 13年5月22日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAMInteger.h"
#import "math.h"

typedef enum  {
	TASuccess,
	TABadParam,
	TAOutOfRangeStartIndex,
    TAOutOfRangeEndIndex,
    TAAllocErr,
    TAInternalError
}TARetCode;

typedef enum {
	TASma,
	TAEma,
	TAWma,
	TADema,
	TATema,
	TATrima,
	TAKama,
	TAMama,
	TAT3
}TAMAType;

@interface TACore : NSObject {

}

- (TARetCode)testArray:(NSArray *)inArray withOutArray:(NSMutableArray *)outArray;

- (TARetCode)sma:(int)startIdx withEndIdx:(int)endIdx withInClose:(NSArray *)inReal withOptInTimePeriod:(int)optInTimePeriod 
    withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement withOutSMA:(NSMutableArray *)outReal;

- (TARetCode)stoch:(int)startIdx withEndIdx:(int)endIdx withInHigh:(NSArray *)inHigh withInLow:(NSArray *)inLow withInClose:(NSArray *)inClose
	withOptInFastKPeriod:(int)optInFastK_Period withOptInSlowKPeriod:(int)optInSlowK_Period withOptInSlowKMAType:(TAMAType)optInSlowK_MAType 
	withOptInSlowDPeriod:(int)optInSlowD_Period withOptInSlowDMAType:(TAMAType)optInSlowD_MAType 
	withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement withOutSlowK:(NSMutableArray *)outSlowK 
	withOutSlowD:(NSMutableArray *)outSlowD;


- (int)movingAverageLookback:(int)optInTimePeriod withOptInMAType:(TAMAType)optInMAType;

- (int)smaLookback:(int)optInTimePeriod;

- (TARetCode)movingAverage:(int)startIdx withEndIdx:(int)endIdx withInReal:(NSArray *)inReal withOptInTimePeriod:(int)optInTimePeriod 
	withOptMAType:(TAMAType)optInMAType withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement 
	withOutReal:(NSMutableArray *)outReal;

- (TARetCode)adx:(int)startIdx withEndIdx:(int)endIdx withInHigh:(NSArray *)inHigh withInLow:(NSArray *)inLow withInClose:(NSArray *)inClose
		withOptInTimePeriod:(int)optInTimePeriod withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElements:(TAMInteger *)outNBElement
		withOutADX:(NSMutableArray *)outADX withOutDIPlus:(NSMutableArray *)outDIPlus withOutDIMinus:(NSMutableArray *)outDIMinus;

@end
