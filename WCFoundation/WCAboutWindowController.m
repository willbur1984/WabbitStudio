//
//  WCAboutWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 7/28/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//

#import "WCAboutWindowController.h"

NSString *const WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString = @"WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString";

@interface WCAboutWindowController ()
@property (weak,nonatomic) IBOutlet NSTextField *applicationNameLabel;
@property (weak,nonatomic) IBOutlet NSTextField *applicationVersionLabel;
@property (unsafe_unretained,nonatomic) IBOutlet NSTextView *creditsTextView;
@property (weak,nonatomic) IBOutlet NSTextField *copyrightNoticeLabel;
@property (weak,nonatomic) IBOutlet NSButton *acknowledgementsButton;
@property (weak,nonatomic) IBOutlet NSButton *visitApplicationWebsiteButton;

@property (weak,nonatomic) id windowWillCloseNotificationToken;

- (IBAction)_acknowledgementsButtonAction:(id)sender;
- (IBAction)_visitApplicationWebsiteButtonAction:(id)sender;
@end

@implementation WCAboutWindowController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.windowWillCloseNotificationToken];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setTitle:NSLocalizedStringFromTableInBundle(@"About", nil, [NSBundle bundleForClass:self.class], @"about window title")];
    
    [self.creditsTextView setTextContainerInset:NSZeroSize];
    
    [self.applicationNameLabel setStringValue:[NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"]];
    [self.applicationVersionLabel setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Version %@ (Build %@)", nil, [NSBundle bundleForClass:self.class], @"about window application version label format string"),[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]]];
    [self.copyrightNoticeLabel setStringValue:[NSBundle mainBundle].infoDictionary[@"NSHumanReadableCopyright"]];
    
    [self.acknowledgementsButton setTitle:NSLocalizedStringFromTableInBundle(@"Acknowledgements", nil, [NSBundle bundleForClass:self.class], @"acknowledgements button title")];
    [self.visitApplicationWebsiteButton setTitle:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Visit %@ Website", nil, [NSBundle bundleForClass:self.class], @"about window visit application website format string"),[NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"]]];
    
    [self.creditsTextView setString:({
        NSString *retval = @"";
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"txt"];
        NSString *credits = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
        
        if (credits)
            retval = credits;
        
        retval;
    })];
    
    __block WCAboutWindowController *bself = self;
    
    [self setWindowWillCloseNotificationToken:[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:self.window queue:nil usingBlock:^(NSNotification *note) {
        bself = nil;
    }]];
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    
    [self.window center];
}

- (IBAction)_acknowledgementsButtonAction:(id)sender; {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Acknowledgements" withExtension:@"markdown"];
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}
- (IBAction)_visitApplicationWebsiteButtonAction:(id)sender; {
    if (![NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString])
        return;
    
    NSURL *url = [NSURL URLWithString:[NSBundle mainBundle].infoDictionary[WCAboutWindowControllerInfoPlistKeyApplicationWebsiteURLString]];
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
