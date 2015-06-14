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

- (NSInteger) numberOfCellsInmenuView:(PUMenuView *) menuView;
- (UIImage *) menuView:(PUMenuView *) menuView iconForCellAtIndex: (NSInteger) index;
- (NSString *) menuView:(PUMenuView *) menuView titleForCellAtIndex: (NSInteger) index;

@end

@protocol PUMenuViewDelegate

- (void) menuView:(PUMenuView *) menuView cellDidSelectAtIndex: (NSInteger) index;

@end

@interface PUMenuView : UIView

@property id<PUMenuViewDelegate> delegate;
@property id<PUMenuViewDataSource> dataSource;

- (void)addCell:(UIView *)cell;
- (void)reloadContent;

@end