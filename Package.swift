// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "Obscura",
	platforms: [
		.macOS(.v13)
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
		.package(url: "https://github.com/UnpxreTW/SwiftStyleKit.git", from: "1.1.2")
	],
	targets: [
		// Obscura：DocC 文件 target。
		.target(name: "Obscura"),
		// Emulator：Hypervisor.framework 的純 Swift 包裝層。
		.target(
			name: "Emulator",
			plugins: [.plugin(name: "SwiftStyleLint", package: "SwiftStyleKit")]
		),
		// EmulatorSmoke：建 VM、跑 vCPU 的執行檔。獨立 executable 而非 XCTest，
		// 因為 hv_vcpu_run 需 codesign 帶 com.apple.security.hypervisor entitlement。
		.executableTarget(
			name: "EmulatorSmoke",
			dependencies: ["Emulator"],
			plugins: [.plugin(name: "SwiftStyleLint", package: "SwiftStyleKit")]
		),
		// EmulatorTests：不依賴 HVF 的純邏輯測試。
		.testTarget(
			name: "EmulatorTests",
			dependencies: ["Emulator"],
			plugins: [.plugin(name: "SwiftStyleLint", package: "SwiftStyleKit")]
		)
	]
)
