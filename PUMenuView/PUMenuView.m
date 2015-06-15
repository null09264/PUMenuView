//
//  PUMenuView.m
//  PUMenuViewDemo
//
//  Created by Wang, Jinghan on 11/06/15.
//  Copyright (c) 2015 Wang, Jinghan. All rights reserved.
//

#import "PUMenuView.h"

#define TAG_BASE 9743

@interface PUMenuView ()

//layout accessory views
@property (nonatomic) UIView *itemTemplate;
@property (nonatomic) UIView *positionLayoutGuideContainer;
@property (nonatomic) UIView *horizontalSpacingLayoutGuideItemTemplate;
@property (nonatomic) NSMutableDictionary *horizontalPositionLayoutGuideItems;
@property (nonatomic) NSMutableDictionary *horizontalSpacingLayoutGuideItems;
@property (nonatomic) UIView *verticalSpacingLayoutGuideItemTemplate;
@property (nonatomic) NSMutableDictionary *verticalPositionLayoutGuideItems;
@property (nonatomic) NSMutableDictionary *verticalSpacingLayoutGuideItems;

//explicit constraints
@property (nonatomic) NSLayoutConstraint *trailingLayoutConstraint;
@property (nonatomic) NSLayoutConstraint *bottomLayoutConstraint;

//visible items
@property (nonatomic) NSMutableArray *items;

//gesture recoginizer
@property (nonatomic) UITapGestureRecognizer *dismissTapGesture;

@end

@implementation PUMenuView {
	NSInteger _completionCount;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.items = [[NSMutableArray alloc]init];
		self.userInfo = [[NSMutableDictionary alloc]init];
		[self registerDefaults];
	}
	return self;
}

- (void)registerDefaults {
	//behavior
	self.menuShouldHideAfterSelection = YES;
	
	//layouts
	self.numberOfColumns = 3;
	self.itemSideLengthMultiplier = 1/5.0;
	self.verticalSpaceMultiplier = 1/15.0;
	self.horizontalMarginMultiplier = 1/12.0;
	
	//animations
	self.animationUnitDelay = 0.05;
	self.animationSpringDamping = 0.8;
	self.animationDuration = 0.5;
	self.animationOrder = @[@1, @0, @2];
	self.animationBackgroundDismissDelay = 0.5;
	self.animationBackgroundDuration = 0.3;
	//background
	UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	UIVisualEffectView * backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
	self.backgroundView = backgroundView;
}

- (void)setBackgroundView:(UIView *)backgroundView {
	_backgroundView = backgroundView;
	backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
	backgroundView.userInteractionEnabled = YES;
	backgroundView.alpha = 0;
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
	[backgroundView addGestureRecognizer:tap];
	self.dismissTapGesture = tap;
	[self addSubview:backgroundView];
	NSDictionary *viewBindings = NSDictionaryOfVariableBindings(backgroundView);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:viewBindings]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:viewBindings]];
}

- (void)setAnimationOrder:(NSArray *)animationOrder {
	NSAssert(animationOrder.count == self.numberOfColumns, @"Order array count must equal to number of columns");
	_animationOrder = animationOrder;
}

- (CGFloat)horizontalSpacingMultiplier {
	return (1 - 2 * self.horizontalMarginMultiplier - 3 * self.itemSideLengthMultiplier) / (self.numberOfColumns - 1);
}

- (void)setDataSource:(NSObject<PUMenuViewDataSource> *)dataSource {
	_dataSource = dataSource;
	[self setUpLayoutGuides];
	[self setUpItems];
	[self prepare];
}

#pragma mark - show and hide animation

- (void)prepare {
	if (self.readyForShowing && self.isAnimationPresenting) {
		return;
	}
	[self setNeedsLayout];
	[self layoutIfNeeded];
	
	for (UIView *item in self.items) {
		CGPoint center = item.center;
		center.y += CGRectGetHeight([UIScreen mainScreen].bounds);
		item.center = center;
		item.alpha = 0;
	}
	
	_completionCount = 0;
	self.readyForShowing = YES;
	self.isHidden = YES;
	self.isAnimationPresenting = NO;
}

- (void)show {
	[self prepare];
	
	if (self.isAnimationPresenting || !self.isHidden || !self.readyForShowing) {
		return;
	}
	
	NSObject<PUMenuViewDelegate> *delegate = self.delegate;
	[self performOptionSelector:@selector(menuViewWillShow:) on:delegate withObject:self];
	self.isAnimationPresenting = YES;
	[UIView animateWithDuration:self.animationBackgroundDuration animations:^(void){
		self.backgroundView.alpha = 1;
	}];
	
	for (int i = 0; i < self.items.count; i++) {
		UIView *item = self.items[i];
		[item setNeedsLayout];
		NSNumber *order = self.animationOrder[i % self.numberOfColumns];
		[UIView animateWithDuration:self.animationDuration
							  delay:self.animationUnitDelay * (order.doubleValue + 2 * i / self.numberOfColumns)
			 usingSpringWithDamping:self.animationSpringDamping
			  initialSpringVelocity:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^(void) {
							 item.alpha = 1;
							 [item layoutIfNeeded];
						 } completion:^(BOOL finished){
							 self.isAnimationPresenting = NO;
							 self.isHidden = NO;
							 self.readyForShowing = NO;
							 [self itemDidShow];
						 }];
	}
}

- (void)itemDidShow {
	_completionCount++;
	if (_completionCount == self.items.count) {
		[self performOptionSelector:@selector(menuViewDidShow:) on:self.delegate withObject:self];
		_completionCount = 0;
	}
}

- (void)hide {
	
	if (self.isAnimationPresenting || self.isHidden || self.readyForShowing) {
		return;
	}
	
	NSObject<PUMenuViewDelegate> *delegate = self.delegate;
	[self performOptionSelector:@selector(menuViewWillHide:) on:delegate withObject:self];
	self.isAnimationPresenting = YES;
	
	[UIView animateWithDuration:self.animationBackgroundDuration
						  delay:self.animationBackgroundDismissDelay
						options:0
					 animations:^(void){
						 self.backgroundView.alpha = 0;
					 } completion:nil];
	
	for (int i = 0; i < self.items.count; i++) {
		UIView *item = self.items[i];
		[item setNeedsLayout];
		NSNumber *order = self.animationOrder[i % self.numberOfColumns];
		[UIView animateWithDuration:self.animationDuration
							  delay:self.animationUnitDelay * (order.doubleValue + 2 * i / self.numberOfColumns)
			 usingSpringWithDamping:self.animationSpringDamping
			  initialSpringVelocity:0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^(void) {
							 CGPoint center = item.center;
							 CGFloat farestDistance = CGRectGetHeight(self.positionLayoutGuideContainer.bounds)/2 + self.positionLayoutGuideContainer.center.y;
							 center.y -= farestDistance;
							 item.center = center;
							 item.alpha = 0;
						 } completion:^(BOOL finished){
							 self.isAnimationPresenting = NO;
							 self.isHidden = YES;
							 self.readyForShowing = NO;
							 [self itemDidHide];
						 }];
	}
}

- (void)itemDidHide {
	_completionCount++;
	if (_completionCount == self.items.count) {
		[self performOptionSelector:@selector(menuViewDidHide:) on:self.delegate withObject:self];
		[self prepare];
		_completionCount = 0;
	}
}

#pragma mark - button configuration

- (void)setUpItems {
	NSObject<PUMenuViewDataSource> *dataSrouce = self.dataSource;
	NSAssert(dataSrouce != nil, @"DataSource is nil.");
	
	if ([dataSrouce respondsToSelector:@selector(menuView:buttonForItemAtIndex:)]) {
		for (int index = 0; index < [dataSrouce numberOfItemsInMenuView:self]; index++) {
			UIButton *button = [dataSrouce menuView:self buttonForItemAtIndex:index];
			[button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = index + TAG_BASE;
			[self addItem:button];
		}
	} else if ([dataSrouce respondsToSelector:@selector(menuView:viewForItemAtIndex:)]){
		for (int index = 0; index < [dataSrouce numberOfItemsInMenuView:self]; index++) {
			UIView *view = [dataSrouce menuView:self viewForItemAtIndex:index];
			if ([view isKindOfClass:[PUMenuItem class]]) {
				UIButton *button = ((PUMenuItem *)view).button;
				[button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
				button.tag = index + TAG_BASE;
			} else {
				view.tag = index + TAG_BASE;
				UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDidTap:)];
				[view addGestureRecognizer:tap];
			}
			[self addItem:view];
		}
	}
}

#pragma mark - event handler

- (void)buttonDidClick:(UIButton *)button {
	NSObject<PUMenuViewDelegate> *delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(menuView:itemDidSelectAtIndex:)]) {
		[delegate menuView:self itemDidSelectAtIndex:button.tag - TAG_BASE];
	}
	
	if (self.menuShouldHideAfterSelection) {
		[self hide];
	}
}

- (void)viewDidTap:(UITapGestureRecognizer *)recognizer {
	if (recognizer == self.dismissTapGesture) {
		[self hide];
		return;
	}
	
	NSObject<PUMenuViewDelegate> *delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(menuView:itemDidSelectAtIndex:)]) {
		[delegate menuView:self itemDidSelectAtIndex:recognizer.view.tag - TAG_BASE];
	}
	
	if (self.menuShouldHideAfterSelection) {
		[self hide];
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
													multiplier:self.itemSideLengthMultiplier
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
													multiplier:self.horizontalSpacingMultiplier
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
													multiplier:self.verticalSpaceMultiplier
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
	NSInteger numberOfColumns = self.numberOfColumns;
	NSInteger row = index / numberOfColumns;
	NSInteger column = index % numberOfColumns;
	
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void) performOptionSelector:(SEL)selector on:(NSObject *)subject withObject:(NSObject *)object{
	if (subject && [subject respondsToSelector:selector]) {
		[subject performSelector:selector withObject:object];
	}
}
#pragma clang diagnostic pop

@end
