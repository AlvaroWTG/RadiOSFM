//
//  LocalDatabase.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Crashlytics

class Station: NSObject, NSCoding {

    // MARK: - Properties

    /** Property that represents the name of the icon for radio station */
    var iconName = Tag.Empty
    /** Property that represents the popularity of the station */
    var popularity = Tag.Empty
    /** Property that represents the name of the station */
    var name = Tag.Empty
    /** Property that represents the artwork of the station */
    var artwork = Tag.Empty
    /** Property that represents the host of the station */
    var url = Tag.Empty
    /** Property that represents whether the station is favorite or not */
    var isFavorite = false

    // MARK: - Functions

    /**
     Function to initialize the instance with some parameters
     - parameter name: The displayed name of the station
     - parameter url: The url of the station
     - parameter artwork: The artwork of the station
     - parameter popularity: The popularity of the station
     - parameter imageName: The name of the image of the station
     - parameter isFavorite: Whether is favorite station or not
     */
    init(_ name: String, url: String, artwork: String?, popularity: String?, imageName: String?, isFavorite: Bool) {
        self.popularity = popularity ?? Tag.Empty
        self.iconName = imageName ?? "radio"
        self.artwork = artwork ?? Tag.Empty
        self.isFavorite = isFavorite
        self.name = name
        self.url = url
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.popularity, forKey: Encode.Popularity)
        aCoder.encode(self.isFavorite, forKey: Encode.Favorite)
        aCoder.encode(self.artwork, forKey: Encode.Artwork)
        aCoder.encode(self.iconName, forKey: Encode.Icon)
        aCoder.encode(self.name, forKey: Encode.Name)
        aCoder.encode(self.url, forKey: Encode.URL)
    }

    required init?(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: Encode.Popularity) as? String { self.popularity = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Favorite) as? Bool { self.isFavorite = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Artwork) as? String { self.artwork = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Icon) as? String { self.iconName = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Name) as? String { self.name = value }
        if let value = aDecoder.decodeObject(forKey: Encode.URL) as? String { self.url = value }
    }
}

class LocalDatabase: NSObject {

    // MARK: - Properties

    /** Property that represents the list of favorites stations */
    var favorites: NSMutableArray = NSMutableArray()

    // MARK: - Singleton

    static let standard = LocalDatabase()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Functions

    /**
     Function that adds an entry to DB
     - parameter element: The element to add
     - parameter url: The url to add
     */
    func add(_ element: String, url: String) {
        var isValid = true
        for item in self.favorites {
            if let favorite = item as? Station {
                if favorite.url == url || favorite.name == element {
                    isValid = false
                    break
                }
            }
        }
        if isValid { // needs to add into favorites
            self.favorites.add(Station(element, url: url, artwork: nil, popularity: nil, imageName: nil, isFavorite: true))
            if Verbose.Active { NSLog("[LocalDB] Log: Added \(element) to Favorites...") }
            self.synchronize()
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(element) already in Favorites -> Insert IGNORED...") } }
    }
    
    /**
     Function that creates dummy entries in the DB
     */
    func createDummy() -> [Station] {
        let dummyStations = NSMutableArray()
        let names = ["Megastar FM", "RPA Radio", "RNE", "Ibiza Sonica Radio", "RAC 105", "Cadena Ser", "Radio Voz", "Radio Galaxia"]
        let urls = ["http://195.10.10.222/cope/megastar.aac?GKID=d51d8e14d69011e88f2900163ea2c744", "http://195.55.74.203/rtpa/live/radio.mp3?GKID=280fad92d69a11e8b65b00163e914", "http://rne-hls.flumotion.com/playlist.m3u8", "http://s1.sonicabroadcast.com:7005/stream/1/", "http://rac105.radiocat.net/", "http://playerservices.streamtheworld.com/api/livestream-redirect/CADENASERAAC_SC", "http://live.radiovoz.es/coruna/master.m3u8", "http://radios-ec.cdn.nedmedia.io/radios/ec-galaxia.m3u8"]
        for i in 0..<names.count { dummyStations.add(Station(names[i], url: urls[i], artwork: nil, popularity: nil, imageName: nil, isFavorite: false)) }
        return dummyStations as! [Station]
    }

    /**
     Function that filter the stations
     - parameter stations: The list of stations to map
     - returns: The new filtered list of stations
     */
    func filter(_ stations: [Station]) -> [Station] {
        if self.favorites.count <= 0 { return stations }
        var mappedStations = stations
        for i in 0..<stations.count {
            let station = stations[i]
            for item in self.favorites {
                if let favorite = item as? Station {
                    if favorite.name == station.name {
                        station.isFavorite = true
                        mappedStations[i] = station
                        if Verbose.Active { NSLog("[LocalDB] Log: \(station.name) filtered...") }
                    }
                }
            }
        }
        return mappedStations
    }

    /**
     Function that gets the radio station by name
     - parameter name: The string-value for the name
     - returns: The radio station instance
     */
    func getStation(_ name: String) -> Station? {
        for item in self.favorites { if let favorite = item as? Station { if favorite.name == name { return favorite } } }
        return nil
    }

    /**
     Function that gets the radio station by name
     - parameter index: The index of the list
     - returns: The radio station instance
     */
    func getStation(_ index: Int) -> Station? {
        if index < self.favorites.count { if let favorite = self.favorites[index] as? Station { return favorite } }
        return nil
    }

    /**
     Function that loads the objects required from the database
     */
    func load() {
        if var storedFavorites = UserDefaults.standard.object(forKey: "keyStoreFavorites") as? NSMutableArray {
            let auxiliarStoredFavorites = storedFavorites
            storedFavorites = NSMutableArray()
            for item in auxiliarStoredFavorites {
                if let dataResultStore = item as? Data {
                    if let favorite = NSKeyedUnarchiver.unarchiveObject(with: dataResultStore) { storedFavorites.add(favorite) }
                }
            }
            self.favorites = storedFavorites
        } else if Verbose.Active { NSLog("[LocalDB] Log: No favorites found in database...") }
    }

    /**
     Function that removes an entry from DB
     - parameter station: The station to remove or nil
     - parameter url: The url to remove
     */
    func remove(_ station: Station?) {
        if let foundStation = station { // radio station found
            if Verbose.Active { NSLog("[LocalDB] Log: Removed \(foundStation.name) from Favorites...") }
            self.favorites.remove(foundStation)
            self.synchronize()
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! station not found in Favorites -> Delete IGNORED...") } }
    }

    /**
     Function that stores the objects required in the database
     */
    func synchronize() {
        let favoritesData = NSMutableArray()
        for item in self.favorites {
            if let station = item as? Station {
                let dataStore = NSKeyedArchiver.archivedData(withRootObject: station)
                favoritesData.add(dataStore)
            }
        }
        UserDefaults.standard.set(favoritesData, forKey: "keyStoreFavorites")
        let synchronized = UserDefaults.standard.synchronize()
        if !synchronized { // error message
            NSLog("[LocalDB] Error! An error trying to synch all values in local storage!")
            let userInfo = [NSLocalizedDescriptionKey : "UserDefaults - Failed to synch all values in local storage",
                            NSLocalizedFailureReasonErrorKey : "500 - Failed to synch all values in local storage"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
        } else if Verbose.Active { NSLog("[LocalDB] Log: Stored \(favoritesData.count) favorites...") }
    }
}
