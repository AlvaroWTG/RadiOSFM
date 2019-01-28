//
//  LocalDatabase.swift
//  RadioFmApp
//
//  Created by Alvaro on 12/11/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Alamofire
import Crashlytics
import SQLite

protocol LocalDbDelegate: class {

    /**
     This method is invoked wheter the local database hander fails.
     - parameter database: The database util component
     - parameter error: The error of the action
     */
    func database(_ database: LocalDatabase, didFailWithError error: NSError)
}

class Country: NSObject {

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
    var imageUrl = Tag.Empty

    // MARK: - Function

    /**
     Function to initialize the instance with some parameters
     - parameter parameters: The list of parameters
     */
    init(_ parameters: [String : Any]) {
        if let value = parameters["created_at"] as? String { self.dateCreated = value }
        if let value = parameters["updated_at"] as? String { self.dateUpdated = value }
        if let value = parameters["nombre"] as? String { self.localizedName = value }
        if let value = parameters["image"] as? String { self.imageUrl = value }
        if let value = parameters["iso"] as? String { self.isoCode = value }
        if let value = parameters["id"] as? Int { self.identifier = value }
        if let value = parameters["name"] as? String { self.name = value }
    }
}

class Station: NSObject {

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
    /** Property that represents whether the icon is downloaded or not */
    var iconDownloaded = false
    /** Property that represents the icon of the station */
    var icon = UIImage()
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
        self.iconDownloaded = false
        self.countryID = Tag.Empty
        self.imageUrl = Tag.Empty
        self.isFavorite = false
        self.parentStation = 0
        self.name = Tag.Empty
        self.isGeoblocked = 0
        self.icon = UIImage()
        self.identifier = 0
        self.isEnabled = 0
    }

    /*
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
    }
}

class LocalDatabase: NSObject {

    // MARK: - Properties

    /** Property that represents the delegate of the utils */
    weak var delegate: LocalDbDelegate?
    /** Property that represents the list of favorites stations */
    var favorites = NSMutableArray()
    /** Property that represents the list of countries */
    var countries = NSMutableArray()
    /** Property that represents the list of stations on a country */
    var stations = NSMutableArray()
    /** Property that represents the database for the connection */
    var database: Connection?

    // MARK: - Singleton

    static let standard = LocalDatabase()
    private override init() {
        // This prevents others from using the default '()' initializer for this class.
    }

    // MARK: - Functions

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
     Function that fill the list from a response
     - parameter level: The level of response
     - parameter list: The list of stations
     */
    func parse(_ level: Int, list: [Any]) {
        self.open()
        switch level {
            case 0: // countries
                if self.countries.count == 0 { self.countries = NSMutableArray() }
                for element in list { // loop around countries
                    if let parameters = element as? [String : Any] {
                        let country = Country(parameters)
                        self.countries.add(country)
                        if Verbose.Active { NSLog("[LocalDB] Log: Added \(country.name)...") }
                    }
                }
                if Verbose.Active { NSLog("[LocalDB] Log: Stored \(self.countries.count) countries...") }
                break
            case 1: // stations
                if self.stations.count == 0 { self.stations = NSMutableArray() }
                for element in list { // loop around countries
                    if let parameters = element as? [String : Any] {
                        let station = Station(parameters)
                        self.stations.add(station)
                        if Verbose.Active { NSLog("[LocalDB] Log: Added \(station.name)...") }
                    }
                }
                if Verbose.Active { NSLog("[LocalDB] Log: Stored \(self.stations.count) stations...") }
                break
            default: // invalid level
                NSLog("[HTTP] Error! Invalid response level!")
                break
        }
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
            let userInfo = [NSLocalizedDescriptionKey : "Failed to synch all values in local storage"]
            Crashlytics.sharedInstance().recordError(NSError(domain: "LocalDB", code: 500, userInfo: userInfo))
        } else if Verbose.Active { NSLog("[LocalDB] Log: Stored \(favoritesData.count) favorites...") }
    }

    // MARK: - Functions DB Manager

    /**
     Function that connects to DB
     */
    private func connect() {
        guard let path = self.getDatabasePath() else { return }
        do {
            self.database = try Connection(path)
            NSLog("[LocalDB] Log: DB connection established...")
        } catch let error as NSError {
            self.delegate?.database(self, didFailWithError: error)
        }
    }

    /**
     Function that opens the DB connection
     */
    private func createSchema() {
        guard let db = self.database else {
            let userInfo = [NSLocalizedDescriptionKey : "Invalid database to handle"]
            self.delegate?.database(self, didFailWithError: NSError(domain: "SQLite3", code: 404, userInfo: userInfo))
            return
        }

        // Table Countries and Stations
        let stations = Table("stations")
        let countries = Table("countries")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let localizedName = Expression<String>("localized_name")
        let dateCreated = Expression<String?>("date_created")
        let dateUpdated = Expression<String>("date_updated")
        let isoCode = Expression<String?>("iso_country_code")
        let imageUrl = Expression<String>("image_url")
        let countryID = Expression<String>("country_id")
        let descriptionStation = Expression<String?>("description_station")
        let isEnabled = Expression<Int64>("is_enabled")
        let isGeoblocked = Expression<Int64>("is_geoblocked")
        let parentStation = Expression<Int64>("parent_station")
        do {
            try db.run(countries.create { table in
                table.column(id, primaryKey: true)
                table.column(name, unique: true)
                table.column(localizedName)
                table.column(dateCreated)
                table.column(dateUpdated)
                table.column(isoCode)
                table.column(imageUrl)
            })
            try db.run(stations.create { table in
                table.column(id, primaryKey: true)
                table.column(name, unique: true)
                table.column(dateCreated)
                table.column(dateUpdated)
                table.column(imageUrl)
                table.column(countryID)
                table.column(descriptionStation)
                table.column(isEnabled)
                table.column(isGeoblocked)
                table.column(parentStation)
            })
        } catch let error as NSError {
            NSLog("[LocalDB] Error \(error.code) - \(error.localizedDescription)")
            self.delegate?.database(self, didFailWithError: error)
        }
    }

    /**
     Function that destroys the DB
     */
    private func destroyDatabase() {
        guard let path = self.getDatabasePath() else { return }
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                if Verbose.Active { NSLog("[NSFileManager] Log: Removed item @ /.../Documents/db.sqlite3") }
            } catch let error as NSError {
                self.delegate?.database(self, didFailWithError: error)
            }
        } else { if Verbose.Active { NSLog("[NSFileManager] Warning! Not found DB @ /.../Documents/db.sqlite3") } }
    }

    /**
     Function that gets the DB path
     - returns: The optional database path
     */
    private func getDatabasePath() -> String? {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            return "\(path)/db.sqlite3"
        } else { // error
            let userInfo = [NSLocalizedDescriptionKey : "Database path not found"]
            self.delegate?.database(self, didFailWithError: NSError(domain: "documentDirectory", code: 404, userInfo: userInfo))
            return nil
        }
    }

    /**
     Function that inserts a new country
     */
    private func insert(_ country: Country) {
        guard let db = self.database else {
            let userInfo = [NSLocalizedDescriptionKey : "Invalid database to handle, cannot insert country"]
            self.delegate?.database(self, didFailWithError: NSError(domain: "SQLite3", code: 404, userInfo: userInfo))
            return
        }
        let countries = Table("countries")
//        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let localizedName = Expression<String>("localized_name")
        let dateCreated = Expression<String?>("date_created")
        let dateUpdated = Expression<String>("date_updated")
        let isoCode = Expression<String?>("iso_country_code")
        let imageUrl = Expression<String>("image_url")
        do {
            let rowID = try db.run(countries.insert(name <- country.name, localizedName <- country.localizedName, dateCreated <- country.dateCreated,
                                                dateUpdated <- country.dateUpdated, isoCode <- country.isoCode, imageUrl <- country.imageUrl))
            NSLog("[LocalDB] Log: Country inserted @ \(rowID)")
        } catch let error as NSError {
            NSLog("[LocalDB] Error \(error.code) - \(error.localizedDescription)")
            self.delegate?.database(self, didFailWithError: error)
        }
    }

    /**
     Function that opens the DB connection
     */
    private func manage() {
        guard let db = self.database else {
            let userInfo = [NSLocalizedDescriptionKey : "Invalid database to handle"]
            self.delegate?.database(self, didFailWithError: NSError(domain: "SQLite3", code: 404, userInfo: userInfo))
            return
        }
        // Table Countries
        let countries = Table("countries")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        do {
            if let country = self.getCountry(0) { self.insert(country) }
            for country in try db.prepare(countries) { print("id: \(country[id]), name: \(country[name] ?? "unknown")") } // SELECT * FROM "users"

//            let alice = users.filter(id == rowID)
//            try db.run(alice.update(email <- email.replace("mac.com", with: "me.com"))) // UPDATE
//            try db.run(alice.delete()) // DELETE
//            let result = try db.scalar(users.count)
        } catch let error as NSError {
            NSLog("[LocalDB] Error \(error.code) - \(error.localizedDescription)")
            self.delegate?.database(self, didFailWithError: error)
        }
    }

    /**
     Function that opens the DB connection
     */
    func open() {
        if !Verbose.Production { self.destroyDatabase() }
        self.connect()
        self.createSchema()
    }

    // MARK: - Functions Favorites

    /**
     Function that adds an entry to DB
     - parameter element: The element to add
     - parameter url: The url to add
     */
    func addToFavorites(_ element: Station) {
        var isValid = true
        for item in self.favorites {
            if let favorite = item as? Station {
                if favorite.name == element.name {
                    isValid = false
                    break
                }
            }
        }
        if isValid { // needs to add into favorites
            self.favorites.add(element)
            if Verbose.Active { NSLog("[LocalDB] Log: Added \(element.name) to Favorites...") }
            self.synchronize()
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(element.name) already in Favorites -> Insert IGNORED...") } } // ignored
    }

    /**
     Function that filter the stations
     - parameter stations: The list of stations to map
     - returns: The new filtered list of stations
     */
    func filterFavorites(_ stations: [Station]) -> [Station] {
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
     Function that removes an entry from DB
     - parameter station: The station to remove or nil
     - parameter url: The url to remove
     */
    func removeFromFavorites(_ station: Station?) {
        if let foundStation = station { // radio station found
            if Verbose.Active { NSLog("[LocalDB] Log: Removed \(foundStation.name) from Favorites...") }
            self.favorites.remove(foundStation)
            self.synchronize()
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! station not found in Favorites -> Delete IGNORED...") } }
    }
}
