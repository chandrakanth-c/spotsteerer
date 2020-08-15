//
//  JobDetailViewController.swift
//  TestFinalProject
//
//  Created by Pavan Rao on 4/23/20.
//  Copyright © 2020 Pavan Rao. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class JobAddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var logo: UIImageView!
    let db = Firestore.firestore()
    var jobURL = ""
    var logoPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logo.image = UIImage(named: "logo")
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogoUpload)))
        logo.isUserInteractionEnabled = true
    }
    
    @objc func handleLogoUpload() {
        print("123")
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileImage(imageData: Data)
    {
        let activityIndicator = UIActivityIndicatorView.init(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("users").child(currentUser!.uid).child("\(currentUser!.uid)-profileImage.jpg")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
           
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                
                self.logo.image = UIImage(data: imageData)
                profileImageRef.downloadURL { (url,error) in
                    guard let downloadURL = url else {
                        return
                    }
                    self.jobURL = downloadURL.absoluteString
                    self.logoPath = uploadedImageMeta?.name ?? ""
                }
                
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = profileImage.jpegData(compressionQuality: 0.6)
        {
            // upload image from here
            uploadProfileImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SaveJob" {
            if (positionTextField.text == "" || companyTextField.text == "" || locationTextField.text == "" ||  deadlineTextField.text == "" || linkTextField.text == "") {
                let alert = UIAlertController(title: "Incorrect input", message: "All fields are mandatory!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "SaveJob"{
            if let position = positionTextField.text,
            let company = companyTextField.text,
            let location = locationTextField.text,
            let deadline = deadlineTextField.text,
            let link = linkTextField.text{
                db.collection("job").addDocument(data:["position":position, "company": company, "location": location, "deadline": deadline, "link": link, "companyLogo": jobURL])
            }
        }
    }

}
