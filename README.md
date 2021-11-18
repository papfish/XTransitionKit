# XTransitionKit

[![CI Status](https://img.shields.io/travis/Leo/XTransitionKit.svg?style=flat)](https://travis-ci.org/Leo/XTransitionKit)
[![Version](https://img.shields.io/cocoapods/v/XTransitionKit.svg?style=flat)](https://cocoapods.org/pods/XTransitionKit)
[![License](https://img.shields.io/cocoapods/l/XTransitionKit.svg?style=flat)](https://cocoapods.org/pods/XTransitionKit)
[![Platform](https://img.shields.io/cocoapods/p/XTransitionKit.svg?style=flat)](https://cocoapods.org/pods/XTransitionKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 9.0+
* Swift 5.0+

## Installation

XTransitionKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XTransitionKit'
```

## Features

- [x] Present & dismiss transitioning animation.
- [x] Push & pop transitioning animation.
- [x] Tab bar transitioning animation.

## Examples

You can use the animation effects that have been implemented.
```
func setup(animationType: AnimationType?, interactionType: InteractionType?)
```

Or you can use custom animation effects, just implement the **Animation** or **Interaction** protocol.
```
func setup(animation: Animation?, interaction: Interaction?)
```

Example for UIViewController / UINavigationController / UITabbarController

```
controller.tk.setup(animationType: .flip, interactionType: .horizontal)
controller.tk.setup(animation: FlipAnimation(), interactionType: HorizontalInteraction())
```
### Delegate

It is worth noting that the original delegate method can no longer be used.

So, If you still need to use UIViewControllerTransitioningDelegate / UINavigationControllerDelegate / UITabBarControllerDelegate. A delegate is provided here.

```
controller.tk.delegate = controller
```
Then implement **TransitionKitDelegate**，
It's the same as the original method.

## Author

Leo, 153419620@qq.com

## License

XTransitionKit is available under the MIT license. See the LICENSE file for more info.
