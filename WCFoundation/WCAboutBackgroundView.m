//
//  WCAboutBackgroundView.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//

#import "WCAboutBackgroundView.h"

@implementation WCAboutBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
    
    [[NSColor lightGrayColor] setFill];
    NSRectFill(NSMakeRect(0.0, 0.0, NSWidth(self.bounds), 1.0));
}

@end
