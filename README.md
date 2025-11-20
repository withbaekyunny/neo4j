# 基于Neo4j 化妆品智能推荐系统

> 基于图数据库的个性化美妆产品推荐平台，实现成分、功效与肤质的精准匹配。

[![Project Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)](https://github.com/your-username/your-repo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![Neo4j](https://img.shields.io/badge/Neo4j-5.x-4C8E3E.svg)](https://neo4j.com/)
[![Frontend](https://img.shields.io/badge/Frontend-React%20%7C%20Vite-61DAFB.svg)](https://reactjs.org/)

---

## 目录

1.  [项目概述](#-项目概述)
2.  [核心技术栈](#-核心技术栈)
3.  [关键功能与实现](#-关键功能与实现)
4.  [快速开始](#-快速开始)
    *   [环境准备](#环境准备)
    *   [数据初始化](#数据初始化)
    *   [项目启动](#项目启动)
5.  [核心功能演示](#-核心功能演示)
6.  [维护与贡献](#-维护与贡献)
7.  [许可证](#-许可证)

---

## 项目概述

本项目是一个全栈式智能推荐系统，专注于解决化妆品领域信息过载和个性化推荐不足的问题。通过将产品数据转化为 **Neo4j 图谱**，系统能够高效地处理产品、成分、功效和肤质之间的复杂关系，为用户提供科学、可靠的选品建议。

## 核心技术栈

本项目采用经典的前后端分离架构，技术选型如下：

| 模块 | 技术栈 | 关键依赖 | 职责 |
| :--- | :--- | :--- | :--- |
| **图数据库** | **Neo4j** | Cypher | 核心数据存储，图谱建模与复杂关系查询。 |
| **后端 API** | **Python (Flask)** | `neo4j`, `flask-cors` | 提供 RESTful 接口，实现推荐算法和业务逻辑。 |
| **前端 UI** | **React + Vite** | `axios`, `react-router-dom` | 现代化、响应式用户界面，负责数据展示和用户交互。 |
| **样式/组件** | **Tailwind CSS** | `Radix UI` | 快速、原子化 CSS 框架，确保界面美观和可访问性。 |

##  关键功能与实现

### **1. 图数据建模**

项目将化妆品数据转化为图结构，实现了以下核心实体和关系：

| 节点 (Node) | 关系 (Relationship) | 描述 |
| :--- | :--- | :--- |
| `:Product` (产品) | `[:CONTAINS]` | 产品包含成分，关系属性可存储浓度。 |
| `:Ingredient` (成分) | `[:HAS_EFFICACY]` | 成分具有特定功效。 |
| `:Efficacy` (功效) | `[:SUITABLE_FOR]` | 产品或成分适合特定肤质。 |
| `:SkinType` (肤质) | `[:AVOID]` | 敏感肤质应避免的成分。 |

### **2. 个性化推荐 API**

后端 API 能够根据用户输入的多个条件，构建复杂的 Cypher 查询，实现：

*   **多条件筛选：** 基于肤质、功效、产品类型等组合筛选。
*   **成分相似度推荐：** 查找与用户偏好产品共享成分最多的产品。
*   **敏感成分排除：** 确保推荐结果不包含用户指定的敏感成分。

## 快速开始

### **环境准备**

请确保本地环境已安装：`Python 3.8+`、`Node.js 18+`、`pnpm` 和 `Neo4j Server`。

### **数据初始化**

1.  **配置 Neo4j：** 启动 Neo4j，并确认连接信息为 `bolt://localhost:7687` (User: `neo4j`, Pass: `CosmeticGraph2025`)。
2.  **安装依赖：**
    ```bash
    # 后端依赖
    cd backend
    pip install -r requirements.txt
    pip install neo4j # 确保安装 Neo4j 驱动
    
    # 前端依赖
    cd frontend
    pnpm install
    ```
3.  **在neo4j浏览器导入数据：**
   
    确保在命令行执行文件neo4j_data_initialization_V2.cypher
    

### **项目启动**

在两个独立的终端中分别启动前后端服务：

| 服务 | 启动命令 | 默认地址 |
| :--- | :--- | :--- |
| **后端 API** | `cd backend && python src/main.py` | `http://localhost:5000` |
| **前端 UI** | `cd frontend && pnpm run dev --host` | `http://localhost:5173` |

## 核心功能演示

<img width="1353" height="519" alt="Screenshot 2025-11-20 at 6 29 58 pm" src="https://github.com/user-attachments/assets/d177d72a-ca43-4828-b489-98f6f9bae9de" />

<img width="1353" height="673" alt="Screenshot 2025-11-20 at 6 31 46 pm" src="https://github.com/user-attachments/assets/ac34052d-a4f2-431a-a742-f46536613794" />

<img width="1353" height="442" alt="Screenshot 2025-11-20 at 6 31 59 pm" src="https://github.com/user-attachments/assets/6dfcdc95-e5bf-4848-8206-a4c52e34dd6e" />


## 维护与贡献

本项目由 [withbaekyunny] 维护。

*   **问题反馈：** 遇到 Bug 或有功能建议，请通过 [GitHub Issues](https://github.com/your-username/your-repo/issues) 提交。
*   **贡献指南：** 欢迎查阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与代码贡献。

## 许可证

本项目基于 **MIT 许可证**发布。详情请参阅 [LICENSE](LICENSE) 文件。
