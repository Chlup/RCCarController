//
//  SimpleDI.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation

/// Based on Lyfts SimpleDI. More info:
/// https://www.youtube.com/watch?v=dA9rGQRwHGs
/// https://noahgilmore.com/blog/swift-dependency-injection/

private var instantiators: [String: Any] = [:]
private var mockInstantiators: [String: Any] = [:]
private var lock = Mutex(name: "SimpleDI")

public enum DI {
    public static func bind<T>(_ type: T.Type, instantiator: @escaping () -> T) -> () -> T {
        lock.lock()
        instantiators[String(describing: type)] = instantiator
        lock.unlock()
        return self.instance
    }

    private static func instance<T>() -> T {
        let key = String(describing: T.self)
        lock.lock()
        let instantiator = instantiators[key] as! () -> T
        lock.unlock()
        return instantiator()
    }
}
