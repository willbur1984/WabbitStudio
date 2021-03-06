//
//  WCAppDelegate.m
//  WabbitCode
//
//  Created by William Towe on 7/27/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCAppDelegate.h"
#import <WCFoundation/WCAboutWindowController.h>
#import <WCFoundation/WCPreferencesWindowController.h>
#import "WCPreferencesGeneralViewController.h"
#import "WCPreferencesAdvancedViewController.h"
#import "WCPreferencesTextEditingViewController.h"

@interface WCAppDelegate ()
- (IBAction)_aboutAction:(id)sender;
- (IBAction)_preferencesAction:(id)sender;

- (void)_registerDefaultPreferences;
@end

@implementation WCAppDelegate
#pragma mark NSApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self _registerDefaultPreferences];
}
- (void)applicationDidFinishLaunching:(NSNotification *)note {
    
}
#pragma mark *** Private Methods ***
- (void)_registerDefaultPreferences; {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"DefaultPreferences" withExtension:@"plist"];
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfURL:url];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:prefs];
}
#pragma mark Actions
- (IBAction)_aboutAction:(id)sender; {
    [[[WCAboutWindowController alloc] init] showWindow:nil];
}
- (IBAction)_preferencesAction:(id)sender; {
    [[[WCPreferencesWindowController alloc] initWithViewControllerClasses:@[[WCPreferencesTextEditingViewController class]]] showWindow:nil];
}

@end
