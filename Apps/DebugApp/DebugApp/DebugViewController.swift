import UIKit
import MapboxMaps
import CarPlay

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        view.backgroundColor = .red
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }

    func zoomIn() {
        let cameraOptions = CameraOptions(zoom: mapView.cameraState.zoom + 1)
        mapView.camera.ease(to: cameraOptions, duration: 1)
    }

    func zoomOut() {
        let cameraOptions = CameraOptions(zoom: mapView.cameraState.zoom - 1)
        mapView.camera.ease(to: cameraOptions, duration: 1)
    }
}

@available(iOS 12.0, *)
extension DebugViewController: CPMapTemplateDelegate {
    func mapTemplateDidBeginPanGesture(_ mapTemplate: CPMapTemplate) {

    }

    func mapTemplate(_ mapTemplate: CPMapTemplate, didUpdatePanGestureWithTranslation translation: CGPoint, velocity: CGPoint) {

    }

    func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        
    }
}

@available(iOS 12.0, *)
final class Foo: CPMapTemplate {
    
}
