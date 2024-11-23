//
//  ATPTGNativeExpressAdapter.m
//  PTGSDKDemo
//
//  Created byttt on 2024/11/11.
//

#import "ATPTGNativeExpressAdapter.h"
#import "ATPTGNativeExpressCustomEvent.h"
#import <PTGAdSDK.h>
#import <objc/message.h>
#import "ATPTGNativeRenderer.h"
#import "ATPTGBiddingRequest.h"
#import "ATPTGBiddingManager.h"

@interface ATPTGNativeExpressAdapter()

@property (nonatomic, strong) ATPTGNativeExpressCustomEvent *customEvent;
@property (nonatomic, strong) PTGNativeExpressAdManager *expressAdManager;


@end

@implementation ATPTGNativeExpressAdapter


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

// 竞价完成并发送了ATBidInfo给SDK后，来到该方法，或普通广告源加载广告来到该方法
- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *slotId = serverInfo[@"slot_id"];
    ATPTGBiddingRequest *request = [[ATPTGBiddingManager sharedInstance] getRequestItemWithUnitID:slotId];
    if (request && request.expressAd) {
        self.customEvent = [[ATPTGNativeExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.requestCompletionBlock = completion;
        if (request.customObject == nil) {
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATAdErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:@"PTG has failed to load splash.", NSLocalizedFailureReasonErrorKey:@"PTGAdSDK 广告竞价失败"}];
            [self.customEvent trackNativeAdLoadFailed:error];
            [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotId];
            return;
        }
        self.expressAdManager = request.customObject;
        self.expressAdManager.delegate = self.customEvent;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.customEvent ptg_nativeExpressAdSuccessToLoad:self.expressAdManager ads:@[request.expressAd]];
        });
        [[ATPTGBiddingManager sharedInstance] removeRequestItmeWithUnitID:slotId];
    } else {
        [self normalLoadADWithInfo:serverInfo localInfo:localInfo completion:completion];
    }
}

- (void)normalLoadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    NSString *appid = serverInfo[@"app_id"];
    NSString *appKey = serverInfo[@"app_key"];
    NSString *placementId = serverInfo[@"slot_id"];
    [PTGSDKManager setAppKey:appid appSecret:appKey completion:^(BOOL result, NSError * _Nonnull error) {
        if (error){
            NSLog(@"PTGSDKManager 初始化失败%@",error);
            return;
        }
        self.customEvent = [[ATPTGNativeExpressCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        self.customEvent.delegate = self.customEvent;
        self.customEvent.requestCompletionBlock = completion;
        CGSize size = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
        self.expressAdManager = [[PTGNativeExpressAdManager alloc] initWithPlacementId:placementId type:PTGNativeExpressAdTypeFeed adSize:size];
        self.expressAdManager.delegate = self.customEvent;
        self.expressAdManager.currentViewController = localInfo[kATExtraInfoRootViewControllerKey];
        self.customEvent.currentController = localInfo[kATExtraInfoRootViewControllerKey];
        [self.expressAdManager loadAd];
    }];
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info{
    PTGNativeExpressAdManager *expressAdManager = customObject;
    ATPTGNativeExpressCustomEvent *event = (ATPTGNativeExpressCustomEvent *)expressAdManager.delegate;
    return event.isReady;
}

+ (BOOL)isSupportAdType:(nonnull ATUnitGroupModel *)unitGroupModel {
    return true;
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
        NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"获取广告size失败，请检查extra中kATExtraInfoNativeAdSizeKey CGSize的值");
        PTGNativeExpressAdManager *manager = [[PTGNativeExpressAdManager alloc] initWithPlacementId:slotId type:PTGNativeExpressAdTypeFeed adSize:size];
        ATPTGBiddingManager *biddingManage = [ATPTGBiddingManager sharedInstance];
        ATPTGBiddingRequest *request = [ATPTGBiddingRequest new];
        request.unitGroup = unitGroupModel;
        request.placementID = placementModel.placementID;
        request.bidCompletion = completion;
        request.unitID = slotId;
        request.extraInfo = info;
        request.adType = PTGAdFormatNativeExpress;
        request.customObject = manager;
        [biddingManage startWithRequestItem:request];
        [manager loadAd];
    }];
}

+ (Class)rendererClass {
    return [ATPTGNativeRenderer class];
}

+ (CGSize)getNativeAdSizePlacementId:(NSString *)placementId {
    CGSize size = CGSizeZero;
    if (![placementId isKindOfClass:NSString.class] || placementId.length == 0) {
        return size;
    }
    NSDictionary *dict = [ATAdManager.sharedManager lastExtraInfoForPlacementID:placementId];;
    id sizeValue = dict[kATExtraInfoNativeAdSizeKey];

    if ([sizeValue respondsToSelector:@selector(CGSizeValue)]) {
        size = [sizeValue CGSizeValue];
    }
    return size;
}

@end
