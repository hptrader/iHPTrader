//
//  HPTYahooFinanceMarketDataLoader.h
//  iHPTrader
//
//  Created by hugo on 13年6月1日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTMarketDataLoaderProtocol.h"


@interface HPTYahooFinanceMarketDataLoader : NSOperation <HPTMarketDataLoaderProtocol> {
	
	NSDateFormatter *_inDF;
	NSNumberFormatter *_inNF;
	
	id<HPTWatchListProtocol> _watchList;
	HPTDictionary *_dictionary;
	id<HPTMarketDataStoreProtocol> _store;
	NSString *_yahoo_URL;
	NSCalendar *_calendar;
	id realTimeLoader;
}

@property (readonly, nonatomic)NSString *Yahoo_URL_EOD_Daily_Prefix;
@property (assign, nonatomic)BOOL onlyLoadExisting;




@end
