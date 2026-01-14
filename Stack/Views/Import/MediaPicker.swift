import SwiftUI
import PhotosUI

struct MediaPicker: UIViewControllerRepresentable {
    let selectionLimit: Int
    let onSelection: ([PHPickerResult]) -> Void
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .any(of: [.videos, .images])
        config.selectionLimit = selectionLimit
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true) {
                if results.isEmpty {
                    self.parent.onDismiss()
                } else {
                    self.parent.onSelection(results)
                }
            }
        }
    }
}
