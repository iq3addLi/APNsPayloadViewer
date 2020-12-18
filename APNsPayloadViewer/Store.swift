//
//  Store.swift
//  APNsPayloadViewer
//
//  Created by iq3AddLi on 2020/10/29.
//

import Foundation

final class Store{
    
    let ext = "json"
    
    private init() {}
    public static let shared = Store()
    
    private var path: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first! + "/payloads/"
    }
    
    private func ifNeedCreateDirectoryPath() -> String{
        if FileManager.default.fileExists(atPath: path) == false {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true , attributes: [:])
        }
        return path
    }
    
    func put<T>( payload: T ) throws where T: Encodable{
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let body = try! encoder.encode(payload)
        let path = "\(ifNeedCreateDirectoryPath())\(Date().timeIntervalSince1970).\(ext)"
        try body.write(to: URL(fileURLWithPath: path), options: [.atomic])
    }
    
    func payloads(location: Int, length: Int) -> [Payload]{
        let fileManager = FileManager.default
        let files = try! fileManager.contentsOfDirectory(atPath: ifNeedCreateDirectoryPath())
        guard files.count != 0 else {
            return []
        }
        let limit = { files.count < (location + length) ? files.count : location + length }
        return files
            .map{ ($0 as NSString).deletingPathExtension }
            .sorted{ Double($0)! > Double($1)! }[location...limit() - 1]
            .map{ file in
                let body = String(
                    data: try! Data(contentsOf: URL(fileURLWithPath: "\(path)\(file).\(ext)")),
                    encoding: .utf8
                )!
                return Payload(date: Date(timeIntervalSince1970: TimeInterval(Double(file)!)), body: body)
            }
    }
}
