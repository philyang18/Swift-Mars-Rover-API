//
//  FilterViewController.swift
//  final_project
//
//  Created by Phillip Yang on 4/29/19.
//  Copyright © 2019 Phillip Yang. All rights reserved.
//

import UIKit
import CoreImage

class FilterViewController: UIViewController{

    // variables
    @IBOutlet weak var mySaveButton: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var myImageView: UIImageView!
    var originalImage: UIImage?
    var processedImage: UIImage?
    var context: CIContext?
    var currentFilter: CIFilter?
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = originalImage
        context = CIContext()
        intensitySlider.setValue(0.0, animated: false)
        mySaveButton.isEnabled = false
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
    
    // when the slider moves, adjust the intensity of the filter
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    // when the button is clicked, open an action sheet to present the filter options
    @IBAction func changeFilterAction(_ sender: UIButton) {
        
        let filterAlertController = UIAlertController(title: "Choose a Filter", message: nil, preferredStyle: .actionSheet)
        
        filterAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        filterAlertController.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        filterAlertController.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        filterAlertController.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        
        // pin the popover to the button
        if let popoverController = filterAlertController.popoverPresentationController {
            popoverController.sourceView = sender
            // dimensions of the source
            popoverController.sourceRect = sender.bounds
        }
        present(filterAlertController, animated: true)
        
    }
    
    // completion handler to apply the filter to the image
    func setFilter(action: UIAlertAction) {
        guard originalImage != nil else { return }
        guard let actionTitle = action.title else { return }
        
        currentFilter = CIFilter(name: actionTitle)
        let imageCopy = CIImage(image: originalImage!)
        currentFilter!.setValue(imageCopy, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    // takes the filter and translates the slider value to match the input key
    func applyProcessing() {
        
        guard currentFilter != nil else { return }
        
        // applies different keys that the filter has
        let inputKeys = currentFilter?.inputKeys
        if inputKeys!.contains(kCIInputIntensityKey) {
            currentFilter!.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys!.contains(kCIInputRadiusKey) {
            currentFilter!.setValue(intensitySlider.value*200, forKey: kCIInputRadiusKey)
        }
        if inputKeys!.contains(kCIInputScaleKey) {
            currentFilter!.setValue(intensitySlider.value*10, forKey: kCIInputScaleKey)
        }
        if inputKeys!.contains(kCIInputCenterKey) {
            currentFilter!.setValue(CIVector(x: myImageView.image!.size.width / 2, y: myImageView.image!.size.height / 2), forKey: kCIInputCenterKey)
        }
        // create the filtered image
        if let cgImage = context?.createCGImage((currentFilter?.outputImage!)!, from: (currentFilter?.outputImage!.extent)!) {
            
            // cast the cgImage into a UIImage
            processedImage = UIImage(cgImage: cgImage)
            
            // present the new image and allow user to now save the image
            myImageView.image = processedImage
            mySaveButton.isEnabled = true
        }
        
    }
    
    // saves image to camera roll
    @IBAction func savePhoto(_ sender: Any) {
        guard processedImage != nil else { return }
        UIImageWriteToSavedPhotosAlbum(processedImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // call back to handle any errors while saving
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your filtered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}
