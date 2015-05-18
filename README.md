## What it is?

CHXNetworkingWrapper is an [AFNetworking](https://github.com/AFNetworking/AFNetworking) wrapper. the swift version is under developing, checkout [here](https://github.com/atcuan/Daemon).

## Feature

- Done asynchronously
- Cache Request
- Support RESTful API
- Low coupling degree

## Requirements

- iOS 7.0+ / Mac OS X 10.9+
- Xcode 6.3

## Installation

You can install CHXNetworkingWrapper using [CocoaPods](http://cocoapods.org/)

## Getting started

- subclass `CHXRequest`
- overload `@interface CHXRequest (CHXConstruct)` methods, gather request data
- overload `@interface CHXRequest (CHXRetrieve)` methods setting response configure
- call `CHXRequest (CHXAsynchronously)` method and `startRequest` method start a request
- Or using `@interface CHXRequest (CHXConvenience)` methods start a request

## Others

- checkout Sample or send me a issue
- Pull request is always welcome

## Refrence

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [YTKNetwork](https://github.com/yuantiku/YTKNetwork)

## License

CHXNetworkingWrapper is available under the MIT license. See the LICENSE file for more info.



