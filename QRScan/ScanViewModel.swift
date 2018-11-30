//
//  ScanViewModel.swift
//  QRScan
//
//  Created by 張翔 on 2018/11/29.
//  Copyright © 2018 張翔. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa


class ScanViewModel: NSObject {
    
    let session = AVCaptureSession()
    
    private let foundQRRelay = BehaviorRelay<(count: Int, text: String)>(value: (count: 0, text: ""))
    var foundQR: Driver<(count: Int, text: String)> {
        return foundQRRelay.asDriver()
    }
    
    var recentlyScanedQR: [String] = []
    
    override init() {
    }
    
    func setupQRScan() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        let devices = discoverySession.devices
        if let backCamera = devices.first {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                    let metadataOutput = AVCaptureMetadataOutput()
                    if session.canAddOutput(metadataOutput) {
                        session.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    func startQRScan() {
        session.startRunning()
    }
    
    func stopQRScan() {
        session.stopRunning()
    }
    
}

extension ScanViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            guard metadata.type == .qr,
                let text = metadata.stringValue,
                recentlyScanedQR.firstIndex(of: text) == nil
                else {
                    continue
            }
            
            foundQRRelay.accept((count: foundQRRelay.value.count + 1, text: text))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +  10) {
                if let index = self.recentlyScanedQR.firstIndex(of: text) {
                    self.recentlyScanedQR.remove(at: index)
                }
            }
        }
    }
}
