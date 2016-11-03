//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

static NSString * const kAlertIcon = @"icon";
static NSString * const kAlertTitle = @"title";
static NSString * const kAlertColor = @"color";
static NSString * const kAlertFont = @"font";
static NSString * const kBackgroundColor = @"bg_color";

@protocol CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomIOSAlertView : UIView<CustomIOSAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, assign) id<CustomIOSAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex) ;

+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset;
+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset andURL:(NSURL *)url;
+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withOffset:(CGFloat)offset padding:(CGFloat)padding width:(CGFloat)width height:(CGFloat)height cornerRadius:(CGFloat)cornerRadius preloadImage:(UIImage *)preloadImage andURL:(NSURL *)url;
+ (UIView *)viewWithString:(NSAttributedString *)string inRect:(CGRect)rect withPadding:(CGFloat)padding andImage:(UIImage *)image;

- (id)init;

/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
