//
//  HPTYahooFinanceMarketDataLoader.m
//  iHPTrader
//
//  Created by hugo on 13年6月1日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HPTYahooFinanceMarketDataLoader.h"
#import "HPTSymbolProtocol.h"
#import "HPTBarData.h"

/*
 * a obj-c style on define private methods
 * other class still can call the private method
 * but get a warning when calling it
 */
@interface HPTYahooFinanceMarketDataLoader(private)
- (NSString *)getURLString:(id<HPTSymbolProtocol>)aSymbol withTimeframe:(HPTTimeframe)aTimeframe withFromDate:(NSDate *)fromDate;
- (BOOL)loadSymbolData:(id<HPTSymbolProtocol>)aSymbol withFromDate:(NSDate *)fromDate;
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
- (NSDate *)addDays:(int)days fromDate:(NSDate *)fromDate;
@end


@implementation HPTYahooFinanceMarketDataLoader

@synthesize onlyLoadExisting;

- (id)init{
	self=[super init];
	if (self) {
		_inDF = [[NSDateFormatter alloc] init];
		[_inDF setDateFormat:@"yyyy-MM-dd"];
		_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		_yahoo_URL = [[NSString alloc] initWithString:@"http://ichart.finance.yahoo.com/table.csv?"];
	}
	return self;
}

- (void)dealloc {
	[_watchList release];
	[_dictionary release];
	[_store release];
	[_inDF release];
	[_calendar release];
    [super dealloc];
}


- (NSString *)Yahoo_URL_EOD_Daily_Prefix{
	return _yahoo_URL;
}

- (void)setWatchList:(id <HPTWatchListProtocol>)aWatchList{
	if (aWatchList != _watchList) {
		if (_watchList) {
			[_watchList release];
		}
		_watchList = [aWatchList retain];
	}
	
}

- (void)setDictionary:(HPTDictionary *)aDictionary{
	if (aDictionary != nil && [aDictionary getSymbolType] == HPT_YAHOO_CODE) {
		if (aDictionary != _dictionary) {
			if (_dictionary) {
				[_dictionary release];

			}
			_dictionary = [aDictionary retain];
		}
	}
}

- (void)setStore:(id<HPTMarketDataStoreProtocol>)aStore{
	if (aStore != _store) {
		if (_store) {
			[_store release];
		}
		_store = [aStore retain];
	}
}

- (void)setRealtimeMarketDataLoader:(id)realTimeLoader{
	//to do
}

//NSOperation
- (void)main{
	if (_store != nil && _watchList != nil && _dictionary != nil) {
		[_dictionary initSymbols];
		[self load];
	}

}

- (void)load{
	/*
	 * Possible actions: 1. full load 2. use yahooMDLoader to append from
	 * last+1 3. use currMDLoader to add 4. use currMDLoader to update
	 * 
	 * Mon-Sat (n=1), Sun (n=2): - if not Sun, run currMDLoader; - if
	 * lastbar is null, run 1+3; - if gap > nD, run 2+3; - if gap = nD, run
	 * 3, - else if gap < nD, run 4.
	 */
	
	NSMutableArray *invalidSymbols = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	NSDate *now = [[NSDate alloc] init];
	long long int base=  (long long int) 30 * (long long int) 24 * (long long int) 3600;
	
	//HPTBarData *currBar = nil;
	NSMutableArray *allSymbols = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	[allSymbols addObjectsFromArray:[_watchList getPrioritySymbols]];
	[allSymbols addObjectsFromArray:[_dictionary getSymbols]];
	//[allSymbols addObjectsFromArray:[_watchList getOtherSymbols]];
	for (id<HPTSymbolProtocol> aSymbol in allSymbols) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	    @try{
		//NSLog(@"load symbol %@",[aSymbol getSymbol]);
		BOOL loadHistory = YES;
		BOOL loadCurrent = YES;
		BOOL addCurrent = YES;
		HPTBarData *lastBar = [_store getLastBar:aSymbol];
		NSDate *fromDate = nil;
		if (lastBar != nil && lastBar.date != nil) {
			NSDate *lastDate = lastBar.date;
			NSDate *nowDate = [[NSDate alloc] init];
			int days = [self daysBetweenDate:lastDate andDate:nowDate];
			//NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDateComponents *components = [_calendar components:NSWeekdayCalendarUnit fromDate:nowDate];
			
			int n = 1;
			//if (nowCal.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
			if ([components weekday] == 1){
				n = 2;
				loadCurrent = NO;
			}
			if (days > n) {
				// append from last+1, then add current
				loadHistory = YES;
				addCurrent = YES;
				fromDate = [self addDays:1 fromDate:lastDate];
			} else if (days == n) {
				// add current
				loadHistory = YES;
				addCurrent = YES;
				//if (nowCal.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {
				if ([components weekday] == 7){
					loadHistory = NO;
					loadCurrent = NO;
					addCurrent = NO;
					NSLog(@"today is SATURDAY and days=%i", days);
				}
				//if (nowCal.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
				if ([components weekday] == 1){
					loadHistory = NO;
					loadCurrent = NO;
					addCurrent = NO;
					NSLog(@"today is SUNDAY and days=%i", days);
				}
			} else {
				// update current
				loadHistory = NO;
				addCurrent = NO;
			}
			[nowDate release];
			//[calendar release];
		} else {
			// full load, then add current
			loadHistory = YES;
			addCurrent = YES;
		}
		
		if ([[aSymbol getSymbol] intValue] == 0){
			loadCurrent = NO;
		}
		
		
		if (loadCurrent) {
			//log.info("[" + symbol + "] Load current.");
			//currentBar = rtLoader.getBarSnapshot(symbol);
			//***not implement real time loader
		}
		BOOL loadSuccess = NO;
		BOOL expiredSymbol = NO;
		if (loadHistory) {
			NSLog(@"[ %@ ] load history from %@", [aSymbol getSymbol], fromDate);
			if (self.onlyLoadExisting) {
				if (fromDate) {
					loadSuccess = [self loadSymbolData:aSymbol withFromDate:fromDate];
				}
			}else
				loadSuccess = [self loadSymbolData:aSymbol withFromDate:fromDate];
				//loadSuccess = [self loadSymbolData222:aSymbol withFromDate:fromDate];
			
			lastBar = [_store getLastBar:aSymbol];
			
			if (lastBar != nil) {
				long long int diff = [now timeIntervalSinceDate:lastBar.date];
				if(diff > base)
					expiredSymbol = YES;
			}
			if (!loadSuccess || expiredSymbol) {
				[invalidSymbols addObject:aSymbol];
				[_store removeSymbol:aSymbol];
				if (expiredSymbol) {
					NSLog(@"[ %@ ] expired and not flushed.", [aSymbol getSymbol]);
				}
			}
		}
		/*
		if (loadCurrent) {
			// add/update current
			if (!addCurrent) {
				[_store removeLastBar:aSymbol];
				//store.removeLastBar(symbol);
			}
			if (currentBar != null) {
				boolean isStoreCurrentBar = false;
				if (lastBar == null) {
					isStoreCurrentBar = true;
				}
				else if (lastBar.date != null && currentBar.date != null){
					// TODO: loop until date is not 20090120
					Day currentDay = new Day(currentBar.date);
					Day lastDay = new Day(lastBar.date);
					if (currentDay.isAfter(lastDay)) {
						isStoreCurrentBar = true;
					}
				}
				if (isStoreCurrentBar) {
					store.getBars(symbol).put(currentBar.date, currentBar);
				}
				else {
					log.warn("[" + symbol + "] Current bar not stored.");
				}
			} else {
				log.warn("[" + symbol + "] No current bar data stored.");
			}
		}
		*/ 
		if (loadSuccess && !expiredSymbol)
			[_store flushSymbol:aSymbol];
		}@catch (NSException *error) {
			NSLog(@"catch exception %@=%@", [error name], [error reason]);
		}
		[pool drain];
	}
	NSLog(@"end of load");
	[now release];
	
	for (id<HPTSymbolProtocol> invalidSymbol in invalidSymbols) {
		[_dictionary removeSymbol:invalidSymbol];
		[_store removeSymbol:invalidSymbol];
	}
}


@end

#pragma mark -
#pragma mark private methods:

@implementation HPTYahooFinanceMarketDataLoader(private)

- (NSString *)getURLString:(id<HPTSymbolProtocol>)aSymbol withTimeframe:(HPTTimeframe)aTimeframe withFromDate:(NSDate *)fromDate{
	
	NSString *g = nil;
	switch (aTimeframe) {
		case HPT_Daily:
			g = @"d";
			break;
		case HPT_Weekly:
			g = @"w";
			break;
		case HPT_Monthly:
			g = @"m";
			break;
	}
	// TODO: configuration
	NSString *a = @"0";
	NSString *b = @"1";
	NSString *c = @"2012";
	if (fromDate) {
		/*
		Calendar calFrom = Calendar.getInstance();
		calFrom.setTime(from);
		a = Integer.toString(calFrom.get(Calendar.MONTH));
		b = Integer.toString(calFrom.get(Calendar.DAY_OF_MONTH));
		c = Integer.toString(calFrom.get(Calendar.YEAR));
		*/
		NSDateComponents *components = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:fromDate];
		//yahoo use 0~11 as month
		a = [NSString stringWithFormat:@"%i",[components month]-1];
		b = [NSString stringWithFormat:@"%i",[components day]];
		c = [NSString stringWithFormat:@"%i",[components year]];
		//*** shouldn't release an object is not created by [xxx alloc] ***
		//[components1 release];
		
	}
	 
	//Calendar cal = Calendar.getInstance();
	NSDate *nowDate = [[NSDate alloc] init];
	NSDateComponents *components = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:nowDate];
	//StringBuffer urlStringSB = new StringBuffer(YF_URL_EOD_DAILY_PREFIX);
	NSMutableString *urlStringSB = [[NSMutableString alloc] initWithString:self.Yahoo_URL_EOD_Daily_Prefix];
	//urlStringSB.append("s=");
	[urlStringSB appendFormat:@"s="];
	//urlStringSB.append(symbol);
	[urlStringSB appendFormat:@"%@",[aSymbol getSymbol]];
	/*
	if ([[aSymbol getSymbol] intValue]) {
		[urlStringSB appendFormat:@".HK"];
	}
	 */
	if ([aSymbol getAreaCode] != nil) {
		[urlStringSB appendFormat:[aSymbol getAreaCode]];
	}
	/*
	urlStringSB.append("&a=");
	urlStringSB.append(a);
	urlStringSB.append("&b=");
	urlStringSB.append(b);
	urlStringSB.append("&c=");
	urlStringSB.append(c);
	urlStringSB.append("&ignore=.csv");
	urlStringSB.append("&d=");
	urlStringSB.append(cal.get(Calendar.MONTH));
	urlStringSB.append("&e=");
	urlStringSB.append(cal.get(Calendar.DAY_OF_MONTH));
	urlStringSB.append("&f=");
	urlStringSB.append(cal.get(Calendar.YEAR));
	urlStringSB.append("&g=");
	urlStringSB.append(g);
	*/
	[urlStringSB appendFormat:@"&a="];
	[urlStringSB appendFormat:@"%@",a];
	[urlStringSB appendFormat:@"&b="];
	[urlStringSB appendFormat:@"%@",b];
	[urlStringSB appendFormat:@"&c="];
	[urlStringSB appendFormat:@"%@",c];
	[urlStringSB appendFormat:@"&ignore=.csv"];
	[urlStringSB appendFormat:@"&d="];
	[urlStringSB appendFormat:@"%i",[components month]-1];
	[urlStringSB appendFormat:@"&e="];
	[urlStringSB appendFormat:@"%i",[components day]];
	[urlStringSB appendFormat:@"&f="];
	[urlStringSB appendFormat:@"%i",[components year]];
	[urlStringSB appendFormat:@"&g="];
	[urlStringSB appendFormat:@"%@",g];
	NSString *finalURL = [NSString stringWithString:urlStringSB];
	[urlStringSB release];
	[nowDate release];
	return finalURL;
}

- (BOOL)loadSymbolData:(id<HPTSymbolProtocol>)aSymbol withFromDate:(NSDate *)fromDate{
	BOOL isSuccess = NO;
	//[[NSURLCache sharedURLCache] removeAllCachedResponses];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSURLRequest *urlRequest = nil;
	@try{
		NSString *urlString = [self getURLString:aSymbol withTimeframe:HPT_Daily withFromDate:fromDate];
		NSLog(@"url  = %@", urlString);
		NSURL *url = [NSURL	URLWithString:urlString];
		urlRequest = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5*60];
		NSURLResponse *urlResponse = nil;
		NSData *urlData = nil;
		NSError *urlError = nil;
		urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&urlError];
		if (urlError != nil) {
			NSLog(@"url error=%@", [urlError description]);
		} else {
			NSString *urlStringData = nil;
			urlStringData = [NSString stringWithCString:[urlData bytes] encoding:NSUTF8StringEncoding];
			//NSLog(@"url data = %@", urlStringData);
			//NSLog(@"*****************************************************************");
			NSRange htmlStringFlag = [urlStringData rangeOfString:@"html"];
			if (htmlStringFlag.location == NSNotFound || htmlStringFlag.location > 220){
				NSArray *lineArray = [urlStringData componentsSeparatedByString:@"\n"];
				if ([lineArray count]>1) {
					BOOL breakAfterInvalidData = NO;
					for (int i=1; i<[lineArray count]-1; i++) {
						NSString *lineString = [lineArray objectAtIndex:i];
						if ([lineString length]>20 && [lineString length]<65) {
							HPTBarData *bar = [[HPTBarData alloc] init];
							//NSLog(@"line %i = %@",i,[lineArray objectAtIndex:i]);
							NSCharacterSet *st = [NSCharacterSet characterSetWithCharactersInString:@","];
							NSScanner *scanner = [[NSScanner alloc] initWithString:lineString];
							NSString *dateString=nil, *openString=nil, *highString=nil, *lowString=nil, *closeString=nil, *volumeString=nil, *adjString=nil;
							[scanner scanUpToCharactersFromSet:st intoString:&dateString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToCharactersFromSet:st intoString:&openString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToCharactersFromSet:st intoString:&highString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToCharactersFromSet:st intoString:&lowString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToCharactersFromSet:st intoString:&closeString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToCharactersFromSet:st intoString:&volumeString];
							[scanner scanString:@"," intoString:NULL];
							[scanner scanUpToString:@"\n" intoString:&adjString];
							//NSLog(@"date=%@",dateString);
							//NSLog(@"open=%@",openString);
							//NSLog(@"high=%@",highString);
							//NSLog(@"low=%@",lowString);
							//NSLog(@"close=%@",closeString);
							//NSLog(@"volume=%@",volumeString);
							//NSLog(@"adj=%@",adjString);
							bar.date = [_inDF dateFromString:dateString];
							if (bar.date == nil) {
								breakAfterInvalidData = YES;
								//NSLog(@"null datestring=%@",dateString);
								//NSLog(@"line %i = %@",i,[lineArray objectAtIndex:i]);
							}
							bar.open = [openString doubleValue];
							bar.high = [highString doubleValue];
							bar.low = [lowString doubleValue];
							bar.close = [closeString doubleValue];
							double adjClose = [adjString doubleValue];
							if (adjClose != 0.0) {
								bar.open *= adjClose/bar.close;
								bar.high *= adjClose/bar.close;
								bar.low *= adjClose/bar.close;
								bar.close *=adjClose/bar.close;
							}
							bar.volume = [volumeString longLongValue];
						
							//NSLog(@"%@",bar);
							if (!breakAfterInvalidData){ 
								if (bar.open == bar.high && bar.open == bar.low && bar.open == bar.close && bar.volume == 0) {
									//NSLog(@"ignore bar= %@",bar);
								}else {
									[_store addOrUpdate:aSymbol withBarData:bar];
								}
							}else {
								//NSLog(@"***invalid data***");
							}

							[bar release];
							[scanner release];
						}
					}
					isSuccess = YES;
				}
			}
		}
		
	}@catch (NSException *error) {
		NSLog(@"catch exception %@=%@", [error name], [error reason]);
	}
	if (urlRequest != nil) {
		[urlRequest release];
	}
	[pool drain];
	[NSThread sleepForTimeInterval:0.2f];
	
	return isSuccess;
}

//test purpose
- (BOOL)loadSymbolData222:(id<HPTSymbolProtocol>)aSymbol withFromDate:(NSDate *)fromDate{
	BOOL isSuccess = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"symbo [%@] retain count = %i",[aSymbol getSymbol], [aSymbol retainCount]);
	NSDate *initDate = [_inDF dateFromString:@"2012-01-01"];
	for (int i=0; i<2000; i++) {
		//NSDate	*initDate = [[NSDate alloc] init];
		NSDate *newDate = [self addDays:i fromDate:initDate];
		HPTBarData *bar = [[HPTBarData alloc] init];
		bar.date = newDate;
		bar.open = 100.00;
		bar.high = 100.00;
		bar.low	= 100.00;
		bar.close = 100.00;
		bar.volume = 123456789;
		//NSLog(@"bar111 bar=%@ retaincount=%i date=%@ retaincount=%i",bar, [bar retainCount], bar.date, [bar.date retainCount]);
		[_store addOrUpdate:aSymbol withBarData:bar];
		//int dayDiff = [self daysBetweenDate:initDate andDate:bar.date];
		//NSLog(@"bar222 dayDiff=%i %@, %@ ",dayDiff, initDate, bar.date);
		//NSDate *tempDate = bar.date;
		//NSLog(@"bar222 bar=%@ retaincount=%i date=%@ retaincount=%i",bar, [bar retainCount], bar.date, [bar.date retainCount]);
		[bar release];
		//[initDate release];
		//NSLog(@"bar333 date=%@ retaincount=%i",tempDate, [tempDate retainCount]);
		//NSLog(@"bar333 bar=%@ retaincount=%i date=%@ retaincount=%i",bar, [bar retainCount], bar.date, [bar.date retainCount]);
	}
	[pool drain];
	return isSuccess;
}

- (int)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    int days = -1;
	NSDate *fromDate=nil;
    NSDate *toDate=nil;
	
	if (fromDateTime != nil && toDateTime != nil) {
		
		[_calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
				 interval:NULL forDate:fromDateTime];
		[_calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
				 interval:NULL forDate:toDateTime];
	
		NSDateComponents *difference = [_calendar components:NSDayCalendarUnit
											   fromDate:fromDate toDate:toDate options:0];
	
		days = [difference day];
	}
    return days;
}

- (NSDate *)addDays:(int)days fromDate:(NSDate *)fromDate{
	NSDate *roundDate = nil;
	NSDate *resultDate = nil;
	
	
	if (days >= 0 && fromDate != nil) {
		
		[_calendar rangeOfUnit:NSDayCalendarUnit startDate:&roundDate interval:NULL forDate:fromDate];
		NSDateComponents *dayAfter = [[NSDateComponents alloc] init];
		[dayAfter setDay:days];
		resultDate = [_calendar dateByAddingComponents:dayAfter toDate:roundDate options:0];
		[dayAfter release];
	}
	return resultDate;
}


@end

