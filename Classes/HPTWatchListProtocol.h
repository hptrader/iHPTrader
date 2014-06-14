//
//  HPTWatchListProtocol.h
//  iHPTrader
//
//  Created by hugo on 13年6月3日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HPTWatchListProtocol<NSObject>

- (NSMutableArray *)getPrioritySymbols;
- (NSMutableArray *)getOtherSymbols;

@end
