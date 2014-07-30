//
//  WCFunctions.h
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//

#ifndef __WC_FOUNDATION_FUNCTIONS__
#define __WC_FOUNDATION_FUNCTIONS__

#import <dispatch/dispatch.h>
#import <Foundation/NSBundle.h>
#import <WCFoundation/WCConstants.h>

static inline NSBundle *WCFoundationBundle(void) {
    static NSBundle *kWCFoundationBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kWCFoundationBundle = [NSBundle bundleWithIdentifier:WCFoundationBundleIdentifier];
    });
    return kWCFoundationBundle;
}

#endif
