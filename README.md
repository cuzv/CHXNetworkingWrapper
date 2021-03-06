## What it is?

CHXNetworkingWrapper is an [AFNetworking](https://github.com/AFNetworking/AFNetworking) wrapper. The swift version checkout [here](https://github.com/cuzv/redes).

The 1.x version support AFNetworking 2.x version only.

The 2.x version support AFNetworking 3.x version only.

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

- Subclass `CHXRequest`.
- Conforms `CHXRequestable`, `CHXResponseable`.
- Inject `command` by `CHXRequest`'s property.
- Call  `start` method start a request, call `cancel` to stop the request.
- Process response by completion handlers.
- Checkout sample code for more info.

## Refrence

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [YTKNetwork](https://github.com/yuantiku/YTKNetwork)

## License

CHXNetworkingWrapper is available under the MIT license. See the LICENSE file for more info.