//
//  HPTInMemoryMarketDataStore.h
//  iHPTrader
//
//  Created by hugo on 13年6月8日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTMarketDataStoreProtocol.h"


@interface HPTInMemoryMarketDataStore : NSObject<HPTMarketDataStoreProtocol>{
	NSMutableDictionary *_data;
	NSDate **_testDate;
}


@end
