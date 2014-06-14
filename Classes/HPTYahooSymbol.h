//
//  HPTYahooSymbol.h
//  iHPTrader
//
//  Created by hugo on 13年5月28日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTSymbolProtocol.h"


@interface HPTYahooSymbol : NSObject<HPTSymbolProtocol> {
	NSString *_symbolString;
	NSString *_areaCode;
}


@end
