import Foundation
import CFuse

public protocol ByteBuffer:
    ByteBufferReadable,
    ByteBufferWritable { }

public protocol ByteBufferReadable {
    var readerIndex: Int { get }
    
    func getInt8 (at offset: Int) -> Int8
    func getInt16(at offset: Int, endianness: ByteBufferEndianness) -> Int16
    func getInt32(at offset: Int, endianness: ByteBufferEndianness) -> Int32
    func getInt64(at offset: Int, endianness: ByteBufferEndianness) -> Int64
    func getBytes(at offset: Int, length: Int) -> [UInt8]
    
    func readInt8 () -> Int8
    func readInt16(endianness: ByteBufferEndianness) -> Int16
    func readInt32(endianness: ByteBufferEndianness) -> Int32
    func readInt64(endianness: ByteBufferEndianness) -> Int64
    func readBytes(_ length: Int) -> [UInt8]
}

public protocol ByteBufferWritable {
    var writerIndex: Int { get }
    
    mutating func set(int8  value: Int8,    at offset: Int) -> Self
    mutating func set(int16 value: Int16,   at offset: Int, endianness: ByteBufferEndianness) -> Self
    mutating func set(int32 value: Int32,   at offset: Int, endianness: ByteBufferEndianness) -> Self
    mutating func set(int64 value: Int64,   at offset: Int, endianness: ByteBufferEndianness) -> Self
    mutating func set(bytes value: [UInt8], at offset: Int) -> Self
    
    mutating func write(int8  value: Int8) -> Self
    mutating func write(int16 value: Int16, endianness: ByteBufferEndianness) -> Self
    mutating func write(int32 value: Int32, endianness: ByteBufferEndianness) -> Self
    mutating func write(int64 value: Int64, endianness: ByteBufferEndianness) -> Self
    mutating func write(bytes value: [UInt8]) -> Self
}

public class UnsafeByteBuffer: ByteBuffer {
    private var handle: fs_byte_buffer_t
    
    public init(capacity: Int) {
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
}

extension UnsafeByteBuffer: ByteBufferReadable {
    public var readerIndex: Int {
        return Int(self.handle.reader_index)
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
    
    public func getInt16(at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Int16 {
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
    
    public func getInt32(at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Int32 {
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
    
    public func getInt64(at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Int64 {
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
    
    public func readInt16(endianness: ByteBufferEndianness = .bigEndian) -> Int16 {
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
    
    public func readInt32(endianness: ByteBufferEndianness = .bigEndian) -> Int32 {
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
    
    public func readInt64(endianness: ByteBufferEndianness = .bigEndian) -> Int64 {
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
    public var writerIndex: Int {
        return Int(self.handle.writer_index)
    }
    
    public func set(int8 value: Int8, at offset: Int) -> Self {
        let result = fs_byte_buffer_set_int8(&self.handle, UInt32(offset), value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int8 to byte buffer. Reason: \(message)")
        }
        
        return self
    }
    
    public func set(int16 value: Int16, at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
    
    public func set(int32 value: Int32, at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
    
    public func set(int64 value: Int64, at offset: Int, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
        let result = fs_byte_buffer_set_bytes(&self.handle, UInt32(offset), value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while setting Int64 to byte buffer. Reason: \(message)")
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
    
    public func write(int16 value: Int16, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
    
    public func write(int32 value: Int32, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
    
    public func write(int64 value: Int64, endianness: ByteBufferEndianness = .bigEndian) -> Self {
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
        let result = fs_byte_buffer_write_bytes(&self.handle, value)
        
        guard result == FS_OKAY else {
            let message = String(cString: fs_error_to_string(result))
            fatalError("Fatal error while writing [UInt8] to byte buffer. Reason: \(message)")
        }
        
        return self
    }
}
