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

    // MARK: - Functions

    /**
     Function to initialize the instance with some parameters
     - parameter name: The displayed name of the account
     - parameter deviceId: The device identifier of the account
     - parameter identifier: The identifier of the conversation
     - parameter path: The path of the avatar of the account
     */
    init(_ name: String, url: String, artwork: String?, popularity: String?, imageName: String?) {
        self.popularity = popularity ?? Tag.Empty
        self.iconName = imageName ?? "radio"
        self.artwork = artwork ?? Tag.Empty
        self.name = name
        self.url = url
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.popularity, forKey: Encode.Popularity)
        aCoder.encode(self.artwork, forKey: Encode.Artwork)
        aCoder.encode(self.iconName, forKey: Encode.Icon)
        aCoder.encode(self.name, forKey: Encode.Name)
        aCoder.encode(self.url, forKey: Encode.URL)
    }

    required init?(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: Encode.Popularity) as? String { self.popularity = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Artwork) as? String { self.artwork = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Icon) as? String { self.iconName = value }
        if let value = aDecoder.decodeObject(forKey: Encode.Name) as? String { self.name = value }
        if let value = aDecoder.decodeObject(forKey: Encode.URL) as? String { self.url = value }
    }
}

class LocalDatabase: NSObject {

    // MARK: - Properties

    /** Property that represents the list of accounts */
    var favorites: NSMutableArray = NSMutableArray()
    /** Property that represents the list of inet addresses */
    var favoritesUrl: NSMutableArray = NSMutableArray()

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
        if !self.favoritesUrl.contains(url) {
            if !self.favorites.contains(element) {
                self.favorites.add(element)
                self.favoritesUrl.add(url)
                if Verbose.Active { NSLog("[LocalDB] Log: Added \(element) to Favorites...") }
            } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(element) not found in Favorites -> Insert IGNORED...") } }
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(url) not found in URL-favorites -> Insert IGNORED...") } }
        self.synchronize(0)
        self.synchronize(1)
    }

    /**
     Function that loads the objects required from the database
     - parameter type: The type of objects required:
     - 0: favorites
     - 1: favorites URL
     */
    func load(_ type: Int) {
        switch type {
        case 0: // accounts
            if var storedFavorites = UserDefaults.standard.array(forKey: "keyStoreFavorites") as? NSMutableArray {
                let auxiliarStoredFavorites = storedFavorites
                storedFavorites = NSMutableArray()
                for item in auxiliarStoredFavorites {
                    if let dataResultStore = item as? Data {
                        if let favorite = NSKeyedUnarchiver.unarchiveObject(with: dataResultStore) { storedFavorites.add(favorite) }
                    }
                }
                self.favorites = storedFavorites
            } else if Verbose.Active { NSLog("[LocalDB] Log: No favorites found in database...") }
            break
        case 1: // conversations
            if var storedFavorites = UserDefaults.standard.array(forKey: "keyStoreFavoritesURL") as? NSMutableArray {
                let auxiliarStoredFavorites = storedFavorites
                storedFavorites = NSMutableArray()
                for item in auxiliarStoredFavorites {
                    if let dataResultStore = item as? Data {
                        let conversation = NSKeyedUnarchiver.unarchiveObject(with: dataResultStore)
                        storedFavorites.add(conversation!)
                    }
                }
                self.favoritesUrl = storedFavorites
            } else if Verbose.Active { NSLog("[LocalDB] Log: No favorite-URLs found in database...") }
            break
        default: break
        }
    }

    /**
     Function that removes an entry from DB
     - parameter element: The element to remove
     - parameter url: The url to remove
     */
    func remove(_ element: String, url: String) {
        if self.favoritesUrl.contains(url) {
            if self.favorites.contains(element) {
                self.favorites.remove(element)
                self.favoritesUrl.remove(url)
                NSLog("[LocalDB] Log: Removed \(element) from Favorites...")
            } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(element) not found in Favorites -> Delete IGNORED...") } }
        } else { if Verbose.Active { NSLog("[LocalDB] Warning! \(url) not found in URL-favorites -> Delete IGNORED...") } }
        self.synchronize(0)
        self.synchronize(1)
    }

    /**
     Function that stores the objects required in the database
     - parameter type: The type of objects required:
     - 0: accounts
     - 1: conversations
     - 2: support conversations
     - 3: inet addresses
     - 4: tests
     */
    func synchronize(_ type: Int) {
        var key = Tag.Empty
        var count = 0
        switch type {
        case 0: // accounts
            let favoritesData = NSMutableArray()
            for item in self.favorites {
                if let favorite = item as? String {
                    let dataStore = NSKeyedArchiver.archivedData(withRootObject: favorite)
                    favoritesData.add(dataStore)
                }
            }
            UserDefaults.standard.set(favoritesData, forKey: "keyStoreFavorites")
            count = favoritesData.count
            key = "FAVORITES"
            break
        case 1: // conversations
            let urlsData = NSMutableArray()
            for item in self.favoritesUrl {
                if let url = item as? String {
                    let dataStore = NSKeyedArchiver.archivedData(withRootObject: url)
                    urlsData.add(dataStore)
                }
            }
            UserDefaults.standard.set(urlsData, forKey: "keyStoreFavoritesURL")
            count = urlsData.count
            key = "FAVORITE-URLS"
            break
        default: break
        }
        let synchronized = UserDefaults.standard.synchronize()
        if !synchronized { // error message
            NSLog("[LocalDB] Error! An error trying to synch all values in local storage!")
            let userInfo = [NSLocalizedDescriptionKey : "UserDefaults - Failed to synch all values in local storage",
                            NSLocalizedFailureReasonErrorKey : "500 - Failed to synch all values in local storage"]
            Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: -1001, userInfo: userInfo))
        } else if Verbose.Active { NSLog("[LocalDB] Log: Stored \(count) items stored in \(key)...") }
    }
}
