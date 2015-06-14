//
//  PUMenuView.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "PUMenuView.h"

#define NUMBER_OF_COLUMN 3
#define ITEM_SIDE_LENGTH_MULTIPLIER 1/5.0
#define VERTICAL_SPACE_MULTIPLIER 1/12.0
#define HORIZONTAL_MARGIN_MULTIPLIER 1/12.0
#define HORIZONTAL_SPACING_MULTIPLIER (1 - 2 * HORIZONTAL_MARGIN_MULTIPLIER - 3 * ITEM_SIDE_LENGTH_MULTIPLIER) / (NUMBER_OF_COLUMN - 1)
#define BUTTON_TAG_BASE 9743

@interface PUMenuView ()

@property UIView *itemTemplate;

@property UIView *positionLayoutGuideContainer;

@property UIView *horizontalSpacingLayoutGuideItemTemplate;
@property NSMutableDictionary *horizontalPositionLayoutGuideItems;
@property NSMutableDictionary *horizontalSpacingLayoutGuideItems;

@property UIView *verticalSpacingLayoutGuideItemTemplate;
@property NSMutableDictionary *verticalPositionLayoutGuideItems;
@property NSMutableDictionary *verticalSpacingLayoutGuideItems;

@property NSLayoutConstraint *trailingLayoutConstraint;
@property NSLayoutConstraint *bottomLayoutConstraint;


//items
@property NSMutableArray *items;
@property NSMutableArray *itemVerticalConstraints;

@end

@implementation PUMenuView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.items = [[NSMutableArray alloc]init];
        [self setUpLayoutGuides];
	}
	return self;
}

- (void)setDataSource:(NSObject<PUMenuViewDataSource> *)dataSource {
    _dataSource = dataSource;
    [self setUpItems];
}

#pragma mark - button configuration

- (void)setUpItems {
    NSObject<PUMenuViewDataSource> *dataSrouce = self.dataSource;
    NSAssert(dataSrouce != nil, @"DataSource is nil.");
    
    if ([dataSrouce respondsToSelector:@selector(menuView:buttonForItemAtIndex:)]) {
        for (int index = 0; index < [dataSrouce numberOfItemsInMenuView:self]; index++) {
            UIButton *button = [dataSrouce menuView:self buttonForItemAtIndex:index];
            [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = index + BUTTON_TAG_BASE;
            [self addItem:button];
        }
    } else if ([dataSrouce respondsToSelector:@selector(menuView:viewForItemAtIndex:)]){
        for (int index = 0; index < [dataSrouce numberOfItemsInMenuView:self]; index++) {
            UIView *view = [dataSrouce menuView:self viewForItemAtIndex:index];
            [self addItem:view];
        }
    }
}

#pragma mark - button event handler

- (void)buttonDidClick:(UIButton *)button {
    NSObject<PUMenuViewDelegate> *delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(menuView:itemDidSelectAtIndex:)]) {
        [delegate menuView:self itemDidSelectAtIndex:button.tag - BUTTON_TAG_BASE];
    }
}


#pragma mark - constraint configuration

- (void)setUpLayoutGuides {
    [self setUpItemTemplate];
	[self setUpPositionLayoutGuideContainer];
	[self setUpHorizontalSpacingLayoutGuideItemTemplate];
	[self setUpVerticalSpacingLayoutGuide];
}

- (void)setUpItemTemplate {
    UIView *template = [[UIView alloc]init];
    template.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:template atIndex:0];
    
    //constraint: item.width = x * self.width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:template
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:ITEM_SIDE_LENGTH_MULTIPLIER
                                                          constant:0]];
    
    //constraint: item.width = item.height
    [template addConstraint:[NSLayoutConstraint constraintWithItem:template
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:template
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
    self.itemTemplate = template;
}

- (void)setUpPositionLayoutGuideContainer {
	UIView *container = [[UIView alloc]init];
    container.translatesAutoresizingMaskIntoConstraints =  NO;
    [self insertSubview:container atIndex:0];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:container
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:container
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
	self.positionLayoutGuideContainer = container;
}

- (void)setUpHorizontalSpacingLayoutGuideItemTemplate {
	UIView *template = [[UIView alloc]init];
    template.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:template atIndex:0];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:template
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:HORIZONTAL_SPACING_MULTIPLIER
													  constant:0]];
	self.horizontalSpacingLayoutGuideItemTemplate = template;
}

- (void)setUpVerticalSpacingLayoutGuide {
	UIView *guide = [[UIView alloc]init];
    guide.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:guide atIndex:0];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:guide
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeHeight
													multiplier:VERTICAL_SPACE_MULTIPLIER
													  constant:0]];
	self.verticalSpacingLayoutGuideItemTemplate = guide;
}

- (UIView *)positionGuideItemForRowAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Row index must be non-negative");
    
    NSMutableDictionary *guideItems = self.verticalPositionLayoutGuideItems;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideItem = [guideItems objectForKey:indexKey];
    
    if (!guideItem) {
        guideItem = [[UIView alloc]init];   
        guideItem.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideItem atIndex:0];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.itemTemplate
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        if (index == 0) {
            //constraint with top
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.positionLayoutGuideContainer
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0]];
        } else {
            //constraint with spacingGuideItem bottom
            UIView *spacingGuideItem = [self spacingGuideItemAfterRowAtIndex:index - 1];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:spacingGuideItem
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0]];
        }
        
        [guideItems setObject:guideItem forKey:indexKey];
    }
    
    return guideItem;
}

- (UIView *)spacingGuideItemAfterRowAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Row index must be non-negative");
    
    NSMutableDictionary *guideItems = self.verticalSpacingLayoutGuideItems;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideItem = [guideItems objectForKey:indexKey];
    
    if (!guideItem) {
        guideItem = [[UIView alloc]init];
        guideItem.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideItem atIndex:0];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.verticalSpacingLayoutGuideItemTemplate
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        UIView *positionGuideItem = [self positionGuideItemForRowAtIndex:index];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:positionGuideItem
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
        [guideItems setObject:guideItem forKey:indexKey];
    }
    
    return guideItem;
}

- (UIView *)positionGuideItemForColumnAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Column index must be non-negative");
    
    NSMutableDictionary *guideItems = self.horizontalPositionLayoutGuideItems;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideItem = [guideItems objectForKey:indexKey];
    
    if (!guideItem) {
        guideItem = [[UIView alloc]init];
        guideItem.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideItem atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.itemTemplate
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        if (index == 0) {
            //constraint with leading
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.positionLayoutGuideContainer
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0]];
        } else {
            //constraint with spacingGuideItem trailing
            UIView *spacingGuideItem = [self spacingGuideItemAfterColumnAtIndex:index - 1];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:spacingGuideItem
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
        }
        
        [guideItems setObject:guideItem forKey:indexKey];
    }
    
    return guideItem;
}

- (UIView *)spacingGuideItemAfterColumnAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Column index must be non-negative");
    
    NSMutableDictionary *guideItems = self.horizontalSpacingLayoutGuideItems;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideItem = [guideItems objectForKey:indexKey];
    
    if (!guideItem) {
        guideItem = [[UIView alloc]init];
        guideItem.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideItem atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.horizontalSpacingLayoutGuideItemTemplate
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        UIView *positionGuideItem = [self positionGuideItemForColumnAtIndex:index];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideItem
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:positionGuideItem
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
        [guideItems setObject:guideItem forKey:indexKey];
    }
    
    return guideItem;
}

- (void)addItem:(UIView *)item {
    //update constraints
    NSMutableArray *items = self.items;
    item.translatesAutoresizingMaskIntoConstraints = NO;
    NSInteger index = items.count;
    NSInteger row = index / NUMBER_OF_COLUMN;
    NSInteger column = index % NUMBER_OF_COLUMN;
    
    [self addSubview:item];
    
    //constraint: item.width = itemTemplate.width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.itemTemplate
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
    //constraint: item.width = item.height
    [item addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:item
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
    
    //set horizontal constraints for guide items
    if (row == 0) {
        UIView *positionLayoutGuide = [self positionGuideItemForColumnAtIndex:column];
        UIView *container = self.positionLayoutGuideContainer;
        switch (column) {
            case 0: {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:container
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:positionLayoutGuide
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1
                                                                  constant:0]];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:container
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:positionLayoutGuide
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1
                                                                               constant:0];
                [self addConstraint:constraint];
                self.trailingLayoutConstraint = constraint;
            } break;
                
            default: {
                NSLayoutConstraint *oldTrailingConstraint = self.trailingLayoutConstraint;
                [self removeConstraint:oldTrailingConstraint];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:container
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:positionLayoutGuide
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1
                                                                               constant:0];
                [self addConstraint:constraint];
                self.trailingLayoutConstraint = constraint;
            } break;
        }
    }
    
    //align the item vertically with the guide item for this column
    {
        UIView *layoutGuideForCurrentColumn = [self positionGuideItemForColumnAtIndex:column];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:layoutGuideForCurrentColumn
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
    }
    
    
    
    //set vertical constraints for guide items
    if (column == 0) {
        UIView *positionLayoutGuide = [self positionGuideItemForRowAtIndex:row];
        UIView *container = self.positionLayoutGuideContainer;
        switch (row) {
            case 0: {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:container
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:positionLayoutGuide
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:0]];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:container
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:positionLayoutGuide
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
                [self addConstraint:constraint];
                self.bottomLayoutConstraint = constraint;
            } break;
                
            default: {
                NSLayoutConstraint *oldBottomConstraint = self.bottomLayoutConstraint;
                [self removeConstraint:oldBottomConstraint];
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:container
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:positionLayoutGuide
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
                [self addConstraint:constraint];
                self.bottomLayoutConstraint = constraint;
            } break;
        }
    }
    
    //align the item horizontally with the guide item for this row
    {
        UIView *layoutGuideForCurrentRow = [self positionGuideItemForRowAtIndex:row];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:item
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:layoutGuideForCurrentRow
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
    }
    
    
    [items addObject:item];
}

@end
