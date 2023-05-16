//
//  ViewController.swift
//  Dardish
//
//  Created by Youssef on 12/12/2021.
//

import UIKit
import ImagePicker
import Firebase
import ProgressHUD
class WelcomeVC: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var nameTF: UITextField!{
        didSet{
            nameTF.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        }
    }
    @IBOutlet weak var emailTF: UITextField!{
        didSet{
            emailTF.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        }
    }
    @IBOutlet weak var passwordTF: UITextField!{
        didSet{
            passwordTF.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)])
        }
    }
    @IBOutlet weak var signOutlet: UIButton!{
        didSet{
            signOutlet.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var logNotificationLBL: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    //MARK: - Constants & Variables
    let leftSwip = UISwipeGestureRecognizer()
    let rightSwip = UISwipeGestureRecognizer()
    var profileImage:UIImage?
    let imageTapped = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setSwipesSettings()
        addTabGeastureToProfileImage()
    }
    
    //MARK:- IBAction
    @IBAction func signAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Sign up"{
            signUpBtnPressed()
        }else{
            signInBtnPressed()
        }
    }
    
    //MARK:- helper methods
    func setSwipesSettings(){
        leftSwip.direction = .left
        rightSwip.direction = .right
        self.view.addGestureRecognizer(leftSwip)
        self.view.addGestureRecognizer(rightSwip)
        leftSwip.addTarget(self, action: #selector(self.swiped))
        rightSwip.addTarget(self, action: #selector(self.swiped))
    }
    @objc func swiped(){
        if signOutlet.titleLabel?.text == "Sign up"{
            signOutlet.setTitle("Sign in", for: .normal)
            nameTF.isHidden = true
            profileImageView.isHidden = true
            logNotificationLBL.text = "Swip to sign up"
        }else{
            signOutlet.setTitle("Sign up", for: .normal)
            nameTF.isHidden = false
            profileImageView.isHidden = false
            logNotificationLBL.text = "Swip to sign in"
        }
    }
    func addTabGeastureToProfileImage(){
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTapped)
        imageTapped.addTarget(self, action: #selector(self.addActionToImageTappedGeasture))
    }
    func screenDefaultForm() {
        self.profileImageView.image = UIImage(systemName: "person.fill.badge.plus")
        self.nameTF.text = ""
        self.emailTF.text = ""
        self.passwordTF.text = ""
    }
    @objc func addActionToImageTappedGeasture() {
        let imagePickerControllerInstanse = ImagePickerController()
        imagePickerControllerInstanse.imageLimit = 1
        imagePickerControllerInstanse.delegate = self
        present(imagePickerControllerInstanse, animated: true, completion: nil)
    }
    func signUpBtnPressed() {
        guard !( emailTF.text!.isEmpty||passwordTF.text!.isEmpty||nameTF.text!.isEmpty||profileImage == nil )
        else {
            ProgressHUD.showError("Fill all required information")
            return }
        Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!) {  (result, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            print(result?.user.uid ?? "")
            self.saveUserInDB(uID: (result?.user.uid)!)
        }
    }
    func signInBtnPressed() {
        guard !( emailTF.text!.isEmpty||passwordTF.text!.isEmpty )
        else {
            ProgressHUD.showError("Fill all required information")
            return }
        Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!) { (result, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            print(result?.user.uid ?? "")
            SaveCurrentUser(uId: (result?.user.uid)!) { (isExisted) in
                if isExisted{
                    self.goToHome()
                }else{
                    ProgressHUD.showError("user not existed")
                }
            }
            self.nameTF.text = ""
            self.emailTF.text = ""
            self.passwordTF.text = ""
        }
    }
    func saveUserInDB(uID:String) {
        let userObjForm = FUser(_objectId: uID, _createdAt: Date(), _updatedAt: Date(), _email: emailTF.text!, _fullname: nameTF.text!, _avatar:getStringFromImage(image: profileImage!))
        print("object created")
        let userDict = userDictionaryFrom(user: userObjForm)
        print("dictionary created")
        DBref.child(reference(.User)).child(uID).setValue(userDict) { (error, ref) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            self.screenDefaultForm()
            print("success")
            saveUserLocally(fUser: userObjForm)
            self.goToHome()
        }
    }
    func goToHome() {
        let homeVC = UIStoryboard(name: "Users", bundle: nil).instantiateViewController(identifier: "UserNavVC")
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true, completion: nil)
    }
}


extension WelcomeVC:ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            profileImage = images.first
            profileImageView.image = profileImage?.circleMasked
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
