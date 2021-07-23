//
//  VideoEntity.swift
//  Video Editor Youtube & Maker
//
//  Created by nguyenhuyson2 on 1/20/21.
//

import Foundation
import SQLite

class VideoEntity {
    
    static let shared = VideoEntity()
    private let tbl = Table("Video")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let url = Expression<String>("url")
    private let date = Expression<String>("date")
    
    private init(){
        do{
            if let connection = SqlDataBase.shared.connectionData{
                try connection.run(tbl.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (table) in
                    table.column(id, primaryKey: true)
                    table.column(name)
                    table.column(url)
                    table.column(date)
                }))
            }
        } catch{
            print("Canont create to table video, Error is: \(error)")
        }
    }
    
    func insertName(name: String, url: String, date: String) -> Int64? {
        do {
            let insert = tbl.insert(self.name <- name,
                                    self.url <- url,
                                    self.date <- date)
            let insertedId = try SqlDataBase.shared.connectionData!.run(insert)
            return insertedId
        } catch {
            let nserror = error as NSError
            print("Cannot insert new tblVideo. Error is: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func getData() -> [VideoModel]{
        var listData = [VideoModel]()
        do {
            if let listCate = try SqlDataBase.shared.connectionData?.prepare(self.tbl) {
                for item in listCate {
                    listData.append(VideoModel(id: item[id], name: item[name], url: item[url], date: item[date]))
                }
            }
        } catch {
            print("Cannot get data from table video, Error is: \(error)")
        }
        return listData
    }
    
    func getDataId(_ id: Int) -> [VideoModel] {
         var listData = [VideoModel]()
         for item in self.getData() {
            if item.id == id  {
                 listData.append(item)
             }
         }
         return listData
     }
    
    func updateName(newname: String, id: Int) -> Bool {
        do{
            if SqlDataBase.shared.connectionData == nil{
                return false
            }
            let tblFilter = self.tbl.filter(self.id == id)
            var setter: [SQLite.Setter] = [SQLite.Setter]()
            setter.append(self.name <- newname)
            let tblUpdate = tblFilter.update(setter)
            if try SqlDataBase.shared.connectionData!.run(tblUpdate) <= 0
            {
                return false
            }
            return true
        }catch {
            let nsError = error as NSError
            print("Cannot update data from table video, Error is: \(nsError), \(nsError)")
            return false
        }
    }
    
    func delete(id: Int) -> Bool {
        if SqlDataBase.shared.connectionData == nil {
            return false
        }
        do {
            let tblFilter = self.tbl.filter(self.id == id)
            let delete = tblFilter.delete()
            if try SqlDataBase.shared.connectionData!.run(delete) <= 0 {
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete object new video. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    func deleteURL(url: String) -> Bool {
        if SqlDataBase.shared.connectionData == nil {
            return false
        }
        do {
            let tblFilter = self.tbl.filter(self.url == url)
            let delete = tblFilter.delete()
            if try SqlDataBase.shared.connectionData!.run(delete) <= 0 {
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete object new video. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
    func deleteAll() -> Bool {
        if SqlDataBase.shared.connectionData == nil {
            return false
        }
        do {
            let delete = tbl.delete()
            if try SqlDataBase.shared.connectionData!.run(delete) <= 0 {
                return false
            }
            return true
        } catch {
            let nserror = error as NSError
            print("Cannot delete object new video. Error is: \(nserror), \(nserror.userInfo)")
            return false
        }
    }
    
}
