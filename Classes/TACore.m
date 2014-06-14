//
//  TACore.m
//  TA-LibOC
//
//  Created by hugo on 13年5月22日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "TACore.h"


@implementation TACore

//NSNumber is autorelease by default
- (TARetCode)testArray:(NSArray *)inArray withOutArray:(NSMutableArray *)outArray{
	
	for(int i =0; i< [inArray count]; i++){
		NSNumber *arrayVal = [inArray objectAtIndex:i];
		NSNumber *tempVal = [NSNumber numberWithDouble:[arrayVal doubleValue]+2.0f];
		[outArray insertObject:tempVal atIndex:i];
		//[arrayVal release];
		 
	}
	return TASuccess;
}

#pragma mark -
#pragma mark SMA method

- (TARetCode)sma:(int)startIdx withEndIdx:(int)endIdx withInClose:(NSArray *)inReal withOptInTimePeriod:(int)optInTimePeriod 
   withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement withOutSMA:(NSMutableArray *)outReal{
	
	if (startIdx < 0) 
		return TAOutOfRangeStartIndex;
	if (endIdx < 0 || endIdx < startIdx) 
		return TAOutOfRangeEndIndex;
	if (optInTimePeriod < 2 || optInTimePeriod > 100000)
		return TABadParam;
	if (inReal == nil || outReal == nil)
		return TABadParam;
	if ([inReal count] <2)
		return TABadParam;
	
	//code here
	//different from standard TA_Lib, from 0 to outBegIdx-1 a NSNumber with zero value inserted
	//into outReal (in this case, outReal[outNBElement-1] return the last value of SMA)
	double periodTotal, tempReal;
	int i, startIdx2, outIdx, trailingIdx, lookbackTotal;
	startIdx2 = startIdx;
	lookbackTotal = (optInTimePeriod-1);
	if( startIdx2 < lookbackTotal )
		startIdx2 = lookbackTotal;
	if( startIdx2 > endIdx )
	{
		outBegIdx.intValue = 0 ;
		outNBElement.intValue = 0 ;
		return TASuccess;
	}
	periodTotal = 0;
	trailingIdx = startIdx2-lookbackTotal;
	i=trailingIdx;
	if( optInTimePeriod > 1 )
	{
		while( i < startIdx2 ){
			NSNumber *tempNumber = [inReal objectAtIndex:i++];
			periodTotal += [tempNumber doubleValue];
		}
	}
	for(int j=0; j<startIdx2; j++){
		[outReal insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
	}
	outIdx = startIdx2;
	do
	{
		NSNumber *tempNumber = [inReal objectAtIndex:i++];
		periodTotal += [tempNumber doubleValue];
		tempReal = periodTotal;
		NSNumber *tempNumber2 = [inReal objectAtIndex:trailingIdx++];
		periodTotal -= [tempNumber2 doubleValue];
		NSNumber *tempResult = [NSNumber numberWithDouble:tempReal/(double)optInTimePeriod];
		[outReal insertObject:tempResult atIndex:outIdx++];
	} while( i <= endIdx );
	outNBElement.intValue = outIdx;
	outBegIdx.intValue = startIdx2;
	return TASuccess ;
}


#pragma mark full STC method
// (14, 1, 3) -> fast STC    (14, 3, 3) -> slow STC
- (TARetCode)stoch:(int)startIdx withEndIdx:(int)endIdx withInHigh:(NSArray *)inHigh withInLow:(NSArray *)inLow withInClose:(NSArray *)inClose
   withOptInFastKPeriod:(int)optInFastK_Period withOptInSlowKPeriod:(int)optInSlowK_Period withOptInSlowKMAType:(TAMAType)optInSlowK_MAType 
   withOptInSlowDPeriod:(int)optInSlowD_Period withOptInSlowDMAType:(TAMAType)optInSlowD_MAType 
   withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement withOutSlowK:(NSMutableArray *)outSlowK 
   withOutSlowD:(NSMutableArray *)outSlowD{
	
	TARetCode retCode;
	double lowest, highest, tmp, diff;
	//double []tempBuffer ;
	NSMutableArray *tempBuffer;
	int startIdx2, outIdx, lowestIdx, highestIdx;
	int lookbackTotal, lookbackK, lookbackKSlow, lookbackDSlow;
	int trailingIdx, today, i;
	if( startIdx < 0 )
		return TAOutOfRangeStartIndex ;
	if( (endIdx < 0) || (endIdx < startIdx))
		return TAOutOfRangeEndIndex ;
	//if( (int)optInFastK_Period == 1)
		//optInFastK_Period = 5;
	if( ((int)optInFastK_Period < 1) || ((int)optInFastK_Period > 100000) )
		return TABadParam ;
	//if( (int)optInSlowK_Period == 1 )
		//optInSlowK_Period = 3;
	if( ((int)optInSlowK_Period < 1) || ((int)optInSlowK_Period > 100000) )
		return TABadParam ;
	//if( (int)optInSlowD_Period == 1 )
		//optInSlowD_Period = 3;
	if( ((int)optInSlowD_Period < 1) || ((int)optInSlowD_Period > 100000) )
		return TABadParam ;
	
	//in this version, SMA is main focus
	//ema... kma.... will added later
	startIdx2 = startIdx;
	lookbackK = optInFastK_Period-1;
	//lookbackKSlow = movingAverageLookback ( optInSlowK_Period, optInSlowK_MAType );
	lookbackKSlow = [self movingAverageLookback:optInSlowK_Period withOptInMAType:optInSlowK_MAType];
	//lookbackDSlow = movingAverageLookback ( optInSlowD_Period, optInSlowD_MAType );
	lookbackDSlow = [self movingAverageLookback:optInSlowD_Period withOptInMAType:optInSlowD_MAType];
	lookbackTotal = lookbackK + lookbackDSlow + lookbackKSlow;
	if( startIdx2 < lookbackTotal )
		startIdx2 = lookbackTotal;
	if( startIdx2 > endIdx )
	{
		outBegIdx.intValue = 0 ;
		outNBElement.intValue = 0 ;
		return TASuccess;
	}
	outIdx = 0;
	trailingIdx = startIdx2-lookbackTotal;
	today = trailingIdx+lookbackK;
	lowestIdx = highestIdx = -1;
	diff = highest = lowest = 0.0;
	if( (outSlowK == inHigh) ||
	   (outSlowK == inLow) ||
	   (outSlowK == inClose) )
	{
		tempBuffer = outSlowK;
	}
	else if( (outSlowD == inHigh) ||
			(outSlowD == inLow) ||
			(outSlowD == inClose) )
	{
		tempBuffer = outSlowD;
	}
	else
	{
		tempBuffer = [[NSMutableArray alloc] initWithCapacity:endIdx-today+1];
	}
	
	//.....
	for(int j=0; j<today; j++){
		[tempBuffer insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
	}
	outIdx = today;
	
	while( today <= endIdx )
	{
		//tmp = inLow[today];
		tmp = [[inLow objectAtIndex:today] doubleValue];
		if( lowestIdx < trailingIdx )
		{
            lowestIdx = trailingIdx;
            //lowest = inLow[lowestIdx];
			lowest = [[inLow objectAtIndex:lowestIdx] doubleValue];
            i = lowestIdx;
            while( ++i<=today )
            {
				//tmp = inLow[i];
				tmp = [[inLow objectAtIndex:i] doubleValue];
				if( tmp < lowest )
				{
					lowestIdx = i;
					lowest = tmp;
				}
            }
            diff = (highest - lowest)/100.0;
		}
		else if( tmp <= lowest )
		{
            lowestIdx = today;
            lowest = tmp;
            diff = (highest - lowest)/100.0;
		}
		//tmp = inHigh[today];
		tmp = [[inHigh objectAtIndex:today] doubleValue];
		if( highestIdx < trailingIdx )
		{
            highestIdx = trailingIdx;
            //highest = inHigh[highestIdx];
			highest = [[inHigh objectAtIndex:highestIdx] doubleValue];
            i = highestIdx;
            while( ++i<=today )
            {
				//tmp = inHigh[i];
				tmp = [[inHigh objectAtIndex:i] doubleValue];
				if( tmp > highest )
				{
					highestIdx = i;
					highest = tmp;
				}
            }
            diff = (highest - lowest)/100.0;
		}
		else if( tmp >= highest )
		{
            highestIdx = today;
            highest = tmp;
            diff = (highest - lowest)/100.0;
		}
		if( diff != 0.0f ){
            //tempBuffer[outIdx++] = (inClose[today]-lowest)/diff;
			NSNumber *tempDiff = [NSNumber numberWithDouble:([[inClose objectAtIndex:today] doubleValue]-lowest)/diff];
			//NSLog(@"tempBuff %i = %f",outIdx,[tempDiff doubleValue]);
			[tempBuffer insertObject:tempDiff atIndex:outIdx];
			outIdx++;
			
		}else{
            //tempBuffer[outIdx++] = 0.0;
			[tempBuffer insertObject:[NSNumber numberWithDouble:0.0f] atIndex:outIdx];
			outIdx++;
		}
		trailingIdx++;
		today++;
	}
	
	//retCode = movingAverage ( 0, outIdx-1,
							 //tempBuffer, optInSlowK_Period,
							 //optInSlowK_MAType,
							 //outBegIdx, outNBElement, tempBuffer );
	//NSLog(@"current optInSlowK_Period = %i",optInSlowK_Period);
	retCode = [self movingAverage:0 withEndIdx:outIdx-1 withInReal:tempBuffer withOptInTimePeriod:optInSlowK_Period 
					withOptMAType:optInSlowK_MAType withOutBegIdx:outBegIdx withOutNBElement:outNBElement 
					withOutReal:outSlowK];
																 
	if( (retCode != TASuccess ) || ((int) outNBElement.intValue == 0) )
	{
		outBegIdx.intValue = 0 ;
		outNBElement.intValue = 0 ;
		return retCode;
	}
	/*
	retCode = movingAverage ( 0, (int) outNBElement.value -1,
							 tempBuffer, optInSlowD_Period,
							 optInSlowD_MAType,
							 outBegIdx, outNBElement, outSlowD );
	*/
	retCode = [self movingAverage:0 withEndIdx:outNBElement.intValue -1 withInReal:outSlowK withOptInTimePeriod:optInSlowD_Period 
					withOptMAType:optInSlowD_MAType withOutBegIdx:outBegIdx withOutNBElement:outNBElement 
					withOutReal:outSlowD];
	//System.arraycopy(tempBuffer,lookbackDSlow,outSlowK,0,(int)outNBElement.value) ;
	if( retCode != TASuccess )
	{
		outBegIdx.intValue = 0 ;
		outNBElement.intValue = 0 ;
		return retCode;
	}
	outBegIdx.intValue = startIdx2;
	
	return TASuccess;
}

#pragma mark adx (DMI)
- (TARetCode)adx:(int)startIdx withEndIdx:(int)endIdx withInHigh:(NSArray *)inHigh withInLow:(NSArray *)inLow withInClose:(NSArray *)inClose 
	withOptInTimePeriod:(int)optInTimePeriod withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElements:(TAMInteger *)outNBElement 
	   withOutADX:(NSMutableArray *)outADX withOutDIPlus:(NSMutableArray *)outDIPlus withOutDIMinus:(NSMutableArray *)outDIMinus{


	//TARetCode retCode;
	int startIdx2, today, lookbackTotal, outIdx, tailIdx;
	double prevHigh, prevLow, prevClose, todayHigh, todayLow, todayClose;
	double prevTR=0.0f;
	double tempRealTR, tempRealDMP, tempRealDMM, tempRealTRSum, tempRealDMPSum, tempRealDMMSum, tempDIP, tempDIM, diffP, diffM;
	double sumDX, prevADX, todayADX;
	
	if( startIdx < 0 )
		return TAOutOfRangeStartIndex;
	if( (endIdx < 0) || (endIdx < startIdx))
		return TAOutOfRangeStartIndex;
	if (optInTimePeriod < 2 || optInTimePeriod > 10000)
		return TABadParam;
	if (inHigh == nil || inLow == nil || inClose == nil || outADX == nil || outDIPlus == nil || outDIMinus == nil)
		return TABadParam;
	if ([inHigh count] < 20 || [inLow count] < 20 || [inClose count] < 20)
		return TABadParam;
	
	lookbackTotal = (2*optInTimePeriod) -1;
	if( startIdx < lookbackTotal )
		startIdx2 = lookbackTotal;
	else 
		startIdx2 = startIdx;

	if( startIdx2 > endIdx )
	{
		outBegIdx.intValue = 0 ;
		outNBElement.intValue = 0 ;
		return TASuccess;
	}
	
	outIdx = 0;
	outBegIdx.intValue = startIdx2;
	NSMutableArray *tempDMPlus1 = [[NSMutableArray alloc] initWithCapacity:500];
	NSMutableArray *tempDMMinus1 = [[NSMutableArray alloc] initWithCapacity:500];
	NSMutableArray *tempTR1 = [[NSMutableArray alloc] initWithCapacity:500];
    NSMutableArray *tempDMPlusN = [[NSMutableArray alloc] initWithCapacity:500];
	NSMutableArray *tempDMMinusN = [[NSMutableArray alloc] initWithCapacity:500];
	NSMutableArray *tempTRN = [[NSMutableArray alloc] initWithCapacity:500];
    NSMutableArray *tempDX = [[NSMutableArray alloc] initWithCapacity:500];
    
	
	for (int j=0; j<= endIdx; j++) {
		[tempDMPlus1 insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
		[tempDMMinus1 insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
		[tempTR1 insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        [tempDMPlusN insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
		[tempDMMinusN insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
		[tempTRN insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        [tempDX insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        
        [outADX insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        [outDIPlus insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        [outDIMinus insertObject:[NSNumber numberWithDouble:0.0f] atIndex:j];
        
	}
	
	tempRealTRSum = tempRealDMPSum = tempRealDMMSum = sumDX = 0.0f;
	today = startIdx2 - lookbackTotal;
    tailIdx = today;
	
	int i = optInTimePeriod;
    
    //NSLog(@"start while today = %d",today);
    //NSLog(@"start while i = %d", i);
	
	while (i-- > 0) {
        today++;
		prevHigh = [[inHigh objectAtIndex:today-1] doubleValue];
		prevLow = [[inLow objectAtIndex:today-1] doubleValue];
		prevClose = [[inClose objectAtIndex:today-1] doubleValue];
		
		todayHigh = [[inHigh objectAtIndex:today] doubleValue];
		todayLow = [[inLow objectAtIndex:today] doubleValue];
		todayClose = [[inClose objectAtIndex:today] doubleValue];
		
		
		
		tempRealTR = fmax(todayHigh - todayLow, fmax(fabs(todayHigh - prevClose), fabs(todayLow - prevClose)));
		tempRealDMP = todayHigh - prevHigh > prevLow - todayLow ? fmax(todayHigh-prevHigh, 0.0f): 0.0f;
        //NSLog(@"in while tempRealDMP = %f", tempRealDMP);
		tempRealDMM = prevLow - todayLow > todayHigh - prevHigh ? fmax(prevLow - todayLow, 0.0f): 0.0f;
        
        [tempDMPlus1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMP]];
        [tempDMMinus1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMM]];
        [tempTR1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealTR]];
        
        
		
		tempRealTRSum += tempRealTR;
		tempRealDMPSum += tempRealDMP;
		tempRealDMMSum += tempRealDMM;
        
    }
	
	//First TR14 = Sum of first 14 periods of TR1
	//Second TR14 = First TR14 - (First TR14/14) + Current TR1
	//Subsequent Values = Prior TR14 - (Prior TR14/14) + Current TR14
    [tempTRN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealTRSum]];
    [tempDMPlusN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMPSum]];
    [tempDMMinusN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMMSum]];
    tempDIP = (tempRealDMPSum/tempRealTRSum)*100.0f;
    [outDIPlus replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempDIP]];
    tempDIM = (tempRealDMMSum/tempRealTRSum)*100.0f;
    [outDIMinus replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempDIM]];
    
    diffP = fabs(tempDIP-tempDIM);
    diffM = tempDIP+tempDIM;
    [tempDX replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:(diffP/diffM)*100]];
    sumDX += [[tempDX objectAtIndex:today] doubleValue];
    
    i=0;
	while (today < endIdx) {
		today++;
		tailIdx++;
        i++;
        
        prevHigh = [[inHigh objectAtIndex:today-1] doubleValue];
		prevLow = [[inLow objectAtIndex:today-1] doubleValue];
		prevClose = [[inClose objectAtIndex:today-1] doubleValue];
		
		todayHigh = [[inHigh objectAtIndex:today] doubleValue];
		todayLow = [[inLow objectAtIndex:today] doubleValue];
		todayClose = [[inClose objectAtIndex:today] doubleValue];
		
		
		
		tempRealTR = fmax(todayHigh - todayLow, fmax(fabs(todayHigh - prevClose), fabs(todayLow - prevClose)));
		tempRealDMP = todayHigh - prevHigh > prevLow - todayLow ? fmax(todayHigh-prevHigh, 0.0f): 0.0f;
		tempRealDMM = prevLow - todayLow > todayHigh - prevHigh ? fmax(prevLow - todayLow, 0.0f): 0.0f;
        
        [tempDMPlus1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMP]];
        [tempDMMinus1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMM]];
        [tempTR1 replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealTR]];
        
        prevTR = [[tempTRN objectAtIndex:today-1] doubleValue];
        tempRealTRSum = prevTR - prevTR/optInTimePeriod + tempRealTR;
        [tempTRN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealTRSum]];
        
        tempRealDMPSum += tempRealDMP;
        tempRealDMPSum -= [[tempDMPlus1 objectAtIndex:tailIdx] doubleValue];
		tempRealDMMSum += tempRealDMM;
        tempRealDMMSum -= [[tempDMMinus1 objectAtIndex:tailIdx] doubleValue];
        
        [tempDMPlusN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMPSum]];
        [tempDMMinusN replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempRealDMMSum]];
        
       
        tempDIP = (tempRealDMPSum/tempRealTRSum)*100.0f;
        [outDIPlus replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempDIP]];
        tempDIM = (tempRealDMMSum/tempRealTRSum)*100.0f;
        [outDIMinus replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:tempDIM]];
        
        diffP = fabs(tempDIP-tempDIM);
        diffM = tempDIP+tempDIM;
        [tempDX replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:(diffP/diffM)*100]];
        sumDX += [[tempDX objectAtIndex:today] doubleValue];
        
        if (i >= (optInTimePeriod-1)) {
            if (i == (optInTimePeriod -1)) {
                [outADX replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:sumDX/(optInTimePeriod-1)]];
            }else{
                prevADX = [[outADX objectAtIndex:today-1] doubleValue];
                todayADX = [[tempDX objectAtIndex:today] doubleValue];
                [outADX replaceObjectAtIndex:today withObject:[NSNumber numberWithDouble:(prevADX*(optInTimePeriod-1)+todayADX)/optInTimePeriod]];
            }
            
        }
        
	}
    outNBElement.intValue = outIdx;
	
	[tempDMPlus1 release];
    [tempDMPlusN release];
	[tempDMMinus1 release];
    [tempDMMinusN release];
	[tempTR1 release];
    [tempTRN release];
    [tempDX release];
    
    return TASuccess;
}


#pragma mark -
#pragma mark helper method(developer shouldn't call it directly)
#pragma mark movingAverageLookback method
- (int)movingAverageLookback:(int)optInTimePeriod withOptInMAType:(TAMAType)optInMAType{
	int retValue;
	//if( (int)optInTimePeriod == 0 )
		//optInTimePeriod = 30;
	//else 
	if( ((int)optInTimePeriod < 1) || ((int)optInTimePeriod > 100000) )
		return -1;
	if( optInTimePeriod == 1 )
		return 0;
	switch( optInMAType )
	{
		case TASma :
            retValue = [self smaLookback:optInTimePeriod];
			break;
		/*
		case Ema :
            retValue = emaLookback ( optInTimePeriod );
			break;
		case Wma :
            retValue = wmaLookback ( optInTimePeriod );
			break;
		case Dema :
            retValue = demaLookback ( optInTimePeriod );
			break;
		case Tema :
            retValue = temaLookback ( optInTimePeriod );
			break;
		case Trima :
            retValue = trimaLookback ( optInTimePeriod );
			break;
		case Kama :
            retValue = kamaLookback ( optInTimePeriod );
			break;
		case Mama :
            retValue = mamaLookback ( 0.5, 0.05 );
			break;
		case T3 :
            retValue = t3Lookback ( optInTimePeriod, 0.7 );
			break;
		*/
		default:
            retValue = optInTimePeriod - 1;
	}
	return retValue;
}

#pragma mark smaLookback method
- (int)smaLookback:(int)optInTimePeriod{
	//if( (int)optInTimePeriod == 0 )
		//optInTimePeriod = 30;
	//else 
	if( ((int)optInTimePeriod < 2) || ((int)optInTimePeriod > 100000) )
		return -1;
	return optInTimePeriod - 1;
}

#pragma mark movingAverage method
- (TARetCode)movingAverage:(int)startIdx withEndIdx:(int)endIdx withInReal:(NSArray *)inReal withOptInTimePeriod:(int)optInTimePeriod 
   withOptMAType:(TAMAType)optInMAType withOutBegIdx:(TAMInteger *)outBegIdx withOutNBElement:(TAMInteger *)outNBElement 
   withOutReal:(NSMutableArray *)outReal{
	
	//double []dummyBuffer ;
	TARetCode retCode;
	int nbElement;
	int outIdx, todayIdx;
	if( startIdx < 0 )
		return TAOutOfRangeStartIndex ;
	if( (endIdx < 0) || (endIdx < startIdx))
		return TAOutOfRangeEndIndex ;
	//if( (int)optInTimePeriod == ( Integer.MIN_VALUE ) )
		//optInTimePeriod = 30;
	//else 
	if( ((int)optInTimePeriod < 1) || ((int)optInTimePeriod > 100000) )
		return TABadParam ;
	if( optInTimePeriod == 1 )
	{
		nbElement = endIdx-startIdx+1;
		outNBElement.intValue = nbElement;
		if (startIdx >0) {
			for(int j=0; j<startIdx; j++)
				[outReal insertObject:[[NSNumber alloc] initWithDouble:0.0f] atIndex:j];
		}
		for( todayIdx=startIdx, outIdx=startIdx; outIdx < nbElement; outIdx++, todayIdx++ )
            //outReal[outIdx] = inReal[todayIdx];
			[outReal insertObject:[inReal objectAtIndex:todayIdx] atIndex:outIdx];
		outBegIdx.intValue = startIdx;
		return TASuccess ;
	}
	switch( optInMAType )
	{
		case TASma :
            //retCode = sma ( startIdx, endIdx, inReal, optInTimePeriod,
						   //outBegIdx, outNBElement, outReal );
			retCode = [self sma:startIdx withEndIdx:endIdx withInClose:inReal withOptInTimePeriod:optInTimePeriod 
						withOutBegIdx:outBegIdx	withOutNBElement:outNBElement withOutSMA:outReal];
			break;
		/*
		case Ema :
            retCode = ema ( startIdx, endIdx, inReal, optInTimePeriod,
						   outBegIdx, outNBElement, outReal );
			break;
		case Wma :
            retCode = wma ( startIdx, endIdx, inReal, optInTimePeriod,
						   outBegIdx, outNBElement, outReal );
			break;
		case Dema :
            retCode = dema ( startIdx, endIdx, inReal, optInTimePeriod,
							outBegIdx, outNBElement, outReal );
			break;
		case Tema :
            retCode = tema ( startIdx, endIdx, inReal, optInTimePeriod,
							outBegIdx, outNBElement, outReal );
			break;
		case Trima :
            retCode = trima ( startIdx, endIdx, inReal, optInTimePeriod,
							 outBegIdx, outNBElement, outReal );
			break;
		case Kama :
            retCode = kama ( startIdx, endIdx, inReal, optInTimePeriod,
							outBegIdx, outNBElement, outReal );
			break;
		case Mama :
            dummyBuffer = new double[(endIdx-startIdx+1)] ;
			retCode = mama ( startIdx, endIdx, inReal, 0.5, 0.05,
							outBegIdx, outNBElement,
							outReal, dummyBuffer );
			break;
		case T3 :
            retCode = t3 ( startIdx, endIdx, inReal,
						  optInTimePeriod, 0.7,
						  outBegIdx, outNBElement, outReal );
			break;
		*/
		default:
            retCode = TABadParam ;
			break;
	}
	
	return retCode;
}

@end
