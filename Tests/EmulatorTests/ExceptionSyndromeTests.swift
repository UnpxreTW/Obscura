//
//  EmulatorTests
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Emulator
import Hypervisor
import Testing

// ESR_EL2 解碼的純邏輯測試；不碰 Hypervisor.framework 的執行路徑，
// 所以可以在 XCTest/Swift Testing 裡跑、不需 entitlement。

@Test
private func `brk syndrome decodes exception class`() {
	// EC（bits 31:26）= 0x3C 即 AArch64 BRK；低位塞非零值，驗證欄位切割乾淨。
	let syndrome: ExceptionSyndrome = .init(0x3C << 26 | 0x1234)
	#expect(syndrome.exceptionClass == 0x3C)
	#expect(syndrome.isBreakpoint)
}

@Test
private func `data abort syndrome is not breakpoint`() {
	// EC 0x24 = 低 EL 的 Data Abort，不該被認成 BRK。
	let syndrome: ExceptionSyndrome = .init(0x24 << 26)
	#expect(syndrome.exceptionClass == 0x24)
	#expect(!syndrome.isBreakpoint)
}

@Test
private func `exit reason maps exception with syndrome`() {
	let exit = hv_vcpu_exit_t(
		reason: HV_EXIT_REASON_EXCEPTION,
		exception: hv_vcpu_exit_exception_t(syndrome: 0x3C << 26, virtual_address: 0, physical_address: 0)
	)
	guard case let .exception(syndrome) = ExitReason(exit) else {
		Issue.record("應解析為 .exception")
		return
	}
	#expect(syndrome.isBreakpoint)
}
