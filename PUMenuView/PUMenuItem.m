//
//  PUMenuItem.m
//  PUMenuViewDemo
//
//  Created by NULL on 14/06/15.
//  Copyright (c) 2015年 Wang, Jinghan. All rights reserved.
//

#import "PUMenuItem.h"

@implementation PUMenuItem

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self configureButton];
		[self configureLabel];
		[self configureLayout];
	}
	return self;
}

- (instancetype)init {
	return [self initWithFrame:CGRectZero];
}

- (void)configureButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:button];
	self.button = button;
}

- (void)configureLabel {
	UILabel *label = [[UILabel alloc]init];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	label.font = [UIFont systemFontOfSize:12];
	[self addSubview:label];
	self.label = label;
}

- (void)configureLayout {
	UIButton *button = self.button;
	UILabel *label = self.label;
	NSDictionary *viewBindings = NSDictionaryOfVariableBindings(button, label);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]-10-[label(12)]|"
																 options:NSLayoutFormatAlignAllCenterX
																 metrics:nil
																   views:viewBindings]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:button
													 attribute:NSLayoutAttributeWidth
													 relatedBy:NSLayoutRelationEqual
														toItem:button
													 attribute:NSLayoutAttributeHeight
													multiplier:1
													  constant:0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:button
													 attribute:NSLayoutAttributeCenterX
													multiplier:1
													  constant:0]];
}

@end
