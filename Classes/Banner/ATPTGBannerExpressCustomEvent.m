//
//  ATPTGBannerExpressCustomEvent.m
//  PTGSDKDemo
//
//  Created byttt on 2024/11/12.
//

#import "ATPTGBannerExpressCustomEvent.h"


@interface ATPTGBannerView : UIView

@property(nonatomic,strong)PTGNativeExpressBannerAd *bannerAd;

@end

@implementation ATPTGBannerExpressCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

///  广告加载成功
///  在此方法中调用 showAdFromView:frame 方法
- (void)ptg_nativeExpressBannerAdDidLoad:(PTGNativeExpressBannerAd *)bannerAd {
    ATPTGBannerView *adView = [[ATPTGBannerView alloc] init];
    adView.bannerAd = bannerAd;
    adView.frame = CGRectMake(0, 0, bannerAd.realSize.width, bannerAd.realSize.height);
    self.isReady = true;
    [self trackBannerAdLoaded:adView adExtra:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [bannerAd showAdFromView:adView frame:adView.bounds];
    });
}

/// 广告加载失败
- (void)ptg_nativeExpressBannerAd:(PTGNativeExpressBannerAd *)bannerAd didLoadFailWithError:(NSError *_Nullable)error {
    self.isReady = false;
    [self trackBannerAdLoadFailed:error];
}

/// 广告将要曝光
- (void)ptg_nativeExpressBannerAdWillBecomVisible:(PTGNativeExpressBannerAd *)bannerAd {
    [self trackBannerAdImpression];
}

/// 广告被点击
- (void)ptg_nativeExpressBannerAdDidClick:(PTGNativeExpressBannerAd *)bannerAd {
    [self trackBannerAdClick];
}
 
/// 广告被关闭
- (void)ptg_nativeExpressBannerAdClosed:(PTGNativeExpressBannerAd *)bannerAd {
    [self trackBannerAdClosed];
}

/// 广告详情页给关闭
- (void)ptg_nativeExpressBannerAdViewDidCloseOtherController:(PTGNativeExpressBannerAd *)bannerAd {
    [self trackBannerAdDetailClosed];
}

@end


@implementation ATPTGBannerView



@end
