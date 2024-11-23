//
//  ATTMBiddingDelegate.m
//  HeadBiddingDemo
//
//  Created by lix on 2022/10/20.
//

#import "ATPTGBiddingDelegate.h"
#import "ATPTGBiddingManager.h"
#import "ATPTGBiddingRequest.h"

#import <PTGAdSDK/PTGAdSDK.h>
#import <AnyThinkSplash/AnyThinkSplash.h>

@interface ATPTGBiddingDelegate () <PTGSplashAdDelegate,PTGNativeExpressAdDelegate,PTGNativeExpressBannerAdDelegate>

@end

@implementation ATPTGBiddingDelegate

#pragma mark - 开屏 -
- (void)ptg_splashAdDidLoad:(PTGSplashAd *)splashAd {
    NSLog(@"%s", __FUNCTION__);
    // 拿到unitID的 ATTMBiddingRequest 对象
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    if (request.bidCompletion) {
        // 通过该方法告诉 我们SDK C2S竞价为多少，price：元(CN) or 美元(USD)，currencyType：币种
        // request.unitGroup.bidTokenTime :广告竞价超时时间
        // request.unitGroup.adapterClassString 自定义广告平台的文件名
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(splashAd.ecpm/100.0f).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:splashAd];
        // 绑定对应后台下发的 firm id
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        request.bidCompletion(bidInfo, nil);
    }
    
    // 从biddingManager 移除bidding 代理。
    [[ATPTGBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}

- (void)ptg_splashAd:(PTGSplashAd *)splashAd didFailWithError:(NSError *)error {
    NSLog(@"%s %@", __FUNCTION__ ,error);
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[ATPTGBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}

#pragma mark - 原生模版 -
// 原生模版广告获取成功
/// @param manager 广告管理类
/// @param ads 广告数组 一般只会有一条广告数据 使用数组预留扩展
- (void)ptg_nativeExpressAdSuccessToLoad:(PTGNativeExpressAdManager *)manager ads:(NSArray<__kindof PTGNativeExpressAd *> *)ads {
    NSLog(@"%s", __FUNCTION__);
    PTGNativeExpressAd *ad = ads.firstObject;
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    request.expressAd = ad;
    if (request.bidCompletion) {
        // 通过该方法告诉 我们SDK C2S竞价为多少，price：元(CN) or 美元(USD)，currencyType：币种
        // request.unitGroup.bidTokenTime :广告竞价超时时间
        // request.unitGroup.adapterClassString 自定义广告平台的文件名
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(ad.price/100.0f).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:manager];
        // 绑定对应后台下发的 firm id
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        request.bidCompletion(bidInfo, nil);
    }
}

/// 原生模版广告获取失败
/// @param manager 广告管理类
/// @param error 错误信息
- (void)ptg_nativeExpressAdFailToLoad:(PTGNativeExpressAdManager *)manager error:(NSError *_Nullable)error {
    NSLog(@"%s %@", __FUNCTION__ ,error);
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[ATPTGBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}

#pragma mark - 横幅 -
///  广告加载成功
///  在此方法中调用 showAdFromView:frame 方法
- (void)ptg_nativeExpressBannerAdDidLoad:(PTGNativeExpressBannerAd *)bannerAd {
    NSLog(@"%s", __FUNCTION__);
    // 拿到unitID的 ATTMBiddingRequest 对象
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    if (request.bidCompletion) {
        // 通过该方法告诉 我们SDK C2S竞价为多少，price：元(CN) or 美元(USD)，currencyType：币种
        // request.unitGroup.bidTokenTime :广告竞价超时时间
        // request.unitGroup.adapterClassString 自定义广告平台的文件名
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:@(bannerAd.ecpm/100.0f).stringValue currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:bannerAd];
        // 绑定对应后台下发的 firm id
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        request.bidCompletion(bidInfo, nil);
    }
    
    // 从biddingManager 移除bidding 代理。
    [[ATPTGBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}

/// 广告加载失败
- (void)ptg_nativeExpressBannerAd:(PTGNativeExpressBannerAd *)bannerAd didLoadFailWithError:(NSError *_Nullable)error {
    NSLog(@"%s %@", __FUNCTION__ ,error);
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[ATPTGBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.unitID];
}

@end
