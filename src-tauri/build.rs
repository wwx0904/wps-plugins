fn main() {
    // 检查是否在 CI 环境中
    if std::env::var("CI").is_ok() && cfg!(target_os = "windows") {
        // 在 Windows CI 环境中，跳过图标处理
        std::env::set_var("TAURI_SKIP_ICON_CHECK", "1");
    }
    
    tauri_build::build()
}