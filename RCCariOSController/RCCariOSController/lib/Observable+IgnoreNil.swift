//
//  Observable+IgnoreNil.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 04/08/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//

import Foundation
import RxSwift

public protocol OptionalWrapper {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalWrapper {
    public var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalWrapper {

    /// This operator ignore `next` events which contains nil. Output is non-optional type.
    ///
    /// - Returns: Observable with non-optional type.
    public func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else { return Observable<Element.Wrapped>.empty() }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}
