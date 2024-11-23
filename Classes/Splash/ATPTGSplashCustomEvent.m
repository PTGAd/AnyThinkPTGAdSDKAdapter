//
//  ATPTGSplashCustomEvent.m
//  AnyThinkSDKDemo
//

//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import "ATPTGSplashCustomEvent.h"

@implementation ATPTGSplashCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (void)removeCustomViewAndsplashAd:(PTGSplashAd *)splashAd {
    
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    
    if (splashAd) {
        splashAd = nil;
    }
}

#pragma mark - PTGSplashAdDelegate -
/// 开屏加载成功
- (void)ptg_splashAdDidLoad:(PTGSplashAd *)splashAd {
    NSLog(@"开屏广告%s",__func__);
    self.isReady = true;
    [self trackSplashAdLoaded:splashAd adExtra:nil];
}

/// 开屏加载失败
- (void)ptg_splashAd:(PTGSplashAd *)splashAd didFailWithError:(NSError *)error {
    NSLog(@"开屏广告请求失败%@",error);
    self.isReady = false;
    [self removeCustomViewAndsplashAd:splashAd];
    [self trackSplashAdLoadFailed:error];
}

/// 开屏广告被点击了
- (void)ptg_splashAdDidClick:(PTGSplashAd *)splashAd {
    NSLog(@"开屏广告%s",__func__);
    [self removeCustomViewAndsplashAd:splashAd];
    [self trackSplashAdClick];
}

/// 开屏广告关闭了
- (void)ptg_splashAdDidClose:(PTGSplashAd *)splashAd {
    NSLog(@"开屏广告%s",__func__);
    [self removeCustomViewAndsplashAd:splashAd];
    [self trackSplashAdClosed:nil];
}

///  开屏广告将要展示
- (void)ptg_splashAdWillVisible:(PTGSplashAd *)splashAd {
    NSLog(@"开屏广告%s",__func__);
    [self trackSplashAdShow];
}

@end

