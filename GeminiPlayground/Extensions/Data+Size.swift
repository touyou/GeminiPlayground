//
//  Data+Size.swift
//  GeminiPlayground
//
//  Created by lease-emp-mac-yosuke-fujii on 2023/12/14.
//

import Foundation

// ref: https://gist.github.com/siempay/1dd2af4ccc06cea2858ced27d0988c21

extension Data {
    var bytes: Int64 {
        .init(self.count)
    }
    
    public var kilobytes: Double {
        return Double(bytes) / 1024
    }
    
    public var megabytes: Double {
        return Double(kilobytes) / 1024
    }
}
