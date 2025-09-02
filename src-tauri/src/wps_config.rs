use anyhow::{Result, anyhow};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::fs;
use quick_xml::{Reader, Writer, events::{Event, BytesStart, BytesEnd}};
use std::io::Cursor;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PluginConfig {
    pub name: String,
    pub url: String,
    #[serde(rename = "type")]
    pub config_type: String,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct JSPluginOnline {
    pub name: String,
    pub config_type: String,
    pub url: String,
    pub debug: String,
    pub enable: String,
    pub install: String,
}

/// 获取WPS配置文件路径
pub fn get_wps_config_path() -> String {
    let path = if cfg!(target_os = "windows") {
        // Windows: %APPDATA%\kingsoft\wps\jsaddons\publish.xml
        let appdata = std::env::var("APPDATA").unwrap_or_else(|_| String::new());
        PathBuf::from(&appdata)
            .join("kingsoft")
            .join("wps")
            .join("jsaddons")
            .join("publish.xml")
    } else if cfg!(target_os = "macos") {
        // macOS: ~/Library/Containers/com.kingsoft.wpsoffice.mac/Data/.kingsoft/wps/jsaddons/publish.xml
        let home = std::env::var("HOME").unwrap_or_else(|_| String::new());
        PathBuf::from(&home)
            .join("Library")
            .join("Containers")
            .join("com.kingsoft.wpsoffice.mac")
            .join("Data")
            .join(".kingsoft")
            .join("wps")
            .join("jsaddons")
            .join("publish.xml")
    } else {
        // Linux: ~/.local/share/Kingsoft/wps/jsaddons/publish.xml
        let home = std::env::var("HOME").unwrap_or_else(|_| String::new());
        PathBuf::from(&home)
            .join(".local")
            .join("share")
            .join("Kingsoft")
            .join("wps")
            .join("jsaddons")
            .join("publish.xml")
    };
    
    path.to_string_lossy().to_string()
}

/// 读取当前配置
pub fn read_current_config() -> Result<Option<PluginConfig>> {
    let config_path = get_wps_config_path();
    let path = PathBuf::from(&config_path);
    
    if !path.exists() {
        return Ok(None);
    }
    
    let content = fs::read_to_string(&path)?;
    
    // 如果文件为空或只有空标签，返回None
    if content.trim().is_empty() || content.trim() == "<jsplugins></jsplugins>" {
        return Ok(None);
    }
    
    // 解析XML找到第一个插件配置
    let mut reader = Reader::from_str(&content);
    reader.trim_text(true);
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf)? {
            Event::Start(ref e) if e.name().as_ref() == b"jspluginonline" => {
                let mut plugin = JSPluginOnline {
                    name: String::new(),
                    config_type: String::new(),
                    url: String::new(),
                    debug: String::new(),
                    enable: String::new(),
                    install: String::new(),
                };
                
                // 解析属性
                for attr in e.attributes() {
                    let attr = attr?;
                    let key = String::from_utf8(attr.key.as_ref().to_vec())?;
                    let value = String::from_utf8(attr.value.as_ref().to_vec())?;
                    
                    match key.as_str() {
                        "name" => plugin.name = value,
                        "type" => plugin.config_type = value,
                        "url" => plugin.url = value,
                        "debug" => plugin.debug = value,
                        "enable" => plugin.enable = value,
                        "install" => plugin.install = value,
                        _ => {}
                    }
                }
                
                // 转换为PluginConfig并返回第一个找到的
                if !plugin.name.is_empty() {
                    let description = get_description_by_name(&plugin.name);
                    return Ok(Some(PluginConfig {
                        name: plugin.name,
                        url: plugin.url,
                        config_type: plugin.config_type,
                        description,
                    }));
                }
            }
            Event::Eof => break,
            _ => {}
        }
        buf.clear();
    }
    
    Ok(None)
}

/// 根据配置名称获取描述
fn get_description_by_name(name: &str) -> String {
    match name {
        "AI_zdxy" => "zdxy环境".to_string(),
        "AI_localhost" => "本地开发".to_string(),
        _ => name.to_string(),
    }
}

/// 应用WPS配置
pub async fn apply_wps_config(config: &PluginConfig) -> Result<()> {
    let config_path = get_wps_config_path();
    let path = PathBuf::from(&config_path);
    
    // 确保目录存在
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    
    // 读取现有配置
    let mut existing_plugins = Vec::new();
    if path.exists() {
        let content = fs::read_to_string(&path)?;
        if !content.trim().is_empty() && content.trim() != "<jsplugins></jsplugins>" {
            existing_plugins = parse_existing_plugins(&content)?;
        }
    }
    
    // 构建新的插件配置
    let new_plugin = JSPluginOnline {
        name: config.name.clone(),
        config_type: config.config_type.clone(),
        url: config.url.clone(),
        debug: String::new(),
        enable: "enable".to_string(),
        install: config.url.clone(),
    };
    
    // 查找是否已存在相同名称的插件，如果存在则替换
    let mut found = false;
    for plugin in &mut existing_plugins {
        if plugin.name == config.name {
            *plugin = new_plugin.clone();
            found = true;
            break;
        }
    }
    
    // 如果没找到，则添加新配置
    if !found {
        existing_plugins.push(new_plugin);
    }
    
    // 生成XML内容
    let xml_content = generate_xml_content(&existing_plugins)?;
    
    // 写入文件
    fs::write(&path, xml_content)?;
    
    Ok(())
}

/// 解析现有的插件配置
fn parse_existing_plugins(content: &str) -> Result<Vec<JSPluginOnline>> {
    let mut plugins = Vec::new();
    let mut reader = Reader::from_str(content);
    reader.trim_text(true);
    let mut buf = Vec::new();
    
    loop {
        match reader.read_event_into(&mut buf)? {
            Event::Start(ref e) if e.name().as_ref() == b"jspluginonline" => {
                let mut plugin = JSPluginOnline {
                    name: String::new(),
                    config_type: String::new(),
                    url: String::new(),
                    debug: String::new(),
                    enable: String::new(),
                    install: String::new(),
                };
                
                for attr in e.attributes() {
                    let attr = attr?;
                    let key = String::from_utf8(attr.key.as_ref().to_vec())?;
                    let value = String::from_utf8(attr.value.as_ref().to_vec())?;
                    
                    match key.as_str() {
                        "name" => plugin.name = value,
                        "type" => plugin.config_type = value,
                        "url" => plugin.url = value,
                        "debug" => plugin.debug = value,
                        "enable" => plugin.enable = value,
                        "install" => plugin.install = value,
                        _ => {}
                    }
                }
                
                plugins.push(plugin);
            }
            Event::Eof => break,
            _ => {}
        }
        buf.clear();
    }
    
    Ok(plugins)
}

/// 生成XML内容
fn generate_xml_content(plugins: &[JSPluginOnline]) -> Result<String> {
    let mut writer = Writer::new(Cursor::new(Vec::new()));
    
    // XML头部
    let mut xml_content = String::from("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    
    // 根元素开始
    writer.write_event(Event::Start(BytesStart::new("jsplugins")))?;
    
    // 写入每个插件配置
    for plugin in plugins {
        let mut elem = BytesStart::new("jspluginonline");
        elem.push_attribute(("name", plugin.name.as_str()));
        elem.push_attribute(("type", plugin.config_type.as_str()));
        elem.push_attribute(("url", plugin.url.as_str()));
        elem.push_attribute(("debug", plugin.debug.as_str()));
        elem.push_attribute(("enable", plugin.enable.as_str()));
        elem.push_attribute(("install", plugin.install.as_str()));
        
        writer.write_event(Event::Empty(elem))?;
    }
    
    // 根元素结束
    writer.write_event(Event::End(BytesEnd::new("jsplugins")))?;
    
    let result = writer.into_inner().into_inner();
    let xml_body = String::from_utf8(result)?;
    
    xml_content.push_str(&xml_body);
    
    Ok(xml_content)
}

/// 清空WPS配置
pub async fn clear_wps_config() -> Result<()> {
    let config_path = get_wps_config_path();
    let path = PathBuf::from(&config_path);
    
    if path.exists() {
        fs::remove_file(&path)?;
    }
    
    Ok(())
}

/// 启动WPS应用程序
pub async fn launch_wps(addon_type: &str) -> Result<()> {
    if cfg!(target_os = "windows") {
        launch_wps_windows(addon_type).await
    } else if cfg!(target_os = "macos") {
        launch_wps_macos().await
    } else {
        launch_wps_linux(addon_type).await
    }
}

/// Windows平台启动WPS
async fn launch_wps_windows(addon_type: &str) -> Result<()> {
    use std::process::Command;
    
    // 根据插件类型确定注册表键
    let reg_type = match addon_type {
        "wpp" => "KWPP.Presentation.12",
        "et" => "KET.Sheet.12", 
        _ => "KWPS.Document.12", // 默认为wps
    };
    
    // 查询注册表获取WPS路径
    let output = Command::new("reg")
        .args(&[
            "query",
            &format!("HKEY_CLASSES_ROOT\\{}\\shell\\new\\command", reg_type),
            "/ve"
        ])
        .output()?;
    
    if !output.status.success() {
        return Err(anyhow!("WPS未安装，请安装WPS 2019 最新版本"));
    }
    
    let output_str = String::from_utf8_lossy(&output.stdout);
    
    // 解析注册表输出
    let mut cmd_line = String::new();
    for line in output_str.lines() {
        if line.contains("REG_SZ") {
            if let Some(pos) = line.find("REG_SZ") {
                cmd_line = line[pos + 6..].trim().to_string();
                break;
            }
        }
    }
    
    if cmd_line.is_empty() {
        return Err(anyhow!("WPS未安装，请安装WPS 2019 最新版本"));
    }
    
    // 处理命令行，移除 "%1" 参数
    cmd_line = cmd_line.replace("\"%1\"", "");
    cmd_line = cmd_line.trim().to_string();
    
    // 解析可执行文件路径
    let exe_path = if cmd_line.starts_with('"') {
        // 路径被引号包围
        if let Some(end_quote) = cmd_line[1..].find('"') {
            cmd_line[1..end_quote + 1].to_string()
        } else {
            return Err(anyhow!("解析WPS路径失败"));
        }
    } else {
        // 路径没有引号，取第一个空格前的部分
        cmd_line.split_whitespace().next().unwrap_or("").to_string()
    };
    
    if exe_path.is_empty() {
        return Err(anyhow!("解析WPS路径失败"));
    }
    
    // 启动WPS
    Command::new(&exe_path)
        .spawn()?;
    
    Ok(())
}

/// macOS平台启动WPS
async fn launch_wps_macos() -> Result<()> {
    use std::process::Command;
    
    let app_path = "/Applications/wpsoffice.app";
    
    // 检查WPS是否安装
    if !PathBuf::from(app_path).exists() {
        return Err(anyhow!("WPS未安装，请安装WPS Office"));
    }
    
    // 使用open命令启动应用
    Command::new("open")
        .args(&["-a", app_path])
        .spawn()?;
    
    Ok(())
}

/// Linux平台启动WPS  
async fn launch_wps_linux(addon_type: &str) -> Result<()> {
    use std::process::Command;
    
    // 常见的WPS安装路径
    let possible_paths = vec![
        format!("/opt/kingsoft/wps-office/office6/{}", addon_type),
        format!("/opt/apps/cn.wps.wps-office-pro/files/kingsoft/wps-office/office6/{}", addon_type),
    ];
    
    let mut exe_path = String::new();
    for path in &possible_paths {
        if PathBuf::from(path).exists() {
            exe_path = path.clone();
            break;
        }
    }
    
    if exe_path.is_empty() {
        return Err(anyhow!("WPS未安装或路径不正确，请安装WPS Office"));
    }
    
    // 启动WPS
    Command::new(&exe_path)
        .spawn()?;
    
    Ok(())
}

/// 关闭WPS应用程序
pub async fn terminate_wps() -> Result<()> {
    if cfg!(target_os = "windows") {
        terminate_wps_windows().await
    } else if cfg!(target_os = "macos") {
        terminate_wps_macos().await
    } else {
        terminate_wps_linux().await
    }
}

/// 清理WPS缓存
pub async fn clear_wps_cache_internal() -> Result<()> {
    if cfg!(target_os = "windows") {
        clear_wps_cache_windows().await
    } else if cfg!(target_os = "macos") {
        clear_wps_cache_macos().await
    } else {
        clear_wps_cache_linux().await
    }
}

/// Windows平台清理WPS缓存
async fn clear_wps_cache_windows() -> Result<()> {
    use std::fs;
    use std::path::PathBuf;
    
    // 先关闭所有WPS进程
    terminate_wps_windows().await?;
    
    // 清理WPS缓存目录
    let app_data = std::env::var("APPDATA").unwrap_or_else(|_| String::new());
    let cache_path = PathBuf::from(&app_data)
        .join("Kingsoft")
        .join("wps")
        .join("addons")
        .join("data")
        .join("win-i386");
    
    if cache_path.exists() {
        fs::remove_dir_all(&cache_path)?;
    }
    
    Ok(())
}

/// macOS平台清理WPS缓存
async fn clear_wps_cache_macos() -> Result<()> {
    use std::fs;
    use std::path::PathBuf;
    
    // 先关闭所有WPS进程
    terminate_wps_macos().await?;
    
    // 清理WPS缓存目录
    let home = std::env::var("HOME").unwrap_or_else(|_| String::new());
    let cache_paths = vec![
        PathBuf::from(&home).join("Library").join("Containers").join("com.kingsoft.wpsoffice.mac").join("Data").join(".kingsoft").join("wps").join("addons").join("data"),
        PathBuf::from(&home).join("Library").join("Application Support").join("Kingsoft").join("wps").join("addons").join("data"),
    ];
    
    for path in cache_paths {
        if path.exists() {
            let _ = fs::remove_dir_all(&path);
        }
    }
    
    Ok(())
}

/// Linux平台清理WPS缓存
async fn clear_wps_cache_linux() -> Result<()> {
    use std::fs;
    use std::path::PathBuf;
    
    // 先关闭所有WPS进程
    terminate_wps_linux().await?;
    
    // 清理WPS缓存目录
    let home = std::env::var("HOME").unwrap_or_else(|_| String::new());
    let cache_path = PathBuf::from(&home)
        .join(".local")
        .join("share")
        .join("Kingsoft")
        .join("wps")
        .join("addons")
        .join("data");
    
    if cache_path.exists() {
        fs::remove_dir_all(&cache_path)?;
    }
    
    Ok(())
}

/// Windows平台关闭WPS
async fn terminate_wps_windows() -> Result<()> {
    use std::process::Command;
    
    // 使用taskkill命令关闭WPS相关进程
    let _ = Command::new("taskkill")
        .args(&["/F", "/IM", "wpsoffice.exe"])
        .output();
    
    let _ = Command::new("taskkill")
        .args(&["/F", "/IM", "wpscloudsvr.exe"])
        .output();
    
    Ok(())
}

/// macOS平台关闭WPS
async fn terminate_wps_macos() -> Result<()> {
    use std::process::Command;
    
    // 使用killall命令关闭WPS相关进程
    let _ = Command::new("killall")
        .args(&["wpsoffice"])
        .output();
    
    let _ = Command::new("killall")
        .args(&["wpscloudsvr"])
        .output();
    
    let _ = Command::new("killall")
        .args(&["promecefpluginhost"])
        .output();
    
    Ok(())
}

/// Linux平台关闭WPS
async fn terminate_wps_linux() -> Result<()> {
    use std::process::Command;
    
    // 使用killall命令关闭WPS相关进程
    let _ = Command::new("killall")
        .args(&["wps", "wpscloudsvr"])
        .output();
    
    Ok(())
}

/// 配置hosts文件
pub async fn configure_hosts_internal(host_config: &str) -> Result<()> {
    if cfg!(target_os = "windows") {
        configure_hosts_windows(host_config).await
    } else if cfg!(target_os = "macos") {
        configure_hosts_macos(host_config).await
    } else {
        configure_hosts_linux(host_config).await
    }
}

/// Windows平台配置hosts文件
async fn configure_hosts_windows(host_config: &str) -> Result<()> {
    use std::fs::{OpenOptions, read_to_string};
    use std::io::Write;
    use std::path::PathBuf;
    
    let hosts_file = PathBuf::from(std::env::var("SystemRoot").unwrap_or_else(|_| "C:\\Windows".to_string()))
        .join("System32")
        .join("drivers")
        .join("etc")
        .join("hosts");
    
    // 读取现有hosts文件内容
    let mut existing_content = String::new();
    if hosts_file.exists() {
        existing_content = read_to_string(&hosts_file)?;
    }
    
    // 检查是否已存在该配置
    if existing_content.contains(host_config.trim()) {
        return Err(anyhow!("already_exists")); // 已存在，返回特殊状态
    }
    
    // 备份原文件（可选）
    let backup_file = hosts_file.with_extension("hosts.backup");
    if hosts_file.exists() {
        std::fs::copy(&hosts_file, &backup_file)?;
    }
    
    // 添加新的hosts配置
    let new_content = format!("{}\n{}", existing_content, host_config.trim());
    
    // 写入文件
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .open(&hosts_file)?;
    
    file.write_all(new_content.as_bytes())?;
    
    Ok(())
}

/// macOS平台配置hosts文件
async fn configure_hosts_macos(host_config: &str) -> Result<()> {
    use std::path::PathBuf;
    use std::process::Command;
    
    let hosts_file = PathBuf::from("/etc/hosts");
    
    // 检查是否已存在该配置
    let mut existing_content = String::new();
    if hosts_file.exists() {
        let output = Command::new("cat")
            .arg(&hosts_file)
            .output();
        
        if let Ok(output) = output {
            existing_content = String::from_utf8_lossy(&output.stdout).to_string();
        }
    }
    
    // 检查是否已存在该配置
    if existing_content.contains(host_config.trim()) {
        return Err(anyhow!("already_exists")); // 已存在，返回特殊状态
    }
    
    // 方法1: 尝试使用osascript获取管理员权限
    let script = format!(
        "do shell script \"echo '{}' >> {}\" with administrator privileges",
        host_config.trim(),
        hosts_file.display()
    );
    
    let output = Command::new("osascript")
        .arg("-e")
        .arg(&script)
        .output();
    
    match output {
        Ok(output) if output.status.success() => Ok(()),
        _ => {
            // 方法2: 如果osascript失败，提供手动配置指导
            Err(anyhow!(
                "无法自动配置hosts文件。请手动执行以下命令：\n\
                sudo echo '{}' >> {}\n\
                或者使用文本编辑器以管理员身份打开 /etc/hosts 文件并添加配置", 
                host_config.trim(),
                hosts_file.display()
            ))
        }
    }
}

/// Linux平台配置hosts文件
async fn configure_hosts_linux(host_config: &str) -> Result<()> {
    use std::path::PathBuf;
    use std::process::Command;
    
    let hosts_file = PathBuf::from("/etc/hosts");
    
    // 在Linux上需要管理员权限，尝试使用sudo
    let mut existing_content = String::new();
    if hosts_file.exists() {
        let output = Command::new("cat")
            .arg(&hosts_file)
            .output();
        
        if let Ok(output) = output {
            existing_content = String::from_utf8_lossy(&output.stdout).to_string();
        }
    }
    
    // 检查是否已存在该配置
    if existing_content.contains(host_config.trim()) {
        return Err(anyhow!("already_exists")); // 已存在，返回特殊状态
    }
    
    // 使用echo和sudo追加配置
    let output = Command::new("sh")
        .arg("-c")
        .arg(&format!("echo '{}' | sudo tee -a {}", host_config.trim(), hosts_file.display()))
        .output();
    
    match output {
        Ok(output) if output.status.success() => Ok(()),
        _ => Err(anyhow!("在Linux上配置hosts文件需要管理员权限"))
    }
}