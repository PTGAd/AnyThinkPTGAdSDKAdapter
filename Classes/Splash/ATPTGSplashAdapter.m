//
//  ATPTGSplashAdapter.m
//  AnyThinkSDKDemo
//

//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import "ATPTGSplashAdapter.h"
#import "ATPTGSplashCustomEvent.h"
#import <PTGAdSDK/PTGAdSDK.h>
#import <objc/runtime.h>
#import "ATPTGBiddingManager.h"
#import "ATPTGBiddingRequest.h"

@interface ATPTGSplashAdapter()
@property (nonatomic, strong) ATPTGSplashCustomEvent *customEvent;
@property (nonatomic, strong) PTGSplashAd *splashAd;
@end

@implementation ATPTGSplashAdapter

// 注册三方广告平台的SDK
- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        NSString *appid = serverInfo[@"app_id"];
        NSString *appKey = serverInfo[@"app_key"];
        [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
            if (error){
                NSLog(@"PTGSDK 初始化失败%@",error);
            }
        }];
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *placementId = serverInfo[@"slot_id"];
    
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:placementId];
    if (request) {
        self.customEvent = [[ATPTGSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        if (request.customObject == nil) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"PTG has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"PTGAdSDK 广告竞价失败"}];
            [self.customEvent trackSplashAdLoadFailed:error];
            [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:placementId];
            return;
        }
        self.splashAd = request.customObject;
        self.splashAd.delegate = self.customEvent;
        [self.customEvent ptg_splashAdDidLoad:self.splashAd];
        [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:placementId];
    } else {
        [self normalLaodAdWithServerInfo:serverInfo localInfo:localInfo completion:completion];
    }
}

- (void)normalLaodAdWithServerInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *appid = serverInfo[@"app_id"];
    NSString *appKey = serverInfo[@"app_key"];
    NSString *placementId = serverInfo[@"slot_id"];
    UIView *bottomView = localInfo[@"container_view"];
    [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
        if (error){
            NSError *error = [NSError errorWithDomain:@"com.PTGAdSDK.ios" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey :@"PTGAdSDK 初始化失败"}];
            completion ? completion(nil,error) : nil;
            return;
        }
        self.customEvent = [[ATPTGSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        self.customEvent.delegate = self.customEvent;
        self.splashAd = [[PTGSplashAd alloc] initWithPlacementId:placementId];
        self.splashAd.delegate = self.customEvent;
        self.splashAd.bottomView = bottomView;
        [self.splashAd loadAd];
    }];
}

// 外部调用了show的API后，来到该方法。请实现三方平台的展示逻辑。
+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate {
    ATPTGSplashCustomEvent *event = (ATPTGSplashCustomEvent *)splash.customEvent;
    event.isReady = false;
    PTGSplashAd *splashAd = splash.customObject;
    if (splashAd) {
        UIViewController *viewController = localInfo[kATSplashExtraInViewControllerKey];
        [splashAd showAdWithViewController:viewController];
    }
}

// 返回三方广告平台的广告对象是否可使用，例如穿山甲的开屏广告的 adValid 属性
+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info{
    PTGSplashAd *splashAd = customObject;
    ATPTGSplashCustomEvent *event = (ATPTGSplashCustomEvent *)splashAd.delegate;
    return event.isReady;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel { 
    return true;
}

#pragma mark - Header bidding
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    NSString *appid = info[@"app_id"];
    NSString *appKey = info[@"app_key"];
    NSString *slotId = info[@"slot_id"];
    NSString *placementID = info[@"placement_id"];
    [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
        if (error) {
            NSError *error = [NSError errorWithDomain:@"com.PTGAdSDK.ios" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey :@"PTGAdSDK 初始化失败"}];
            completion ? completion(nil,error) : nil;
            return;
        }
        PTGSplashAd *splashAd = [[PTGSplashAd alloc] initWithPlacementId:slotId];
        UIView *bottomView = [ATAdManager.sharedManager lastExtraInfoForPlacementID:placementID][@"container_view"];
        if ([bottomView isKindOfClass:UIView.class]) {
            splashAd.bottomView = bottomView;
        }
        ATPTGBiddingManager *biddingManage = [ATPTGBiddingManager sharedInstance];
        ATPTGBiddingRequest *request = [ATPTGBiddingRequest new];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.bidCompletion = completion;
        request.unitID = slotId;
        request.extraInfo = info;
        request.adType = PTGAdFormatSplash;
        request.customObject = splashAd;
        [biddingManage startWithRequestItem:request];
        [splashAd loadAd];
    }];
}

@end
