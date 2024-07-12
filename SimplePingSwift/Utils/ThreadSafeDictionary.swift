//
//  ThreadSafeDictionary.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 08/07/2024.
//

import Foundation

class ThreadSafeDictionary<Key: Hashable, Value> {
    typealias Element = (key: Key, value: Value)
    typealias SafeDictionary = Dictionary<Key, Value>

    private var dictionary = SafeDictionary()
    private let lock = ReadWriteLock()

    var isEmpty: Bool {
        lock.readLock()
        let result = dictionary.isEmpty
        lock.unlock()
        return result
    }

    var count: Int {
        let result: Int
        lock.readLock()
        result = dictionary.count
        lock.unlock()
        return result
    }

    var keys: SafeDictionary.Keys {
        let result: SafeDictionary.Keys
        lock.readLock()
        result = dictionary.keys
        lock.unlock()
        return result
    }

    var values: SafeDictionary.Values {
        let result: SafeDictionary.Values
        lock.readLock()
        result = dictionary.values
        lock.unlock()
        return result
    }

    func updateValue(_ value: Value, forKey key: Key) {
        lock.writeLock()
        dictionary.updateValue(value, forKey: key)
        lock.unlock()
    }

    func removeValue(forKey key: Key) {
        lock.writeLock()
        dictionary.removeValue(forKey: key)
        lock.unlock()
    }

    func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, (key: Key, value: Value)) throws -> ()) rethrows -> Result {
        lock.readLock()
        defer { lock.unlock() }
        var accumulator = initialResult
        for element in dictionary {
            try updateAccumulatingResult(&accumulator, element)
        }
        return accumulator
    }

    subscript(key: Key) -> Value? {
        get {
            lock.readLock()
            let value = dictionary[key]
            lock.unlock()
            return value
        }
        set {
            lock.writeLock()
            dictionary[key] = newValue
            lock.unlock()
        }
    }
}
