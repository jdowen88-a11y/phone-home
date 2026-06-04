import Foundation

enum LocalStore {
    private static func url(for filename: String) throws -> URL {
        let directory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return directory.appendingPathComponent(filename)
    }

    static func save<T: Encodable>(_ value: T, as filename: String) {
        do {
            let data = try JSONEncoder.pretty.encode(value)
            let fileURL = try url(for: filename)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("LocalStore save failed:", error)
        }
    }

    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        do {
            let fileURL = try url(for: filename)
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("LocalStore load failed:", error)
            return nil
        }
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
