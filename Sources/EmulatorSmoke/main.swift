//
//  EmulatorSmoke
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Emulator
import Hypervisor

// EmulatorSmoke：空 vCPU 冒煙驗證。
// guest 記憶體只放一條 BRK 指令，讓 vCPU 從那裡開跑；BRK 觸發的同步例外
// 以 VM exit 回到 host，解碼出 Exception Class 0x3C 就代表
// 「建 VM → 映射記憶體 → 跑 vCPU → 解 exit」整條路是通的。

/// BRK 指令所在的 guest 實體位址。
let loadAddress: UInt64 = 0x4000_0000

/// 映射一頁就夠；Apple Silicon 的頁大小是 16 KiB。
let pageSize = 16_384

/// 配一塊 page-aligned 的 host 記憶體當 guest 的實體記憶體，
/// 開頭寫進 AArch64 的 `BRK #0`（編碼 0xD4200000）。
var hostMemory: UnsafeMutableRawPointer?
guard posix_memalign(&hostMemory, pageSize, pageSize) == 0, let hostMemory else {
	fatalError("host 記憶體配置失敗")
}

hostMemory.storeBytes(of: 0xD420_0000 as UInt32, as: UInt32.self)

do {
	let machine = try VirtualMachine()
	try machine.mapMemory(
		hostMemory,
		at: loadAddress,
		size: pageSize,
		flags: hv_memory_flags_t(HV_MEMORY_READ | HV_MEMORY_EXEC)
	)

	// vCPU 綁建立它的 thread；一次性冒煙在主 thread 完成整個生命週期即可。
	// 內層 scope 讓 vCPU 先於 VM 釋放。
	do {
		let cpu = try VirtualCPU()

		// PC 指向 BRK；CPSR 0x3C4 = EL1、用 SP_EL0、DAIF 例外遮罩全開。
		try cpu.setRegister(HV_REG_PC, to: loadAddress)
		try cpu.setRegister(HV_REG_CPSR, to: 0x3C4)

		// 空 vCPU 的 VBAR_EL1 是 0：不開 trap 的話 BRK 會進 guest 自己的
		// 例外向量、在 0x0 取指令又摔 stage-2 fault，永遠到不了 host。
		try cpu.setTrapsDebugExceptions(true)

		try cpu.run()

		switch cpu.lastExit {
		case let .exception(syndrome) where syndrome.isBreakpoint:
			print("BRK 驗證通過：EC=0x\(String(syndrome.exceptionClass, radix: 16))")
		case let .exception(syndrome):
			let fault = cpu.exit.pointee.exception
			print("非預期例外：ESR_EL2=0x\(String(syndrome.rawValue, radix: 16))")
			print("FAR=0x\(String(fault.virtual_address, radix: 16))、IPA=0x\(String(fault.physical_address, radix: 16))")
			exit(EXIT_FAILURE)
		default:
			print("非預期 exit 原因：\(cpu.lastExit)")
			exit(EXIT_FAILURE)
		}
	}
} catch let error as HypervisorError {
	print("Hypervisor.framework 呼叫失敗：hv_return_t=0x\(String(UInt32(bitPattern: error.status), radix: 16))")
	exit(EXIT_FAILURE)
} catch {
	print("非預期錯誤：\(error)")
	exit(EXIT_FAILURE)
}
