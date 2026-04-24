#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Utils/NSBundle+YTMU.h"

// MARK: - Splash Screen Handler

static NSString *const kSplashScreenDismissedKey = @"YTMUSplashScreenDismissed";
static BOOL splashHasShown = NO;
static __weak UIView *currentSplashView = nil;

static void openTelegram(void) {
    NSURL *url = [NSURL URLWithString:@"https://t.me/IL_Apk"];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

static void closeSplash(void) {
    UIView *splash = currentSplashView;
    if (!splash) return;

    // Mark as permanently dismissed
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSplashScreenDismissedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [UIView animateWithDuration:0.3 animations:^{
        splash.alpha = 0;
    } completion:^(BOOL finished) {
        [splash removeFromSuperview];
    }];
}

// Button action selectors need an NSObject target
@interface YTMUSplashActions : NSObject
+ (void)telegramTapped;
+ (void)closeTapped;
@end

@implementation YTMUSplashActions
+ (void)telegramTapped {
    openTelegram();
}
+ (void)closeTapped {
    closeSplash();
}
@end

static void buildAndPresentSplash(UIWindow *window) {
    UIView *splash = [[UIView alloc] initWithFrame:window.bounds];
    splash.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.12 alpha:1.0];
    splash.alpha = 0;
    splash.tag = 999222;
    splash.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    currentSplashView = splash;

    // ── Scroll view for content ──
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:splash.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsVerticalScrollIndicator = NO;
    [splash addSubview:scrollView];

    // ── Content container ──
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor],
    ]];

    // ── Title: ברוכים הבאים 👋 ──
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"ברוכים הבאים 👋";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];

    // ── Subtitle: Credit ──
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"אפליקציות פרוצות לאייפון ❄️";
    subtitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:subtitleLabel];

    // ── Logo image ──
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.clipsToBounds = YES;
    logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:logoImageView];

    // Load logo from the tweak bundle
    NSString *logoPath = [NSBundle.ytmu_defaultBundle pathForResource:@"splash_logo" ofType:@"png"];
    if (logoPath) {
        logoImageView.image = [UIImage imageWithContentsOfFile:logoPath];
    }

    // ── Heart emoji ──
    UILabel *heartLabel = [[UILabel alloc] init];
    heartLabel.text = @"❤️";
    heartLabel.font = [UIFont systemFontOfSize:40];
    heartLabel.textAlignment = NSTextAlignmentCenter;
    heartLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:heartLabel];

    // ── Telegram button ──
    UIButton *telegramButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [telegramButton setTitle:@"הטלגרם שלנו 👾" forState:UIControlStateNormal];
    telegramButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [telegramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    telegramButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]; // YouTube red
    telegramButton.layer.cornerRadius = 14;
    telegramButton.clipsToBounds = YES;
    telegramButton.translatesAutoresizingMaskIntoConstraints = NO;
    [telegramButton addTarget:[YTMUSplashActions class] action:@selector(telegramTapped) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:telegramButton];

    // ── Close button ──
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"סגירה" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.35 alpha:1.0]; // Dark gray
    closeButton.layer.cornerRadius = 14;
    closeButton.clipsToBounds = YES;
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:[YTMUSplashActions class] action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];

    // ── Layout constraints ──
    CGFloat padding = 30;

    [NSLayoutConstraint activateConstraints:@[
        // Title
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:80],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],

        // Subtitle
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],

        // Logo
        [logoImageView.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:30],
        [logoImageView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [logoImageView.widthAnchor constraintEqualToConstant:200],
        [logoImageView.heightAnchor constraintEqualToConstant:200],

        // Heart
        [heartLabel.topAnchor constraintEqualToAnchor:logoImageView.bottomAnchor constant:25],
        [heartLabel.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],

        // Telegram button
        [telegramButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [telegramButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],
        [telegramButton.heightAnchor constraintEqualToConstant:52],

        // Close button
        [closeButton.topAnchor constraintEqualToAnchor:telegramButton.bottomAnchor constant:12],
        [closeButton.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:padding],
        [closeButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-padding],
        [closeButton.heightAnchor constraintEqualToConstant:52],
        [closeButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-50],
    ]];

    // Push Telegram button toward the bottom with a low-priority constraint
    NSLayoutConstraint *telegramTopGreater = [telegramButton.topAnchor constraintGreaterThanOrEqualToAnchor:heartLabel.bottomAnchor constant:40];
    telegramTopGreater.active = YES;

    NSLayoutConstraint *bottomPush = [telegramButton.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:window.bounds.size.height - 200];
    bottomPush.priority = UILayoutPriorityDefaultLow;
    bottomPush.active = YES;

    // ── Add to window and animate ──
    [window addSubview:splash];

    [UIView animateWithDuration:0.35 animations:^{
        splash.alpha = 1;
    }];

    // Subtle heart pulse animation
    [UIView animateWithDuration:1.2
                          delay:0.5
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
        heartLabel.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:nil];
}

static void showSplash(UIWindow *window) {
    // If user already dismissed the splash once, never show again
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSplashScreenDismissedKey]) return;
    if (splashHasShown) return;
    splashHasShown = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        buildAndPresentSplash(window);
    });
}

// MARK: - UIWindow Hook to trigger splash screen

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    showSplash(self);
}

%end
