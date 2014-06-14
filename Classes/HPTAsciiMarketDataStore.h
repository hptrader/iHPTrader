//
//  HPTAsciiMarketDataStore.h
//  iHPTrader
//
//  Created by hugo on 13年6月9日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTInMemoryMarketDataStore.h"


@interface HPTAsciiMarketDataStore : HPTInMemoryMarketDataStore {
	NSString *_asciiDirectory;
	NSDateFormatter *_outDF1;
}

@property (nonatomic, copy)NSString *asciiDirectory;

@end
