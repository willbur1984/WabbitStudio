//
//  WCTextFinder.m
//  WCEdit
//
//  Created by William Towe on 8/10/14.
//  Copyright (c) 2014 William Towe, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextFinder.h"
#import "WCFindBarViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/EXTScope.h>

@interface WCTextFinder ()
@property (strong,nonatomic) WCFindBarViewController *findBarViewController;
@end

@implementation WCTextFinder

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setFindBarViewController:[[WCFindBarViewController alloc] init]];
    
    @weakify(self);
    
    [[self.findBarViewController.doneCommand.executionSignals
      concat]
     subscribeNext:^(id _) {
         @strongify(self);
         
         [self performTextFinderAction:NSTextFinderActionHideFindInterface];
    }];
    
    return self;
}

- (BOOL)validateTextFinderAction:(NSTextFinderAction)action; {
    switch (action) {
        case NSTextFinderActionSetSearchString:
            return [self.client firstSelectedRange].length > 0;
        case NSTextFinderActionShowReplaceInterface:
        case NSTextFinderActionReplace:
        case NSTextFinderActionReplaceAll:
        case NSTextFinderActionReplaceAllInSelection:
        case NSTextFinderActionReplaceAndFind:
            return [self.client isEditable];
        default:
            return YES;
    }
}
- (void)performTextFinderAction:(NSTextFinderAction)action; {
    switch (action) {
        case NSTextFinderActionShowFindInterface:
            [self.viewContainer setTextFinderViewVisible:YES];
            break;
        case NSTextFinderActionHideFindInterface:
            [self.viewContainer setTextFinderViewVisible:NO];
            break;
        default:
            break;
    }
}

- (void)setViewContainer:(id<WCTextFinderViewContainer>)viewContainer {
    if (self.viewContainer) {
        [self.viewContainer setTextFinderViewVisible:NO];
        [self.viewContainer setTextFinderView:nil];
    }
    
    _viewContainer = viewContainer;
    
    if (self.viewContainer) {
        [self.viewContainer setTextFinderView:self.findBarViewController.view];
    }
}

@end
