//
//  Emulator
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Hypervisor

/// ESR_EL2 的解碼視圖。
///
/// guest 觸發同步例外時，Hypervisor.framework 把完整的 ESR_EL2 放進
/// exit 結構的 `syndrome` 欄位。這個型別包住原始值，按需解出各欄位。
/// 目前只取最上層的 Exception Class，足夠認出空 vCPU 撞上的 BRK；
/// ISS 子欄位（MMIO data abort 等）留待 Stage 0b 需要時再長。
public struct ExceptionSyndrome {

	/// Exception Class（ESR_EL2 bits 31:26），決定例外的種類。
	public var exceptionClass: UInt8 { UInt8((rawValue >> 26) & 0x3F) }

	/// guest 是否執行了 AArch64 的 BRK 指令（Exception Class 0x3C）。
	public var isBreakpoint: Bool { exceptionClass == 0x3C }

	/// 原始 ESR_EL2 值，保留供未來解 ISS 子欄位。
	public let rawValue: UInt64

	public init(_ rawValue: UInt64) {
		self.rawValue = rawValue
	}

}
