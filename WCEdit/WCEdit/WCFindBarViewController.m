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

@interface WCFindBarViewController ()
@property (readwrite,weak,nonatomic) IBOutlet NSPopUpButton *modePopUpButton;
@property (readwrite,weak,nonatomic) IBOutlet NSSearchField *searchField;
@property (readwrite,weak,nonatomic) IBOutlet NSSegmentedControl *nextPreviousSegmentedControl;
@property (weak,nonatomic) IBOutlet NSButton *doneButton;

@property (readwrite,strong,nonatomic) RACCommand *doneCommand;

@end

@implementation WCFindBarViewController

- (NSBundle *)nibBundle {
    return WCEditBundle();
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setDoneCommand:[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@YES];
            [subscriber sendCompleted];
            
            return nil;
        }];
    }]];
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.doneButton setRac_command:self.doneCommand];
}

@end
