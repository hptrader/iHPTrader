//
//  HPTIndicatorOperation.h
//  iHPTrader
//
//  Created by hugo on 13年6月18日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPTIndicatorProtocol.h"
#import "HPTDictionary.h"


@interface HPTIndicatorOperation : NSOperation {
	NSObject<HPTIndicatorProtocol> *_indicator;
	HPTDictionary *_dictionary;
}

@property(nonatomic, retain)NSObject<HPTIndicatorProtocol> *indicator;
@property(nonatomic, retain)HPTDictionary *dictionary;

@end
