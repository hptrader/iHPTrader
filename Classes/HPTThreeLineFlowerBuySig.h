//
//  HPTThreeLineFlowerBuySig.h
//  iHPTrader
//
//  Created by hugo on 13年6月16日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "math.h"
#import "HPTIndicatorProtocol.h"
#import "TACore.h"


@interface HPTThreeLineFlowerBuySig : NSObject<HPTIndicatorProtocol> {
	id<HPTMarketDataStoreProtocol> _store;
	id<HPTSymbolProtocol> _symbol;
	BOOL _isBuy;
	BOOL _isSell;
	HPTIndicatorRank _rank;
	int _sma1, _sma2, _sma3;
	
	TACore *_core;
}


@end
