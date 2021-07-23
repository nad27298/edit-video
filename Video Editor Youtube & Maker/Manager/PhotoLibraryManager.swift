//
//  PhotoLibraryManager.swift
//  MasterCleaner
//
//  Created by Nhuom Tang on 6/26/19.
//  Copyright © 2019 Nhuom Tang. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryManager: NSObject {

    static let shared = PhotoLibraryManager()
   
    var sizeAssets: [[String:String]] = []
    var videos: [PHAsset] = []

    let cachingImageManager = PHCachingImageManager.default()
   
    func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(), fromViewController: UIViewController, completion: @escaping (_ authorized: Bool) -> Void) {
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.authorize(status, fromViewController: fromViewController, completion: completion)
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            completion(false)
        })
        }
    }
    
    func getVideoAsset(id: String) -> PHAsset?{
        let ids = videos.map({$0.localIdentifier})
        if ids.contains(id){
            if let index = ids.firstIndex(of: id){
                return videos[index]
            }
        }
        return nil
    }

    func getCacheSizeOfAsset(asset: PHAsset) -> Int64{
        let ids = sizeAssets.map({$0["id"]})
        let sizes = sizeAssets.map({$0["size"]})
        if ids.contains(asset.localIdentifier){
            if let index = ids.firstIndex(of: asset.localIdentifier){
                return Int64(sizes[index]!)!
            }
        }
        let size = self.getSizeOfAsset(asset: asset)
        let data = ["id": asset.localIdentifier, "size": "\(size)"]
        sizeAssets.append(data)
        return size
    }
    
    func getAllVideoAsset() -> [PHAsset]{
        videos.removeAll()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        let allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        for i in 0..<allVideos.count{
            videos.append(allVideos[i])
        }
        return videos
    }
    
    func getAllAlbumAsset() -> [PHAsset]{
        videos.removeAll()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = nil
        let allVideos = PHAsset.fetchAssets(with: fetchOptions)
        for i in 0..<allVideos.count{
            videos.append(allVideos[i])
        }
        return videos
    }

    func deleteVideoAssets(assetIds:[String], completion: @escaping (_ success: Bool) -> Void){
        var indexesToRemove: [Int] = []
        let ids = self.videos.map({$0.localIdentifier})
        var deleteAssets:[PHAsset] = []
       
        for id in assetIds{
            if let asset = self.getVideoAsset(id: id){
                deleteAssets.append(asset)
            }
            if ids.contains(id){
                if let index = ids.firstIndex(of: id){
                    indexesToRemove.append(index)
                }
            }
        }
        
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.deleteAssets(deleteAssets as NSFastEnumeration)},
                                                            completionHandler: {
                                                                [weak self] success, error in
                                                                if success{
                                                                    if let temp = self?.videos{
                                                                        self?.videos = temp
                                                                            .enumerated()
                                                                            .filter { !indexesToRemove.contains($0.offset) }
                                                                            .map { $0.element }
                                                                    }
                                                                }
                                                                print(success)
                                                                completion(success)
        })
    }
    
    func fetchCollection(type: PHAssetCollectionType, subType: PHAssetCollectionSubtype = .any, fetchOptions:PHFetchOptions = PHFetchOptions()) -> PHFetchResult<PHAssetCollection>{
       
        let albumResult = PHAssetCollection.fetchAssetCollections(with: type, subtype: subType, options: fetchOptions)
        
        return albumResult
    }
    
    func fetchAssetInCollection(collection: PHAssetCollection, fetchOptions: PHFetchOptions = PHFetchOptions())  -> PHFetchResult<PHAsset>{
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        return result
    }
    
    func getSizeOfAsset(asset: PHAsset) -> Int64{
        let resources = PHAssetResource.assetResources(for: asset)
        
        var sizeOnDisk: Int64 = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
        }
        return sizeOnDisk
    }
  
    func getSizeText(asset: PHAsset) -> String{
        let size = self.getCacheSizeOfAsset(asset: asset)
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(size))
    }
    
    func defaultAssetInCollectionOption() -> PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return fetchOptions
    }
    
    func fetchImageInAlbum(album: PHAssetCollection){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        let scale = UIScreen.main.scale
        var width = (DEVICE_WIDTH - 10)/3
        if IS_IPAD{
            width = (DEVICE_WIDTH - 15)/4
        }

        let imageSize = CGSize(width: width * scale, height: width * scale)
        let imageContentMode: PHImageContentMode = .aspectFill
        let result = PHAsset.fetchAssets(in: album, options: fetchOptions)
        result.enumerateObjects({ (asset, idx, stop) in
            switch idx {
            case 0:
                PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                }
            case 1:
                PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                }
            case 2:
                PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                }
                
            default:
                // Stop enumeration
                stop.initialize(to: true)
            }
        })
    }
}
extension PHAsset {
    var thumbnailImage : UIImage {
        get {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            option.isNetworkAccessAllowed = true
            manager.requestImage(for: self, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                thumbnail = result!
            })
            return thumbnail
        }
    }
    
    
    
    func getUIImage(completionHandle: @escaping (UIImage?) -> ()){

        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        option.resizeMode = .exact
        option.deliveryMode = .highQualityFormat
        let _ = Int(PhotoLibraryManager.shared.cachingImageManager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) {(result, _) in
            completionHandle(result)
        })
    }
}
