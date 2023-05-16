//
//  UserVC.swift
//  Dardish
//
//  Created by Youssef on 17/12/2021.
//

import UIKit

class UserVC: UIViewController {
// MARK:- IBOoutlet
    @IBOutlet weak var userTable: UITableView!
    
// MARK:- Constants & Variables
    var users:[FUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
    }
    

// MARK: - Helper Method
func getUser() {
    let userNode = DBref.child(reference(.User))
    userNode.observe(.value) { (snapShot) in
        let userDict = snapShot.value as! [String:Any]
        for (key,value) in userDict{
            if key != FUser.currentId(){
                self.users.append(FUser(_dictionary: value as! NSDictionary))
                self.userTable.reloadData()
            }
          }
        }
     }

}

extension UserVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTVC", for: indexPath) as! UsersTVCell
        cell.cellUserNameLBL.text = users[indexPath.row].fullname
        cell.email.text = users[indexPath.row].email
        imageFromStringData(pictureData: users[indexPath.row].avatar) { (img) in
            guard let handledImg = img else {return}
            cell.cellProfilImage.image = handledImg.circleMasked
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let messageVCObject = UIStoryboard(name: "Messages", bundle: nil).instantiateViewController(identifier: "MessagesVC") as! MessagesVC
        messageVCObject.users = [FUser.currentUser()! , users[indexPath.row]]
        messageVCObject.usersID = [FUser.currentId() , users[indexPath.row].objectId]
        self.navigationController?.pushViewController(messageVCObject, animated: true)
    }
}
