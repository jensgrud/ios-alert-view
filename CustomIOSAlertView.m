//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOSAlertView.h"
#import <QuartzCore/QuartzCore.h>

@import SDWebImage;

const static CGFloat kCustomIOSAlertViewDefaultButtonHeight       = 56;
const static CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight = .5;
const static CGFloat kCustomIOSAlertViewCornerRadius              = 5;
const static CGFloat kCustomIOS7MotionEffectExtent                = 10.0;

@implementation CustomIOSAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonTitles;
@synthesize useMotionEffects;

- (id)initWithParentView: (UIView *)_parentView
{
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        delegate = self;
        useMotionEffects = YES;
        buttonTitles = @[@"Close"];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    dialogView = [self createContainerView];
  
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    self.gestureRecognizers = @[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)]];

    [self addSubview:dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (parentView != NULL) {
        [parentView addSubview:self];

    // Attached to the top most window
    } else {

        // On iOS7, calculate with orientation
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        // On iOS8, just place the dialog in the middle
        } else {

            CGSize screenSize = [self countScreenSize];
            CGSize dialogSize = [self countDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);

            dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);

        }

        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }

    dialogView.layer.opacity = 0.5f;
    dialogView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    
    CGFloat duration = .7;
    
    [UIView animateWithDuration:duration/3 delay:0.0 options:0 animations:^{
    
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
        dialogView.layer.opacity = 1.0f;
        dialogView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration/2 animations:^{
            dialogView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }];

}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }

    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Default button behaviour
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self close];
}

// Dialog close animation then cleaning and removing the view from the parent

- (void)close:(UITapGestureRecognizer *)recognizer
{
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:-1];
    }
    
    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, -1);
    }
}

- (void)closeFromButton:(UITapGestureRecognizer *)recognizer
{
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:-2];
    }
    
    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, -2);
    }
}

- (void)close
{
    CATransform3D currentTransform = dialogView.layer.transform;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

        dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }

    dialogView.layer.opacity = 1.0f;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         for (UIView *view in self.subviews) {
                             view.alpha = 0.0;
                         }
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *view in self.subviews) {
                             [view removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }

    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];

    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];

    dialogContainer.backgroundColor = [UIColor whiteColor];
    dialogContainer.layer.cornerRadius = kCustomIOSAlertViewCornerRadius + 1;

    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];

    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];

    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    UIImage *closeimage = [UIImage imageNamed:@"CancelButton"];
    UIImageView *close = [[UIImageView alloc] initWithImage:closeimage];
    close.frame = (CGRect) {dialogContainer.frame.size.width - closeimage.size.width/2 - 4, - closeimage.size.height/2 + 4, closeimage.size};
    close.image = closeimage;
    
    
    close.userInteractionEnabled = YES;
    close.gestureRecognizers = @[
                                 [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFromButton:)]
                                 ];
    
    [dialogContainer addSubview:close];

    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (buttonTitles==NULL) { return; }

    CGFloat buttonWidth = container.bounds.size.width / [buttonTitles count];

    for (int i=0; i<[buttonTitles count]; i++) {

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)];

        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];

        [closeButton setTitle:buttonTitles[i][kAlertTitle] forState:UIControlStateNormal];
        if (buttonTitles[i][kBackgroundColor]) {
            [closeButton setBackgroundColor:buttonTitles[i][kBackgroundColor]];
        }
        [closeButton setTitleColor:[buttonTitles[i][kAlertColor] colorWithAlphaComponent:1.0] forState:UIControlStateNormal];
        [closeButton setTitleColor:[buttonTitles[i][kAlertColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:buttonTitles[i][kAlertFont]];

        [container addSubview:closeButton];
        
        if (buttonTitles.count > 0 && i < buttonTitles.count - 1) {
            
            // There is a line above the button
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((i + 1) * buttonWidth, container.bounds.size.height - buttonHeight, buttonSpacerHeight, buttonHeight)];
            lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
            [container addSubview:lineView];
        }
        
        if (buttonTitles.count == 1) {
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:closeButton.bounds
                                                           byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(kCustomIOSAlertViewCornerRadius, kCustomIOSAlertViewCornerRadius)];
            
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = maskPath.CGPath;
            closeButton.layer.mask = maskLayer;
        }
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kCustomIOSAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// Rotation changed, on iOS7
- (void)changeOrientationForIOS7 {

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
            
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.transform = rotation;
                         
                     }
                     completion:nil
     ];
    
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8: (NSNotification *)notification {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
    

}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (parentView != NULL) {
        return;
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

#pragma mark

+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset
{
    return [self viewWithString:string inRect:rect withOffset:offset andURL:nil];
}

+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset andURL:(NSURL *)url
{
    CGFloat padding = 16;
    CGFloat width = 76;
    CGFloat height = 76;
    CGFloat cornerRadius = 3;
    
    return [self viewWithString:string inRect:rect withOffset:offset padding:padding width:width height:height cornerRadius:cornerRadius preloadImage:nil andURL:url];
}

+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset padding:(CGFloat)padding width:(CGFloat)width height:(CGFloat)height cornerRadius:(CGFloat)cornerRadius preloadImage:(UIImage *)preloadImage andURL:(NSURL *)url
{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rect.size.width/2 - width/2, padding * 2, width, height)];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView.layer setCornerRadius:cornerRadius];
    [imageView setClipsToBounds:YES];
    
    imageView.alpha = preloadImage == nil ? 0.0 : 1.0;
    
    [imageView sd_setImageWithURL:url placeholderImage:preloadImage options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType type, NSURL *url) {
        
        [UIView animateWithDuration:.5 animations:^{
            
            imageView.alpha = 1.0;
        }];
    }];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(padding, offset, rect.size.width - padding * 2, rect.size.height)];
    info.textAlignment = NSTextAlignmentCenter;
    info.textColor = [UIColor colorWithRed:.46 green:.46 blue:.46 alpha:1.0];
    info.attributedText = string;
    info.numberOfLines = 20;    
    
    [view addSubview:imageView];
    [view addSubview:info];
    
    return view;
}

+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withPadding:(CGFloat)padding andImage:(UIImage *)image
{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView.layer setCornerRadius:3.0];
    [imageView setClipsToBounds:YES];
    [imageView setCenter:CGPointMake(rect.size.width/2, imageView.frame.size.height/2 + padding * 2)];
    
    UILabel *info = [[UILabel alloc] init];
    info.textAlignment = NSTextAlignmentCenter;
    info.textColor = [UIColor colorWithRed:.46 green:.46 blue:.46 alpha:1.0];
    info.attributedText = string;
    info.numberOfLines = 10;
    [info sizeToFit];
    
    info.center = CGPointMake(rect.size.width/2, imageView.frame.size.height + info.frame.size.height/2 + padding * 3);
    
    [view addSubview:imageView];
    [view addSubview:info];
    
    return view;
}

@end
