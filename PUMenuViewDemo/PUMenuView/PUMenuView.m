//
//  PUMenuView.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "PUMenuView.h"

#define NUMBER_OF_COLUMN 3
#define CELL_SIDE_LENGTH_MULTIPLIER 1/9
#define VERTICAL_SPACE_MULTIPLIER 1/12
#define HORIZONTAL_MARGIN_MULTIPLIER 1/12
#define HORIZONTAL_SPACING_MULTIPLIER (1 - 2 * HORIZONTAL_MARGIN_MULTIPLIER) / (NUMBER_OF_COLUMN - 1)

@interface PUMenuView ()

@property UIView *horizontalPositionLayoutGuide;
@property UIView *horizontalSpacingLayoutGuide;
@property UIView *verticalPositionLayoutGuide;
@property UIView *verticalSpacingLayoutGuide;

@property NSLayoutConstraint *bottomLayoutConstraint;

@property NSMutableArray *cells;

@end

@implementation PUMenuView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setUpLayoutGuides];
		self.cells = [[NSMutableArray alloc]init];
	}
	return self;
}

- (void)setUpLayoutGuides {
	[self setUpHorizontalPositionLayoutGuide];
	[self setUpHorizontalSpacingLayoutGuide];
	[self setUpVerticalPositionLayoutGuide];
	[self setUpVerticalSpacingLayoutGuide];
}

- (void)setUpHorizontalPositionLayoutGuide {
	UIView *guide = [[UIView alloc]init];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:guide
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:HORIZONTAL_MARGIN_MULTIPLIER
													  constant:0]];
	self.horizontalPositionLayoutGuide = guide;
}

- (void)setUpHorizontalSpacingLayoutGuide {
	UIView *guide = [[UIView alloc]init];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:guide
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeWidth
													multiplier:HORIZONTAL_SPACING_MULTIPLIER
													  constant:0]];
	self.horizontalSpacingLayoutGuide = guide;
}

- (void)setUpVerticalPositionLayoutGuide {
	UIView *guide = [[UIView alloc]init];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:guide
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterY
													multiplier:1
													  constant:0]];
	self.verticalPositionLayoutGuide = guide;
}

- (void)setUpVerticalSpacingLayoutGuide {
	UIView *guide = [[UIView alloc]init];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:guide
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeHeight
													multiplier:VERTICAL_SPACE_MULTIPLIER
													  constant:0]];
	self.verticalSpacingLayoutGuide = guide;
}

- (void)addCell: (UIView *)cell {
	//update constraints
	NSMutableArray *cells = self.cells;
	NSInteger index = cells.count;
	NSInteger row = index / NUMBER_OF_COLUMN;
	NSInteger column = index % NUMBER_OF_COLUMN;
	
	//constrant: cell.width = cell.height
	[cell addConstraint:[NSLayoutConstraint constraintWithItem:cell
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:cell
													 attribute:NSLayoutAttributeHeight
													multiplier:1
													  constant:0]];
	
	//horizontal constraint
	if (row == 0) {
		//set up constaints
		switch (column) {
			case 0: {
				//set up leading constraint with leadingLayoutGuide
			} break;
				
			default: {
				//set up top constraint with last cell
			} break;
		}
	} else {
		//align the cell horizontally with the cell at index % NUMBER_OF_COLUMN
	}

	
	//vertical constraints
	if (column == 0) {
		switch (row) {
			case 0: {
				//set up top constraint with verticalPositionLayoutGuide
				//init self.bottomLayoutConstraint
			} break;
				
			default: {
				//get a new verticalSpacingLayoutGuide
				//set up topconstraint with verticalSpacingLayoutGuide
				//update self.bottomLayoutConstraint
			} break;
		}
	} else {
		//align the cell vertically with cell at row * NUMBER_OF_COLUMN
	}

	
	[cells addObject:cell];
}

- (UIView *)getNewVerticalSpacingGuide {
	UIView *spacingGuide = [[UIView alloc]init];
	
	//insert at the lowest level in the hierachy
	[self insertSubview:spacingGuide atIndex:0];
	
	//set up height constaints
	[self addConstraint:[NSLayoutConstraint constraintWithItem:spacingGuide
													 attribute:NSLayoutAttributeHeight
													 relatedBy:NSLayoutRelationEqual
														toItem:self.verticalSpacingLayoutGuide
													 attribute:NSLayoutAttributeHeight
													multiplier:1
													  constant:0]];
	return spacingGuide;
}

- (void)reloadContent {
	
}

@end
