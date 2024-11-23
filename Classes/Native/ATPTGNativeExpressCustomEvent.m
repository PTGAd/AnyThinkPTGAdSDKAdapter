//
//  ATPTGNativeExpressCustomEvent.m
//  PTGSDKDemo
//
//  Created byttt on 2024/11/11.
//

#import "ATPTGNativeExpressCustomEvent.h"
#import <objc/message.h>

@interface ATPTGNativeExpressCustomEvent()

@property(nonatomic,strong) PTGNativeExpressAd *expressAd;

@end



@implementation ATPTGNativeExpressCustomEvent

/// 原生模版广告获取成功
/// @param manager 广告管理类
/// @param ads 广告数组 一般只会有一条广告数据 使用数组预留扩展
- (void)ptg_nativeExpressAdSuccessToLoad:(PTGNativeExpressAdManager *)manager ads:(NSArray<__kindof PTGNativeExpressAd *> *)ads {
    PTGNativeExpressAd *nativeExpressAd = ads.firstObject;
    [nativeExpressAd render];
    [nativeExpressAd setController:self.currentController];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SEL getterSEL = sel_registerName("nativeExpressAdView");
        if (![nativeExpressAd respondsToSelector:getterSEL]) {
            [self trackNativeAdLoadFailed:nil];
            self.requestCompletionBlock(nil, nil);
            return;
        }
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        UIView* expressView = ((UIView *(*)(id, SEL))objc_msgSend)(nativeExpressAd, getterSEL);
        [asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [asset setValue:nativeExpressAd forKey:kATAdAssetsCustomObjectKey];
        // 原生模板广告
        [asset setValue:@(1) forKey:kATNativeADAssetsIsExpressAdKey];
        [asset setValue:@(expressView.frame.size.width) forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
        [asset setValue:@(expressView.frame.size.height) forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
        [asset setValue:manager forKey:@"ptg_nativeexpress_manager"];
        nativeExpressAd.controller = self.currentController;
        [assets addObject:asset];
        self.isReady = true;
        [self trackNativeAdLoaded:assets];
        self.requestCompletionBlock(assets, nil);
    });
}

/// 原生模版广告获取失败
/// @param manager 广告管理类
/// @param error 错误信息
- (void)ptg_nativeExpressAdFailToLoad:(PTGNativeExpressAdManager *)manager error:(NSError *_Nullable)error {
    self.isReady = false;
    [self trackNativeAdLoadFailed:error];
    self.requestCompletionBlock(nil, error);
}

- (void)ptg_nativeExpressAdRenderSuccess:(PTGNativeExpressAd *)nativeExpressAd {

}

/// 原生模版渲染失败
/// @param nativeExpressAd 渲染失败的模板广告
/// @param error 渲染过程中的错误
- (void)ptg_nativeExpressAdRenderFail:(PTGNativeExpressAd *)nativeExpressAd error:(NSError *_Nullable)error {
    self.isReady = false;
    [self trackNativeAdLoadFailed:error];
}

/// 原生模板将要显示
/// @param nativeExpressAd 要显示的模板广告
- (void)ptg_nativeExpressAdWillShow:(PTGNativeExpressAd *)nativeExpressAd {
    [self trackNativeAdImpression];
}

/// 原生模板将被点击了
/// @param nativeExpressAd  被点击的模板广告
- (void)ptg_nativeExpressAdDidClick:(PTGNativeExpressAd *)nativeExpressAd {
    [self trackNativeAdClick];
}
///  原生模板广告被关闭了
/// @param nativeExpressAd 要关闭的模板广告
- (void)ptg_nativeExpressAdViewClosed:(PTGNativeExpressAd *)nativeExpressAd {
    [self trackNativeAdClosed];
}

/// 原生模板广告将要展示详情页
/// @param nativeExpressAd  广告
- (void)ptg_nativeExpressAdWillPresentScreen:(PTGNativeExpressAd *)nativeExpressAd {

}

/// 原生模板广告将要关闭详情页
/// @param nativeExpressAd 广告
- (void)ptg_nativeExpressAdVDidCloseOtherController:(PTGNativeExpressAd *)nativeExpressAd {
    [self trackNativeAdCloseDetail];
}

///// callback to developer when ad is loaded
///// @param assets - native ad assets
//- (void)trackNativeAdLoaded:(NSArray *)assets;
//
///// callback to developer when ad is load failed
///// @param error - error message
//- (void)trackNativeAdLoadFailed:(NSError *)error;
//
///// callback to developer when ad is showed
///// @param refresh - whether the show is trigered by a ad refresh
//- (void)trackNativeAdShow:(BOOL)refresh;
//
//- (void)trackNativeAdImpression;
//
///// callback to developer when ad is clicked
//- (void)trackNativeAdClick;
//
//- (void)trackNativeAdVideoStart;
//
//- (void)trackNativeAdVideoEnd;
//
///// callback to developer when ad is closed
//- (void)trackNativeAdClosed;
//
//- (void)trackNativeAdDeeplinkOrJumpResult:(BOOL)success;
//
////v5.7.47
//- (void)trackNativeAdCloseDetail;

@end
