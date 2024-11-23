//
//  ATPTGBannerExpressAdapter.m
//  PTGSDKDemo
//
//  Created byttt on 2024/11/12.
//

#import "ATPTGNativeExpressBannerAdapter.h"
#import "ATPTGBannerExpressCustomEvent.h"
#import <PTGAdSDK/PTGAdSDK.h>
#import "ATPTGBiddingManager.h"
#import "ATPTGBiddingManager.h"

@interface ATPTGNativeExpressBannerAdapter()

@property(nonatomic,strong)ATPTGBannerExpressCustomEvent *customEvent;
@property(nonatomic,strong)PTGNativeExpressBannerAd *bannerAd;

@end

@implementation ATPTGNativeExpressBannerAdapter

- (instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
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

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info{
    PTGNativeExpressBannerAd *bannerAd = customObject;
    ATPTGBannerExpressCustomEvent *event = (ATPTGBannerExpressCustomEvent *)bannerAd.delegate;
    return event.isReady;
}


+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel { 
    return true;
}


- (void)loadADWithInfo:(nonnull NSDictionary *)serverInfo localInfo:(nonnull NSDictionary *)localInfo completion:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    
    
    NSString *slotId = serverInfo[@"slot_id"];
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
    if (request && request.expressAd) {
        self.customEvent = [[ATPTGBannerExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        if (request.customObject == nil) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"PTG has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"PTGAdSDK 广告竞价失败"}];
            [self.customEvent trackBannerAdLoadFailed:error];
            [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotId];
            return;
        }
        self.bannerAd = request.customObject;
        self.bannerAd.delegate = self.customEvent;
        self.bannerAd.rootViewController = localInfo[kATExtraInfoRootViewControllerKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.customEvent ptg_nativeExpressBannerAdDidLoad:self.bannerAd];
        });
        [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotId];
    } else {
        [self normalLoadADWithInfo:serverInfo localInfo:localInfo completion:completion];
    }
}

- (void)normalLoadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *appid = serverInfo[@"app_id"];
    NSString *appKey = serverInfo[@"app_key"];
    NSString *slotId = serverInfo[@"slot_id"];
    [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
        if (error){
            NSLog(@"PTGSDK 初始化失败%@",error);
            return;
        }
        CGSize adSize = [localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)] ? [localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue] : CGSizeMake(320.0f, 50.0f);
        self.customEvent = [[ATPTGBannerExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        self.bannerAd = [[PTGNativeExpressBannerAd alloc] initWithPlacementId:slotId size:adSize];
        self.bannerAd.delegate = self.customEvent;
        self.bannerAd.rootViewController = localInfo[kATExtraInfoRootViewControllerKey];
        [self.bannerAd loadAd];
    }];
}


#pragma mark - Bidding -
+ (void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    
    NSString *appid = info[@"app_id"];
    NSString *appKey = info[@"app_key"];
    NSString *slotId = info[@"slot_id"];
    NSString *placementId = info[@"placement_id"];
    [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
        if (error) {
            NSError *error = [NSError errorWithDomain:@"com.PTGAdSDK.ios" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Bid request has failed", NSLocalizedFailureReasonErrorKey :@"PTGAdSDK 初始化失败"}];
            completion ? completion(nil,error) : nil;
            return;
        }
        CGSize size = [self getNativeAdSizePlacementId:placementId];
        NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"获取广告size失败，请检查extra中kATAdLoadingExtraBannerAdSizeKey CGSize的值");
        PTGNativeExpressBannerAd *bannerAd = [[PTGNativeExpressBannerAd alloc] initWithPlacementId:slotId size:size];
        ATPTGBiddingManager *biddingManage = [ATPTGBiddingManager sharedInstance];
        ATPTGBiddingRequest *request = [ATPTGBiddingRequest new];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.bidCompletion = completion;
        request.unitID = slotId;
        request.extraInfo = info;
        request.adType = PTGAdFormatNativeBanner;
        request.customObject = bannerAd;
        [biddingManage startWithRequestItem:request];
        [bannerAd loadAd];
    }];
}

+ (CGSize)getNativeAdSizePlacementId:(NSString *)placementId {
    CGSize size = CGSizeZero;
    if (![placementId isKindOfClass:NSString.class] || placementId.length == 0) {
        return size;
    }
    NSDictionary *dict = [ATAdManager.sharedManager lastExtraInfoForPlacementID:placementId];;
    id sizeValue = dict[kATAdLoadingExtraBannerAdSizeKey];

    if ([sizeValue respondsToSelector:@selector(CGSizeValue)]) {
        size = [sizeValue CGSizeValue];
    }
    return size;
}

@end
