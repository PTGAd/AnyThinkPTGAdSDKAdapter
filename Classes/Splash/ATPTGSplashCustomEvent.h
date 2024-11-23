//
//  ATPTGSplashCustomEvent.h
//  AnyThinkSDKDemo
//

//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
#import <AnyThinkSDK/ATBidInfoCacheManager.h>
#import <PTGAdSDK/PTGAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATPTGSplashCustomEvent : ATSplashCustomEvent<PTGSplashAdDelegate>

@property(nonatomic,weak) UIView *containerView;

@property(nonatomic,assign) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
