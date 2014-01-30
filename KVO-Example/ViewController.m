//
//  ViewController.m
//  KVO-Example
//
//  Created by Christopher Constable on 1/30/14.
//  Copyright (c) 2014 Christopher Constable. All rights reserved.
//

#import "ViewController.h"
#import "SomeObject.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *array;
@property (copy, nonatomic) NSString *lastRowDisplayed;
@property (strong, nonatomic) SomeObject *someObject;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"----------------------------------------");
    NSLog(@"         GET READY FOR SOME KVC         ");
    NSLog(@"----------------------------------------");

    /**
     KVC (Key-Value Coding) can be used to access "KVC-compliant"
     properties or values of a class. By synthesizing a @property,
     we get KVC compliance for free! (Remember: Xcode automatically
     synthesizes properties for us now).
     
     We can access values and also set values using the following
     methods:
     */
    UITableView *myTableView = [self valueForKey:@"tableView"]; // self.tableView
    myTableView.backgroundColor = [UIColor blueColor];
    
    [self setValue:@"Hey!" forKey:@"lastRowDisplayed"]; // self.lastRowDisplayed
    
    /**
     We can also do neat things like sum up all the values in an array...
     Check out KVO Collection Operators for more details.
     */
    self.array = @[@10, @40, @12, @340, @86];
    
    int total = 0;
    for (NSNumber *number in self.array) {
        total += [number intValue];
    }
    NSLog(@"Sum: %d", total);
    
    /** 
     This is saying "for the ARRAY, @sum all the objects in the array".
     Since everything in the array is an NSNumber, self == an NSNumber
     and that is something we can sum.
    */
    NSLog(@"Sum: %@", [self.array valueForKeyPath:@"@sum.self"]);
    
    /**
     Oh yea!
     */
    NSLog(@"Max: %@", [self.array valueForKeyPath:@"@max.self"]);
    NSLog(@"Min: %@", [self.array valueForKeyPath:@"@min.self"]);
    NSLog(@"Average: %@", [self.array valueForKeyPath:@"@avg.self"]);
    NSLog(@"Count: %@", [self.array valueForKeyPath:@"@count.self"]);
    
    NSLog(@"----------------------------------------");
    NSLog(@"         GET READY FOR SOME KVO         ");
    NSLog(@"----------------------------------------");
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.someObject = [[SomeObject alloc] init];

    /**
     Here we are setting up some observers for KVO (key-value
     observing).
     */
    [self addObserver:self.someObject
           forKeyPath:@"lastRowDisplayed"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    /**
     We can optionally specify a "context". This is literally just a
     value that gets passed in everytime we observe the value...
     nothing more. It's up to you want you want to do with the context.
     
     People might say using a pointer to "self" like I do below is bad (remember,
     from the perspective of the observer the "context" (self.someObject)
     will be "self") but they are silly people*.
     */
    [self.tableView addObserver:self.someObject
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew
                        context:(__bridge void *)self.someObject];
}

- (void)dealloc
{
    /**
     ALWAYS remember to remove you observers.
     */
    [self removeObserver:self.someObject
              forKeyPath:@"lastRowDisplayed"];
    [self.tableView removeObserver:self.someObject
                        forKeyPath:@"contentOffset"];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     WARNING: If you set the backing iVar you will need to manually trigger some
     events to cause observers to get notifications.
     */
    [self willChangeValueForKey:@"lastRowDisplayed"];
    _lastRowDisplayed = [NSString stringWithFormat:@"Row %d", indexPath.row];
    [self didChangeValueForKey:@"lastRowDisplayed"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *cellTestimonial = [NSString stringWithFormat:@"\"Now people don't have to steal my table view's delegate to observe things... Thanks KVO!\"\n- Cell %d", indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Testimonial"
                                                    message:cellTestimonial
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

/**
 * They aren't really silly people, they are just saying that it's not a context
 that is guarenteed to be unique (and that's correct). The odds of someone else
 using YOU as a context though and somehow that causing a conflict is very slim.
 I'd prefer to not having file-scoped global vars in my implementation files.
 */
