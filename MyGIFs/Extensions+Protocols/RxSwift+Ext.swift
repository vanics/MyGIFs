//
//  RxSwift+Ext.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 29/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxSwift

// Util for unwrapping nils using RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}

extension Observable where Element: OptionalType {
    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.empty()
        }
    }
}
