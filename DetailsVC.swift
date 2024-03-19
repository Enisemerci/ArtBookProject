//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Enis Semerci on 16.03.2024.
//
import CoreData
import UIKit

class DetailsVC: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imagevİEW: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingID:UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            saveButton.isHidden = true
            //core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imagevİEW.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        //Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imagevİEW.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imagevİEW.addGestureRecognizer(imageTapRecognizer)
    }
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate=self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagevİEW.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //appdelegate i değişken olarak tanımlamamız gerekiyor içeriğe ulaşma için
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //attributes
        newPainting.setValue(nameText.text, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        //yıl int bir değer olduğu için böyle yapıyoruz
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        //görseli data olarak sıkıştırmak
        let data = imagevİEW.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        } catch{
         print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
