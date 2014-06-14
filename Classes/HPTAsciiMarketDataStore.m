//
//  HPTAsciiMarketDataStore.m
//  iHPTrader
//
//  Created by hugo on 13年6月9日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTAsciiMarketDataStore.h"

/*
 a obj-c style on define private methods
 other class still can call the private method
 but get a warning when calling it
*/
@interface HPTAsciiMarketDataStore(private)
- (NSString *)getFilename:(NSString *)aSymbolString;
- (NSString *)serialize:(HPTBarData *)aBar;
- (HPTBarData *)deserialize:(NSString *)aDataline;
- (void)flush:(NSString *)aSymbolString withBars:(NSDictionary *)bars;
- (HPTBarData *)getLastBarFromFile:(NSString *)aSymbolString;
@end

@implementation HPTAsciiMarketDataStore
@synthesize asciiDirectory = _asciiDirectory;

- (id)init{
	self = [super init];
	if(self){
		_outDF1 = [[NSDateFormatter alloc] init];
		[_outDF1 setDateFormat:@"yyyyMMdd"];
	}
	return self;
}

- (void)dealloc{
	[_asciiDirectory release];
	[_outDF1 release];
	[super dealloc];
}

- (void)flushSymbol:(id <HPTSymbolProtocol>)aSymbol{
	if (_data) {
		NSMutableDictionary *bars = [self getBars:aSymbol];
		if ([bars count]>0) {
			[self flush:[aSymbol getSymbol] withBars:bars];
		}
	}
	[super flushSymbol:aSymbol];
}

- (void)loadSymbol:(id <HPTSymbolProtocol>)aSymbol{
	if ([[super getBars:aSymbol] count] == 0) {
		NSString *asciiFilename = [self getFilename:[aSymbol getSymbol]];
		NSError *fileError = nil;
		NSString *dataString = [NSString stringWithContentsOfFile:asciiFilename encoding:NSASCIIStringEncoding error:&fileError];
		if (fileError) {
			//NSLog(@"error in loadSymbol : %@ error:%@", [aSymbol getSymbol], [fileError localizedDescription]);
		}else {
			NSArray *lineArray = [dataString componentsSeparatedByString:@"\n"];
			if ([lineArray count]>0) {
				//NSLog(@"linearry size=%i",[lineArray count]);
				for (NSString *lineString in lineArray) {
					if([lineString length] > 10){ 
						HPTBarData *bar = [self deserialize:lineString];
						[super addOrUpdate:aSymbol withBarData:bar];
					}
				}
			}
		}
	}
}

- (NSMutableDictionary *)getBars:(id <HPTSymbolProtocol>)aSymbol{
	return [super getBars:aSymbol];
}

- (HPTBarData *)getLastBar:(id <HPTSymbolProtocol>)aSymbol{
	HPTBarData *bar = [super getLastBar:aSymbol];
	if(bar == nil){
		// check from persistence store
		bar = [self getLastBarFromFile:[aSymbol getSymbol]];
	}
	return bar;
}


@end

#pragma mark -
#pragma mark private methods:
@implementation HPTAsciiMarketDataStore(private)
- (NSString *)getFilename:(NSString *)aSymbolString{
	NSString *filename = nil;
	if (self.asciiDirectory) {
		filename = [NSString stringWithFormat:@"%@/%@_D.txt",self.asciiDirectory, aSymbolString];
	}
	return filename;

}

- (NSString *)serialize:(HPTBarData *)aBar{
	NSString *asciiDataline = [NSString stringWithFormat:@"%@ %g %g %g %g %lli \r\n",
							   [_outDF1 stringFromDate:aBar.date], aBar.open, aBar.high, aBar.low, aBar.close, aBar.volume];
	return asciiDataline;
}

- (HPTBarData *)deserialize:(NSString *)aDataline{
	HPTBarData *bar = [[[HPTBarData alloc] init] autorelease];
	if (aDataline != nil && ![aDataline isEqualToString:@""]) {
		NSCharacterSet *st = [NSCharacterSet characterSetWithCharactersInString:@" "];
		NSScanner *scanner = [NSScanner scannerWithString:aDataline];
		NSString *dateString, *openString, *highString, *lowString, *closeString, *volumeString;
		[scanner scanUpToCharactersFromSet:st intoString:&dateString];
		[scanner scanString:@" " intoString:NULL];
		[scanner scanUpToCharactersFromSet:st intoString:&openString];
		[scanner scanString:@" " intoString:NULL];
		[scanner scanUpToCharactersFromSet:st intoString:&highString];
		[scanner scanString:@" " intoString:NULL];
		[scanner scanUpToCharactersFromSet:st intoString:&lowString];
		[scanner scanString:@" " intoString:NULL];
		[scanner scanUpToCharactersFromSet:st intoString:&closeString];
		[scanner scanString:@" " intoString:NULL];
		[scanner scanUpToCharactersFromSet:st intoString:&volumeString];
		//NSLog(@"date=%@",dateString);
		//NSLog(@"open=%@",openString);
		//NSLog(@"high=%@",highString);
		//NSLog(@"low=%@",lowString);
		//NSLog(@"close=%@",closeString);
		//NSLog(@"volume=%@",volumeString);
		bar.date = [_outDF1 dateFromString:dateString];
		bar.open = [openString doubleValue];
		bar.high = [highString doubleValue];
		bar.low = [lowString doubleValue];
		bar.close = [closeString doubleValue];
		bar.volume = [volumeString longLongValue];
	}
	return bar;
}

- (void)flush:(NSString *)aSymbolString withBars:(NSDictionary *)bars{
	if (_asciiDirectory) {
		HPTBarData *lastBarFile = [self getLastBarFromFile:aSymbolString];
		if (lastBarFile != nil) {
			NSString *asciiFilename = [self getFilename:aSymbolString];
			HPTBarData *firstBar = nil;
			NSMutableString *dataString = [[NSMutableString alloc] initWithString:@""];
			if ([bars count] > 0) {
				NSArray *keys = [bars allKeys];
				NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
				firstBar = [bars objectForKey:[sortedKeys objectAtIndex:0]];
				for (NSDate *date in sortedKeys) {
					if (date) {
						HPTBarData *bar = [bars objectForKey:date];
						[dataString appendString:[self serialize:bar]];
					}
				}
				//NSError *fileError = nil;
				if ([firstBar.date compare:lastBarFile.date] == NSOrderedDescending) {
					NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:asciiFilename];
					[fileHandle seekToEndOfFile];
					[fileHandle writeData:[dataString dataUsingEncoding:NSASCIIStringEncoding]];
					[fileHandle closeFile];
				}
			}
			[dataString release];
			
		}else {
			NSString *asciiFilename = [self getFilename:aSymbolString];
			NSMutableString *dataString = [[NSMutableString alloc] initWithString:@""];
			if ([bars count] > 0) {
				NSArray *keys = [bars allKeys];
				NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
				for (NSDate *date in sortedKeys) {
					if (date) {
						HPTBarData *bar = [bars objectForKey:date];
						[dataString appendString:[self serialize:bar]];
					}
				}
				NSError *fileError = nil;
				[dataString writeToFile:asciiFilename atomically:YES encoding:NSASCIIStringEncoding error:&fileError];
				if (fileError) {
					NSLog(@"error in flush:%@",[fileError localizedDescription]);
				}
			
			}
			[dataString release];
		}
	}
}

- (HPTBarData *)getLastBarFromFile:(NSString *)aSymbolString{
	HPTBarData *bar = nil;
	if(aSymbolString != nil){
		// check from persistence store
		NSString *asciiFilename = [self getFilename:aSymbolString];
		if ([[NSFileManager defaultManager] fileExistsAtPath:asciiFilename]){ 		
			NSError *fileError = nil;
			NSString *dataString = [NSString stringWithContentsOfFile:asciiFilename encoding:NSASCIIStringEncoding error:&fileError];
			if (fileError) {
				NSLog(@"error in loadSymbol : %@ error:%@", aSymbolString, [fileError localizedDescription]);
			}else {
				NSArray *lineArray = [dataString componentsSeparatedByString:@"\n"];
				if ([lineArray count] > 0) {
					NSString *lineString = [lineArray objectAtIndex:[lineArray count]-1];
					if([lineString length] > 10){ 
						bar = [self deserialize:lineString];
					}else {
						bar = [self deserialize:[lineArray objectAtIndex:[lineArray count]-2]];
					}
					
				}
			}
		}
	}
	return bar;
}


@end
