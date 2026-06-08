// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "Obscura",
	platforms: [
		.macOS(.v13)
	],
	targets: [
		// Emulator：Hypervisor.framework 的純 Swift 包裝層（VM / VCPU / Exit）。
		// 之後寫的 VM / VCPU / Exit 都放這裡，給上層（EmulatorSmoke、測試）import。
		.target(name: "Emulator"),

		// EmulatorSmoke：實際建 VM、跑 vCPU 的執行檔（Stage 0a 的驗證入口）。
		// 刻意做成獨立 executable 而非 XCTest——跑 hv_vcpu_run 要 codesign 帶
		// com.apple.security.hypervisor entitlement，XCTest bundle 很難簽進這權限。
		.executableTarget(name: "EmulatorSmoke", dependencies: ["Emulator"]),

		// EmulatorTests：純邏輯單元測試（不碰 HVF，例如 ESR_EL2 欄位解碼）。
		.testTarget(name: "EmulatorTests", dependencies: ["Emulator"])
	]
)
