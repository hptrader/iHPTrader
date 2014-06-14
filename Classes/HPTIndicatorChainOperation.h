//
//  HPTIndicatorChainOperation.h
//  iHPTrader
//
//  Created by hugo on 14年5月5日.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTIndicatorProtocol.h"
#import "HPTDictionary.h"
#import "HPTRankSymbol.h"


@interface HPTIndicatorChainOperation : NSOperation {
	NSMutableArray *_indicators;
	HPTDictionary *_dictionary;
}

@property (nonatomic, retain)HPTDictionary *dictionary;

- (void)addIndicator:(id<HPTIndicatorProtocol>)indicator;

@end
