//
//  PrinterState+Codable.swift
//  Calliope
//
//  Created by Mitsuharu Emoto on 2024/06/30.
//

import Foundation

fileprivate let KeyStatePrinter = "state.printer"

extension PrinterState {
    
    static func save(_ state: PrinterState) {
        let encoder = JSONEncoder()
        if let object = try? encoder.encode(state) {
            UserDefaults.standard.set(object, forKey: KeyStatePrinter)
        }
    }
    
    static func load() -> PrinterState? {
        if let object = UserDefaults.standard.data(forKey: KeyStatePrinter) {
            let decoder = JSONDecoder()
            if let state = try? decoder.decode(PrinterState.self, from: object) {
                return state
            }
        }
        return nil
    }
    
}

extension PrinterState.BuildJob: Codable {
    
    enum CodingKeys: String, CodingKey {
      case id
      case title
      case jobs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.jobs = try container.decode([Print.Job].self, forKey: .jobs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(jobs, forKey: .jobs)
    }
}

extension PrinterState: Codable {

    private enum CodingKeys: String, CodingKey {
        case buildJobs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deviceInfo = nil
        self.candiates = nil
        self.buildJobs = try container.decode([BuildJob].self, forKey: .buildJobs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(buildJobs, forKey: .buildJobs)
    }
}
