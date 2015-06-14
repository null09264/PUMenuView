//
//  PUMenuView.h
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUMenuView;

@protocol PUMenuViewDataSource

- (NSInteger) numberOfItemsInMenuView:(PUMenuView *) menuView;

@optional
- (UIButton *) menuView:(PUMenuView *) menuView buttonForItemAtIndex:(NSInteger) index;
- (UIView *) menuView:(PUMenuView *) menuView viewForItemAtIndex:(NSInteger) index;

@end

@protocol PUMenuViewDelegate

@optional
- (void) menuView:(PUMenuView *) menuView itemDidSelectAtIndex: (NSInteger) index;

@end

@interface PUMenuView : UIView

@property (nonatomic, weak) NSObject<PUMenuViewDelegate> *delegate;
@property (nonatomic, weak) NSObject<PUMenuViewDataSource> *dataSource;

- (void)addItem:(UIView *)item;

@end