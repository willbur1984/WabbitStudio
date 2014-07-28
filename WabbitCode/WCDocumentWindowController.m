//
//  WCDocumentWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//
//

#import "WCDocumentWindowController.h"

@interface WCDocumentWindowController ()

@end

@implementation WCDocumentWindowController

- (id)init {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 640.0, 480.0) styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    if (!(self = [super initWithWindow:window]))
        return nil;
    
    return self;
}

@end
