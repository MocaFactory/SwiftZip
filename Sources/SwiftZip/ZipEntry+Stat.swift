// SwiftZip -- Swift wrapper for libzip
//
// Copyright (c) 2019-2020 Victor Pavlychko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import zip

extension ZipEntry.Stat {

    // MARK: - Validity Flags

    public struct ValidFields: OptionSet {
        public let rawValue: UInt64
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public static let name = ValidFields(rawValue: UInt64(ZIP_STAT_NAME))
        public static let index = ValidFields(rawValue: UInt64(ZIP_STAT_INDEX))
        public static let size = ValidFields(rawValue: UInt64(ZIP_STAT_SIZE))
        public static let compressedSize = ValidFields(rawValue: UInt64(ZIP_STAT_COMP_SIZE))
        public static let modificationDate = ValidFields(rawValue: UInt64(ZIP_STAT_MTIME))
        public static let crc32 = ValidFields(rawValue: UInt64(ZIP_STAT_CRC))
        public static let compressionMethod = ValidFields(rawValue: UInt64(ZIP_STAT_COMP_METHOD))
        public static let encryptionMethod = ValidFields(rawValue: UInt64(ZIP_STAT_ENCRYPTION_METHOD))
        public static let flags = ValidFields(rawValue: UInt64(ZIP_STAT_FLAGS))
    }

    // MARK: - Property Accessors

    public var valid: ValidFields {
        return ValidFields(rawValue: stat.valid)
    }

    public var rawName: Data? {
        return stat.name.flatMap {
            return Data(bytes: $0, count: strlen($0))
        }
    }

    public func decodedName(using encoding: String.Encoding = .utf8) throws -> String? {
        return try rawName.flatMap {
            return try String(data: $0, encoding: .utf8).unwrapped(or: ZipError.stringDecodingFailed)
        }
    }

    public var index: UInt64 {
        return stat.index
    }

    public var size: Int {
        do {
            return try zipCast(stat.size)
        } catch {
            preconditionFailure("Failed to cast entry size: \(error)")
        }
    }

    public var compressedSize: Int {
        do {
            return try zipCast(stat.comp_size)
        } catch {
            preconditionFailure("Failed to cast entry compressed size: \(error)")
        }
    }

    public var modificationDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(stat.mtime))
    }

    public var crc32: UInt32 {
        return stat.crc
    }

    public var compressionMethod: ZipEntry.CompressionMethod {
        return .init(rawValue: Int32(stat.comp_method))
    }

    public var encryptionMethod: ZipEntry.EncryptionMethod {
        return .init(rawValue: stat.encryption_method)
    }

    public var flags: UInt32 {
        return stat.flags
    }
}
