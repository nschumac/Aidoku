//
//  WasmDefaults.swift
//  Aidoku
//
//  Created by Skitty on 4/14/22.
//

import Foundation

class WasmDefaults {

    var globalStore: WasmGlobalStore

    init(globalStore: WasmGlobalStore) {
        self.globalStore = globalStore
    }

    func export(into namespace: String = "defaults") {
        try? globalStore.vm.linkFunction(name: "get", namespace: namespace, function: self.get)
        try? globalStore.vm.linkFunction(name: "set", namespace: namespace, function: self.set)
    }

    var get: (Int32, Int32) -> Int32 {
        { key, len in
            guard len > 0 else { return -1 }

            if let keyString = self.globalStore.readString(offset: key, length: len),
               let value = UserDefaults.standard.value(forKey: "\(self.globalStore.id).\(keyString)") {
                return self.globalStore.storeStdValue(value)
            }

            return -1
        }
    }

    var set: (Int32, Int32, Int32) -> Void {
        { key, len, value in
            guard len > 0, value >= 0 else { return }

            if let keyString = self.globalStore.readString(offset: key, length: len) {
                UserDefaults.standard.set(self.globalStore.readStdValue(value), forKey: "\(self.globalStore.id).\(keyString)")
            }
        }
    }
}
