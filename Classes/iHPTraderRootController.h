//
//  iHPTraderRootController.h
//  iHPTrader
//
//  Created by hugo on 13年5月28日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPTSymbolProtocol.h"
#import "HPTYahooSymbol.h"
#import "HPTBarData.h"
#import "HPTYahooFinanceMarketDataLoader.h"
#import "HPTYahooWatchList.h"
#import "HPTYahooHKExEquityDictionary.h"
#import "HPTInMemoryMarketDataStore.h"
#import "HPTAsciiMarketDataStore.h"
#import "HPTThreeLineFlowerBuySig.h"
#import "HPTIndicatorOperation.h"
#import "HPTPriceFilterIndicator.h"
#import "HPTIndicatorChainOperation.h"
#import "HPTVolumeSig.h"
#import "HPTAdvSig.h"
#import "HPTOneOfTenthSig.h"


@interface iHPTraderRootController : UIViewController {
	HPTYahooFinanceMarketDataLoader *_dataLoader;
	NSOperationQueue *_loadQueue;
    NSOperationQueue *_scanQueue;
	HPTIndicatorOperation *_indicator;
	HPTIndicatorChainOperation *_indicators;
	
}

@property(nonatomic, retain)HPTYahooFinanceMarketDataLoader *dataLoader;
@property(nonatomic, retain)NSOperationQueue *loadQueue;
@property(nonatomic, retain)NSOperationQueue *scanQueue;
@property(nonatomic, retain)HPTIndicatorOperation *indicator;
@property(nonatomic, retain)HPTIndicatorChainOperation *indicators;


- (IBAction)buttonPressed: (id)sender;
- (IBAction)loadPressed:(id)sender;  

@end
