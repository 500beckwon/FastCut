//
//  TrimError.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//


struct TrimError: Error {
    let description: String
    let underlyingError: Error?

    init(_ description: String, underlyingError: Error? = nil) {
        self.description = "TrimVideo: " + description
        self.underlyingError = underlyingError
    }
}
