//
//  ATPTGNativeRenderer.m
//  PTGSDKDemo
//
//  Created byttt on 2024/11/11.
//

#import "ATPTGNativeRenderer.h"
#import "ATPTGNativeExpressCustomEvent.h"
#import <PTGAdSDK/PTGAdSDK.h>
#import <objc/message.h>

@interface ATPTGNativeRenderer()

@property (nonatomic, weak) ATPTGNativeExpressCustomEvent *customEvent;

@end

@implementation ATPTGNativeRenderer

-(void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    _customEvent = offer.assets[kATAdAssetsCustomEventKey];
    _customEvent.adView = self.ADView;
    self.ADView.customEvent = _customEvent;
    PTGNativeExpressAdManager *manager = (PTGNativeExpressAdManager *)offer.assets[@"ptg_nativeexpress_manager"];
    manager.delegate = _customEvent;
    PTGNativeExpressAd *expressAd = offer.assets[kATAdAssetsCustomObjectKey];
    [expressAd displayAdToView:self.ADView];
    
    if ([expressAd respondsToSelector:@selector(nativeExpressAdView)]) {
        SEL getterSEL = sel_registerName("nativeExpressAdView");
        UIView *adView = ((UIView *(*)(id, SEL))objc_msgSend)(expressAd, getterSEL);
        self.ADView.frame = adView.bounds;
        
    }
}


- (UIView *)createMediaView {
    return  nil;
}

@end
