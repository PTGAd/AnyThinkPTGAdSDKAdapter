//
//  ATPTGBannerExpressCustomEvent.h
//  PTGSDKDemo
//
//  Created byttt on 2024/11/12.
//

#import <Foundation/Foundation.h>
#import <PTGAdSDK/PTGAdSDK.h>
#import <AnyThinkBanner/AnyThinkBanner.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATPTGBannerExpressCustomEvent : ATBannerCustomEvent<PTGNativeExpressBannerAdDelegate>

@property(nonatomic,assign)BOOL isReady;

@end

NS_ASSUME_NONNULL_END
