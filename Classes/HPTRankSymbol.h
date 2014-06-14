//
//  HPTRankSymbol.h
//  iHPTrader
//
//  Created by hugo on 14年5月7日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTIndicatorProtocol.h"
#import "HPTSymbolProtocol.h"


@interface HPTRankSymbol : NSObject {
	id<HPTSymbolProtocol> _symbol;
	HPTIndicatorRank _rank;
}

@property (nonatomic, retain)id<HPTSymbolProtocol> symbol;
@property (nonatomic, assign)HPTIndicatorRank rank;


@end
