import SwiftUI

@propertyWrapper
public struct SWR<Key, Value> : DynamicProperty where Key: Hashable {
    @ObservedObject var controller: SWRState<Key, Value>
    
    // Initialize with value
    public init(wrappedValue value: Value, key: Key, fetcher: Fetcher<Key, Value>, options: SWROptions = .init()) {
        controller = SWRState(key: key, fetcher: fetcher, data: value)
        
        controller.revalidate(force: false)
        // Refresh
        controller.setupRefresh(options)
    }
    // Initialize without value
    public init(key: Key, fetcher: Fetcher<Key, Value>, options: SWROptions = .init()) {
        controller = SWRState(key: key, fetcher: fetcher)
        
        controller.revalidate(force: false)
        // Refresh
        controller.setupRefresh(options)
    }
    
    public var wrappedValue: StateResponse<Key, Value> {
        get {
            return controller.get
        }
        nonmutating set {
            controller.set(data: newValue.data, error: newValue.error)
        }
    }
}
/// Other inits
public extension SWR where Key == URL {
    /// JSON Decoder init
    init(wrappedValue value: Value, url: String, options: SWROptions = .init()) where Value: Decodable {
        guard let uri = URL(string: url) else { fatalError("[SwiftSWR] Invalid URL: \(url)") }
        self.init(wrappedValue: value, key: uri, fetcher: FetcherDecodeJSON(), options: options)
    }
    /// JSON Decoder init
    init(url: String, options: SWROptions = .init()) where Value: Decodable {
        guard let uri = URL(string: url) else { fatalError("[SwiftSWR] Invalid URL: \(url)") }
        self.init(key: uri, fetcher: FetcherDecodeJSON(), options: options)
    }
}
