-- Emerging 官网测试数据
-- 版权 (c) 2026 Deep Learning Corporation

USE emerging_website;

-- =====================================================
-- 插入测试用户
-- =====================================================

-- 密码都是 'password123' 的哈希值
INSERT INTO users (username, email, password_hash, role, bio, email_verified) VALUES
('john_doe', 'john@example.com', '$2a$10$YourHashedPasswordHere', 'user', '操作系统开发者，Emerging 爱好者', TRUE),
('jane_smith', 'jane@example.com', '$2a$10$YourHashedPasswordHere', 'contributor', '内核开发者，Emerging 贡献者', TRUE),
('bob_wilson', 'bob@example.com', '$2a$10$YourHashedPasswordHere', 'user', '嵌入式系统工程师', TRUE),
('alice_chen', 'alice@example.com', '$2a$10$YourHashedPasswordHere', 'contributor', '系统编程讲师', TRUE),
('david_li', 'david@example.com', '$2a$10$YourHashedPasswordHere', 'user', '学生，学习系统编程', FALSE);

-- =====================================================
-- 插入版本发布
-- =====================================================

INSERT INTO releases (version, release_date, is_stable, is_latest, changelog, release_notes) VALUES
('1.0.0', '2026-03-04', TRUE, TRUE, 
'# 变更日志

## 新特性
- 完整的标准库
- 改进的内存安全
- 更好的跨平台支持

## 修复
- 修复了多个编译器bug
- 改进了错误信息',
'# 发布说明

Emerging 1.0.0 是首个稳定版本，包含了完整的语言特性和工具链。'),

('0.9.0', '2025-12-15', FALSE, FALSE,
'# 变更日志

## 新特性
- 基础编译器实现
- 简单的标准库
- 链接器支持',
'# 发布说明

这是首个公测版本，欢迎反馈问题。'),

('0.8.0', '2025-09-01', FALSE, FALSE,
'# 变更日志

## 新特性
- 原型编译器
- 基础语法支持',
'# 发布说明

内部测试版本。');

-- =====================================================
-- 插入发布文件
-- =====================================================

-- 获取版本ID
SET @v1_id = (SELECT id FROM releases WHERE version = '1.0.0');
SET @v09_id = (SELECT id FROM releases WHERE version = '0.9.0');
SET @v08_id = (SELECT id FROM releases WHERE version = '0.8.0');

INSERT INTO release_files (release_id, platform, arch, filename, file_path, file_size, checksum_sha256) VALUES
(@v1_id, 'windows', 'x86_64', 'emerging-1.0.0-win64.zip', '/downloads/emerging-1.0.0-win64.zip', 15200000, 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6'),
(@v1_id, 'windows', 'x86', 'emerging-1.0.0-win32.zip', '/downloads/emerging-1.0.0-win32.zip', 14800000, 'b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7'),
(@v1_id, 'linux', 'x86_64', 'emerging-1.0.0-linux64.tar.gz', '/downloads/emerging-1.0.0-linux64.tar.gz', 13500000, 'c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8'),
(@v1_id, 'linux', 'x86', 'emerging-1.0.0-linux32.tar.gz', '/downloads/emerging-1.0.0-linux32.tar.gz', 13200000, 'd4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9'),
(@v1_id, 'macos', 'x86_64', 'emerging-1.0.0-macos64.tar.gz', '/downloads/emerging-1.0.0-macos64.tar.gz', 13800000, 'e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0'),
(@v1_id, 'macos', 'arm64', 'emerging-1.0.0-macos-arm64.tar.gz', '/downloads/emerging-1.0.0-macos-arm64.tar.gz', 13600000, 'f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1'),
(@v1_id, 'source', 'src', 'emerging-1.0.0-source.tar.gz', '/downloads/emerging-1.0.0-source.tar.gz', 8900000, 'g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2'),

(@v09_id, 'windows', 'x86_64', 'emerging-0.9.0-win64.zip', '/downloads/emerging-0.9.0-win64.zip', 14100000, 'h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3'),
(@v09_id, 'linux', 'x86_64', 'emerging-0.9.0-linux64.tar.gz', '/downloads/emerging-0.9.0-linux64.tar.gz', 12800000, 'i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4'),
(@v09_id, 'macos', 'x86_64', 'emerging-0.9.0-macos64.tar.gz', '/downloads/emerging-0.9.0-macos64.tar.gz', 13100000, 'j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5'),

(@v08_id, 'source', 'src', 'emerging-0.8.0-source.tar.gz', '/downloads/emerging-0.8.0-source.tar.gz', 8200000, 'k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2g3h4i5j6');

-- =====================================================
-- 插入下载记录
-- =====================================================

INSERT INTO downloads (user_id, platform, version, ip_address, user_agent, country_code, download_date, file_size) VALUES
(1, 'windows', '1.0.0', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'US', DATE_SUB(NOW(), INTERVAL 2 DAY), 15200000),
(2, 'linux', '1.0.0', '192.168.1.101', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'CN', DATE_SUB(NOW(), INTERVAL 1 DAY), 13500000),
(3, 'macos', '1.0.0', '192.168.1.102', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'JP', DATE_SUB(NOW(), INTERVAL 12 HOUR), 13800000),
(4, 'windows', '0.9.0', '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'GB', DATE_SUB(NOW(), INTERVAL 3 DAY), 14100000),
(5, 'linux', '0.9.0', '192.168.1.104', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'DE', DATE_SUB(NOW(), INTERVAL 4 DAY), 12800000),
(NULL, 'source', '1.0.0', '192.168.1.105', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'FR', DATE_SUB(NOW(), INTERVAL 5 DAY), 8900000),
(NULL, 'macos', '0.9.0', '192.168.1.106', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'CA', DATE_SUB(NOW(), INTERVAL 6 DAY), 13100000);

-- 更新下载计数
UPDATE release_files SET download_count = 3 WHERE release_id = @v1_id AND platform = 'windows';
UPDATE release_files SET download_count = 2 WHERE release_id = @v1_id AND platform = 'linux';
UPDATE release_files SET download_count = 2 WHERE release_id = @v1_id AND platform = 'macos';
UPDATE release_files SET download_count = 1 WHERE release_id = @v09_id AND platform = 'windows';
UPDATE release_files SET download_count = 1 WHERE release_id = @v09_id AND platform = 'linux';
UPDATE release_files SET download_count = 1 WHERE release_id = @v09_id AND platform = 'macos';
UPDATE release_files SET download_count = 1 WHERE release_id = @v1_id AND platform = 'source';

-- =====================================================
-- 插入博客文章
-- =====================================================

INSERT INTO blog_posts (title, slug, excerpt, content, author_id, tags, is_published, published_at, view_count, like_count) VALUES
('Emerging 1.0.0 正式发布', 'emerging-1.0-released',
 '经过两年的开发，Emerging 1.0.0 版本正式发布，带来了完整的工具链和标准库...',
 '# Emerging 1.0.0 正式发布

我们非常高兴地宣布，Emerging 编程语言 1.0.0 版本正式发布了！

## 主要特性

- **完整的标准库**：包含IO、字符串、数学、内存管理等模块
- **改进的内存安全**：编译时检查，消除常见漏洞
- **跨平台支持**：Windows、Linux、macOS 全平台支持
- **高性能**：媲美 C 语言的运行时性能

## 下载

访问我们的[下载页面](/download)获取最新版本。

感谢所有贡献者的支持！',
 2, '["release", "announcement"]', TRUE, '2026-03-04 10:00:00', 1234, 89),

('Deep Learning Corporation 赞助 Emerging 项目', 'deeplearning-sponsor',
 'Deep Learning Corporation 正式成为 Emerging 语言的主要赞助商，支持其长期发展...',
 '# Deep Learning Corporation 宣布赞助 Emerging 项目

我们荣幸地宣布，Deep Learning Corporation 正式成为 Emerging 语言项目的金牌赞助商。

## 关于赞助

Deep Learning Corporation 将提供资金和基础设施支持，帮助 Emerging 语言项目快速发展。

## 未来规划

- 招聘全职开发者
- 改进编译器性能
- 扩展标准库功能

感谢 Deep Learning Corporation 的支持！',
 1, '["announcement", "sponsor"]', TRUE, '2026-02-15 09:30:00', 567, 34),

('Emerging 语法特性介绍', 'emerging-syntax-features',
 'Emerging 语言提供了简洁而强大的语法，本文将介绍其主要特性...',
 '# Emerging 语法特性

Emerging 语言的语法设计兼顾了简洁性和表达力。

## 基础语法

```emerging
use <stdio.emh>

int main() {
    println("Hello, World!");
    ret 0;
}