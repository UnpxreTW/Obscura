//
//  Emulator
//
//  Copyright © 2026 Unpxre (GitHub: UnpxreTW)
//  Licensed under the GNU General Public License v3.0. See LICENSE for details.
//
//  SPDX-License-Identifier: GPL-3.0-only

import Hypervisor

/// Hypervisor.framework 呼叫失敗時拋出，包住原始 `hv_return_t` 結果碼。
struct HypervisorError: Error {

	let status: hv_return_t
}
