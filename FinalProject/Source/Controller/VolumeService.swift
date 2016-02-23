//
//  VolumeService.swift
//  FinalProject
//
//  Created by Runex on 7/30/15.
//
//


import Foundation


class VolumeService {
    // MARK: Service
    /*func catCategories() -> Array<(title: String, subtitle: String)> {
        return [("Burmese", "Contains \(burmeseCats.count) images"), ("Savannah", "Contains \(savannahCats.count) images"), ("Ragdoll", "Contains \(ragdollCats.count) images"), ("Himalayan", "Contains \(himalayanCats.count) images"), ("Scottish Fold", "Contains \(scottishFoldCats.count) images")]
    }
    */
    func imageNamesForCategory() -> Array<String>? {
        let result: Array<String>? = imagedata
        return result
    }
    
    func titleNamesForCategory() -> Array<String>? {
        let result: Array<String>? = titledata
        return result
    }
    
    func urlForCategory() -> Array<String>? {
        let result: Array<String>? = urldata
        return result
    }
    // MARK: Initialization
    private init() {
        imagedata = ["1", "2", "3", "4", "5"]
        titledata = ["Jazz", "Coffee", "New Age","Blues", "Folk"]
        urldata = [ "http://douban.fm/j/mine/playlist?channel=10",
                    "http://douban.fm/j/mine/playlist?channel=20",
                    "http://douban.fm/j/mine/playlist?channel=23",
                    "http://douban.fm/j/mine/playlist?channel=24",
                    "http://douban.fm/j/mine/playlist?channel=7"]
    }
    
    // MARK: Properties (Private)
    private let imagedata: Array<String>
    private let titledata: Array<String>
    private let urldata: Array<String>
    
    // MARK: Properties (Static)
    static let volumeService = VolumeService()
}