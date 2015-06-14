## PUMenuView
PUMenuView is a "tumblr" style popping menu view. It is built with Objective C and fully backed by Auto Layout. With PUMenuView, you can animate the menu easily and add as many menu items as you wish.

=====

####Using with CocoaPods

`pod 'PUMenuView', '~> 1.0.0'`

=====

####DataSource Methods


#####Necessary:
```objc
-(NSInteger)numberOfItemsInMenuView:(PUMenuView *)menuView;
```
This method is necessary because it feeds the view how many menu items it need to display. Since it is must-have info for the menu to layout its subview, it must be implemented by the datasource instance.

#####Optional:
```objc
-(UIButton *)menuView:(PUMenuView *)menuView buttonForItemAtIndex:(NSInteger)index;
```

This method provides the menu the buttons it needs to show. These buttons will serve as the menu items inside the menu. After the buttons are passed in, the menu view will index them and assign the index to their tags. When the buttons are clicked, the delegate method `menuView: itemDidSelectAtIndex:` will be called.

```objc
-(UIView *)menuView:(PUMenuView *)menuView viewForItemAtIndex:(NSInteger)index;
```

This method provides the menu the customized views it needs to show. This method has a lower priority than `menuView:menuView buttonForItemAtIndex:`, which means when `menuView:buttonForItemAtIndex:` is implemented in the datasource, this method won't be called. After the view is passed in, the menu view will attach an UITapGestureRecognizer onto the view. One the view is tapped, the delegate `menuView:itemDidSelectAtIndex:` will be triggered.


####Delegate Methods

```objc
- (void)menuView:(PUMenuView *) menuView itemDidSelectAtIndex:(NSInteger)index;
- (void)menuViewWillShow:(PUMenuView *)menuView;
- (void)menuViewDidShow:(PUMenuView *)menuView;
- (void)menuViewWillHide:(PUMenuView *)menuView;
- (void)menuViewDidHide:(PUMenuView *)menuView;
```

=====

####Parameters
```objc
@property (nonatomic, weak) NSObject<PUMenuViewDelegate> *delegate;
@property (nonatomic, weak) NSObject<PUMenuViewDataSource> *dataSource;

@property (nonatomic, strong) UIView *backgroundView;

//behavior
@property (nonatomic) BOOL menuShouldHideAfterSelection;

//state
@property (nonatomic) BOOL isAnimationPresenting;
@property (nonatomic) BOOL isHidden;
@property (nonatomic) BOOL readyForShowing;

//animation (show & hide)
@property (nonatomic) CGFloat animationUnitDelay;
@property (nonatomic) CGFloat animationSpringDamping;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) NSArray *animationOrder;

//layout
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat itemSideLengthMultiplier;
@property (nonatomic) CGFloat verticalSpaceMultiplier;
@property (nonatomic) CGFloat horizontalMarginMultiplier;
@property (nonatomic, readonly) CGFloat horizontalSpacingMultiplier;
```

##PUMenuItem
PUMenuItem is a container which combines a UIButton instance and a UILabel instance. PUMenuItem can be passes to PUMenuView via the datasource method `menuView:viewForItemAtIndex:`. In this case the UIControlEvent for the UIButton inside the PUMenuItem will be picked by the menuView and passed out view the delegate method `menuView:itemDidSelectAtIndex:`.

####Parameters
```objc
@property (nonatomic) UIButton *button;
@property (nonatomic) UILabel *label;
```
