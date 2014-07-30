//
//  WCPreferencesAdvancedViewController.m
//  WabbitCode
//
//  Created by William Towe on 7/30/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCPreferencesAdvancedViewController.h"

@interface WCPreferencesAdvancedViewController ()

@end

@implementation WCPreferencesAdvancedViewController

+ (NSString *)preferencesIdentifier {
    return @"com.williamtowellc.wabbitcode.preferences.advanced";
}
+ (NSString *)preferencesName {
    return NSLocalizedString(@"General", @"preferences advanced name");
}
+ (NSImage *)preferencesImage {
    return [NSImage imageNamed:NSImageNameAdvanced];
}

+ (NSString *)preferencesToolTip {
    return NSLocalizedString(@"Show the Advanced preferences", @"preferences advanced tooltip");
}

@end