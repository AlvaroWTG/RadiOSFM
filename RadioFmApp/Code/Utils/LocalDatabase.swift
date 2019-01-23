//
//  LocalDatabase.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Crashlytics

class Country: NSObject, NSCoding {

    // MARK: - Properties

    /** Property that represents the date of creation */
    var dateCreated = Tag.Empty
    /** Property that represents the date of updated */
    var dateUpdated = Tag.Empty
    /** Property that represents the country identifier */
    var identifier = 0
    /** Property that represents the country name */
    var name = Tag.Empty
    /** Property that represents the country localized name */
    var localizedName = Tag.Empty
    /** Property that represents the ISO country code */
    var isoCode = Tag.Empty
    /** Property that represents the URL of the country image */
    var url = Tag.Empty

    // MARK: - Functions

    /**
     Initializes the station as default
     */
    override init() {
        self.localizedName = Tag.Empty
        self.dateCreated = Tag.Empty
        self.dateUpdated = Tag.Empty
        self.identifier = 0
        self.isoCode = Tag.Empty
        self.name = Tag.Empty
        self.url = Tag.Empty
    }

    /**
     Function to initialize the instance with some parameters
     - parameter parameters: The list of parameters
     */
    init(_ parameters: [String : Any]) {
        if let value = parameters["nombre"] as? String { self.localizedName = value }
        if let value = parameters["created_at"] as? String { self.dateCreated = value }
        if let value = parameters["updated_at"] as? String { self.dateUpdated = value }
        if let value = parameters["id"] as? Int { self.identifier = value }
        if let value = parameters["iso"] as? String { self.isoCode = value }
        if let value = parameters["name"] as? String { self.name = value }
        if let value = parameters["image"] as? String { self.url = value }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.localizedName, forKey: Encode.CountryLocalName)
        aCoder.encode(self.dateCreated, forKey: Encode.DateCreated)
        aCoder.encode(self.dateUpdated, forKey: Encode.DateUpdated)
        aCoder.encode(self.name, forKey: Encode.CountryName)
        aCoder.encode(self.identifier, forKey: Encode.Id)
        aCoder.encode(self.url, forKey: Encode.ImageUrl)
        aCoder.encode(self.isoCode, forKey: Encode.Iso)
    }

    required init?(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: Encode.CountryLocalName) as? String { self.localizedName = value }
        if let value = aDecoder.decodeObject(forKey: Encode.DateCreated) as? String { self.dateCreated = value }
        if let value = aDecoder.decodeObject(forKey: Encode.DateUpdated) as? String { self.dateUpdated = value }
        if let value = aDecoder.decodeObject(forKey: Encode.CountryName) as? String { self.name = value }
        if let value = aDecoder.decodeObject(forKey: Encode.ImageUrl) as? String { self.url = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Iso) as? String { self.isoCode = value }
        self.identifier = aDecoder.decodeInteger(forKey: Encode.Id)
    }
}

class Station: NSObject, NSCoding {

    // MARK: - Properties

    /** Property that represents the ISO country code */
    var countryID = Tag.Empty
    /** Property that represents the date of creation */
    var dateCreated = Tag.Empty
    /** Property that represents the date of updated */
    var dateUpdated = Tag.Empty
    /** Property that represents the name of the icon for radio station */
    var descriptionStation = Tag.Empty
    /** Property that represents the country identifier */
    var identifier = 0
    /** Property that represents the popularity of the station */
    var isEnabled = 0
    /** Property that represents the name of the station */
    var isGeoblocked = 0
    /** Property that represents the URL of the country image */
    var imageUrl = Tag.Empty
    /** Property that represents the country name */
    var name = Tag.Empty
    /** Property that represents the artwork of the station */
    var parentStation = 0
    /** Property that represents whether the station is favorite or not */
    var isFavorite = false

    // MARK: - Functions

    /**
     Initializes the station as default
     */
    override init() {
        self.descriptionStation = Tag.Empty
        self.dateCreated = Tag.Empty
        self.dateUpdated = Tag.Empty
        self.countryID = Tag.Empty
        self.imageUrl = Tag.Empty
        self.isFavorite = false
        self.parentStation = 0
        self.name = Tag.Empty
        self.isGeoblocked = 0
        self.identifier = 0
        self.isEnabled = 0
    }

    /**
     Function to initialize the instance with some parameters
     - parameter parameters: The list of parameters
     */
    init(_ parameters: [String : Any]) {
        if let value = parameters["description"] as? String { self.descriptionStation = value }
        if let value = parameters["station_parent"] as? Int { self.parentStation = value }
        if let value = parameters["created_at"] as? String { self.dateCreated = value }
        if let value = parameters["updated_at"] as? String { self.dateUpdated = value }
        if let value = parameters["geoblocked"] as? Int { self.isGeoblocked = value }
        if let value = parameters["country_id"] as? String { self.countryID = value }
        if let value = parameters["enabled"] as? Int { self.isEnabled = value }
        if let value = parameters["image"] as? String { self.imageUrl = value }
        if let value = parameters["id"] as? Int { self.identifier = value }
        if let value = parameters["name"] as? String { self.name = value }
        self.isFavorite = false
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.descriptionStation, forKey: Encode.Description)
        aCoder.encode(self.parentStation, forKey: Encode.Parent)
        aCoder.encode(self.dateCreated, forKey: Encode.DateCreated)
        aCoder.encode(self.dateUpdated, forKey: Encode.DateUpdated)
        aCoder.encode(self.isGeoblocked, forKey: Encode.Geoblocked)
        aCoder.encode(self.countryID, forKey: Encode.CountryId)
        aCoder.encode(self.isFavorite, forKey: Encode.Favorite)
        aCoder.encode(self.isEnabled, forKey: Encode.Enabled)
        aCoder.encode(self.imageUrl, forKey: Encode.ImageUrl)
        aCoder.encode(self.identifier, forKey: Encode.Id)
        aCoder.encode(self.name, forKey: Encode.Name)
    }

    required init?(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: Encode.Description) as? String { self.descriptionStation = value }
        if let value = aDecoder.decodeObject(forKey: Encode.DateCreated) as? String { self.dateCreated = value }
        if let value = aDecoder.decodeObject(forKey: Encode.DateUpdated) as? String { self.dateUpdated = value }
        if let value = aDecoder.decodeObject(forKey: Encode.CountryId) as? String { self.countryID = value }
        if let value = aDecoder.decodeObject(forKey: Encode.ImageUrl) as? String { self.imageUrl = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Name) as? String { self.name = value }
        self.isGeoblocked = aDecoder.decodeInteger(forKey: Encode.Geoblocked)
        self.parentStation = aDecoder.decodeInteger(forKey: Encode.Parent)
        self.isEnabled = aDecoder.decodeInteger(forKey: Encode.Enabled)
        self.isFavorite = aDecoder.decodeBool(forKey: Encode.Favorite)
        self.identifier = aDecoder.decodeInteger(forKey: Encode.Id)
    }
}

class LocalDatabase: NSObject {

    // MARK: - Properties

    /** Property that represents the list of favorites stations */
    var favorites: NSMutableArray = NSMutableArray()
    /** Property that represents the list of countries */
    var countries: NSMutableArray = NSMutableArray()
    /** Property that represents the list of stations on a country */
    var stations: NSMutableArray = NSMutableArray()

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
//        for item in self.favorites {
//            if let favorite = item as? Station {
//                if favorite.url == url || favorite.name == element {
//                    isValid = false
//                    break
//                }
//            }
//        }
        if isValid { // needs to add into favorites
//            self.favorites.add(Station(element, url: url, artwork: nil, popularity: nil, imageName: nil, category: nil, isFavorite: true))
            if Verbose.Active { NSLog("[LocalDB] Log: Added \(element) to Favorites...") }
            self.synchronize()
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(element) already in Favorites -> Insert IGNORED...") } }
    }
    
    /**
     Function that creates dummy entries in the DB
     */
    func createDummy() -> [Station] {
        let dummyStations = NSMutableArray()
//        let names = ["Megastar FM", "RPA Radio", "RNE", "Ibiza Sonica Radio", "RAC 105", "Cadena Ser", "Radio Voz", "Radio Galaxia"]
//        let urls = ["http://195.10.10.222/cope/megastar.aac?GKID=d51d8e14d69011e88f2900163ea2c744", "http://195.55.74.203/rtpa/live/radio.mp3?GKID=280fad92d69a11e8b65b00163e914", "http://rne-hls.flumotion.com/playlist.m3u8", "http://s1.sonicabroadcast.com:7005/stream/1/", "http://rac105.radiocat.net/", "http://playerservices.streamtheworld.com/api/livestream-redirect/CADENASERAAC_SC", "http://live.radiovoz.es/coruna/master.m3u8", "http://radios-ec.cdn.nedmedia.io/radios/ec-galaxia.m3u8"]
//        for i in 0..<names.count { dummyStations.add(Station(names[i], url: urls[i], artwork: nil, popularity: nil, imageName: nil, category: nil, isFavorite: false)) }
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
     Function that gets the country by index
     - parameter index: The index of the list
     - returns: The country instance
     */
    func getCountry(_ index: Int) -> Country? {
        if index < self.countries.count { // found country
            if let country = self.countries[index] as? Country { return country }
        }
        return nil
    }

    /**
     Function that gets the country by isoCountryCode
     - parameter isoCountryCode: The isoCountryCode of the country
     - returns: The country instance
     */
    func getCountry(_ isoCountryCode: String?) -> Country? {
        if let isoCountryCode = isoCountryCode {
            for item in self.countries { // loop on countries
                if let country = item as? Country {
                    if country.isoCode == isoCountryCode { return country }
                }
            }
        }
        return nil
    }

    /**
     Function that gets the radio station by name
     - parameter name: The string-value for the name
     - returns: The radio station instance
     */
    func getStation(_ name: String) -> Station? {
        for item in self.favorites { // loop on favorites
            if let favorite = item as? Station {
                if favorite.name == name { return favorite }
            }
        }
        return nil
    }

    /**
     Function that gets the radio station by index
     - parameter index: The index of the list
     - returns: The radio station instance
     */
    func getStation(_ index: Int) -> Station? {
        if index < self.favorites.count { // found station
            if let favorite = self.favorites[index] as? Station { return favorite }
        }
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
     Function that fill the countries
     - parameter list: The list of countries
     */
    func parseCountries(_ list: [Any]) {
        if self.countries.count == 0 { self.countries = NSMutableArray() }
        for element in list { // loop around countries
            if let parameters = element as? [String : Any] {
                let country = Country(parameters)
                self.countries.add(country)
                if Verbose.Active { NSLog("[LocalDB] Log: Added \(country.name)...") }
            }
        }
        if Verbose.Active { NSLog("[LocalDB] Log: Stored \(self.countries.count) countries...") }
    }

    /**
     Function that fill the stations for a country
     - parameter list: The list of stations
     */
    func parseStations(_ list: [Any]) {
        if self.stations.count == 0 { self.stations = NSMutableArray() }
        for element in list { // loop around countries
            if let parameters = element as? [String : Any] {
                let station = Station(parameters)
                self.stations.add(station)
                if Verbose.Active { NSLog("[LocalDB] Log: Added \(station.name)...") }
            }
        }
        if Verbose.Active { NSLog("[LocalDB] Log: Stored \(self.stations.count) stations...") }
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
                            NSLocalizedFailureReasonErrorKey : "Failed to synch all values in local storage"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: 500, userInfo: userInfo))
        } else if Verbose.Active { NSLog("[LocalDB] Log: Stored \(favoritesData.count) favorites...") }
    }
}
