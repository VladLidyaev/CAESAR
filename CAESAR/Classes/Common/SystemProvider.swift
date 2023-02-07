// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import SystemConfiguration
import UIKit

class SystemProvider {
  static var isConnectedToNetwork: Bool {
    var zeroAddress = sockaddr_in(
      sin_len: .zero,
      sin_family: .zero,
      sin_port: .zero,
      sin_addr: in_addr(s_addr: .zero),
      sin_zero: (.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
    )
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)

    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
        SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
      }
    }

    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: .zero)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
      return false
    }

    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != .zero
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != .zero
    let isConnected = (isReachable && !needsConnection)
    return isConnected
  }

  static var bundleVersion: Float {
    let bundle = Bundle.main
    let bundleVersionKey = "CFBundleVersion"
    let bundleVersionString = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? NSString
    return bundleVersionString?.floatValue ?? .zero
  }
}
