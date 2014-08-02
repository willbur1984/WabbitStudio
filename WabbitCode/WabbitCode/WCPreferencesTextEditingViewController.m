//
//  WCPreferencesTextEditingViewController.m
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

#import "WCPreferencesTextEditingViewController.h"

NSString *const WCPreferencesTextEditingViewControllerUserDefaultsKeyHighlightCurrentLine = @"WCPreferencesTextEditingViewControllerUserDefaultsKeyHighlightCurrentLine";
NSString *const WCPreferencesTextEditingViewControllerUserDefaultsKeyAutoPairCharacters = @"WCPreferencesTextEditingViewControllerUserDefaultsKeyAutoPairCharacters";
NSString *const WCPreferencesTextEditingViewControllerUserDefaultsKeyWrapSelectedTextWithPairCharacters = @"WCPreferencesTextEditingViewControllerUserDefaultsKeyWrapSelectedTextWithPairCharacters";

@interface WCPreferencesTextEditingViewController ()
@property (weak,nonatomic) IBOutlet NSButton *highlightCurrentLineCheckboxButton;
@property (weak,nonatomic) IBOutlet NSButton *autoPairCharactersCheckboxButton;
@property (weak,nonatomic) IBOutlet NSButton *wrapSelectedTextWithPairCharactersCheckboxButton;
@end

@implementation WCPreferencesTextEditingViewController

+ (NSString *)preferencesIdentifier {
    return @"com.williamtowellc.wabbitcode.preferences.text-editing";
}
+ (NSString *)preferencesName {
    return NSLocalizedString(@"Text Editing", @"preferences text editing name");
}
+ (NSImage *)preferencesImage {
    return [NSImage imageNamed:@"preferences-text-editing"];
}

+ (NSString *)preferencesToolTip {
    return NSLocalizedString(@"Show the Text Editing preferences", @"preferences text editing tooltip");
}

@end
