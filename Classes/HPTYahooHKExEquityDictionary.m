//
//  HPTYahooHKExEquityDictionary.m
//  iHPTrader
//
//  Created by hugo on 13年6月4日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTYahooHKExEquityDictionary.h"

/*
 * a obj-c style on define private methods
 * other class still can call the private method
 * but get a warning when calling it
 */

@interface HPTYahooHKExEquityDictionary(private) 

- (void)addIndexSymbols:(NSMutableArray *)inSymbols;
- (void)addHKSymbols:(NSMutableArray *)inSymbols;
- (void)addSHSymbols:(NSMutableArray *)inSymbols;
- (void)addUSSymbols:(NSMutableArray *)inSymbols;
- (void)addTestSymbols:(NSMutableArray *)inSymbols;
- (NSString *)getAlphabetLettle:(int)index;

@end


@implementation HPTYahooHKExEquityDictionary

- (void)setStore:(id)aStore{
	//to do
}

- (HPTSymbolType)getSymbolType{
	return	HPT_YAHOO_CODE;
}

- (NSArray *)getSymbols{
	return	symbols;
}

- (void)initSymbols{
	alphabet = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E",
						 @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
						 @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
						 @"X", @"Y", @"Z", nil];
	
	if (symbols != nil) {
		[symbols release];
	}
	symbols = [[NSMutableArray alloc] initWithCapacity:8000];
	/*
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setFormatWidth:4];
	[nf setPaddingCharacter:@"0"];
	for (int i=1; i<7; i++) {
		NSString *symString = [[NSString alloc] initWithString:[nf stringFromNumber:[NSNumber numberWithInt:i]]];
		HPTYahooSymbol *symbol = [[HPTYahooSymbol alloc] initWithString:symString withAreaCode:@".HK"];
		[symbols addObject:symbol];
		[symString release];
		[symbol release];
	}
	[nf release];
	*/
	
	/*
	for (int i=600000; i<602000; i++) {
		NSString *symString = [[NSString alloc] initWithFormat:@"%i",i];
		HPTYahooSymbol *symbol = [[HPTYahooSymbol alloc] initWithString:symString withAreaCode:@".SS"];
		[symbols addObject:symbol];
		[symString release];
		[symbol release];
	}
	*/
	//[self addIndexSymbols:symbols];
	[self addHKSymbols:symbols];
	[self addSHSymbols:symbols];
	//[self addUSSymbols:symbols];
	//[self addTestSymbols:symbols];
	
	
	//symbols.add(new YahooSymbol("^HSI"));
	//symbols.add(new YahooSymbol("^DJI"));
	//symbols.add(new YahooSymbol("^SSEC"));	
	//[symbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"^HSI"] autorelease]];
	//[symbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"^DJI"] autorelease]];
	//[symbols addObject:[[[HPTYahooSymbol alloc] initWithString:@"^SSEC"] autorelease]];
	
}

- (void)removeSymbol:(id<HPTSymbolProtocol>)aSymbol{
	if (symbols) {
		[symbols removeObject:aSymbol];
	}
}

- (void)dealloc{
	[symbols release];
	[super dealloc];
}


@end

#pragma mark -
#pragma mark private methods
@implementation HPTYahooHKExEquityDictionary(private)

- (void)addTestSymbols:(NSMutableArray *)inSymbols{
	if (inSymbols) {
		HPTYahooSymbol *test = [[HPTYahooSymbol alloc] initWithString:@"3333" withAreaCode:@".HK"];
		[inSymbols addObject:test];
		[test release];
	}


}

- (void)addIndexSymbols:(NSMutableArray *)inSymbols{
	if (inSymbols) {
		HPTYahooSymbol *hsi = [[HPTYahooSymbol alloc] initWithString:@"^HSI" withAreaCode:@""];
		[inSymbols addObject:hsi];
		
		HPTYahooSymbol *dow = [[HPTYahooSymbol alloc] initWithString:@"^DJI" withAreaCode:@""];
		[inSymbols addObject:dow];
		
		HPTYahooSymbol *ssec = [[HPTYahooSymbol alloc] initWithString:@"^SSEC" withAreaCode:@""];
		[inSymbols addObject:ssec];
		
		[hsi release];
		[dow release];
		[ssec release];
	}
}

- (void)addHKSymbols:(NSMutableArray *)inSymbols{
	if (inSymbols) {
		NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
		[nf setFormatWidth:4];
		[nf setPaddingCharacter:@"0"];
		for (int i=1; i<7000; i++) {
			NSString *symString = [[NSString alloc] initWithString:[nf stringFromNumber:[NSNumber numberWithInt:i]]];
			HPTYahooSymbol *symbol = [[HPTYahooSymbol alloc] initWithString:symString withAreaCode:@".HK"];
			[inSymbols addObject:symbol];
			[symString release];
			[symbol release];
		}
		[nf release];
	}
}

- (void)addSHSymbols:(NSMutableArray *)inSymbols{
	if (inSymbols) {
		for (int i=600000; i<602000; i++) {
			NSString *symString = [[NSString alloc] initWithFormat:@"%i",i];
			HPTYahooSymbol *symbol = [[HPTYahooSymbol alloc] initWithString:symString withAreaCode:@".SS"];
			[inSymbols addObject:symbol];
			[symString release];
			[symbol release];
		}
	}
}

- (void)addUSSymbols:(NSMutableArray *)inSymbols{
	if (inSymbols) {
		for (int i=0; i<4; i++) {
			int total_i = pow(26, i+1);
			NSMutableArray *stringIndexArray = [[NSMutableArray alloc] initWithCapacity:i+1];
			for (int i2=0; i2<=i; i2++) {
				[stringIndexArray addObject:[NSNumber numberWithInt:0]];
			}
			
			int j = 1;
			while (j<=total_i) {
				NSMutableString *symbolString = [[NSMutableString alloc] initWithCapacity:i+1];
				for (int i2=0; i2<=i; i2++) {
					int alphabetIndex = [(NSNumber *)[stringIndexArray objectAtIndex:i2] intValue];
					[symbolString appendString:[self getAlphabetLettle:alphabetIndex]];
				}
				//NSLog(@"in addUS1111 i=%i, lettle = %@",i, symbolString);
				BOOL stepUpFlag = NO;
				int temp_i = [(NSNumber *)[stringIndexArray objectAtIndex:i] intValue];
				temp_i++;
				if (temp_i >25) {
					[stringIndexArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
					stepUpFlag = YES;
				}else
					[stringIndexArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:temp_i]];
				
				int temp_j = i-1;
				while (stepUpFlag && temp_j>=0) {
					stepUpFlag = NO;
					int temp_j2 = [(NSNumber *)[stringIndexArray objectAtIndex:temp_j] intValue];
					temp_j2++;
					if (temp_j2 > 25) {
						[stringIndexArray replaceObjectAtIndex:temp_j withObject:[NSNumber numberWithInt:0]];
						stepUpFlag = YES;
					}else{
						[stringIndexArray replaceObjectAtIndex:temp_j withObject:[NSNumber numberWithInt:temp_j2]];
						break;
					}
					temp_j--;
				}
				
				HPTYahooSymbol *symbol = [[HPTYahooSymbol alloc] initWithString:[NSString stringWithString:symbolString] withAreaCode:@""];
				[inSymbols addObject:symbol];
				[symbolString release];
				[symbol release];
				
				j++;
			}
			[stringIndexArray release];
			
		}
	}
}

- (NSString *)getAlphabetLettle:(int)index{
	if (index >= 0 && index <26) {
		return (NSString *)[alphabet objectAtIndex:index];
	}else {
		return nil;
	}
}

@end



