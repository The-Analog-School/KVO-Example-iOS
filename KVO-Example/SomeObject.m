//
//  SomeObject.m
//  KVO-Example
//
//  Created by Christopher Constable on 1/30/14.
//  Copyright (c) 2014 Christopher Constable. All rights reserved.
//

#import "SomeObject.h"

@implementation SomeObject

- (void)updateSomethingAfterTableViewScrolls
{
    NSLog(@"Table view scrolled!");
}

- (void)updateSomethingAfterThatStringChanges:(NSString *)string
{
    NSLog(@"That string changed: %@", string);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    /**
     Check to see if this is the tableView's contentOffset...
     */
    if ([object isKindOfClass:[UITableView class]]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            [self updateSomethingAfterTableViewScrolls];
        }
    }
    
    /**
     Check to see if this is the ViewController's lastRowDisplayed...
     */
    if ([object isKindOfClass:[UIViewController class]]) {
        if ([keyPath isEqualToString:@"lastRowDisplayed"]) {
            NSString *changeValue = [change objectForKey:@"new"];
            [self updateSomethingAfterThatStringChanges:changeValue];
        }
    }
}

@end
