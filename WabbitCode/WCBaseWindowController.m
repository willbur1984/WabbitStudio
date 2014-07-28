//
//  WCBaseWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//
//

#import "WCBaseWindowController.h"

@interface WCBaseWindowController ()

@end

@implementation WCBaseWindowController

- (NSString *)windowNibName {
    return NSStringFromClass(self.class);
}

@end
