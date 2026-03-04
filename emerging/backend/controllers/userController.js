const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator');

// 用户注册
exports.register = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                errors: errors.array()
            });
        }
        
        const { username, email, password } = req.body;
        
        // 检查用户是否已存在
        const existingUser = await User.findOne({
            $or: [{ email }, { username }]
        });
        
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: '用户名或邮箱已被注册'
            });
        }
        
        // 加密密码
        const hashedPassword = await bcrypt.hash(password, 10);
        
        // 创建用户
        const user = new User({
            username,
            email,
            password: hashedPassword
        });
        
        await user.save();
        
        // 生成JWT令牌
        const token = jwt.sign(
            { userId: user._id, username: user.username },
            process.env.JWT_SECRET || 'emerging-secret-key',
            { expiresIn: '7d' }
        );
        
        res.json({
            success: true,
            message: '注册成功',
            token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email
            }
        });
    } catch (error) {
        console.error('注册错误:', error);
        res.status(500).json({
            success: false,
            message: '注册失败，请稍后重试'
        });
    }
};

// 用户登录
exports.login = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                errors: errors.array()
            });
        }
        
        const { email, password } = req.body;
        
        // 查找用户
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({
                success: false,
                message: '邮箱或密码错误'
            });
        }
        
        // 验证密码
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({
                success: false,
                message: '邮箱或密码错误'
            });
        }
        
        // 更新最后登录时间
        user.lastLogin = new Date();
        await user.save();
        
        // 生成JWT令牌
        const token = jwt.sign(
            { userId: user._id, username: user.username, role: user.role },
            process.env.JWT_SECRET || 'emerging-secret-key',
            { expiresIn: '7d' }
        );
        
        res.json({
            success: true,
            message: '登录成功',
            token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role
            }
        });
    } catch (error) {
        console.error('登录错误:', error);
        res.status(500).json({
            success: false,
            message: '登录失败，请稍后重试'
        });
    }
};

// 获取用户资料
exports.getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId)
            .select('-password');
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: '用户不存在'
            });
        }
        
        res.json({
            success: true,
            user
        });
    } catch (error) {
        console.error('获取资料错误:', error);
        res.status(500).json({
            success: false,
            message: '获取资料失败'
        });
    }
};

// 更新用户资料
exports.updateProfile = async (req, res) => {
    try {
        const { username, email, avatar } = req.body;
        
        const user = await User.findById(req.user.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: '用户不存在'
            });
        }
        
        // 检查用户名/邮箱是否已被其他用户使用
        if (username && username !== user.username) {
            const existingUser = await User.findOne({ username });
            if (existingUser) {
                return res.status(400).json({
                    success: false,
                    message: '用户名已被使用'
                });
            }
            user.username = username;
        }
        
        if (email && email !== user.email) {
            const existingUser = await User.findOne({ email });
            if (existingUser) {
                return res.status(400).json({
                    success: false,
                    message: '邮箱已被使用'
                });
            }
            user.email = email;
        }
        
        if (avatar) {
            user.avatar = avatar;
        }
        
        await user.save();
        
        res.json({
            success: true,
            message: '资料更新成功',
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                avatar: user.avatar
            }
        });
    } catch (error) {
        console.error('更新资料错误:', error);
        res.status(500).json({
            success: false,
            message: '更新资料失败'
        });
    }
};

// 修改密码
exports.changePassword = async (req, res) => {
    try {
        const { oldPassword, newPassword } = req.body;
        
        const user = await User.findById(req.user.userId);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: '用户不存在'
            });
        }
        
        // 验证旧密码
        const isValidPassword = await bcrypt.compare(oldPassword, user.password);
        if (!isValidPassword) {
            return res.status(401).json({
                success: false,
                message: '旧密码错误'
            });
        }
        
        // 更新密码
        user.password = await bcrypt.hash(newPassword, 10);
        await user.save();
        
        res.json({
            success: true,
            message: '密码修改成功'
        });
    } catch (error) {
        console.error('修改密码错误:', error);
        res.status(500).json({
            success: false,
            message: '修改密码失败'
        });
    }
};

// 获取用户下载历史
exports.getDownloads = async (req, res) => {
    try {
        const downloads = await Download.find({ userId: req.user.userId })
            .sort({ date: -1 })
            .limit(50);
        
        res.json({
            success: true,
            downloads
        });
    } catch (error) {
        console.error('获取下载历史错误:', error);
        res.status(500).json({
            success: false,
            message: '获取下载历史失败'
        });
    }
};