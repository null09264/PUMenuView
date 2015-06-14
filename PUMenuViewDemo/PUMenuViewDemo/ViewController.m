//
//  ViewController.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "ViewController.h"
#import "PUMenuView.h"
#import "PUMenuItem.h"

@interface ViewController () <PUMenuViewDelegate, PUMenuViewDataSource>
@property (nonatomic) PUMenuView *menuView;
@end

@implementation ViewController {
	NSArray *_titles;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_titles = @[@"Candy", @"Book", @"Flower", @"Mail", @"Card", @"Camera"];
	
	PUMenuView *menuView = [[PUMenuView alloc]initWithFrame:self.view.bounds];
    menuView.translatesAutoresizingMaskIntoConstraints = NO;
	menuView.itemSideLengthMultiplier = 0.3;
	
	//The order is important, you need to set all constant properly before setting the data source
	menuView.dataSource = self;
	menuView.delegate = self;
	
	[self.view insertSubview:menuView atIndex:0];

	NSDictionary *viewBindings = NSDictionaryOfVariableBindings(menuView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[menuView]|" options:0 metrics:nil views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[menuView]|" options:0 metrics:nil views:viewBindings]];
	
	self.menuView = menuView;
}

#pragma mark - PUMenuViewDataSource

- (NSInteger)numberOfItemsInMenuView:(PUMenuView *)menuView {
    return 6;
}

- (UIView *)menuView:(PUMenuView *)menuView viewForItemAtIndex:(NSInteger)index {
	PUMenuItem *item = [[PUMenuItem alloc]init];
	[item.button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld", index]] forState:UIControlStateNormal];
	item.label.text = _titles[index];
	return item;
}

#pragma mark - PUMenuViewDelegate

- (void)menuView:(PUMenuView *)menuView itemDidSelectAtIndex:(NSInteger)index {
    NSLog(@"Button Did Clicked: %ld", index);
}

- (void)menuViewWillShow:(PUMenuView *)menuView {
	NSLog(@"View will show.");
}

- (void)menuViewDidShow:(PUMenuView *)menuView {
	NSLog(@"View did show.");
}

- (void)menuViewWillHide:(PUMenuView *)menuView {
	NSLog(@"View will hide.");
}

- (void)menuViewDidHide:(PUMenuView *)menuView {
	NSLog(@"View will hide.");
}

#pragma mark - IBActions

- (IBAction)showMenu:(id)sender {
	[self.menuView show];
}

- (IBAction)hideMenu:(id)sender {
	[self.menuView hide];
}

@end
