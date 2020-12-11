//
//  ViewController.swift
//  SeeFood
//
//  Created by Dayton on 09/09/20.
//  Copyright © 2020 Dayton. All rights reserved.
//

import UIKit
import CoreML
    //vision help us to process images more easily and allow us to use images to work with CoreML
    // without writing a lot of code
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.image = userPickedImage
            
            //CIImage = CoreImage Image ; a type that allow us to use Vision and CoreML framework
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image:CIImage) {
        // VNCoreMLModel comes from Vision Framework, allow us to perform image analysis request that uses CoreML Model
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration.init()).model) else {
            fatalError("Loading CoreML Model Failed")
        }
        //asking the model to classify the data we passed i
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //a class that holds classification observation after our model been processed
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
            
        }catch{
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

