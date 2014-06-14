//
//  HPTYahooWatchList.h
//  iHPTrader
//
//  Created by hugo on 13年6月3日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTWatchListProtocol.h"


@interface HPTYahooWatchList : NSObject <HPTWatchListProtocol>{
	NSMutableArray *prioritySymbols;
	NSMutableArray *otherSymbols;
}

@end
