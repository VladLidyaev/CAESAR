// Made by Vladislav Lidiaev [aka Balonka] on 2023.

import Foundation

// MARK: - Throttling

public protocol Throttling {
  func throttle(_ block: @escaping () -> Void)
  func cancel()
}

// MARK: - CancellableTask

public protocol CancellableTask {
  func perform()
  func cancel()
}

// MARK: - TaskScheduler

public protocol TaskScheduler {
  func performTask(after delay: Double, _ task: @escaping () -> Void)
  func performTask(after delay: Double, _ task: CancellableTask)
}

// MARK: - Throttler

public class Throttler: Throttling {
  private let sheduler: TaskScheduler
  private let interval: TimeInterval
  private var workItem: DispatchWorkItem?

  public init(interval: TimeInterval, sheduler: TaskScheduler = DispatchQueue.main) {
    self.interval = interval
    self.sheduler = sheduler
  }

  public func throttle(_ block: @escaping () -> Void) {
    guard workItem == nil else {
      return
    }

    let workItem = DispatchWorkItem {
      self.workItem = nil
      block()
    }

    sheduler.performTask(after: interval, workItem)
    self.workItem = workItem
  }

  public func cancel() {
    workItem?.cancel()
    workItem = nil
  }
}

// MARK: - DispatchQueue

extension DispatchQueue: TaskScheduler {
  public func performTask(after delay: Double, _ task: @escaping () -> Void) {
    asyncAfter(deadline: .now() + delay, execute: task)
  }

  public func performTask(after delay: Double, _ task: CancellableTask) {
    asyncAfter(deadline: .now() + delay) {
      task.perform()
    }
  }
}

// MARK: - DispatchWorkItem

extension DispatchWorkItem: CancellableTask {}
