const jwt = require('jsonwebtoken');

// 认证中间件
exports.authenticate = (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        
        if (!token) {
            return res.status(401).json({
                success: false,
                message: '请先登录'
            });
        }
        
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'emerging-secret-key');
        req.user = decoded;
        
        next();
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: '登录已过期，请重新登录'
            });
        }
        
        res.status(401).json({
            success: false,
            message: '认证失败'
        });
    }
};

// 可选认证（有token就验证，没有也可以）
exports.optionalAuth = (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        
        if (token) {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'emerging-secret-key');
            req.user = decoded;
        }
        
        next();
    } catch (error) {
        // token无效，但不阻止请求
        next();
    }
};

// 管理员权限检查
exports.requireAdmin = (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: '需要管理员权限'
        });
    }
    next();
};

// 贡献者权限检查
exports.requireContributor = (req, res, next) => {
    if (!req.user || !['contributor', 'admin'].includes(req.user.role)) {
        return res.status(403).json({
            success: false,
            message: '需要贡献者权限'
        });
    }
    next();
};

// 生成JWT令牌
exports.generateToken = (user) => {
    return jwt.sign(
        {
            userId: user._id,
            username: user.username,
            role: user.role
        },
        process.env.JWT_SECRET || 'emerging-secret-key',
        { expiresIn: '7d' }
    );
};

// 验证令牌
exports.verifyToken = (token) => {
    try {
        return jwt.verify(token, process.env.JWT_SECRET || 'emerging-secret-key');
    } catch (error) {
        return null;
    }
};