//
//  ChattingViewController.swift
//  MessageLight
//Проект будет интегрирован в приложение Business Ultimate. Дата выхода - год 2017.
//  Created by Владислав Ходеев on 15.07.16.
//  Copyright © 2016 Vlad Samoilov. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChattingViewController:  JSQMessagesViewController {
var lightMessages = [JSQMessage]()
    var avatarDictionary = [String:JSQMessagesAvatarImage]()
    
    
    
    
    

var messageRef = FIRDatabase.database().reference().child("messages")
var outgoingBubbleImageView: JSQMessagesBubbleImage!
var incomingBubbleImageView: JSQMessagesBubbleImage!


override func viewDidLoad() {
    super.viewDidLoad()

    
    if  let currentUser = FIRAuth.auth()?.currentUser {
    
        self.senderId = currentUser.uid

    
    if currentUser.anonymous == true {
        
        self.senderDisplayName = "anonymous"
    
    }else {
        self.senderDisplayName = "\(currentUser.displayName)"
    }

    }

observeMessages()

}

    
    func   observeUser(id:String){
        
        
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value, withBlock: {
            snapshot in
            
            if  let dict = snapshot.value as? [String: AnyObject]{
                
            let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(avatarUrl,messageId: id)
                
            }
            
        })
       // collectionView?.reloadData()
    }
    
    
    func setupAvatar(url:String, messageId:String) {
        
        if url != "" {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image , diameter: 90)
            avatarDictionary[messageId] = userImg
            
        }else {

            avatarDictionary[messageId] =  JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage.png"), diameter: 90)
            
        }
        collectionView!.reloadData()
    }
    
    
    
func observeMessages() {
messageRef.observeEventType(.ChildAdded, withBlock: { snapshot in
    //print(snapshot.value)
    if let dict = snapshot.value as? [String: AnyObject] {
        let mediaType = dict["MediaType"] as! String
        let senderId = dict["senderId"] as! String
        let senderName = dict["senderName"] as! String

        self.observeUser(senderId)
            
            
            
        switch mediaType {
    case "TEXT":
            let text = dict["text"] as! String
            self.lightMessages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
            
    case "PHOTO":
            
        let fileUrl = dict["fileUrl"] as! String
        let url = NSURL(string: fileUrl)
        let data = NSData(contentsOfURL: url!)
        let picture = UIImage(data: data!)
        let photo = JSQPhotoMediaItem(image: picture)
        self.lightMessages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
        if self.senderId == senderId {
            photo.appliesMediaViewMaskAsOutgoing = true

        }else {
            photo.appliesMediaViewMaskAsOutgoing = false

            }

            
    case "VIDEO":
            
            let fileUrl = dict["fileUrl"] as! String
            let video = NSURL(string: fileUrl)
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            self.lightMessages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
            if self.senderId == senderId {
                videoItem.appliesMediaViewMaskAsOutgoing = true
                
            }else {
                videoItem.appliesMediaViewMaskAsOutgoing = false
                
            }
            
    default:
            print("Неизвестный тип данных")

            }
            
            /*
            if  let text = dict["text"] as? String {
                self.lightMessages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
            } else {
                let fileUrl = dict["fileUrl"] as! String
                let data = NSData(contentsOfURL: NSURL(string: fileUrl)!)
                let picture = UIImage(data: data!)
               let lightPhoto = JSQPhotoMediaItem(image: picture)
              self.lightMessages.append(JSQMessage(senderId:self.senderId, displayName:self.senderDisplayName, media: lightPhoto))
            }
            
            */
        
        
    
            
            self.collectionView!.reloadData()

        }
      
    })
}
    

override func didPressSendButton(button: UIButton!,  withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
    
   // print("didPressSendButton")
 //   print("\(text)")
 //  print(senderId)
  //  print(senderDisplayName)
  //  lightMessages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
 //   collectionView?.reloadData()
    
    let newMessages = messageRef.childByAutoId()
    let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
    
    newMessages .setValue(messageData)
    self.finishSendingMessage()
    
    self.finishSendingMessageAnimated(true)
    
}

override func didPressAccessoryButton(sender: UIButton!) {
    print("didPressAccessoryButton")
    let sheet = UIAlertController(title: "Медиа сообщения", message: "Выбрать медиа файл", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction) in
        
    })
    
    let photoLibrary = UIAlertAction(title: "Выбрать фото", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction) in
        self.getMediaFrom(kUTTypeImage)
        
        })
    let videoLibrary = UIAlertAction(title: "Выбрать видео", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction) in
        
        self.getMediaFrom(kUTTypeMovie)

    })
    sheet.addAction(photoLibrary)
    sheet.addAction(videoLibrary)
    sheet.addAction(cancel)
    self.presentViewController(sheet, animated: true, completion: nil)
    
    
    /*
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    self.presentViewController(imagePicker, animated: true, completion: nil)
    */
    
}
    
    

func getMediaFrom(type: CFString) {
    let mediaPicker = UIImagePickerController()
    mediaPicker.delegate = self
    mediaPicker.mediaTypes = [type as String]
    self.presentViewController(mediaPicker, animated: true, completion: nil)
}
    
    

override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    
    
    
    
     let  message = lightMessages[indexPath.item]
    
    return    avatarDictionary[message.senderId]


    
}
    
override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = lightMessages[indexPath.item]
    let bubbleFactory = JSQMessagesBubbleImageFactory()

    if message.senderId == self.senderId {
        return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
    }else {
        
        return bubbleFactory.incomingMessagesBubbleImageWithColor(.grayColor())
    }
    
   
    
}

override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    return lightMessages[indexPath.item]
}

override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(lightMessages.count)
    return lightMessages.count
    
}

override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
    return cell
    
}

    
   

override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
    print("didTapMessageBubbleAtIndexPath: \(indexPath.item)")
    let message = lightMessages[indexPath.item]
    if message.isMediaMessage {
        if let mediaItem = message.media as? JSQVideoMediaItem{
            let player = AVPlayer(URL: mediaItem.fileURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true, completion: nil)
        }
        
    }
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
}

    
    func addMessage(id: String, text: String) {//2
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        lightMessages.append(message)
    }

    
    
@IBAction func logOutButton(sender: AnyObject) {
    
    do {
        try FIRAuth.auth()?.signOut()

        
    }catch let error {
        print(error)
    }
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let loginVC = storyBoard.instantiateViewControllerWithIdentifier("LoginVC") as! LogInViewController
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    appDelegate.window?.rootViewController = loginVC

    print("Пользователь вышел из чата")
}
func sendMedia(picture: UIImage?, video: NSURL?) {
    print(picture)
    
    if let picture = picture {
        let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
        
        let data = UIImageJPEGRepresentation(picture, 0.1)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        
        FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata)  {
            (metadata,error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            
            let fileUrl =  metadata!.downloadURLs![0].absoluteString
            
            let newMessages = self.messageRef.childByAutoId()
            let messageData = ["fileUrl": fileUrl, "senderId":self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
            
            newMessages .setValue(messageData)
            
        }
    } else  if let video = video {
        let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
        
        let data = NSData(contentsOfURL: video)
        let metadata = FIRStorageMetadata()
        metadata.contentType = "video/mp4"
        
        FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata)  {
            (metadata,error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            
            let fileUrl =  metadata!.downloadURLs![0].absoluteString
            
            let newMessages = self.messageRef.childByAutoId()
            let messageData = ["fileUrl": fileUrl, "senderId":self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
            
            newMessages .setValue(messageData)
            
        }
    }
        
    }
    }

extension ChattingViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    print("didFinishPickingMediaWithInfo")
    
    if  let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
        
        
        sendMedia(picture, video: nil)
    }
    else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
       
        sendMedia(nil, video: video)
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
    
   collectionView!.reloadData()
    
}



@IBAction func AddNewContact(sender: UIBarButtonItem) {
    
    
}

/*
override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // messages from someone else
    addMessage("foo", text: "Hello!")
    // messages sent from local sender
    addMessage(senderId, text: "Yo!")
    // animates the receiving of a new message on the view
    finishReceivingMessage()
}
override func textViewDidChange(textView: UITextView) {
    super.textViewDidChange(textView)
    // If the text is not empty, the user is typing
    print(textView.text != "")
}


}
*/
}