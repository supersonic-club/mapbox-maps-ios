import UIKit
import MapboxMobileEvents
@_implementationOnly import MapboxCommon_Private

extension UserDefaults {
    // dynamic var's name has to be the same as corresponding key in UserDefaults
    // to make KVO observing work properly
    @objc dynamic var MGLMapboxMetricsEnabled: Bool {
        get {
            return bool(forKey: #keyPath(MGLMapboxMetricsEnabled))
        }
        set {
            set(newValue, forKey: #keyPath(MGLMapboxMetricsEnabled))
        }
    }
}

internal final class EventsManager {
    private enum Constants {
        static let MGLAPIClientUserAgentBase = "mapbox-maps-ios"
        static let SDKVersion = Bundle.mapboxMapsMetadata.version
        static let UserAgent = String(format: "%/%", MGLAPIClientUserAgentBase, SDKVersion)
    }

    // use a shared instance to avoid redundant calls to
    // MMEEventsManager.shared().pauseOrResumeMetricsCollectionIfRequired()
    // when the MGLMapboxMetricsEnabled UserDefaults key changes and duplicate
    // calls to MMEEventsManager.shared().flush() when handling memory warnings.
    private static var shared: EventsManager?

    internal static func shared(withAccessToken accessToken: String) -> EventsManager {
        let result = shared ?? EventsManager(accessToken: accessToken)
        shared = result
        return result
    }

    private let mmeEventsManager: MMEEventsManager
    private let coreTelemetry: EventsService

    private let metricsEnabledObservation: NSKeyValueObservation

    private init(accessToken: String) {
        let sdkVersion = Bundle.mapboxMapsMetadata.version
        mmeEventsManager = .shared()
        mmeEventsManager.initialize(
            withAccessToken: accessToken,
            userAgentBase: "mapbox-maps-ios",
            hostSDKVersion: sdkVersion)
        mmeEventsManager.skuId = "00"

        let eventsServiceOptions = EventsServiceOptions(token: accessToken, userAgentFragment: Constants.MGLAPIClientUserAgentBase, baseURL: nil)
        coreTelemetry = EventsService(options: eventsServiceOptions)

        UserDefaults.standard.register(defaults: [
            #keyPath(UserDefaults.MGLMapboxMetricsEnabled): true
        ])

        metricsEnabledObservation = UserDefaults.standard.observe(\.MGLMapboxMetricsEnabled, options: [.initial, .new]) { [mmeEventsManager, coreTelemetry] _, change in
            DispatchQueue.main.async {
                guard let metricsEnabled = change.newValue else { return }

                UserDefaults.mme_configuration().mme_isCollectionEnabled = metricsEnabled
                mmeEventsManager.pauseOrResumeMetricsCollectionIfRequired()

                if metricsEnabled {
                    coreTelemetry.resumeEventsCollection()
                } else {
                    coreTelemetry.pauseEventsCollection()
                }
            }
        }
    }

    internal func sendTurnstile() {
        let turnstileEvent = TurnstileEvent(skuId: UserSKUIdentifier.mapsMAUS, sdkIdentifier: Constants.MGLAPIClientUserAgentBase, sdkVersion: Constants.SDKVersion)
        coreTelemetry.sendTurnstileEvent(for: turnstileEvent)
    }

    internal func sendMapLoadEvent() {
        let mapLoadEvent = MapboxCommon_Private.Event(priority: .immediate, attributes: ["event": "mapLoad"])

        coreTelemetry.sendEvent(for: mapLoadEvent)
    }
}
