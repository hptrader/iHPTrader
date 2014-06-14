//
//  HPTMarketDataLoaderProtocol.h
//  iHPTrader
//
//  Created by hugo on 13年6月1日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTWatchListProtocol.h"
#import "HPTDictionary.h"
#import "HPTMarketDataStoreProtocol.h"


@protocol HPTMarketDataLoaderProtocol

- (void)setWatchList:(id<HPTWatchListProtocol>)aWatchList;
- (void)setDictionary:(HPTDictionary *)aDictionary;
- (void)setStore:(id<HPTMarketDataStoreProtocol>)aStore;
- (void)setRealtimeMarketDataLoader:(id)realTimeLoader;
- (void)load;

@end
