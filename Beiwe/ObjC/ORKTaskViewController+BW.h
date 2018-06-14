//
//  ORKTaskViewController+BW.h
//  Beiwe
//
//  Created by Keary Griffin on 4/15/16.
//  Copyright © 2016 Rocketfarm Studios. All rights reserved.
//


#ifndef ORKTaskViewController_BW_h
#define ORKTaskViewController_BW_h

#import "ResearchKit/ORKTaskViewController.h"


@interface ORKTaskViewController (BW)
- (void)presentCancelOptions:(BOOL)saveable sender:(UIBarButtonItem *)sender;
@end

#endif /* ORKTaskViewController_BW_h */
