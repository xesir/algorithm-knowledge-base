# 生长树：图论（AKB 内置版）

本目录是「算法知识点知识库」内置的可玩构建产物。

- 线上地址：https://xesir.github.io/algorithm-knowledge-base/tree-grow/
- 源码目录：`../tree-grow-src/`
- 代码许可：GPL-3.0-or-later（见 `LICENSE`）
- 文档许可：CC BY-NC-SA 4.0（见 `LICENSE-DOCUMENTATION`）
- 第三方组件与本地 Supabase SDK 声明：见 `THIRD_PARTY_NOTICES.md`

## 重新构建

```powershell
cd tree-grow-src
npm install
$env:VITE_BASE_PATH='./'
npm run build
# 将 dist/ 覆盖到本目录
```

`VITE_BASE_PATH='./'` 保证构建产物在任何子路径下都能正确加载资源。
