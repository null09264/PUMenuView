//
//  ViewController.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "ViewController.h"
#import "PUMenuView.h"

@interface ViewController ()
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
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)addItem:(id)sender {
    UIView *item = [UIView new];
    item.backgroundColor = [UIColor blackColor];
    [self.menuView addItem:item];
    [self.menuView setNeedsLayout];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        [self.menuView layoutIfNeeded];
    } completion:nil];
}

@end
