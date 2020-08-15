//
//  JobDisplayViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/24/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit

extension JobDisplayViewController {
    @IBAction func saveUpdatedJobDetail(_ segue: UIStoryboardSegue) {
        guard
            segue.source is JobUpdateViewController
           else {
             return
         }
        viewDidLoad()
    }
    
    @IBAction func cancelUpdateJobDetail(_ segue: UIStoryboardSegue) {
        guard
            segue.source is JobUpdateViewController
           else {
             return
         }
    }
}

class JobDisplayViewController: UIViewController {
    
    @IBOutlet weak var jobIdText: UILabel!
    var jobIdField: String?
    
    @IBOutlet weak var positionText: UILabel!
    var positionField: String?
    
    @IBOutlet weak var companyText: UILabel!
    var companyField: String?
    
    @IBOutlet weak var locationText: UILabel!
    var locationField: String?
    
    @IBOutlet weak var deadlineText: UILabel!
    var deadlineField: String?
    
    @IBOutlet weak var linkText: UILabel!
    var linkField: String?
    
    @IBOutlet weak var logo: UIImageView!
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jobIdText.text = jobIdField
        positionText.text = positionField
        companyText.text = companyField
        locationText.text = locationField
        deadlineText.text = deadlineField
        linkText.text = linkField
        
        print("Begin of code")
        let url = URL(string: self.imageURL ?? "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg")!
        downloadImage(from: url)
        print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")

        
        // Do any additional setup after loading the view.
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.logo.image = UIImage(data: data)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateJob" {
            if let jobUpdateViewController = segue.destination as? JobUpdateViewController {
                jobUpdateViewController.companyField = companyField
                jobUpdateViewController.deadlineField = deadlineField
                jobUpdateViewController.linkField = linkField
                jobUpdateViewController.locationField = locationField
                jobUpdateViewController.positionField = positionField
                jobUpdateViewController.jobIdField = jobIdField
            }
        }
    }

}
