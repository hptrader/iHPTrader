//
//  HPTStandardIndicator.h
//  iHPTrader
//
//  Created by hugo on 14年5月19日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTIndicatorProtocol.h"
#import "TACore.h"


@interface HPTStandardIndicator : NSObject <HPTIndicatorProtocol>{
	id<HPTMarketDataStoreProtocol> _store;
	id<HPTSymbolProtocol> _symbol;
	BOOL _isBuy;
	BOOL _isSell;
	HPTIndicatorRank _rank;
	
	TACore *_core;
}

- (int)loadSymbolBarsWithClose:(NSMutableArray *)closeBar withOpen:(NSMutableArray *)openBar
					  withHigh:(NSMutableArray *)highBar withLow:(NSMutableArray *)lowBar
					withVolume:(NSMutableArray *)volumeBar;

- (NSArray *)getSMA:(NSArray *)input withTimePeriod:(int)inTimePeriod;




@end
