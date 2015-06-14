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
    self.menuView = menuView;
    [self.view insertSubview:menuView atIndex:0];
    NSDictionary *dict = NSDictionaryOfVariableBindings(menuView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[menuView]|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[menuView]|" options:0 metrics:nil views:dict]];
    menuView.dataSource = self;
    menuView.delegate = self;
}

#pragma mark - PUMenuViewDataSource

- (NSInteger)numberOfItemsInMenuView:(PUMenuView *)menuView {
    return 6;
}

- (UIButton *)menuView:(PUMenuView *)menuView buttonForItemAtIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"Button %ld", index] forState:UIControlStateNormal];
    return button;
}

#pragma mark - PUMenuViewDelegate

- (void)menuView:(PUMenuView *)menuView itemDidSelectAtIndex:(NSInteger)index {
    NSLog(@"Button Did Clicked: %ld", index);
}

@end
