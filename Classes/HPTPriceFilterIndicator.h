//
//  HPTPriceFilterIndicator.h
//  iHPTrader
//
//  Created by hugo on 13年6月23日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTIndicatorProtocol.h"
#import "TACore.h"


@interface HPTPriceFilterIndicator : NSObject<HPTIndicatorProtocol> {

	id<HPTMarketDataStoreProtocol> _store;
	id<HPTSymbolProtocol> _symbol;
	BOOL _isBuy;
	BOOL _isSell;
	HPTIndicatorRank _rank;
	double _lowLimit, _highLimit;
	
	TACore *_core;
}

@end
