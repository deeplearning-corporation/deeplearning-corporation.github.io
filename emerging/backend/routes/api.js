const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const downloadController = require('../controllers/downloadController');
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');

// 获取最新版本信息
router.get('/version/latest', (req, res) => {
    res.json({
        success: true,
        version: '1.0.0',
        releaseDate: '2026-03-04',
        changelog: 'https://github.com/deeplearning-corp/emerging/releases/tag/v1.0.0',
        downloadUrl: '/api/download/latest'
    });
});

// 获取所有版本
router.get('/versions', (req, res) => {
    res.json({
        success: true,
        versions: [
            {
                version: '1.0.0',
                releaseDate: '2026-03-04',
                stable: true
            },
            {
                version: '0.9.0',
                releaseDate: '2025-12-15',
                stable: false
            }
        ]
    });
});

// 下载计数
router.get('/download/count', downloadController.getCount);

// 记录下载
router.post('/download/record', downloadController.recordDownload);

// 获取下载链接
router.get('/download/:platform', downloadController.getDownloadLink);

// 用户注册
router.post('/user/register', [
    body('username').isLength({ min: 3 }).trim().escape(),
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6 })
], userController.register);

// 用户登录
router.post('/user/login', [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty()
], userController.login);

// 获取用户信息（需要认证）
router.get('/user/profile', auth.authenticate, userController.getProfile);

// 更新用户信息（需要认证）
router.put('/user/profile', auth.authenticate, userController.updateProfile);

// 获取博客文章列表
router.get('/blog/posts', async (req, res) => {
    // 这里应该从数据库获取
    res.json({
        success: true,
        posts: [
            {
                id: 1,
                title: 'Emerging 1.0.0 正式发布',
                summary: '经过两年的开发，Emerging 1.0.0 版本正式发布...',
                date: '2026-03-04',
                author: 'Deep Learning Corp',
                url: '/blog/emerging-1.0-released'
            },
            {
                id: 2,
                title: 'Deep Learning Corporation 宣布赞助 Emerging 项目',
                summary: 'Deep Learning Corporation 正式成为 Emerging 语言的主要赞助商...',
                date: '2026-02-15',
                author: 'Deep Learning Corp',
                url: '/blog/deeplearning-sponsor'
            }
        ]
    });
});

// 获取单篇博客文章
router.get('/blog/post/:id', (req, res) => {
    const id = req.params.id;
    res.json({
        success: true,
        post: {
            id: id,
            title: 'Emerging 1.0.0 正式发布',
            content: '...',
            date: '2026-03-04',
            author: 'Deep Learning Corp'
        }
    });
});

// 搜索文档
router.get('/docs/search', (req, res) => {
    const query = req.query.q;
    res.json({
        success: true,
        results: [
            {
                title: '快速入门',
                url: '/docs/getting-started',
                snippet: '学习如何安装和使用 Emerging...'
            }
        ]
    });
});

// 获取FAQ
router.get('/faq', (req, res) => {
    res.json({
        success: true,
        faq: [
            {
                question: 'Emerging 适合做什么？',
                answer: 'Emerging 是专为操作系统开发设计的系统编程语言...'
            },
            {
                question: '如何安装 Emerging？',
                answer: '您可以通过我们的安装脚本一键安装...'
            }
        ]
    });
});

// 提交问题反馈
router.post('/feedback', [
    body('email').isEmail().normalizeEmail(),
    body('message').isLength({ min: 10 }).trim().escape()
], (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    
    // 保存反馈到数据库
    res.json({
        success: true,
        message: '反馈已提交，感谢您的支持！'
    });
});

// 获取统计数据
router.get('/stats', async (req, res) => {
    res.json({
        success: true,
        stats: {
            downloads: 10234,
            contributors: 523,
            stars: 3456,
            users: 189
        }
    });
});

module.exports = router;