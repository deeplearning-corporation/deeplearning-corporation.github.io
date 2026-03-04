-- Emerging 官网数据库 Schema
-- 版权 (c) 2026 Deep Learning Corporation

-- =====================================================
-- 数据库初始化
-- =====================================================

CREATE DATABASE IF NOT EXISTS emerging_website
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE emerging_website;

-- =====================================================
-- 用户相关表
-- =====================================================

-- 用户表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255) DEFAULT '/static/images/default-avatar.png',
    bio TEXT,
    website VARCHAR(255),
    github VARCHAR(100),
    twitter VARCHAR(100),
    company VARCHAR(100),
    location VARCHAR(100),
    role ENUM('user', 'contributor', 'admin') DEFAULT 'user',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    reset_token VARCHAR(255),
    reset_token_expires DATETIME,
    last_login DATETIME,
    last_login_ip VARCHAR(45),
    login_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户登录历史表
CREATE TABLE user_login_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    login_time DATETIME NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_success BOOLEAN DEFAULT TRUE,
    failure_reason VARCHAR(255),
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 用户会话表
CREATE TABLE user_sessions (
    id VARCHAR(128) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    payload TEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 下载相关表
-- =====================================================

-- 下载记录表
CREATE TABLE downloads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    platform ENUM('windows', 'linux', 'macos', 'source', 'docs') NOT NULL,
    version VARCHAR(20) NOT NULL,
    arch VARCHAR(10) DEFAULT 'x86_64',
    ip_address VARCHAR(45),
    user_agent TEXT,
    referer VARCHAR(255),
    country_code VARCHAR(2),
    city VARCHAR(100),
    download_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    file_size BIGINT,
    download_duration INT, -- 下载耗时（秒）
    download_speed FLOAT, -- 下载速度（KB/s）
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_platform (platform),
    INDEX idx_version (version),
    INDEX idx_download_date (download_date),
    INDEX idx_user_id (user_id),
    INDEX idx_country (country_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 版本发布表
CREATE TABLE releases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    version VARCHAR(20) NOT NULL UNIQUE,
    release_date DATE NOT NULL,
    is_stable BOOLEAN DEFAULT TRUE,
    is_latest BOOLEAN DEFAULT FALSE,
    changelog TEXT,
    release_notes TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_version (version),
    INDEX idx_is_stable (is_stable),
    INDEX idx_is_latest (is_latest)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 发布文件表
CREATE TABLE release_files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    release_id INT NOT NULL,
    platform ENUM('windows', 'linux', 'macos', 'source') NOT NULL,
    arch VARCHAR(10) DEFAULT 'x86_64',
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    checksum_md5 VARCHAR(32),
    checksum_sha256 VARCHAR(64),
    checksum_sha512 VARCHAR(128),
    download_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE,
    UNIQUE KEY uk_release_platform_arch (release_id, platform, arch),
    INDEX idx_platform (platform)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 内容管理表
-- =====================================================

-- 博客文章表
CREATE TABLE blog_posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content LONGTEXT,
    author_id INT,
    featured_image VARCHAR(255),
    tags JSON,
    categories JSON,
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    published_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_slug (slug),
    INDEX idx_is_published (is_published),
    INDEX idx_published_at (published_at),
    INDEX idx_author_id (author_id),
    FULLTEXT INDEX ft_title_content (title, content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 文档表
CREATE TABLE documentation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    content LONGTEXT,
    version VARCHAR(20) DEFAULT 'latest',
    author_id INT,
    editor_id INT,
    order_num INT DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES documentation(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (editor_id) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_slug_version (slug, version),
    INDEX idx_parent_id (parent_id),
    INDEX idx_version (version),
    INDEX idx_order_num (order_num)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 常见问题表
CREATE TABLE faq (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(50),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    order_num INT DEFAULT 0,
    view_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_order_num (order_num),
    FULLTEXT INDEX ft_question_answer (question, answer)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 社区互动表
-- =====================================================

-- 评论表
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT,
    user_id INT,
    content_type ENUM('blog', 'doc', 'faq') NOT NULL,
    content_id INT NOT NULL,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    is_approved BOOLEAN DEFAULT TRUE,
    is_spam BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_content (content_type, content_id),
    INDEX idx_created_at (created_at),
    INDEX idx_is_approved (is_approved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 点赞表
CREATE TABLE likes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content_type ENUM('blog', 'comment') NOT NULL,
    content_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_content (user_id, content_type, content_id),
    INDEX idx_content (content_type, content_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 订阅表
CREATE TABLE subscriptions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100),
    subscription_type ENUM('newsletter', 'release', 'blog') DEFAULT 'newsletter',
    is_active BOOLEAN DEFAULT TRUE,
    verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255),
    unsubscribe_token VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY uk_email_type (email, subscription_type),
    INDEX idx_email (email),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 反馈和支持表
-- =====================================================

-- 反馈表
CREATE TABLE feedback (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    subject VARCHAR(255),
    message TEXT NOT NULL,
    category ENUM('bug', 'feature', 'question', 'other') DEFAULT 'other',
    status ENUM('new', 'read', 'replied', 'closed') DEFAULT 'new',
    priority ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 反馈回复表
CREATE TABLE feedback_replies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    feedback_id INT NOT NULL,
    user_id INT,
    content TEXT NOT NULL,
    is_staff_reply BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_feedback_id (feedback_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 错误报告表
CREATE TABLE error_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    error_type VARCHAR(50),
    error_message TEXT,
    stack_trace TEXT,
    version VARCHAR(20),
    platform VARCHAR(20),
    url VARCHAR(500),
    user_agent TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_created_at (created_at),
    INDEX idx_error_type (error_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 统计和分析表
-- =====================================================

-- 页面访问统计
CREATE TABLE page_views (
    id INT PRIMARY KEY AUTO_INCREMENT,
    page_url VARCHAR(500) NOT NULL,
    page_title VARCHAR(255),
    referer VARCHAR(500),
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(128),
    user_id INT,
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    time_on_page INT,
    is_unique BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_page_url (page_url(255)),
    INDEX idx_visit_time (visit_time),
    INDEX idx_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 每日统计汇总
CREATE TABLE daily_stats (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stat_date DATE UNIQUE NOT NULL,
    unique_visitors INT DEFAULT 0,
    page_views INT DEFAULT 0,
    downloads INT DEFAULT 0,
    new_users INT DEFAULT 0,
    feedback_count INT DEFAULT 0,
    blog_views INT DEFAULT 0,
    doc_views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_stat_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 实时在线用户
CREATE TABLE online_users (
    session_id VARCHAR(128) PRIMARY KEY,
    user_id INT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    current_url VARCHAR(500),
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 系统管理表
-- =====================================================

-- 系统配置表
CREATE TABLE system_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 操作日志表
CREATE TABLE operation_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at),
    INDEX idx_target (target_type, target_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 通知表
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type ENUM('system', 'comment', 'like', 'mention', 'release') NOT NULL,
    title VARCHAR(255),
    content TEXT,
    link VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 初始数据插入
-- =====================================================

-- 插入默认管理员用户 (密码: admin123)
INSERT INTO users (username, email, password_hash, role, email_verified) VALUES
('admin', 'admin@emerging-lang.org', '$2a$10$YourHashedPasswordHere', 'admin', TRUE);

-- 插入系统配置
INSERT INTO system_config (config_key, config_value, config_type, description) VALUES
('site_name', 'Emerging Language', 'string', '网站名称'),
('site_description', '为操作系统开发而生的系统编程语言', 'string', '网站描述'),
('site_keywords', 'Emerging,编程语言,系统编程,操作系统', 'string', '网站关键词'),
('maintenance_mode', 'false', 'boolean', '维护模式'),
('allow_registrations', 'true', 'boolean', '允许注册'),
('allow_comments', 'true', 'boolean', '允许评论'),
('latest_version', '1.0.0', 'string', '最新版本'),
('contact_email', 'contact@emerging-lang.org', 'string', '联系邮箱');

-- 插入初始FAQ
INSERT INTO faq (category, question, answer, order_num) VALUES
('general', 'Emerging 适合做什么？', 'Emerging 是专为操作系统开发设计的系统编程语言，同时也适用于驱动程序、嵌入式系统、高性能计算等领域。', 1),
('general', 'Emerging 相比 C/C++ 有什么优势？', 'Emerging 提供了更现代的语言特性，包括内存安全保证、更简洁的语法、内置的包管理器、跨平台支持等，同时保持了与 C 语言相当的性能。', 2),
('installation', '如何安装 Emerging？', '您可以通过我们的安装脚本一键安装：curl -sSL https://get.emerging-lang.org | bash', 3),
('installation', '支持哪些操作系统？', 'Emerging 支持 Windows、Linux 和 macOS 三大主流操作系统。', 4);

-- 插入初始文档
INSERT INTO documentation (title, slug, content, order_num) VALUES
('快速入门', 'getting-started', '# 快速入门\n\n欢迎使用 Emerging 语言！本指南将帮助您快速上手。\n\n## 安装\n\n...', 1),
('语言基础', 'language-basics', '# 语言基础\n\n## 语法\n\n...', 2),
('标准库', 'standard-library', '# 标准库\n\nEmerging 提供了丰富的标准库...', 3);

-- =====================================================
-- 创建视图
-- =====================================================

-- 用户下载统计视图
CREATE VIEW user_download_stats AS
SELECT 
    u.id AS user_id,
    u.username,
    COUNT(d.id) AS total_downloads,
    COUNT(DISTINCT d.version) AS versions_downloaded,
    MAX(d.download_date) AS last_download_date
FROM users u
LEFT JOIN downloads d ON u.id = d.user_id
GROUP BY u.id, u.username;

-- 热门文档视图
CREATE VIEW popular_docs AS
SELECT 
    d.id,
    d.title,
    d.slug,
    d.view_count,
    d.updated_at
FROM documentation d
WHERE d.is_published = TRUE
ORDER BY d.view_count DESC
LIMIT 10;

-- 最新版本视图
CREATE VIEW latest_release AS
SELECT 
    r.version,
    r.release_date,
    r.is_stable,
    r.changelog,
    rf.platform,
    rf.arch,
    rf.filename,
    rf.file_size
FROM releases r
JOIN release_files rf ON r.id = rf.release_id
WHERE r.is_latest = TRUE;

-- =====================================================
-- 创建存储过程
-- =====================================================

-- 记录下载并更新统计
DELIMITER //
CREATE PROCEDURE record_download(
    IN p_user_id INT,
    IN p_platform VARCHAR(20),
    IN p_version VARCHAR(20),
    IN p_ip_address VARCHAR(45),
    IN p_user_agent TEXT,
    IN p_file_size BIGINT
)
BEGIN
    -- 插入下载记录
    INSERT INTO downloads (user_id, platform, version, ip_address, user_agent, file_size)
    VALUES (p_user_id, p_platform, p_version, p_ip_address, p_user_agent, p_file_size);
    
    -- 更新版本下载计数
    UPDATE release_files rf
    JOIN releases r ON rf.release_id = r.id
    SET rf.download_count = rf.download_count + 1
    WHERE r.version = p_version AND rf.platform = p_platform;
    
    -- 更新每日统计
    INSERT INTO daily_stats (stat_date, downloads)
    VALUES (CURDATE(), 1)
    ON DUPLICATE KEY UPDATE
    downloads = downloads + 1;
END//
DELIMITER ;

-- 每日统计汇总
DELIMITER //
CREATE PROCEDURE aggregate_daily_stats()
BEGIN
    INSERT INTO daily_stats (stat_date, page_views, unique_visitors)
    SELECT 
        DATE(visit_time) as stat_date,
        COUNT(*) as page_views,
        COUNT(DISTINCT 
            CASE 
                WHEN user_id IS NOT NULL THEN CONCAT('user_', user_id)
                ELSE ip_address 
            END
        ) as unique_visitors
    FROM page_views
    WHERE visit_time >= CURDATE() - INTERVAL 1 DAY
        AND visit_time < CURDATE()
    GROUP BY DATE(visit_time)
    ON DUPLICATE KEY UPDATE
        page_views = VALUES(page_views),
        unique_visitors = VALUES(unique_visitors);
END//
DELIMITER ;

-- =====================================================
-- 创建触发器
-- =====================================================

-- 更新博客文章评论数
DELIMITER //
CREATE TRIGGER update_blog_comment_count
AFTER INSERT ON comments
FOR EACH ROW
BEGIN
    IF NEW.content_type = 'blog' THEN
        UPDATE blog_posts 
        SET comment_count = comment_count + 1 
        WHERE id = NEW.content_id;
    END IF;
END//
DELIMITER ;

-- 更新用户最后登录时间
DELIMITER //
CREATE TRIGGER update_user_last_login
AFTER INSERT ON user_login_history
FOR EACH ROW
BEGIN
    IF NEW.login_success = TRUE THEN
        UPDATE users 
        SET last_login = NEW.login_time,
            last_login_ip = NEW.ip_address,
            login_count = login_count + 1
        WHERE id = NEW.user_id;
    END IF;
END//
DELIMITER ;

-- =====================================================
-- 创建事件调度器
-- =====================================================

-- 每天凌晨3点清理过期会话
CREATE EVENT IF NOT EXISTS clean_expired_sessions
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURDATE() + INTERVAL 1 DAY + INTERVAL 3 HOUR)
DO
    DELETE FROM user_sessions 
    WHERE last_activity < NOW() - INTERVAL 7 DAY;

-- 每小时清理过期在线用户
CREATE EVENT IF NOT EXISTS clean_online_users
ON SCHEDULE EVERY 1 HOUR
DO
    DELETE FROM online_users 
    WHERE last_activity < NOW() - INTERVAL 15 MINUTE;

-- =====================================================
-- 创建索引优化建议
-- =====================================================

-- 分析表
ANALYZE TABLE users;
ANALYZE TABLE downloads;
ANALYZE TABLE blog_posts;
ANALYZE TABLE page_views;

-- 优化表
OPTIMIZE TABLE users;
OPTIMIZE TABLE downloads;
OPTIMIZE TABLE blog_posts;
OPTIMIZE TABLE page_views;

-- =====================================================
-- 权限设置
-- =====================================================

-- 创建应用用户
CREATE USER IF NOT EXISTS 'emerging_app'@'localhost' IDENTIFIED BY 'secure_password_here';
CREATE USER IF NOT EXISTS 'emerging_app'@'%' IDENTIFIED BY 'secure_password_here';

-- 授予权限
GRANT SELECT, INSERT, UPDATE, DELETE ON emerging_website.* TO 'emerging_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON emerging_website.* TO 'emerging_app'@'%';

-- 创建只读用户（用于报表）
CREATE USER IF NOT EXISTS 'emerging_readonly'@'localhost' IDENTIFIED BY 'readonly_password_here';
GRANT SELECT ON emerging_website.* TO 'emerging_readonly'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;

-- =====================================================
-- 数据库维护说明
-- =====================================================

/*
数据库维护指南：

1. 定期备份：
   mysqldump -u root -p emerging_website > backup_$(date +%Y%m%d).sql

2. 优化表：
   mysqlcheck -o emerging_website -u root -p

3. 监控慢查询：
   SET GLOBAL slow_query_log = ON;
   SET GLOBAL long_query_time = 2;

4. 查看表大小：
   SELECT 
       table_name,
       ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
   FROM information_schema.tables
   WHERE table_schema = 'emerging_website'
   ORDER BY size_mb DESC;

5. 清理旧数据：
   DELETE FROM page_views WHERE visit_time < NOW() - INTERVAL 90 DAY;
   DELETE FROM user_login_history WHERE login_time < NOW() - INTERVAL 90 DAY;
   DELETE FROM operation_logs WHERE created_at < NOW() - INTERVAL 90 DAY;
*/