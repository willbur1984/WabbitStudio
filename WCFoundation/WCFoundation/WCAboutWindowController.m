//
//  WCAboutWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCAboutWindowController.h"
#import "WCFoundationFunctions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "NSBundle+WCExtensions.h"

NSString *const WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString = @"WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString";

static WCAboutWindowController *kCurrentAboutWindowController;

@interface WCAboutWindowController ()
@property (weak,nonatomic) IBOutlet NSTextField *applicationNameLabel;
@property (weak,nonatomic) IBOutlet NSTextField *applicationVersionLabel;
@property (unsafe_unretained,nonatomic) IBOutlet NSTextView *creditsTextView;
@property (weak,nonatomic) IBOutlet NSTextField *copyrightNoticeLabel;
@property (weak,nonatomic) IBOutlet NSButton *acknowledgementsButton;
@property (weak,nonatomic) IBOutlet NSButton *visitApplicationWebsiteButton;

- (IBAction)_acknowledgementsButtonAction:(id)sender;
- (IBAction)_visitApplicationWebsiteButtonAction:(id)sender;
@end

@implementation WCAboutWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super init]))
        return nil;
    
    if (kCurrentAboutWindowController)
        return kCurrentAboutWindowController;
    
    kCurrentAboutWindowController = self;
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setTitle:NSLocalizedStringFromTableInBundle(@"About", nil, WCFoundationBundle(), @"about window title")];
    
    [self.creditsTextView setTextContainerInset:NSZeroSize];
    
    [self.applicationNameLabel setStringValue:[NSBundle mainBundle].WC_bundleExecutable];
    [self.applicationVersionLabel setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Version %@ (Build %@)", nil, WCFoundationBundle(), @"about window application version label format string"),[NSBundle mainBundle].WC_bundleShortVersionString,[NSBundle mainBundle].WC_bundleVersion]];
    [self.copyrightNoticeLabel setStringValue:[NSBundle mainBundle].WC_humanReadableCopyright];
    
    [self.acknowledgementsButton setTitle:NSLocalizedStringFromTableInBundle(@"Acknowledgements", nil, WCFoundationBundle(), @"acknowledgements button title")];
    [self.visitApplicationWebsiteButton setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Visit %@ Website", nil, WCFoundationBundle(), @"about window visit application website format string"),[NSBundle mainBundle].WC_bundleExecutable]];
    
    [self.creditsTextView setString:({
        NSString *retval = @"";
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"txt"];
        NSString *credits = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
        
        if (credits)
            retval = credits;
        
        retval;
    })];
    
    [self.acknowledgementsButton setRac_command:[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"Acknowledgements" withExtension:@"txt"];
            
            [[NSWorkspace sharedWorkspace] openURL:url];
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }]];
    
    [self.visitApplicationWebsiteButton setRac_command:[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            if ([NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString]) {
                NSURL *url = [NSURL URLWithString:[NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString]];
                
                [[NSWorkspace sharedWorkspace] openURL:url];
            }
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }]];
    
    [[[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:NSWindowWillCloseNotification object:self.window]
      take:1]
     subscribeNext:^(id _) {
         kCurrentAboutWindowController = nil;
    }];
}

- (void)showWindow:(id)sender {
    [self.window center];
    
    [super showWindow:sender];
}

- (IBAction)_visitApplicationWebsiteButtonAction:(id)sender; {
    if (![NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString])
        return;
    
    NSURL *url = [NSURL URLWithString:[NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString]];
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
