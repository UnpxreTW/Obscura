//
//  Emulator
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Hypervisor

/// 一次 VM exit 的原因，從 Hypervisor.framework 的 C exit 結構解析成 Swift 列舉。
///
/// `hv_vcpu_run` 每次返回後，host 讀 exit 結構決定下一步。把它轉成
/// 帶關聯值的列舉，讓呼叫端用 `switch` 窮舉處理、不必直接碰 C 欄位。
public enum ExitReason {

	/// guest 觸發了一個會送往 host 的同步例外；關聯值是解碼後的 ESR_EL2。
	case exception(ExceptionSyndrome)

	/// 上一次 run 被 `hv_vcpus_exit` 從別的 thread 取消。
	case canceled

	/// ARM Generic VTimer 自上次 run 後變為 pending。
	case vtimerActivated

	/// Hypervisor.framework 無法判定原因；正常運作下不應出現。
	case unknown

	public init(_ exit: hv_vcpu_exit_t) {
		self = switch exit.reason {
		case HV_EXIT_REASON_EXCEPTION: .exception(ExceptionSyndrome(exit.exception.syndrome))
		case HV_EXIT_REASON_CANCELED: .canceled
		case HV_EXIT_REASON_VTIMER_ACTIVATED: .vtimerActivated
		default: .unknown
		}
	}

}
