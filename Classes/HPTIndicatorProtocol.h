//
//  HPTIndicatorProtocol.h
//  iHPTrader
//
//  Created by hugo on 13年6月16日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTMarketDataStoreProtocol.h"
#import "HPTSymbolProtocol.h"

typedef enum  {
	HPT_NO_RANK,
	HPT_SIGNAL_RANK,
    HPT_RECOMMAND_RANK,
	HPT_HIGHLY_RANK	
}HPTIndicatorRank;


@protocol HPTIndicatorProtocol

- (id)initWithStore:(id<HPTMarketDataStoreProtocol>)store;
- (void)setSymbol:(id<HPTSymbolProtocol>)aSymbol;
- (void)setParam:(NSDictionary *)paramSet;
- (void)deriveData;
- (BOOL)isBuy;
- (BOOL)isSell;
- (HPTIndicatorRank)getRank;

@end
