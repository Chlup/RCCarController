//
//  Mutex.swift
//  RCCariOSController
//
//  Created by Michal Fousek on 16/07/2020.
//  Copyright © 2020 Chlup. All rights reserved.
//


import Foundation

public class Mutex {

    let name: String
    private var mutex: pthread_mutex_t

    public init(name: String) {

        self.name = name
        mutex = pthread_mutex_t()

        var attr: pthread_mutexattr_t = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)

        let err = pthread_mutex_init(&self.mutex, &attr)
        pthread_mutexattr_destroy(&attr)

        switch err {

        case 0:
            break

        case EAGAIN:
            assertionFailure("Mutex \(name): Could not create mutex: EAGAIN (The system temporarily lacks the resources to create another mutex.)")

        case EINVAL:
            assertionFailure("Mutex \(name): Could not create mutex: invalid attributes")

        case ENOMEM:
            assertionFailure("Mutex \(name): Could not create mutex: no memory")

        default:
            assertionFailure("Mutex \(name): Could not create mutex, unspecified error \(err)")
        }
    }

    deinit {

        assert(
            pthread_mutex_trylock(&self.mutex) == 0 && pthread_mutex_unlock(&self.mutex) == 0,
            "deinitialization of a locked mutex results in undefined behavior!"
        )

        pthread_mutex_destroy(&self.mutex)
    }

    public func lock() {

        let ret = pthread_mutex_lock(&self.mutex)

        switch ret {

        case 0:
            // Success
            break

        case EDEADLK:
            assertionFailure("Mutex \(name): Could not lock mutex: a deadlock would have occurred")

        case EINVAL:
            assertionFailure("Mutex \(name): Could not lock mutex: the mutex is invalid")

        default:
            assertionFailure("Mutex \(name): Could not lock mutex: unspecified error \(ret)")
        }
    }

    public func unlock() {

        let ret = pthread_mutex_unlock(&self.mutex)

        switch ret {

        case 0:
            // Success
            break

        case EPERM:
            assertionFailure("Mutex \(name): Could not unlock mutex: thread does not hold this mutex")

        case EINVAL:
            assertionFailure("Mutex \(name): Could not unlock mutex: the mutex is invalid")

        default:
            assertionFailure("Mutex \(name): Could not unlock mutex: unspecified error \(ret)")
        }
    }

}

