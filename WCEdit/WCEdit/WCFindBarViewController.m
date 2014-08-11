//
//  WCFindBarViewController.m
//  WCEdit
//
//  Created by William Towe on 8/9/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFindBarViewController.h"
#import <WCFoundation/WCFoundation.h>
#import "WCEditFunctions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>
#import "WCFindOptionsViewController.h"
#import "WCFindBarFieldEditor.h"
#import "WCTextFinder.h"

@interface WCFindBarViewController () <NSTextFieldDelegate>
@property (readwrite,weak,nonatomic) IBOutlet NSPopUpButton *modePopUpButton;
@property (readwrite,weak,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,weak,nonatomic) IBOutlet NSSegmentedControl *nextPreviousSegmentedControl;
@property (weak,nonatomic) IBOutlet NSButton *doneButton;

@property (readwrite,copy,nonatomic) NSString *searchString;

@property (readwrite,strong,nonatomic) RACCommand *doneCommand;

@property (weak,nonatomic) WCTextFinder *textFinder;

@end

@implementation WCFindBarViewController
#pragma mark *** Subclass Overrides ***
- (NSBundle *)nibBundle {
    return WCEditBundle();
}

- (void)loadView {
    [super loadView];
    
    [(NSSearchFieldCell *)self.searchField.cell setPlaceholderString:NSLocalizedString(@"String Matching", @"find bar search field placeholder")];
    [(NSSearchFieldCell *)self.searchField.cell setSearchMenuTemplate:({
        NSMenu *retval = [[NSMenu alloc] initWithTitle:@""];
        NSMenuItem *editFindOptionsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit Find Options…", @"edit find options menu item title") action:@selector(_editFindOptionsAction:) keyEquivalent:@""];
        
        [editFindOptionsItem setTarget:self];
        
        [retval addItem:editFindOptionsItem];
        
        retval;
    })];
    
    [self.searchField setDelegate:self];
    
    [self.doneButton setRac_command:self.doneCommand];
    
    RAC(self,searchString) = [self.searchField rac_textSignal];
}
#pragma mark NSControlTextEditingDelegate
- (void)controlTextDidBeginEditing:(NSNotification *)note {
    WCFindBarFieldEditor *fieldEditor = note.userInfo[@"NSFieldEditor"];
    
    [fieldEditor setTextFinder:self.textFinder];
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [self.doneCommand execute:nil];
        
        return YES;
    }
    return NO;
}
#pragma mark *** Public Methods ***
- (instancetype)initWithTextFinder:(WCTextFinder *)textFinder; {
    if (!(self = [super init]))
        return nil;
    
    NSParameterAssert(textFinder);
    
    [self setTextFinder:textFinder];
    
    [self setDoneCommand:[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@YES];
            [subscriber sendCompleted];
            
            return nil;
        }];
    }]];
    
    return self;
}
#pragma mark *** Private Methods ***
#pragma mark Actions
- (IBAction)_editFindOptionsAction:(id)sender {
    NSPopover *popover = [[NSPopover alloc] init];
    
    [popover setContentViewController:[[WCFindOptionsViewController alloc] initWithTextFinderOptions:self.textFinder.options]];
    [popover setAppearance:NSPopoverAppearanceMinimal];
    [popover setBehavior:NSPopoverBehaviorTransient];
    
    [popover showRelativeToRect:[(NSSearchFieldCell *)self.searchField.cell searchButtonRectForBounds:self.searchField.bounds] ofView:self.searchField preferredEdge:NSMaxYEdge];
}

@end
