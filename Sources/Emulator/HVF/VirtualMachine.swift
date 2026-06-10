//
//  Emulator
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Hypervisor

/// 一個 Hypervisor.framework 虛擬機。
final class VirtualMachine {

	/// 把一塊 host 記憶體映射進 guest 的實體位址空間。
	public func mapMemory(
		_ host: UnsafeMutableRawPointer,
		at guestPhysical: UInt64,
		size: Int,
		flags: hv_memory_flags_t
	) throws {
		let status = hv_vm_map(host, guestPhysical, size, flags)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	public init() throws {
		let status = hv_vm_create(nil)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	deinit {
		// HVF 的 VM 是 process 全域、沒有 handle，所以 destroy 不帶參數。
		hv_vm_destroy()
	}

}
