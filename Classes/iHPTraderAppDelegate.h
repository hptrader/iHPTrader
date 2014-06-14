//
//  iHPTraderAppDelegate.h
//  iHPTrader
//
//  Created by hugo on 13年5月28日.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iHPTraderRootController.h"

@interface iHPTraderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	iHPTraderRootController *rootController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iHPTraderRootController *rootController;

@end

