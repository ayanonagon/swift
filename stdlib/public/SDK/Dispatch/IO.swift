//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

public extension DispatchIO {

	public enum StreamType : UInt  {
		case stream = 0
		case random = 1
	}

	public struct CloseFlags : OptionSet, RawRepresentable {
		public let rawValue: UInt
		public init(rawValue: UInt) { self.rawValue = rawValue }

		public static let stop = CloseFlags(rawValue: 1)
	}

	public struct IntervalFlags : OptionSet, RawRepresentable {
		public let rawValue: UInt
		public init(rawValue: UInt) { self.rawValue = rawValue }
		public init(nilLiteral: ()) { self.rawValue = 0 }

		public static let strictInterval = IntervalFlags(rawValue: 1)
	}

	public class func read(fromFileDescriptor: Int32, maxLength: Int, runningHandlerOn queue: DispatchQueue, handler: (data: DispatchData, error: Int32) -> Void) {
		__dispatch_read(fromFileDescriptor, maxLength, queue) { (data: __DispatchData, error: Int32) in
			handler(data: DispatchData(data: data), error: error)
		}
	}

	public class func write(toFileDescriptor: Int32, data: DispatchData, runningHandlerOn queue: DispatchQueue, handler: (data: DispatchData?, error: Int32) -> Void) {
		__dispatch_write(toFileDescriptor, data as __DispatchData, queue) { (data: __DispatchData?, error: Int32) in
			handler(data: data.flatMap { DispatchData(data: $0) }, error: error)
		}
	}

	public convenience init(
		type: StreamType,
		fileDescriptor: Int32,
		queue: DispatchQueue,
		cleanupHandler: (error: Int32) -> Void)
	{
		self.init(__type: type.rawValue, fd: fileDescriptor, queue: queue, handler: cleanupHandler)
	}

	public convenience init(
		type: StreamType,
		path: UnsafePointer<Int8>,
		oflag: Int32,
		mode: mode_t,
		queue: DispatchQueue,
		cleanupHandler: (error: Int32) -> Void)
	{
		self.init(__type: type.rawValue, path: path, oflag: oflag, mode: mode, queue: queue, handler: cleanupHandler)
	}

	public convenience init(
		type: StreamType,
		io: DispatchIO,
		queue: DispatchQueue,
		cleanupHandler: (error: Int32) -> Void)
	{
		self.init(__type: type.rawValue, io: io, queue: queue, handler: cleanupHandler)
	}

	public func read(offset: off_t, length: Int, queue: DispatchQueue, ioHandler: (done: Bool, data: DispatchData?, error: Int32) -> Void) {
		__dispatch_io_read(self, offset, length, queue) { (done: Bool, data: __DispatchData?, error: Int32) in
			ioHandler(done: done, data: data.flatMap { DispatchData(data: $0) }, error: error)
		}
	}

	public func write(offset: off_t, data: DispatchData, queue: DispatchQueue, ioHandler: (done: Bool, data: DispatchData?, error: Int32) -> Void) {
		__dispatch_io_write(self, offset, data as __DispatchData, queue) { (done: Bool, data: __DispatchData?, error: Int32) in
			ioHandler(done: done, data: data.flatMap { DispatchData(data: $0) }, error: error)
		}
	}

	public func setInterval(interval: DispatchTimeInterval, flags: IntervalFlags = []) {
		__dispatch_io_set_interval(self, interval.rawValue, flags.rawValue)
	}

	public func close(flags: CloseFlags = []) {
		__dispatch_io_close(self, flags.rawValue)
	}
}

