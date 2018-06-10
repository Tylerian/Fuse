import Foundation
import CFuse

public protocol ByteBuffer:
    ByteBufferReadable,
    ByteBufferWritable {
    var capacity: Int { get set }
    var unsafe: UnsafeMutablePointer<UInt8> { get }
    
    init()
    init(capacity: Int)
    
    func copy() -> ByteBuffer
}

public protocol ByteBufferReadable {
    var readable: Bool { get }
    var readerIndex: Int { get set }
    var readableBytes: Int { get }
    
    func markReaderIndex() -> Self
    func resetReaderIndex() -> Self
    
    func discardReadBytes() -> Self
    
    func getInt8 (at offset: Int) -> Int8
    func getInt16(at offset: Int, endianness: Endianness) -> Int16
    func getInt32(at offset: Int, endianness: Endianness) -> Int32
    func getInt64(at offset: Int, endianness: Endianness) -> Int64
    func getBytes(at offset: Int, length: Int) -> [UInt8]
    
    func readInt8 () -> Int8
    func readInt16(endianness: Endianness) -> Int16
    func readInt32(endianness: Endianness) -> Int32
    func readInt64(endianness: Endianness) -> Int64
    func readBytes(_ length: Int) -> [UInt8]
}

public protocol ByteBufferWritable {
    var writable: Bool { get }
    var writerIndex: Int { get }
    var writableBytes: Int { get }
    
    func markWriterIndex() -> Self
    func resetWriterIndex() -> Self
    
    mutating func set(int8  value: Int8,    at offset: Int) -> Self
    mutating func set(int16 value: Int16,   at offset: Int, endianness: Endianness) -> Self
    mutating func set(int32 value: Int32,   at offset: Int, endianness: Endianness) -> Self
    mutating func set(int64 value: Int64,   at offset: Int, endianness: Endianness) -> Self
    mutating func set(bytes value: [UInt8], at offset: Int) -> Self
    
    mutating func write(int8  value: Int8) -> Self
    mutating func write(int16 value: Int16, endianness: Endianness) -> Self
    mutating func write(int32 value: Int32, endianness: Endianness) -> Self
    mutating func write(int64 value: Int64, endianness: Endianness) -> Self
    mutating func write(bytes value: [UInt8]) -> Self
    mutating func write(bytes value: ByteBuffer) -> Self
}

internal final class UnsafeByteBuffer: ByteBuffer {
    private var handle: fs_byte_buffer_t
    
    public  var capacity: Int {
        get {
            return Int(self.handle.capacity)
        }
        
        set(value) {
            let result = fs_byte_buffer_resize(&self.handle, UInt32(value))
            
            guard result == FS_OKAY else {
                let message = String(cString: fs_error_to_string(result))
                fatalError("Fatal error while resizing underlying memory storage. Reason: \(message)")
            }
        }
    }
    
    internal var unsafe: UnsafeMutablePointer<UInt8> {
        return self.handle.heap
    }
    
    public required convenience init() {
        self.init(capacity: kDefaultCapacity)
    }
    
    public required init(capacity: Int) {
        self.handle = fs_byte_buffer_t()
        let  result = fs_byte_buffer_init(&self.handle, UInt32(capacity));
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while initializing underlying memory storage. Reason: \(message)")
        }
    }
    
    deinit {
        fs_byte_buffer_free(&self.handle)
    }
    
    public func copy() -> ByteBuffer {
        let copy   = UnsafeByteBuffer()
        let result = fs_byte_buffer_copy(&self.handle, &copy.handle)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while creating a copy of this UnsafeByteBuffer: \(String(describing: self)).\nReason: \(message)")
        }
        
        return copy
    }
}

extension UnsafeByteBuffer: ByteBufferReadable {
    public var readable: Bool {
        return self.writerIndex > self.readerIndex
    }
    
    public var readerIndex: Int {
        get {
            return Int(self.handle.reader_index)
        }
        set (value) {
            self.handle.reader_index = UInt32(value)
        }
    }
    
    public var readableBytes: Int {
        return self.writerIndex - self.readerIndex
    }
    
    public func markReaderIndex() -> Self {
        return self
    }
    
    public func resetReaderIndex() -> Self {
        return self
    }
    
    public func discardReadBytes() -> Self {
        guard self.readerIndex != 0 else {
            return self
        }
        
        if self.readerIndex == self.writerIndex {
            self.readerIndex = 0
            self.writerIndex = 0
        } else {
            // TODO: Use memmove cuz superposed bytes!!
            _ = self.set(bytes: self, at: 0, length: self.writerIndex)
            self.writerIndex -= self.readerIndex
            self.readerIndex  = 0
        }
        
        return self
    }
    
    public func getInt8(at offset: Int) -> Int8 {
        var value  = Int8()
        let result = fs_byte_buffer_get_int8(&self.handle, UInt32(offset), &value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while getting Int8 from byte buffer at offset: \(offset). Reason: \(message)")
        }
        
        return value
    }
    
    public func getInt16(at offset: Int, endianness: Endianness = .bigEndian) -> Int16 {
        var value = Int16()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_get_int16_be(&self.handle, UInt32(offset), &value)
        } else {
            result = fs_byte_buffer_get_int16_le(&self.handle, UInt32(offset), &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while getting Int16 from byte buffer at offset: \(offset). Reason: \(message)")
        }
        
        return value
    }
    
    public func getInt32(at offset: Int, endianness: Endianness = .bigEndian) -> Int32 {
        var value = Int32()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_get_int32_be(&self.handle, UInt32(offset), &value)
        } else {
            result = fs_byte_buffer_get_int32_le(&self.handle, UInt32(offset), &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while getting Int32 from byte buffer at offset: \(offset). Reason: \(message)")
        }
        
        return value
    }
    
    public func getInt64(at offset: Int, endianness: Endianness = .bigEndian) -> Int64 {
        var value = Int64()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_get_int64_be(&self.handle, UInt32(offset), &value)
        } else {
            result = fs_byte_buffer_get_int64_le(&self.handle, UInt32(offset), &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while getting Int64 from byte buffer at offset: \(offset). Reason: \(message)")
        }
        
        return value
    }
    
    public func getBytes(at offset: Int, length: Int) -> [UInt8] {
        var value  = [UInt8](repeating: 0, count: length)
        let result = fs_byte_buffer_get_bytes(&self.handle, UInt32(offset), UInt32(length), &value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while getting [UInt64] from byte buffer at offset: \(offset). Reason: \(message)")
        }
        
        return value
    }
    
    public func readInt8() -> Int8 {
        var value  = Int8()
        let result = fs_byte_buffer_read_int8(&self.handle, &value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while reading Int8 from byte buffer. Reason: \(message)")
        }
        
        return value
    }
    
    public func readInt16(endianness: Endianness = .bigEndian) -> Int16 {
        var value = Int16()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_read_int16_be(&self.handle, &value)
        } else {
            result = fs_byte_buffer_read_int16_le(&self.handle, &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while reading Int16 from byte buffer. Reason: \(message)")
        }
        
        return value
    }
    
    public func readInt32(endianness: Endianness = .bigEndian) -> Int32 {
        var value = Int32()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_read_int32_be(&self.handle, &value)
        } else {
            result = fs_byte_buffer_read_int32_le(&self.handle, &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while reading Int32 from byte buffer. Reason: \(message)")
        }
        
        return value
    }
    
    public func readInt64(endianness: Endianness = .bigEndian) -> Int64 {
        var value = Int64()
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_read_int64_be(&self.handle, &value)
        } else {
            result = fs_byte_buffer_read_int64_le(&self.handle, &value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while reading Int64 from byte buffer. Reason: \(message)")
        }
        
        return value
    }
    
    public func readBytes(_ length: Int) -> [UInt8] {
        var value  = [UInt8](repeating: 0, count: length)
        let result = fs_byte_buffer_read_bytes(&self.handle, UInt32(length), &value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while reading slice from byte buffer. Reason: \(message)")
        }
        
        return value
    }
}

extension UnsafeByteBuffer: ByteBufferWritable {
    public var writable: Bool {
        return self.capacity > self.writerIndex
    }
    
    public var writerIndex: Int {
        get {
            return Int(self.handle.writer_index)
        }
        
        set (value) {
            self.handle.writer_index = UInt32(value)
        }
    }
    
    public var writableBytes: Int {
        return self.capacity - self.writerIndex
    }
    
    public func markWriterIndex() -> Self {
        return self
    }
    
    public func resetWriterIndex() -> Self {
        return self
    }
    
    public func set(int8 value: Int8, at offset: Int) -> Self {
        let result = fs_byte_buffer_set_int8(&self.handle, UInt32(offset), value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int8 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(int16 value: Int16, at offset: Int, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_set_int16_be(&self.handle, UInt32(offset), value)
        } else {
            result = fs_byte_buffer_set_int16_le(&self.handle, UInt32(offset), value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int16 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(int32 value: Int32, at offset: Int, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_set_int32_be(&self.handle, UInt32(offset), value)
        } else {
            result = fs_byte_buffer_set_int32_le(&self.handle, UInt32(offset), value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int32 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(int64 value: Int64, at offset: Int, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_set_int64_be(&self.handle, UInt32(offset), value)
        } else {
            result = fs_byte_buffer_set_int64_le(&self.handle, UInt32(offset), value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int64 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(bytes value: [UInt8], at offset: Int) -> Self {
        let result = fs_byte_buffer_set_bytes(&self.handle, UInt32(value.count), UInt32(offset), value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting [UInt8] to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(bytes value: ByteBuffer, at offset: Int, length: Int) -> Self {
        let result = fs_byte_buffer_set_bytes(&self.handle, UInt32(length), UInt32(offset), value.unsafe)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting ByteBuffer to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(int8 value: Int8) -> Self {
        let result = fs_byte_buffer_write_int8(&self.handle, value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing Int8 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(int16 value: Int16, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_write_int16_be(&self.handle, value)
        } else {
            result = fs_byte_buffer_write_int16_le(&self.handle, value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing Int16 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(int32 value: Int32, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_write_int32_be(&self.handle, value)
        } else {
            result = fs_byte_buffer_write_int32_le(&self.handle, value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing Int32 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(int64 value: Int64, endianness: Endianness = .bigEndian) -> Self {
        let result: Int32
        
        if endianness == .bigEndian {
            result = fs_byte_buffer_write_int64_be(&self.handle, value)
        } else {
            result = fs_byte_buffer_write_int64_le(&self.handle, value)
        }
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing Int64 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(bytes value: [UInt8]) -> Self {
        let result = fs_byte_buffer_write_bytes(&self.handle, UInt32(value.count), value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing [UInt8] to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func write(bytes value: ByteBuffer) -> Self {
        let result = fs_byte_buffer_write_bytes(&self.handle, UInt32(value.writerIndex), value.unsafe)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing [UInt8] to byte buffer. Reason: \(message)")
        }
        
        return self
    }
}

fileprivate let kDefaultCapacity: Int = 256
