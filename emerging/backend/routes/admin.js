const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const User = require('../models/User');
const Download = require('../models/Download');

// 管理员认证中间件
const adminAuth = async (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: '需要管理员权限'
        });
    }
    next();
};

// 管理员登录
router.post('/login', [
    body('username').notEmpty(),
    body('password').notEmpty()
], async (req, res) => {
    const { username, password } = req.body;
    
    // 验证管理员凭证
    if (username === process.env.ADMIN_USERNAME && 
        password === process.env.ADMIN_PASSWORD) {
        
        const token = jwt.sign(
            { username, role: 'admin' },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );
        
        res.json({
            success: true,
            token
        });
    } else {
        res.status(401).json({
            success: false,
            message: '用户名或密码错误'
        });
    }
});

// 获取仪表盘数据
router.get('/dashboard', auth.authenticate, adminAuth, async (req, res) => {
    try {
        const totalDownloads = await Download.countDocuments();
        const todayDownloads = await Download.countDocuments({
            date: { $gte: new Date().setHours(0, 0, 0, 0) }
        });
        const totalUsers = await User.countDocuments();
        
        // 获取下载趋势
        const downloadTrends = await Download.aggregate([
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                    count: { $sum: 1 }
                }
            },
            { $sort: { _id: -1 } },
            { $limit: 30 }
        ]);
        
        res.json({
            success: true,
            data: {
                totalDownloads,
                todayDownloads,
                totalUsers,
                downloadTrends
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取数据失败'
        });
    }
});

// 获取用户列表
router.get('/users', auth.authenticate, adminAuth, async (req, res) => {
    try {
        const users = await User.find()
            .select('-password')
            .sort({ createdAt: -1 })
            .limit(100);
        
        res.json({
            success: true,
            users
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取用户列表失败'
        });
    }
});

// 更新用户角色
router.put('/users/:userId/role', auth.authenticate, adminAuth, async (req, res) => {
    try {
        const { role } = req.body;
        const user = await User.findByIdAndUpdate(
            req.params.userId,
            { role },
            { new: true }
        ).select('-password');
        
        res.json({
            success: true,
            user
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '更新用户角色失败'
        });
    }
});

// 发布博客文章
router.post('/blog/publish', auth.authenticate, adminAuth, [
    body('title').notEmpty(),
    body('content').notEmpty()
], async (req, res) => {
    try {
        const { title, content, summary, tags } = req.body;
        
        // 保存到数据库
        const post = {
            title,
            content,
            summary,
            tags,
            author: req.user.username,
            date: new Date(),
            published: true
        };
        
        // TODO: 保存到数据库
        
        res.json({
            success: true,
            message: '文章发布成功',
            post
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '发布失败'
        });
    }
});

// 获取下载统计数据
router.get('/downloads/stats', auth.authenticate, adminAuth, async (req, res) => {
    try {
        const stats = await Download.aggregate([
            {
                $group: {
                    _id: {
                        platform: "$platform",
                        year: { $year: "$date" },
                        month: { $month: "$date" }
                    },
                    count: { $sum: 1 }
                }
            },
            { $sort: { "_id.year": -1, "_id.month": -1 } }
        ]);
        
        res.json({
            success: true,
            stats
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取统计数据失败'
        });
    }
});

// 系统设置
router.get('/settings', auth.authenticate, adminAuth, (req, res) => {
    res.json({
        success: true,
        settings: {
            siteName: 'Emerging Language',
            siteUrl: 'https://emerging-lang.org',
            maintenance: false,
            allowRegistrations: true,
            downloadLimit: 1000
        }
    });
});

router.put('/settings', auth.authenticate, adminAuth, (req, res) => {
    // 更新设置
    res.json({
        success: true,
        message: '设置已更新'
    });
});

module.exports = router;