//
//  UserProfileViewController.swift
//  Cab42
//
//  Created by Andres Margendie on 23/07/2018.
//  Copyright © 2018 Margendie Consulting LDT. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var keys: [String] = []
    var values: [String?] = []
    let cellIdentifier = "cellIdentifier"
    
    var user: User?
    
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.roundedImage()
        
        keys = ["","Full Name", "Email","Change Photo","Change Password"]
        values = ["",user?.getName(), user?.getEmail(), "", ""]
        
        self.picker.delegate = self
        self.refreshProfileImage()
    }
    
    func refreshProfileImage(){
        let uid: String! = user?.userId
        print("uid"+uid)
        let path: String! = "images/\(uid!)/profile_photo.jpg"
        let store = Storage.storage()
        let storeRef = store.reference().child(path!)
        
        storeRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("error1: \(error.localizedDescription)")
                if (self.user?.providerID != "password"){
                    self.downloadImage(url: (self.user?.getPhotoURL())!)
                }
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.profilePicture.image = image
            }
        }
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    private func downloadImage(url: URL) {
        print("Download Started")
        self.getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profilePicture.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func cameraAction(_ sender: Any) {
        self.picker.allowsEditing = false
        self.picker.sourceType = UIImagePickerControllerSourceType.camera
        self.picker.cameraCaptureMode = .photo
        self.picker.modalPresentationStyle = .fullScreen
        self.present(picker,animated: true,completion: nil)
    }
    
    @IBAction func libraryAction(_ sender: Any) {
        self.picker.allowsEditing = false
        self.picker.sourceType = .photoLibrary
        self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(picker, animated: true, completion: {
            print("handle saving")
        })
    }
}

extension UserProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let key = keys[indexPath.row]
        let value = values[indexPath.row]
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        if (indexPath.row == 3 || indexPath.row == 4 ){
            cell.accessoryView = UIImageView(image:UIImage(named:"replace-icon")!)
        }
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = keys[indexPath.row]
        if value == "Change Password" {
            print(keys[indexPath.row])
            performSegue(withIdentifier: "segueChangePassword", sender: self)
        } else if value == "Change Photo" {
            print(keys[indexPath.row])
            uploadPhoto()
            
        }else {
            print("no me interesa")
        }
    }
    
    private func uploadPhoto1(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photo = storageRef.child("userPhotos/"+(user?.userId)!+".jpg")
        print(photo)
    }
    private func uploadPhoto(){
        self.picker.allowsEditing = false
        self.picker.sourceType = .photoLibrary
        self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.present(picker, animated: true, completion: {
            print("handle saving")
        })
    }
    
}



//MARK: UIImagePickerView delegate methods
extension UserProfileViewController{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        let profileImageFromPicker = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageData: Data = UIImageJPEGRepresentation(profileImageFromPicker, 0.5)!
        
        let store = Storage.storage()
        if let user = user{
            let storeRef = store.reference().child("images/\(user.userId)/profile_photo.jpg")
            //ASProgressHud.showHUDAddedTo(self.view, animated: true, type: .default)
            let _ = storeRef.putData(imageData, metadata: metadata) { (metadata, error) in
                // ASProgressHud.hideHUDForView(self.view, animated: true)
                guard let _ = metadata else {
                    print("error occured: \(error.debugDescription)")
                    return
                }
                
                print("metadata"+(metadata?.bucket)!)
                
                self.profilePicture.image = profileImageFromPicker
            }
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

