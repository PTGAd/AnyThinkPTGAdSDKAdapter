//
//  ATPSelfRenderDelegate.h
//  PTGSDKDemo
//
//  Created by yongjiu on 2025/2/20.
//

#import <Foundation/Foundation.h>
#import <PTGAdSDK/PTGAdSDK.h>

NS_ASSUME_NONNULL_BEGIN


@protocol ATPSelfRenderActionDelegate <NSObject>

- (void)trackNativeAdClosed;

@end

@protocol ATPSelfRenderDelegate <NSObject>

@property(nonatomic,weak)id<ATPSelfRenderActionDelegate> delegate;

- (void)renderAd:(PTGNativeExpressAd *)ad;

@end

NS_ASSUME_NONNULL_END
