
* [github中的md文档自动创建TOC](#github中的md文档自动创建toc)

	* [使用方法](#使用方法)

		* [命令行模式](#命令行模式)

		* [TODO](#todo)

	* [问题](#问题)

	* [参考文献：](#参考文献：)
# github中的md文档自动创建TOC

github中的md格式并不支持`[TOC]`标签，[markdown为什么不支持目录和脚注？ - 知乎](!https://www.zhihu.com/question/21907056)

github上有一个[项目](!https://github.com/ekalinin/github-markdown-toc)是自动生成toc的，但是很久不维护了

本项目使用python写了一个简单的脚本，用于自动生成TOC。

实现的效果如本项目中的 readme.withtoc.md 所示

## 使用方法

### 命令行模式
```bash
python autoToc.py C:\Users\zhang\Documents\GitHub\YunPingTai\部署K8S.md
```

### TODO
将来会开发桌面应用程序，更加方便使用

## 问题

`Node 端配置——Nginx`   这种的没法处理

## 参考文献：
[ekalinin/github-markdown-toc: Easy TOC creation for GitHub](!https://github.com/ekalinin/github-markdown-toc)

[如何实现Github markdown 目录/页内跳转？ - 知乎](!https://www.zhihu.com/question/58630229/answer/351692390)

[markdown为什么不支持目录和脚注？ - 知乎](!https://www.zhihu.com/question/21907056)


