//
//  ContentView.swift
//  swiftuiavcap
//
//  Created by Ripon sk on 15/07/23.
//

import SwiftUI
import Combine
import AVFoundation
import MultipeerConnectivity
struct ContentView: View {
    @ObservedObject var cam = CameraModel()
    @ObservedObject var vid = VideoModel()
    @State var changeVal = 0.0
    @State var isRecording = false
    @State private var timer: Timer?
    var body: some View {
        
        ZStack{
            VideoPrev(videModel: vid)
            //            CameraPrev(cameModel: cam)
            GeometryReader{ r in
                ZStack{
                    HStack{
                        Button {
                            // For Video Capture
                            if isRecording == false{
                                isRecording = true
                                vid.recordVideo()
                            }else{
                                isRecording = false
                                vid.session.stopRunning()
                            }
                            //For Image Capture
                            //                    cam.takePhoto()
                            print("hi")
                        } label: {
                            ZStack{
                                ZStack{
                                    ProgressBar(val: .constant(0.6)).frame(width: 100,height: 100)
                                    Circle().fill(isRecording ? .red:.black).frame(width: 100,height: 100)
                                }
                                Circle().fill(isRecording ? .red:.gray).frame(width: 75,height: 75)
                                
                                
                            }
                            
                        }
                        /*.simultaneousGesture(LongPressGesture(minimumDuration: 0.10).onEnded({ _ in
                           
                                
                            })
                            
                        }))
                        .highPriorityGesture(TapGesture().onEnded({ _ in
                            print("hi")
                        }))
                        */
                        
                        Button("Retake") {
                            DispatchQueue.global(qos: .background).async {
                                vid.session.startRunning()
                                isRecording = false
                            }
                           
                        }
                    }
                    
                }.offset(x:r.size.width*0.4,y:r.size.height*0.87)
                
            }
            .onAppear{
                vid.checkAuthrozationForVideo()
            }
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
class CameraModel:NSObject,ObservableObject,AVCapturePhotoCaptureDelegate{
    @Published var session = AVCaptureSession()
    @Published var PreViewLayer = AVCaptureVideoPreviewLayer()
    @Published var outPut = AVCapturePhotoOutput()
    @Published var isTaken = false
    func checkAuthrozation(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { access in
                guard access else{return}
                self.setUpCamera()
            }
            break
        case .authorized:
            setUpCamera()
            break
        default:
            break
            
        }
    }
    func setUpCamera(){
        let session = AVCaptureSession()
        do{
            guard let device = AVCaptureDevice.default(for: .video)  else{return}
            let inp = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(inp){
                session.addInput(inp)
            }
            if session.canAddOutput(outPut){
                session.addOutput(outPut)
            }
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            PreViewLayer.session = session
            PreViewLayer.videoGravity = .resizeAspectFill
            self.session = session
            
            
            
        }catch{
            
        }
    }
    func takePhoto(){
        outPut.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else{return}
        guard let data = photo.fileDataRepresentation() else{return}
        let img = UIImage(data: data)
        UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
        
    }
    func savePic(){
        
    }
}
struct CameraPrev:UIViewRepresentable{
    @ObservedObject var cameModel:CameraModel
    func makeUIView(context: Context) ->  UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameModel.PreViewLayer.session = cameModel.session
        cameModel.PreViewLayer.videoGravity = .resizeAspectFill
        cameModel.PreViewLayer.frame = view.bounds
        view.layer.addSublayer(cameModel.PreViewLayer)
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
/*
 struct CameraDisplay:UIViewRepresentable{
 @ObservedObject var camModel:CameraModel
 
 func makeUIView(context: Context) ->  UIView {
 let view = UIView(frame: UIScreen.main.bounds)
 camModel.PreViewLayer.frame = view.bounds
 camModel.PreViewLayer.session = camModel.session
 camModel.PreViewLayer.videoGravity = .resizeAspectFill
 
 view.layer.addSublayer(camModel.PreViewLayer)
 return view
 }
 func updateUIView(_ uiView: UIViewType, context: Context) {
 //        if camModel.session.isRunning{
 //            camModel.takePhot()
 //            camModel.session.stopRunning()
 //        }
 }
 //    func makeCoordinator() -> Coordinator {
 //        return Coordinator(cam: $camModel)
 //    }
 
 
 }
 */
class VideoModel:NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate{
    @Published var session = AVCaptureSession()
    @Published var videoOutput = AVCaptureMovieFileOutput()
    @Published var prevLayer = AVCaptureVideoPreviewLayer()
    func checkAuthrozationForVideo(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { access in
                guard access else{return}
                self.setUpVideo()
            }
            break
        case .authorized:
            setUpVideo()
            break
        default:
            break
            
        }
    }
    func setUpVideo(){
        do{
            let session = AVCaptureSession()
            guard let vidDev = AVCaptureDevice.default(for: .video) else{return}
            guard let audDev = AVCaptureDevice.default(for: .audio) else{return}
            let videInp = try AVCaptureDeviceInput(device: vidDev)
            let audInp = try AVCaptureDeviceInput(device: audDev)
            if session.canAddInput(videInp) && session.canAddInput(videInp){
                session.addInput(videInp)
                session.addInput(audInp)
            }
            if session.canAddOutput(videoOutput){
                session.addOutput(videoOutput)
            }
            self.prevLayer.session = session
            self.prevLayer.videoGravity = .resizeAspectFill
            self.session = session
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            
            
            
        }catch{}
    }
    func recordVideo(){
        let url = NSTemporaryDirectory() + "\(Date()).mov"
        videoOutput.startRecording(to: URL(filePath: url), recordingDelegate: self)
        
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else{
            print(error?.localizedDescription)
            return}
        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        
    }
    
}
struct VideoPrev:UIViewRepresentable{
    @ObservedObject var videModel:VideoModel
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        videModel.prevLayer.frame = view.bounds
        view.layer.addSublayer(videModel.prevLayer)
        return view
        
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
