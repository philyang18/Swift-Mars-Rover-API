//
//  FavoritesTableViewController.swift
//  final_project
//
//  Created by Phillip Yang on 4/25/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//
import Alamofire
import Kingfisher
import SwiftyJSON
import UIKit

class FavoritesTableViewController: UITableViewController{
    
    let API_KEY = "RzyT98G4RWi51f3LYNHdbdEzUJkUH7RdAJnQoOd0"
    let imagesModel = MarsImagesModel.sharedInstance
    var imageToEdit: UIImage?
    var myIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesModel.numberOfImages()
    }

    // fill the table in with an image an their respective date
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        
        let currImage = imagesModel.image(atIndex: indexPath.row, setCurrIndex: false)
        
        Alamofire.request("https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos", method: .get, parameters: ["api_key": API_KEY, "earth_date": currImage!.getUrl()])
            
            .responseJSON { response in
                if let result = response.result.value {
                    let json = JSON(result)
                    if let imageURL = json["photos"][currImage!.getID()]["img_src"].string {
                        let httpsURL = imageURL.replacingOccurrences(of: "http", with: "https")
                        let url = URL(string: httpsURL)
                        
                        // Set the ImageView with an image from a URL
                        cell.imageView!.kf.setImage(with: url)
                        cell.textLabel!.text = currImage?.getUrl()
                    }
                }
        }
        return cell
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            imagesModel.removeImage(atIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // send the image of the selected row to the FilterViewController for processing
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        imageToEdit = tableView.cellForRow(at: indexPath)?.imageView?.image!
        performSegue(withIdentifier: "filterSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let filterViewController = segue.destination as! FilterViewController
            filterViewController.originalImage = imageToEdit
        }
    }
}
