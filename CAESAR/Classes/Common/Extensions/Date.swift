// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

extension Date {
  static func - (recent: Date, previous: Date) -> (
    year: Int?,
    month: Int?,
    week: Int?,
    day: Int?,
    hour: Int?,
    minute: Int?,
    second: Int?
  ) {
    let year = Calendar.current.dateComponents([.year], from: previous, to: recent).year
    let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
    let week = Calendar.current.dateComponents([.weekOfMonth], from: previous, to: recent).weekOfMonth
    let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
    let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
    let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
    let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
    return (
      year: year,
      month: month,
      week: week,
      day: day,
      hour: hour,
      minute: minute,
      second: second
    )
  }
}
