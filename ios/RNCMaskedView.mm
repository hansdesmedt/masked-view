/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCMaskedView.h"
#import <React/UIView+React.h>

// This guard prevent the code from being compiled in the old architecture
#ifdef RCT_NEW_ARCH_ENABLED

#import <react/renderer/components/RNCMaskedViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNCMaskedViewSpec/EventEmitters.h>
#import <react/renderer/components/RNCMaskedViewSpec/Props.h>
#import <react/renderer/components/RNCMaskedViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#else
#import <UIKit/UIKit.h>
#endif

#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;

@implementation RNCMaskedView {
    UIView * _view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNCMaskedViewProps>();
    _props = defaultProps;

    _view = [[UIView alloc] init];

    self.contentView = _view;
  }

  return self;
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if (index == 0) {
        self.contentView.maskView = childComponentView;
    } else {
        [self.contentView mountChildComponentView:childComponentView index:index-1];
    }
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if (index == 0) {
        self.contentView.maskView = NULL;
    } else {
        [self.contentView unmountChildComponentView:childComponentView index:index-1];
    }
}

#pragma mark - RCTComponentViewProtocol

- (void)prepareForRecycle
{
  [super prepareForRecycle];
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RNCMaskedViewComponentDescriptor>();
}

Class<RCTComponentViewProtocol> RNCMaskedViewCls(void)
{
  return RNCMaskedView.class;
}

@end
#else
@implementation RNCMaskedView

- (void)didUpdateReactSubviews
{
  // RNCMaskedView expects that the first subview rendered is the mask.
  UIView *maskView = [self.reactSubviews firstObject];
  self.maskView = maskView;

  // Add the other subviews to the view hierarchy
  for (NSUInteger i = 1; i < self.reactSubviews.count; i++) {
    UIView *subview = [self.reactSubviews objectAtIndex:i];
    [self addSubview:subview];
  }
}

- (void)displayLayer:(CALayer *)layer
{
  // RCTView uses displayLayer to do border rendering.
  // We don't need to do that in RNCMaskedView, so we
  // stub this method and override the default implementation.
}

@end
#endif
