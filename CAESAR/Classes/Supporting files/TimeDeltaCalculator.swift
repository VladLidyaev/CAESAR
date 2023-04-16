// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

enum TimeDeltaCalculator {
  static func calculateTimeDelta(creationDate: Date) -> String {
    let datesDiff = Date() - creationDate

    if let years = datesDiff.year, years != .zero, years > .zero {
      return "\(years) " + Strings.DatesShorts.year
    } else if let months = datesDiff.month, months != .zero, months > .zero {
      return "\(months) " + Strings.DatesShorts.month
    } else if let weeks = datesDiff.week, weeks != .zero, weeks > .zero {
      return "\(weeks) " + Strings.DatesShorts.week
    } else if let days = datesDiff.day, days != .zero, days > .zero {
      return "\(days) " + Strings.DatesShorts.day
    } else if let hours = datesDiff.hour, hours != .zero, hours > .zero {
      return "\(hours) " + Strings.DatesShorts.hour
    } else if let minutes = datesDiff.minute, minutes != .zero, minutes > .zero {
      return "\(minutes) " + Strings.DatesShorts.minute
    } else if let seconds = datesDiff.second, seconds != .zero, seconds > .zero {
      return "\(seconds) " + Strings.DatesShorts.second
    } else {
      return Strings.DatesShorts.justNow
    }
  }
}
