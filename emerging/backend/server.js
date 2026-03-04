const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const path = require('path');
require('dotenv').config();

// 导入路由
const apiRoutes = require('./routes/api');
const adminRoutes = require('./routes/admin');

// 初始化Express应用
const app = express();
const PORT = process.env.PORT || 3000;

// 安全中间件
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'", "https://cdnjs.cloudflare.com"],
            scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
            imgSrc: ["'self'", "data:", "https:"],
            fontSrc: ["'self'", "https://cdnjs.cloudflare.com"],
        },
    },
}));

// CORS配置
app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:8080',
    credentials: true
}));

// 压缩响应
app.use(compression());

// 日志记录
app.use(morgan('combined'));

// 请求限制
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15分钟
    max: 100 // 每个IP限制100个请求
});
app.use('/api/', limiter);

// 解析请求体
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 静态文件服务
app.use('/static', express.static(path.join(__dirname, '../frontend')));

// 数据库连接
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/emerging', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => console.log('✅ MongoDB连接成功'))
.catch(err => {
    console.error('❌ MongoDB连接失败:', err);
    process.exit(1);
});

// 路由
app.use('/api', apiRoutes);
app.use('/admin', adminRoutes);

// 前端路由
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

app.get('/docs', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/docs.html'));
});

app.get('/download', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/download.html'));
});

app.get('/community', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/community.html'));
});

app.get('/blog', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/blog.html'));
});

// 404处理
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: '资源不存在'
    });
});

// 错误处理中间件
app.use((err, req, res, next) => {
    console.error('服务器错误:', err);
    res.status(500).json({
        success: false,
        message: '服务器内部错误',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`
    ╔════════════════════════════════════╗
    ║   Emerging 官网后端服务已启动       ║
    ╠════════════════════════════════════╣
    ║  端口: ${PORT}                      ║
    ║  环境: ${process.env.NODE_ENV || 'development'} ║
    ║  前端: ${process.env.FRONTEND_URL || 'http://localhost:8080'} ║
    ╚════════════════════════════════════╝
    `);
});

// 优雅关闭
process.on('SIGTERM', () => {
    console.log('收到SIGTERM信号，正在关闭服务器...');
    mongoose.connection.close(false, () => {
        console.log('MongoDB连接已关闭');
        process.exit(0);
    });
});

module.exports = app;