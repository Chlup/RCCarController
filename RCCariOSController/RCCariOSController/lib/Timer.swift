//
//  Timer.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

public class Timer {

    fileprivate let timer: DispatchSourceTimer
    fileprivate(set) var valid: Bool
    private let eventHandler: () -> Void
    private let lock = Mutex(name: "Timer")

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    public init(interval: TimeInterval, repeats: Bool, queue: DispatchQueue = DispatchQueue.main, closure: @escaping () -> Void) {
        self.eventHandler = closure
        valid = true

        let inter = Int((interval < 0.0 ? 0.0 : interval) * 1000.0)
        let repeatInterval: DispatchTimeInterval = repeats ? .milliseconds(inter) : .never
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
        timer.schedule(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(inter), repeating: repeatInterval)
        timer.setEventHandler(handler: eventHandler)
        resume()
    }

    deinit {
        invalidate()
    }

    public func invalidate() {
        lock.lock()
        defer { lock.unlock() }
        guard valid else { return }
        valid = false
        timer.setEventHandler(handler: {})
        timer.cancel()
        resume()
    }

    private func resume() {
        guard state == .suspended else { return }
        state = .resumed
        timer.resume()
    }
}
