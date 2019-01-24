//
//  TableViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit
import Crashlytics
import FRadioPlayer

class MainViewCell: UITableViewCell {

    // MARK: - Properties

    /** Property that represents the label for the user */
    @IBOutlet weak var labelTitle: UILabel!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconView: UIImageView!
    /** Property that represents the image view for the user */
    @IBOutlet weak var starView: UIImageView!
}

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, RadioDelegate {

    // MARK: - Properties

    /** Property that represents the label for the error message */
    @IBOutlet weak var labelMessage: UILabel!
    /** Property that represents the image view for the view */
    @IBOutlet weak var tableView: UITableView!
    /** Property that represents the label for the user */
    @IBOutlet weak var footer: UIView!
    /** Property that represents the label for the user */
    @IBOutlet weak var labelStation: UILabel!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconStation: UIImageView!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconPlay: UIImageView!
    /** Property that represents the search controller */
    private var searchController = UISearchController(searchResultsController: nil)
    /** Property that represents the list of stations for the menu */
    private var stations = [Station]()
    /** Property that represents the list of filtered results */
    private var filteredStations = [Station]()
    /** Property that represents the list of scopes */
    private var scopes = [NSLocalizedString("SEARCH_SCOPE_ALL", comment: Tag.Empty), NSLocalizedString("SEARCH_SCOPE_NEWS", comment: Tag.Empty),
                          NSLocalizedString("SEARCH_SCOPE_SPORTS", comment: Tag.Empty), NSLocalizedString("SEARCH_SCOPE_MUSIC", comment: Tag.Empty)]
    /** Property that represents wheter is playing radio or not */
    private var isPlaying = false
    /** Property that represents wheter is favorite screen or not */
    private var isFavorites = false
    /** Property that represents the selected row */
    private var selectedRow = 0

    // MARK: - Inherited functions from UIView controller

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.isPlaying = UserDefaults.standard.bool(forKey: "isPlaying")
        self.isFavorites = UserDefaults.standard.bool(forKey: "isFavorites")
        self.navigationController?.topViewController?.navigationItem.title = NSLocalizedString(self.isFavorites ? "MENU_ITEM_ONE" : "MENU_ITEM_ZERO", comment: Tag.Empty)

        // Setup table view controller and model
        if self.isFavorites { // favorites screen
            LocalDatabase.standard.load()
            self.stations = LocalDatabase.standard.favorites as! [Station]
        } else { // home screen
            self.stations = LocalDatabase.standard.stations as! [Station]
            self.map()
        }
        self.labelMessage.text = NSLocalizedString("MAIN_NO_STATIONS", comment: Tag.Empty).uppercased()
        self.labelMessage.isHidden = self.stations.count > 0
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.isHidden = self.stations.count <= 0
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Setup footer for player
        self.labelStation.text = NSLocalizedString("APP_NAME", comment: Tag.Empty)
        self.footer.isUserInteractionEnabled = true
        self.iconStation.image = UIImage(named: "radio")
        self.iconPlay.image = UIImage(named: "play")
        self.iconPlay.isUserInteractionEnabled = true
        self.footer.isHidden = self.stations.count <= 0
        let tapFooter = UITapGestureRecognizer(target: self, action: #selector(self.didTapFooter(_:)))
        let tapToggle = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        tapFooter.numberOfTouchesRequired = 1
        tapToggle.numberOfTouchesRequired = 1
        tapFooter.numberOfTapsRequired = 1
        tapToggle.numberOfTapsRequired = 1
        self.iconPlay.addGestureRecognizer(tapToggle)
        self.footer.addGestureRecognizer(tapFooter)
        if self.isPlaying { self.refresh() }

        // Setup Search Controller
        self.configureSearchController()

        // Swap Back button
        NotificationCenter.default.post(name: .swapBackButton, object: nil)
    }

    // MARK: - Inherited functions from UITableView data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView = tableView
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewCell", for: indexPath) as? MainViewCell {
            if let station = self.getStationAt(indexPath.row) {
                cell.iconView.image = UIImage(named: "radio")
                cell.iconView.setImageFrom(station.imageUrl)
                cell.starView = self.toggle(cell.starView, selected: station.isFavorite)
                cell.starView.addGestureRecognizer(self.getGesture())
                cell.labelTitle.adjustsFontSizeToFitWidth = true
                cell.starView.isUserInteractionEnabled = true
                cell.labelTitle.text = station.name
                cell.labelTitle.textColor = .gray
                cell.labelTitle.numberOfLines = 0
                cell.starView.tag = indexPath.row
            }
            cell.backgroundColor = .white
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let listOfStations = self.searchBarIsFiltering() ? self.filteredStations : self.stations
        return listOfStations.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: - Inherited functions from UITableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let station = self.getStationAt(indexPath.row) {
            UserDefaults.standard.set(station.name, forKey: "selectedStation")
            self.selectedRow = indexPath.row
            self.play(indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.isFavorites
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if self.isFavorites && editingStyle == .delete { self.deleteRowAt(indexPath) }
    }

    // MARK: - Inherited functions from UISearchController delegate

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            self.filterForSearchText(text, scope: scope)
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let text = searchController.searchBar.text {
            let scope = searchBar.scopeButtonTitles![selectedScope]
            self.filterForSearchText(text, scope: scope)
        }
    }

    /**
     Function that evaluates whether the search bar is empty or not
     - returns: Whether the search bar is empty or not
     */
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    /**
     Function that evaluates whether the search bar is filtering or not
     - returns: Whether the search bar is filtering or not
     */
    private func searchBarIsFiltering() -> Bool {
        return searchController.isActive && !self.searchBarIsEmpty()
    }

    // MARK: - Inherited functions from RadioUtils delegate

    func util(_ util: RadioUtils, playerStateChanged state: FRadioPlayerState) {
        switch state {
        case .error:
            NSLog("[FRadioPlayer] Error! Player failed to load!")
            let userInfo = [NSLocalizedDescriptionKey : "Player failed to load"]
            Crashlytics.sharedInstance().recordError(NSError(domain: "RadioUtils", code: 500, userInfo: userInfo))
            break
        case .loading:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player is loading...") }
            break
        case .loadingFinished:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player finished loading...") }
            UserDefaults.standard.set(true, forKey: "isPlaying")
            self.isPlaying = true
            self.refresh()
            break
        case .readyToPlay:
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Player is ready to play...") }
            break
        case .urlNotSet:
            NSLog("[FRadioPlayer] Log: Player has NO URL set...")
            break
        default: break
        }
    }

    func util(_ util: RadioUtils, metadataChanged rawValue: String?, url: URL?) {
        if let url = url { self.iconStation.setImageFrom(url) }
        if let value = rawValue {
            if Verbose.Active { NSLog("[FRadioPlayer] Log: Received metadata - \(value)") }
            DispatchQueue.main.async { self.labelStation.text = value }
        }
    }

    // MARK: - Inherited functions from UITap gesture recognizers

    /**
     Function that handles the tap gesture
     - parameter sender: The tap gesture recognizer
     */
    @objc func didTap(_ sender: UITapGestureRecognizer) {
        if self.isPlaying {
            RadioUtils.shared.stop()
            self.isPlaying = false
            self.refresh()
        } else { self.play(self.selectedRow) }
        UserDefaults.standard.set(self.isPlaying, forKey: "isPlaying")
    }

    /**
     Function that handles the tap gesture for footer
     - parameter sender: The tap gesture recognizer
     */
    @objc func didTapFooter(_ sender: UITapGestureRecognizer) {
        if let station = self.getStationAt(self.selectedRow) {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
                viewController.isPlaying = self.isPlaying
                viewController.station = station
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    /**
     Function that handles the tap gesture
     - parameter sender: The tap gesture recognizer
     */
    @objc func didTapFavorite(_ sender: UITapGestureRecognizer) {
        if let row = sender.view?.tag {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPath) as? MainViewCell {
                if !self.isFavorites { // default view controller
                    if let station = self.getStationAt(row) {
                        if station.isFavorite {
                            station.isFavorite = false
                        } else { station.isFavorite = true }
                        cell.starView = self.toggle(cell.starView, selected: station.isFavorite)
                        self.populateFavorites(station, isAdding: station.isFavorite)
                    }
                } else { self.deleteRowAt(indexPath) } // favorite screen
            }
        }
    }

    // MARK: - Functions

    /**
     Function that configures the search controller
     */
    private func configureSearchController() {
        self.searchController.searchBar.scopeButtonTitles = self.scopes
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        if #available(iOS 11.0, *) { // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = self.searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else { // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
        definesPresentationContext = true
        self.searchController.searchBar.tintColor = .white
        self.searchController.searchBar.barTintColor = .white
        if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let subview = textfield.subviews.first {
                subview.backgroundColor = .white
                subview.layer.cornerRadius = 10
                subview.clipsToBounds = true
            }
        }
    }

    /**
     Function that deletes a row
     - parameter indexPath: The indexPath of the cell
     */
    private func deleteRowAt(_ indexPath: IndexPath) {
        if let station = self.getStationAt(indexPath.row) {
            var listOfStations = self.searchBarIsFiltering() ? self.filteredStations : self.stations
            self.populateFavorites(station, isAdding: false)
            listOfStations.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
    }

    /**
     Function that filters the table with search text
     - parameter searchText: The search text found from search bar
     - parameter scope: The string-value for the scope
     */
    private func filterForSearchText(_ searchText: String, scope: String) {
        self.filteredStations = self.stations.filter({( station : Station) -> Bool in
            let categoryMatches = (scope == self.scopes[0]) || (station.descriptionStation == scope)
            let stationContainText = station.name.lowercased().contains(searchText.lowercased())
            let bothValid = categoryMatches && stationContainText
            return self.searchBarIsEmpty() ? categoryMatches : bothValid
        })
        self.tableView.reloadData()
    }

    /**
     Function that gets a tap gesture recognizer
     - returns: The tap gesture recognizer
     */
    private func getGesture() -> UITapGestureRecognizer {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapFavorite(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        return tapGesture
    }

    /**
     Function that gets a station at an index
     - parameter row: The row of the station
     - returns: The station found or nil
     */
    private func getStationAt(_ row: Int) -> Station? {
        var listOfStations = self.searchBarIsFiltering() ? self.filteredStations : self.stations
        if row < listOfStations.count { return listOfStations[row] } // valid index
        NSLog("Error! Cell indexPath.row \(row) out of bounds \(listOfStations.count)!")
        let userInfo = [NSLocalizedDescriptionKey : "Cell indexPath.row \(row) out of bounds \(listOfStations.count)"]
        Crashlytics.sharedInstance().recordError(NSError(domain: Api.ErrorDomain, code: 404, userInfo: userInfo))
        return nil
    }

    /**
     Function that maps the radio stations
     */
    private func map() {
        if !UserDefaults.standard.bool(forKey: "applicationIsFresh") {
            let mapped = LocalDatabase.standard.filter(self.stations)
            self.stations = mapped
        }
        UserDefaults.standard.set(false, forKey: "applicationIsFresh")
    }

    /**
     Function that plays the radio station
     - parameter row: The row of the cell
     */
    private func play(_ row: Int) {
        if let station = self.getStationAt(row) {
            RadioUtils.shared.configure(station)
            RadioUtils.shared.delegate = self
        }
    }

    /**
     Function that populates the favorites list
     - parameter row: The row of the cell
     - parameter isAdding: Whether is adding new or not
     */
    private func populateFavorites(_ station: Station, isAdding: Bool) {
        if isAdding { // add
            LocalDatabase.standard.add(station)
        } else { LocalDatabase.standard.remove(station) } // remove
    }

    /**
     Function that refreshes the player footer
     */
    private func refresh() {
        DispatchQueue.main.async {
            self.iconPlay.image = UIImage(named: self.isPlaying ? "pause" : "play")
            let stationName = UserDefaults.standard.string(forKey: "selectedStation")
            self.labelStation.text = self.isPlaying ? stationName : "RadiOS FM"
        }
    }

    /**
     Function that toggles an image view
     - parameter imageView: The image view to toggle
     - parameter selected: Whether is selected or not
     - returns: The image view toggled
     */
    private func toggle(_ imageView: UIImageView, selected: Bool) -> UIImageView {
        var customView = imageView
        if self.isFavorites { // favorites
            customView.image = UIImage(named: "rubbish")
            customView = ColorUtils.shared.renderImage(customView, color: Color.k1097FB, userInteraction: true)
        } else { // home screen
            customView.image = UIImage(named: selected ? "star_full" : "star_empty")
            if !selected { customView = ColorUtils.shared.renderImage(customView, color: Color.k1097FB, userInteraction: true) }
        }
        return customView
    }
}
