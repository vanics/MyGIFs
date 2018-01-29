//
//  Dynamic.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 27/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation

class Dynamic<T> {
    
    var bind: (T) -> () = { _ in }
    
    var value: T? {
        didSet {
            bind(value!)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}
