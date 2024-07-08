//
//  ReadWriteLock.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 06/07/2024.
//

import Foundation

final class ReadWriteLock {
    private var lock: pthread_rwlock_t

    init() {
        lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
    }

    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }

    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }

    func unlock() {
        pthread_rwlock_unlock(&lock)
    }

    deinit { pthread_rwlock_destroy(&lock) }
}
