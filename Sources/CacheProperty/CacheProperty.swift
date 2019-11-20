import Foundation

protocol StorageProtocol {
//    func object(forKey key: Any) -> Any?
//    func setObject(_ obj: Any, forKey key: Any)
//    func remove(forKey key: Any) -> Void
}

protocol Storage: StorageProtocol {
    associatedtype K: Equatable
    associatedtype V: Equatable
    func object(forKey key: K) -> V?
    func setObject(_ obj: V, forKey key: K)
    func remove(forKey key: K) -> Void
}

struct NSCacheWrapper<KeyType: Equatable, ObjectType: Equatable>: Storage {
    typealias K = KeyType
    typealias V = ObjectType
    
    fileprivate class KeyWrapper: Equatable {
        let value: KeyType
        init(_ value: KeyType) {
            self.value = value
        }
        static func == (lhs: NSCacheWrapper<KeyType, ObjectType>.KeyWrapper, rhs: NSCacheWrapper<KeyType, ObjectType>.KeyWrapper) -> Bool {
            return lhs.value == rhs.value
        }
    }
    fileprivate class ValueWrapper: Equatable {
        let value: ObjectType
        init(_ value: ObjectType) {
            self.value = value
        }
        static func == (lhs: NSCacheWrapper<KeyType, ObjectType>.ValueWrapper, rhs: NSCacheWrapper<KeyType, ObjectType>.ValueWrapper) -> Bool {
            return lhs.value == rhs.value
        }
    }
    
    fileprivate let cache = NSCache<KeyWrapper, ValueWrapper>()
    
    func object(forKey key: K) -> V? {
        return self.cache.object(forKey: KeyWrapper(key))?.value
    }
    func setObject(_ obj: V, forKey key: K) {
        self.cache.setObject(ValueWrapper(obj), forKey: KeyWrapper(key))
    }
    func remove(forKey key: K) {
        self.cache.removeObject(forKey: KeyWrapper(key))
    }
}

@propertyWrapper
struct Cache<K: Equatable, V: Equatable> {
    var storage: NSCacheWrapper<K, V>
    var key: K
    var missing: ((K) -> V)

    init(key: K, storage: NSCacheWrapper<K, V> = NSCacheWrapper<K, V>(), missing: @escaping (K) -> V) {
        self.key = key
        self.storage = storage
        self.missing = missing
    }
    
    var wrappedValue: V {
        if let value: V = self.storage.object(forKey: key) {
            return value
        }
        let value = missing(key)
        self.storage.setObject(value, forKey: key)
        return value
    }

    func reset() {
        self.storage.remove(forKey: key)
    }
}
