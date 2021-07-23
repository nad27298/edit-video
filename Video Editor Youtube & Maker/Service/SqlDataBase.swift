//
//  SqlDataBase.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/20/21.
//

import Foundation
import SQLite

class SqlDataBase {
    
    static let shared = SqlDataBase()
    public let connectionData: Connection?
    
    private init() {
        let dbURL = Bundle.main.url(forResource: "data", withExtension: "db")!
        var newURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        newURL.appendPathComponent("data.db")
        print(newURL.path)
        do {
            if !FileManager.default.fileExists(atPath: newURL.path) {
                try FileManager.default.copyItem(atPath: dbURL.path, toPath: newURL.path)
            }
        } catch {
            print(error.localizedDescription)
        }
        do {
            connectionData = try Connection(newURL.path)
        } catch {
            connectionData = nil
            let nserr = error as NSError
            print("Cannot connect to Database. Error is: \(nserr), \(nserr.userInfo)")
        }
    }
}
