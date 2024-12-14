//
//  ContentView.swift
//  ClimbingRouteIdentifier
//
//  Created by Benjamin Cressman on 11/13/24.
//

import SwiftUI
import RealityKit
import PhotosUI

struct ContentView : View {
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer().edgesIgnoringSafeArea(.all)
            
            VStack {
                Button {
                    // Placeholder: take a snapshot
                    ARVariables.arView.snapshot(saveToHDR: false) { (image) in
                        // Compress the image
                        let compressedImage = UIImage(
                            data: (image?.pngData())!)
                        // Save in the photo album
                        UIImageWriteToSavedPhotosAlbum(
                            compressedImage!, nil, nil, nil)
                    }
                    print("Snapshot taken.")
                    
                } label: {
                    Image(systemName: "largecircle.fill.circle")
                        .frame(width:60, height:60)
                        .font(.system(size: 75))
                    //.background(.white.opacity(0.75))
                    //.cornerRadius(30)
                        .padding()
                        .foregroundStyle(.white)
                }
                PhotoPickerButton()
                    .padding()

            }
        }
    }
}

struct ARVariables{
    static var arView: ARView!
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        ARVariables.arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        // let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        // ARVariables.arView.scene.anchors.append(boxAnchor)
        
        return ARVariables.arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

struct PhotoPickerButton: View {
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack {
            // Display the selected image if available
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            }

            // Button to open the photo picker
            Button(action: {
                showPhotoPicker = true
            }) {
                Text("Select Photo")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first,
                  result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self = self, let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self.parent.selectedImage = image
                }
            }
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
