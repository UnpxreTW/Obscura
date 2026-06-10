//
//  Emulator
//
//  Copyright © 2026 Unpxre
//  Licensed under the MIT License. See LICENSE for details.
//
//  SPDX-License-Identifier: MIT

import Hypervisor

/// Hypervisor.framework 呼叫失敗時拋出，包住原始 `hv_return_t` 結果碼。
struct HypervisorError: Error {

	let status: hv_return_t
}
