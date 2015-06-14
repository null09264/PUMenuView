//
//  ViewController.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "ViewController.h"
#import "PUMenuView.h"

@interface ViewController () <PUMenuViewDelegate, PUMenuViewDataSource>
@property (nonatomic) PUMenuView *menuView;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	PUMenuView *menuView = [[PUMenuView alloc]initWithFrame:self.view.bounds];
    menuView.translatesAutoresizingMaskIntoConstraints = NO;
	menuView.itemSideLengthMultiplier = 0.25;
	
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

- (UIButton *)menuView:(PUMenuView *)menuView buttonForItemAtIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor blackColor];
	button.layer.cornerRadius = menuView.itemSideLengthMultiplier * CGRectGetWidth(menuView.frame)/2;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"B%ld", index] forState:UIControlStateNormal];
    return button;
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
