//
//  MenuViewController.swift
//  RadioFmApp
//
//  Created by Alvaro on 28/10/18.
//  Copyright © 2018 Alvaro. All rights reserved.
//

import UIKit

class MenuViewCell: UITableViewCell {

    // MARK: - Properties

    /** Property that represents the label for the user */
    @IBOutlet weak var labelTitle: UILabel!
    /** Property that represents the image view for the user */
    @IBOutlet weak var iconView: UIImageView!
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    /** Property that represents the button for the view */
    @IBOutlet weak var imageView: UIImageView!
    /** Property that represents the image view for the view */
    @IBOutlet weak var tableView: UITableView!
    /** Property that represents the list of titles for the menu */
    private var titles = [String]()
    /** Property that represents the list of images names for the menu */
    private var images = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.titles = ["Stations", "Favorites", "Top20", "Evaluate", "Share App", "Sleep"]
        self.images = ["radio", "star", "top", "rating", "share", "timer"]
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.bounces = false
    }

    // MARK: - Inherited functions from UITableView data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuViewCell", for: indexPath) as! MenuViewCell
        self.tableView = tableView
        cell.iconView.image = UIImage(named: self.images[indexPath.row])
        cell.iconView = ColorUtils.shared.renderImage(cell.iconView, color: .lightGray, userInteraction: true)
        cell.labelTitle.text = NSLocalizedString(self.titles[indexPath.row], comment: Tag.Empty)
        cell.labelTitle.adjustsFontSizeToFitWidth = true
        cell.labelTitle.textColor = .gray
        cell.labelTitle.numberOfLines = 0
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // MARK: - Inherited functions from UITableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: .selectMenuItem, object: indexPath.row)
    }
}
