//
//  PUMenuView.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "PUMenuView.h"

#define NUMBER_OF_COLUMN 3
#define CELL_SIDE_LENGTH_MULTIPLIER 1/5.0
#define VERTICAL_SPACE_MULTIPLIER 1/12.0
#define HORIZONTAL_MARGIN_MULTIPLIER 1/12.0
#define HORIZONTAL_SPACING_MULTIPLIER (1 - 2 * HORIZONTAL_MARGIN_MULTIPLIER - 3 * CELL_SIDE_LENGTH_MULTIPLIER) / (NUMBER_OF_COLUMN - 1)

@interface PUMenuView ()

@property UIView *cellTemplate;

@property UIView *positionLayoutGuideContainer;

@property UIView *horizontalSpacingLayoutGuideCellTemplate;
@property NSMutableDictionary *horizontalPositionLayoutGuideCells;
@property NSMutableDictionary *horizontalSpacingLayoutGuideCells;

@property UIView *verticalSpacingLayoutGuideCellTemplate;
@property NSMutableDictionary *verticalPositionLayoutGuideCells;
@property NSMutableDictionary *verticalSpacingLayoutGuideCells;

@property NSLayoutConstraint *trailingLayoutConstraint;
@property NSLayoutConstraint *bottomLayoutConstraint;


//cells
@property NSMutableArray *cells;
@property NSMutableArray *cellVerticalConstraints;

@end

@implementation PUMenuView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.cells = [[NSMutableArray alloc]init];
        [self setUpLayoutGuides];
	}
	return self;
}

- (void)setUpLayoutGuides {
    [self setUpCellTemplate];
	[self setUpPositionLayoutGuideContainer];
	[self setUpHorizontalSpacingLayoutGuideCellTemplate];
	[self setUpVerticalSpacingLayoutGuide];
}

- (void)setUpCellTemplate {
    UIView *template = [[UIView alloc]init];
    template.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:template atIndex:0];
    
    //constraint: cell.width = x * self.width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:template
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:CELL_SIDE_LENGTH_MULTIPLIER
                                                          constant:0]];
    
    //constraint: cell.width = cell.height
    [template addConstraint:[NSLayoutConstraint constraintWithItem:template
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:template
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
    self.cellTemplate = template;
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

- (void)setUpHorizontalSpacingLayoutGuideCellTemplate {
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
	self.horizontalSpacingLayoutGuideCellTemplate = template;
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
	self.verticalSpacingLayoutGuideCellTemplate = guide;
}

- (void)addCell: (UIView *)cell {
	//update constraints
	NSMutableArray *cells = self.cells;
    cell.translatesAutoresizingMaskIntoConstraints = NO;
	NSInteger index = cells.count;
	NSInteger row = index / NUMBER_OF_COLUMN;
	NSInteger column = index % NUMBER_OF_COLUMN;
    
    [self addSubview:cell];
    
    //constraint: cell.width = cellTemplate.width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:cell
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.cellTemplate
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
	//constraint: cell.width = cell.height
	[cell addConstraint:[NSLayoutConstraint constraintWithItem:cell
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:cell
													 attribute:NSLayoutAttributeHeight
													multiplier:1
													  constant:0]];
	
	//set horizontal constraints for guide cells
	if (row == 0) {
        UIView *positionLayoutGuide = [self positionGuideCellForColumnAtIndex:column];
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
    
    //align the cell vertically with the guide cell for this row
    {
        UIView *layoutGuideForCurrentColumn = [self positionGuideCellForColumnAtIndex:column];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:cell
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:layoutGuideForCurrentColumn
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
	}

	
    
	//set vertical constraints for guide cells
	if (column == 0) {
        UIView *positionLayoutGuide = [self positionGuideCellForRowAtIndex:row];
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
    
    {
        UIView *layoutGuideForCurrentRow = [self positionGuideCellForRowAtIndex:row];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:cell
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:layoutGuideForCurrentRow
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
    }

	
	[cells addObject:cell];
}

- (UIView *)positionGuideCellForRowAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Row index must be non-negative");
    
    NSMutableDictionary *guideCells = self.verticalPositionLayoutGuideCells;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideCell = [guideCells objectForKey:indexKey];
    
    if (!guideCell) {
        guideCell = [[UIView alloc]init];   
        guideCell.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideCell atIndex:0];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.cellTemplate
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        if (index == 0) {
            //constraint with top
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.positionLayoutGuideContainer
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0]];
        } else {
            //constraint with spacingGuideCell bottom
            UIView *spacingGuideCell = [self spacingGuideCellAfterRowAtIndex:index - 1];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:spacingGuideCell
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0]];
        }
        
        [guideCells setObject:guideCell forKey:indexKey];
    }
    
    return guideCell;
}

- (UIView *)spacingGuideCellAfterRowAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Row index must be non-negative");
    
    NSMutableDictionary *guideCells = self.verticalSpacingLayoutGuideCells;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideCell = [guideCells objectForKey:indexKey];
    
    if (!guideCell) {
        guideCell = [[UIView alloc]init];
        guideCell.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideCell atIndex:0];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.verticalSpacingLayoutGuideCellTemplate
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        UIView *positionGuideCell = [self positionGuideCellForRowAtIndex:index];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:positionGuideCell
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
        [guideCells setObject:guideCell forKey:indexKey];
    }
    
    return guideCell;
}

- (UIView *)positionGuideCellForColumnAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Column index must be non-negative");
    
    NSMutableDictionary *guideCells = self.horizontalPositionLayoutGuideCells;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideCell = [guideCells objectForKey:indexKey];
    
    if (!guideCell) {
        guideCell = [[UIView alloc]init];
        guideCell.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideCell atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.cellTemplate
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        if (index == 0) {
            //constraint with leading
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.positionLayoutGuideContainer
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:0]];
        } else {
            //constraint with spacingGuideCell trailing
            UIView *spacingGuideCell = [self spacingGuideCellAfterColumnAtIndex:index - 1];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:spacingGuideCell
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1
                                                              constant:0]];
        }
        
        [guideCells setObject:guideCell forKey:indexKey];
    }
    
    return guideCell;
}

- (UIView *)spacingGuideCellAfterColumnAtIndex:(NSInteger)index {
    NSAssert(index >= 0, @"Column index must be non-negative");
    
    NSMutableDictionary *guideCells = self.horizontalSpacingLayoutGuideCells;
    NSNumber *indexKey = [NSNumber numberWithInteger:index];
    UIView *guideCell = [guideCells objectForKey:indexKey];
    
    if (!guideCell) {
        guideCell = [[UIView alloc]init];
        guideCell.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:guideCell atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.horizontalSpacingLayoutGuideCellTemplate
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        UIView *positionGuideCell = [self positionGuideCellForColumnAtIndex:index];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:guideCell
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:positionGuideCell
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
        [guideCells setObject:guideCell forKey:indexKey];
    }
    
    return guideCell;
}


- (void)reloadContent {
	
}

@end
