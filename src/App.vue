<template>
    <div class="app-container">
        <div class="header">
            <h1 class="title">
                <el-icon class="logo-icon"><Setting /></el-icon>
                AI赢标助手 - WPS环境切换工具
            </h1>
            <p class="subtitle">选择要应用的WPS插件配置环境</p>
        </div>

        <div class="main-content">
            <el-card class="config-card" shadow="hover">
                <template #header>
                    <div class="card-header">
                        <span>插件配置选择</span>
                        <el-tag v-if="currentConfig" type="success" size="small">
                            当前: {{ currentConfig.description }}
                        </el-tag>
                    </div>
                </template>

                <div class="config-options fr_c fj_c">
                    <el-radio-group v-model="selectedConfig" size="large" @change="onConfigChange">
                        <el-space direction="vertical" size="large" style="width: 100%">
                            <el-radio
                                v-for="config in pluginConfigs"
                                :key="config.name"
                                :label="config.name"
                                class="config-option"
                            >
                                <div class="config-info">
                                    <div class="config-title">{{ config.description }}</div>
                                    <div v-if="config.url" class="config-url">{{ config.url }}</div>
                                </div>
                            </el-radio>
                        </el-space>
                    </el-radio-group>
                </div>

                <div class="action-buttons">
                    <el-button
                        type="primary"
                        size="large"
                        :loading="isApplying"
                        :disabled="!selectedConfig"
                        @click="applyConfig"
                    >
                        <el-icon><Check /></el-icon>
                        应用配置并启动WPS
                    </el-button>

                    <el-button type="danger" size="large" :loading="isClearing" @click="clearConfig">
                        <el-icon><Delete /></el-icon>
                        清空本地插件
                    </el-button>
                </div>
            </el-card>
        </div>

        <div class="footer">
            <el-text size="small" type="info"> 配置文件路径: {{ configPath }} </el-text>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { invoke } from "@tauri-apps/api/tauri";
import { ElMessage, ElMessageBox } from "element-plus";

// 响应式数据
const selectedConfig = ref("");
const currentConfig = ref(null);
const configPath = ref("");
const isApplying = ref(false);
const isClearing = ref(false);

// 插件配置列表（与Go版本保持一致）
const pluginConfigs = ref([
    // {
    //     name: "AI_bsh",
    //     url: "http://bsh.ai.qianlima.com/wuye/wordPlugin/wps/bsh",
    //     type: "wps",
    //     description: "宝石花",
    // },
    {
        name: "AI_bsh",
        url: "http://bsh.ai.qianlima.com/wuye/wordPlugin/wps/bsh/",
        type: "wps",
        description: "bsh环境",
        hostConfig: "47.104.218.212 bsh.ai.qianlima.com ", // host配置信息
    },
    // {
    //     name: "AI_localhost",
    //     url: "http://wuye-dev.qianlima.com/",
    //     type: "wps",
    //     description: "本地开发",
    // },
]);

// 组件挂载时初始化
onMounted(async () => {
    try {
        // 获取配置文件路径
        configPath.value = await invoke("get_config_path");

        // 获取当前配置
        const current = await invoke("get_current_config");
        if (current) {
            currentConfig.value = current;
        }
    } catch (error) {
        console.error("初始化失败:", error);
    }
});

// 配置选择变化
const onConfigChange = (value) => {
    console.log("选择配置:", value);
};

// 应用配置
const applyConfig = async () => {
    if (!selectedConfig.value) {
        ElMessage.warning("请先选择一个配置");
        return;
    }

    const config = pluginConfigs.value.find((c) => c.name === selectedConfig.value);
    if (!config) {
        ElMessage.error("配置不存在");
        return;
    }

    isApplying.value = true;

    try {
        // 步骤1: 清理WPS缓存
        // ElMessage.info("正在清理WPS缓存...");
        await invoke("clear_wps_cache");
        // ElMessage.success("WPS缓存清理完成");

        // 步骤2: 配置hosts文件（如果存在hostConfig字段）
        if (config.hostConfig) {
            // ElMessage.info("正在配置hosts文件...");
            try {
                await invoke("configure_hosts", { hostConfig: config.hostConfig });
                // ElMessage.success("hosts文件配置完成");
            } catch (error) {
                if (error.includes("already_exists")) {
                    ElMessage.info("hosts配置已存在，跳过配置");
                } else {
                    throw error; // 重新抛出其他错误
                }
            }
        }

        // 步骤3: 应用配置
        // ElMessage.info("正在应用WPS插件配置...");
        await invoke("apply_config", { config });
        ElMessage.success(` ${config.description} 配置应用成功！`);

        // 步骤4: 询问是否启动WPS
        const result = await ElMessageBox.confirm("配置已应用成功，是否立即启动WPS？", "启动确认", {
            confirmButtonText: "启动WPS",
            cancelButtonText: "稍后启动",
            type: "success",
        });

        if (result === "confirm") {
            await invoke("start_wps", { addonType: config.type });
            ElMessage.success("WPS启动成功！");
        }

        // 更新当前配置
        currentConfig.value = config;
    } catch (error) {
        console.error("应用配置失败:", error);
        ElMessage.error(`应用配置失败: ${error}`);
    } finally {
        isApplying.value = false;
    }
};

// 清空配置
const clearConfig = async () => {
    try {
        await ElMessageBox.confirm("确定要清空本地WPS插件配置吗？此操作不可恢复。", "清空确认", {
            confirmButtonText: "确认清空",
            cancelButtonText: "取消",
            type: "warning",
        });

        isClearing.value = true;

        await invoke("clear_config");

        ElMessage.success("本地插件配置已清空！");
        currentConfig.value = null;
        selectedConfig.value = "";

        await invoke("close_wps");

        // 询问是否关闭WPS
        // try {
        //     await ElMessageBox.confirm("插件配置已清空，是否同时关闭正在运行的WPS程序？", "关闭WPS", {
        //         confirmButtonText: "关闭WPS",
        //         cancelButtonText: "保持运行",
        //         type: "info",
        //     });

        //     // 用户确认关闭WPS
        //     await invoke("close_wps");
        //     ElMessage.success("WPS已关闭！");
        // } catch (wpsError) {
        //     // 用户选择不关闭WPS或关闭失败，不显示错误
        //     if (wpsError !== "cancel") {
        //         console.log("关闭WPS操作:", wpsError);
        //     }
        // }
    } catch (error) {
        if (error !== "cancel") {
            console.error("清空配置失败:", error);
            ElMessage.error(`❌ 清空配置失败: ${error}`);
        }
    } finally {
        isClearing.value = false;
    }
};
</script>

<style scoped>
.app-container {
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 20px;
    display: flex;
    flex-direction: column;
}

.header {
    text-align: center;
    color: white;
    margin-bottom: 30px;
}

.title {
    font-size: 28px;
    font-weight: 600;
    margin: 0 0 10px 0;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
}

.logo-icon {
    font-size: 32px;
}

.subtitle {
    font-size: 16px;
    margin: 0;
    opacity: 0.9;
}

.main-content {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: flex-start;
}

.config-card {
    width: 100%;
    max-width: 600px;
    border-radius: 12px;
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: 600;
    font-size: 16px;
}

.config-options {
    margin: 20px 0 30px 0;
}

.config-option {
    width: 100%;
    padding: 15px;
    border: 1px solid #e4e7ed;
    border-radius: 8px;
    margin-bottom: 10px !important;
    transition: all 0.3s ease;
}

.config-option:hover {
    border-color: #409eff;
    background-color: #f0f9ff;
}

.config-option.is-checked {
    border-color: #409eff;
    background-color: #ecf5ff;
}

.config-info {
    margin-left: 10px;
}

.config-title {
    font-weight: 600;
    font-size: 16px;
    color: #303133;
}

.config-url {
    font-size: 14px;
    color: #909399;
    margin-top: 4px;
}

.action-buttons {
    display: flex;
    gap: 15px;
    justify-content: center;
    flex-wrap: wrap;
}

.action-buttons .el-button {
    min-width: 160px;
}

.footer {
    text-align: center;
    margin-top: 20px;
    color: white;
    opacity: 0.8;
}

/* 深色模式适配 */
.dark .config-option {
    border-color: #4c4d4f;
}

.dark .config-option:hover {
    border-color: #409eff;
    background-color: rgba(64, 158, 255, 0.1);
}

.dark .config-title {
    color: #e5eaf3;
}

:deep(.el-radio.el-radio--large) {
    height: 70px;
}
</style>
