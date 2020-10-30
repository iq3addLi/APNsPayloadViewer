//
//  Payload.swift
//  APNsPayloadViewer
//
//  Created by iq3AddLi on 2020/10/29.
//

import Foundation

// MARK: Model
struct Payload{
    
    // when receive a push
    let date: Date
    
    // decoded payload body
    let body: String
    
}
