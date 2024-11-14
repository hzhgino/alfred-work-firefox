# Firefox Alfred Workflow

## 简介
这是一个 Alfred Workflow 工具集，用于快速搜索 Firefox 的书签和浏览历史记录。通过 Alfred 的搜索界面，可以方便地访问您的 Firefox 书签和历史记录。

## 功能特性
- 快速搜索 Firefox 书签
- 快速搜索 Firefox 历史记录
- 支持模糊匹配
- 支持标题和 URL 搜索
- 按使用频率和时间排序结果

## 系统要求
- macOS 系统
- Alfred 5.0 或更高版本（需要 Powerpack）
- Firefox 浏览器
- sqlite3 命令行工具

## 安装方法
1. 下载最新版本的 workflow 文件
2. 双击下载的文件，自动导入到 Alfred
3. 确保 Firefox 已经安装并创建了配置文件

## 使用说明
1. 书签搜索：
   - 触发关键词：`ff` [关键词]
   - 搜索 Firefox 书签
   - 回车打开选中的书签

2. 历史记录搜索：
   - 触发关键词：`hist` [关键词]
   - 搜索 Firefox 历史记录
   - 回车打开选中的历史记录

## 文件结构
- `alfred.sh`: 核心工具函数库
- `bookmarks.sh`: Firefox 书签搜索实现
- `history.sh`: Firefox 历史记录搜索实现
- `info.plist`: Workflow 配置文件

## 环境变量配置
可以通过设置环境变量来自定义行为：
- `ALFRED_MAX_RESULTS`: 搜索结果显示数量（默认：5）

## 系统要求
### 必需组件
- Firefox 浏览器
- sqlite3 命令行工具
- bash shell

### 目录结构要求
- Firefox 配置文件目录: `~/Library/Application Support/Firefox/Profiles/*.default*`
- 临时文件目录: `/tmp/`
- Alfred 工作流缓存目录

### 权限要求
- 读取 Firefox 配置文件的权限
- 写入临时文件的权限
- 访问 Alfred 工作流缓存目录的权限

## 故障排除
如果遇到问题，请检查：
1. Firefox 是否正确安装并创建了配置文件
2. 是否有权限访问 Firefox 的数据文件
3. sqlite3 命令是否可用
4. 临时目录是否可写

## 贡献指南
欢迎提交 Issue 和 Pull Request 来帮助改进这个项目。

## 许可证
MIT License

## 联系方式
如有问题或建议，请提交 Issue。