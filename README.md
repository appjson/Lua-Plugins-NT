# Lua Plugins for OPQBot-NT

只是把原有的 lua 插件重新适配 NT 新版罢了。

lua 开发插件虽然功能不复杂，但是可做参考。有时候后端服务挂了等情况，有 lua 插件顶一下还是不错的。

## 初始配置

需要在根目录下创建`conf.json`作为配置文件，示例：

```json
{
  "CurrentQQ": "这里填BOT的qq号（不要加引号，直接填数字）",
  "AdminQQ": "这里填你本人的qq号（不要加引号，直接填数字）",
  "Port": 9898,
  "Host": "这里填你的服务器地址和端口号，不要加http等协议头，例如2.2.2.2:9898"
}
```

需要创建两个文件夹用于保存 Data / Cache

```sh
mkdir Plugins/Cache
mkdir Plugins/Data
```