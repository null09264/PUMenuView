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

- (NSInteger) numberOfItemsInmenuView:(PUMenuView *) menuView;
- (UIImage *) menuView:(PUMenuView *) menuView iconForItemAtIndex: (NSInteger) index;
- (NSString *) menuView:(PUMenuView *) menuView titleForItemAtIndex: (NSInteger) index;

@end

@protocol PUMenuViewDelegate

- (void) menuView:(PUMenuView *) menuView itemDidSelectAtIndex: (NSInteger) index;

@end

@interface PUMenuView : UIView

@property id<PUMenuViewDelegate> delegate;
@property id<PUMenuViewDataSource> dataSource;

- (void)addItem:(UIView *)item;
- (void)reloadContent;

@end