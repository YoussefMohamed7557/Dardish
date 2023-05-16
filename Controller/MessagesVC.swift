//
//  MessagesVC.swift
//  Dardish
//
//  Created by Youssef on 02/02/2022.
//

import UIKit
import ImagePicker

class MessagesVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var messagesTextField: UITextField!
    @IBOutlet weak var sendBtnOutlet: UIButton!
    

    //MARK: - Constants & Variables
    var chatRoomId:String!
    var usersID:[String]!
    var messages = [Messages]()
    var users = [FUser]()
    var selectedImage:UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messages = []
        getMessages()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTable.separatorStyle = .none
        messagesTable.rowHeight = UITableView.automaticDimension
        chatRoomId = getChatRoomId(firstUserId: usersID.first!, secondUserId: usersID.last!)
    }
    //MARK: - IBActions
    @IBAction func sendBtnAction(_ sender: UIButton) {
        if messagesTextField.text != ""{
            sendBtnOutlet.isEnabled = false
            sendMyMessage(text: messagesTextField.text!, image: nil)
        }
    }
    @IBAction func imagePickerPressed(_ sender: UIButton) {
        let imagePickerObj = ImagePickerController()
        imagePickerObj.imageLimit = 1
        imagePickerObj.delegate = self
        self.present(imagePickerObj, animated: true, completion: nil)
    }
    
    
    //MARK: - Helper Method
    func sendMyMessage(text:String?,image:String?){
        if let handledText = text {
            let ecryptedText = Encryption.encryptText(chatRoomId: chatRoomId, message: handledText)
            let messageId = UUID().uuidString
            let goingMessage = OutgoingMessages(message: ecryptedText, senderId: FUser.currentId(), senderName: FUser.currentUser()?.fullname ?? "", date: Date(), messageType: kPRIVATE, type:messageType(.text), messageId: messageId)
            goingMessage.sendMessage(chatRoomId: chatRoomId, messageDictionary: goingMessage.messagesDictionary, membersIds: usersID)
            messagesTextField.text = ""
            sendBtnOutlet.isEnabled = true
        }
        if let handledImage = image{
            let messageId = UUID().uuidString
            let ecryptedText = Encryption.encryptText(chatRoomId: chatRoomId, message: "[image]")
            let goingMessage = OutgoingMessages(message: ecryptedText, senderId: FUser.currentId(), senderName: FUser.currentUser()?.fullname ?? "", date: Date(), messageType: kPRIVATE, imageLink: handledImage, type: messageType(.image), messageId: messageId)
            goingMessage.sendMessage(chatRoomId: chatRoomId, messageDictionary: goingMessage.messagesDictionary, membersIds: usersID)
        }
        
    }
    func getMessages() {
        DBref.child(reference(.Message)).child(FUser.currentId()).child(chatRoomId).queryOrdered(byChild: kDATE).observe(.childAdded) { (snapshot) in
            let messageDictionary = snapshot.value as! NSDictionary
            let messageObject = Messages(_dictionary: messageDictionary, _chatRoomId: self.chatRoomId)
            self.messages.append(messageObject)
            self.messagesTable.reloadData()
            self.scrollDown()
        }
    }
    func scrollDown() {
        DispatchQueue.main.async {
            let indexPathForLastMessage = IndexPath(row: self.messages.count-1, section: 0)
            if indexPathForLastMessage.row > 0{
                self.messagesTable.scrollToRow(at: indexPathForLastMessage, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
}

extension MessagesVC:UITableViewDelegate ,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages[indexPath.row].type == kTEXT{
            
            if messages[indexPath.row].senderId == FUser.currentId(){
                let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! myMessageCell
                cell.messageLBL.text = messages[indexPath.row].message
                cell.dateLBL.text = timeElapsed(date: messages[indexPath.row].date)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "myFriendMessageCell", for: indexPath) as! myFriendMessageCell
                cell.messageLBL.text = messages[indexPath.row].message
                cell.dateLBL.text = timeElapsed(date: messages[indexPath.row].date)
                return cell
            }
            
        }else{
            
            if messages[indexPath.row].senderId == FUser.currentId(){
                let cell = tableView.dequeueReusableCell(withIdentifier: "myImageMessageCell", for: indexPath) as! myImageMessageCell
                cell.recieveDate.text = timeElapsed(date: messages[indexPath.row].date)
                downloadImage(imageUrl: messages[indexPath.row].picture) { (downloadedImage) in
                    if let handledImage = downloadedImage{
                        cell.cellImageView.image = handledImage
                    }
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "myFrindImageMessageCell", for: indexPath) as! myFrindImageMessageCell
                cell.recieveDate.text = timeElapsed(date: messages[indexPath.row].date)
                downloadImage(imageUrl: messages[indexPath.row].picture) { (downloadedImage) in
                    if let handledImage = downloadedImage{
                        cell.cellImageView.image = handledImage
                    }
                }
                return cell
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
extension MessagesVC:ImagePickerDelegate{
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            selectedImage = images.last
            // upload image to firestore
            uploadImage(image: selectedImage!, chatRoomId: self.chatRoomId, view: self.navigationController!.view) { (imageURL) in
                // get image url
                guard let imageURL = imageURL else {return}
                // send message to real time DB
                self.sendMyMessage(text: nil, image: imageURL)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
