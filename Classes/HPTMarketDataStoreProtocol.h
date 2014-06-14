//
//  HPTMarketDataStoreProtocol.h
//  iHPTrader
//
//  Created by hugo on 13年6月8日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTSymbolProtocol.h"
#import "HPTBarData.h"
#import "HPTYahooSymbol.h"


@protocol HPTMarketDataStoreProtocol<NSObject>

- (BOOL)isContainsSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)addOrUpdate:(id<HPTSymbolProtocol>)aSymbol withBarData:(HPTBarData *)aBar;
- (void)append:(id<HPTSymbolProtocol>)aSymbol withBarDatas:(NSDictionary *)bars;
- (NSMutableDictionary *)getBars:(id<HPTSymbolProtocol>)aSymbol;
- (HPTBarData *)getFirstBar:(id<HPTSymbolProtocol>)aSymbol;
- (HPTBarData *)getLastBar:(id<HPTSymbolProtocol>)aSymbol;
- (void)removeLastBar:(id<HPTSymbolProtocol>)aSymbol;
- (void)removeSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)loadSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)loadAll;
- (void)unloadSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)unloadAll;
- (void)flushSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)flushAll;

- (NSDate **)getTestDate;

@end
