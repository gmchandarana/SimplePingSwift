//
//  BackgroundWorker.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 03/07/2024.
//

import Foundation

class BackgroundWorker: NSObject {

    var threadName: String? { thread?.name }
    var hasAnActiveThread: Bool { thread.isExecuting }

    private var thread: Thread!
    private var block: (() -> Void)!

    @objc private func runBlock() {
        block()
    }

    func start(_ block: @escaping () -> Void) {
        self.block = block

        let threadName = String(describing: self)
            .components(separatedBy: .punctuationCharacters)[1]

        thread = Thread { [weak self] in
            while (self != nil && !self!.thread.isCancelled) {
                RunLoop.current.run(mode: .default, before: Date.distantFuture)
            }
            Thread.exit()
        }
        thread.name = "\(threadName)-\(UUID().uuidString)"
        thread.start()

        perform(#selector(runBlock),
                on: thread,
                with: nil,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }

    func stop() {
        thread.cancel()
    }
}
