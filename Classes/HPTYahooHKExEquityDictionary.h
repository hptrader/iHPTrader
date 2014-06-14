//
//  HPTYahooHKExEquityDictionary.h
//  iHPTrader
//
//  Created by hugo on 13年6月4日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTDictionary.h"
#import "HPTYahooSymbol.h"


@interface HPTYahooHKExEquityDictionary : HPTDictionary {
	NSMutableArray *symbols;
	NSArray *alphabet;
}

@end
