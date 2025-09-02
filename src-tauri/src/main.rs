// 禁止控制台窗口出现
#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

mod wps_config;

use wps_config::*;

#[tauri::command]
async fn get_config_path() -> Result<String, String> {
    Ok(get_wps_config_path())
}

#[tauri::command]
async fn get_current_config() -> Result<Option<PluginConfig>, String> {
    match read_current_config() {
        Ok(config) => Ok(config),
        Err(e) => Err(format!("读取当前配置失败: {}", e))
    }
}

#[tauri::command]
async fn apply_config(config: PluginConfig) -> Result<(), String> {
    match apply_wps_config(&config).await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("应用配置失败: {}", e))
    }
}

#[tauri::command]
async fn clear_config() -> Result<(), String> {
    match clear_wps_config().await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("清空配置失败: {}", e))
    }
}

#[tauri::command]
async fn start_wps(addon_type: String) -> Result<(), String> {
    match launch_wps(&addon_type).await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("启动WPS失败: {}", e))
    }
}

#[tauri::command]
async fn close_wps() -> Result<(), String> {
    match terminate_wps().await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("关闭WPS失败: {}", e))
    }
}

#[tauri::command]
async fn clear_wps_cache() -> Result<(), String> {
    match clear_wps_cache_internal().await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("清理WPS缓存失败: {}", e))
    }
}

#[tauri::command]
async fn configure_hosts(host_config: String) -> Result<(), String> {
    match configure_hosts_internal(&host_config).await {
        Ok(_) => Ok(()),
        Err(e) => Err(format!("配置hosts文件失败: {}", e))
    }
}

fn main() {
    // 直接使用 generate_context!，但在 Windows 上跳过图标检查
    let context = tauri::generate_context!();
    
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_config_path,
            get_current_config,
            apply_config,
            clear_config,
            start_wps,
            close_wps,
            clear_wps_cache,
            configure_hosts
        ])
        .run(context)
        .expect("error while running tauri application");
}