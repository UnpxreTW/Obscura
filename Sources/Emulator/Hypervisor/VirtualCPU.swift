//
//  Emulator
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Hypervisor

/// 一條 Hypervisor.framework 虛擬 CPU。
///
/// Hypervisor.framework 把 vCPU 綁在建立它的 thread 上：create、run、
/// 暫存器讀寫、destroy 都必須由同一條 thread 呼叫。這個型別不自己管 thread，
/// 由呼叫端負責在同一條 thread 上完成整個生命週期。
public final class VirtualCPU {

	/// 最近一次 `run()` 返回的 exit 原因，解析成 Swift 列舉。
	public var lastExit: ExitReason { ExitReason(exit.pointee) }

	/// VM exit 的原因結構。由 Hypervisor.framework 在 create 時配置、
	/// 每次 `run()` 返回後更新，記憶體由 framework 持有、與 vCPU 同生命週期；
	/// init 成功後保證非 nil。
	public private(set) var exit: UnsafeMutablePointer<hv_vcpu_exit_t>!

	/// 讀出一個 guest 暫存器目前的值。
	public func register(_ register: hv_reg_t) throws -> UInt64 {
		var value: UInt64 = 0
		let status = hv_vcpu_get_reg(handle, register, &value)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
		return value
	}

	/// 讓 guest 從目前的 PC 開始執行，直到下一次 VM exit 才返回；
	/// 返回後 exit 原因可從 `lastExit` 讀取。
	public func run() throws {
		let status = hv_vcpu_run(handle)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	/// 寫入一個 guest 暫存器。
	public func setRegister(_ register: hv_reg_t, to value: UInt64) throws {
		let status = hv_vcpu_set_reg(handle, register, value)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	/// 設定 guest 的 debug 例外（BRK、單步、watchpoint…）要不要交給 host 處理。
	///
	/// 預設是 guest 自己收：BRK 會進 guest 的 EL1 例外向量（VBAR_EL1），
	/// 不會產生 VM exit。開了這個開關（對應 MDCR_EL2.TDE）debug 例外
	/// 才會路由到 EL2、以 `.exception` exit 回到 host。
	public func setTrapsDebugExceptions(_ traps: Bool) throws {
		let status = hv_vcpu_set_trap_debug_exceptions(handle, traps)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	public init() throws {
		let status = hv_vcpu_create(&handle, &exit, nil)
		guard status == HV_SUCCESS else { throw HypervisorError(status: status) }
	}

	deinit {
		hv_vcpu_destroy(handle)
	}

	private var handle: hv_vcpu_t = 0
}
