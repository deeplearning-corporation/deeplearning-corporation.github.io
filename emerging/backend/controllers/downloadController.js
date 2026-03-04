const Download = require('../models/Download');
const path = require('path');
const fs = require('fs');

// 获取下载计数
exports.getCount = async (req, res) => {
    try {
        const count = await Download.countDocuments();
        res.json({
            success: true,
            count
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取下载计数失败'
        });
    }
};

// 记录下载
exports.recordDownload = async (req, res) => {
    try {
        const { platform, version, ip } = req.body;
        
        const download = new Download({
            platform,
            version,
            ip: ip || req.ip,
            userAgent: req.get('User-Agent'),
            date: new Date()
        });
        
        await download.save();
        
        res.json({
            success: true,
            message: '下载记录已保存'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '保存下载记录失败'
        });
    }
};

// 获取下载链接
exports.getDownloadLink = async (req, res) => {
    try {
        const platform = req.params.platform;
        const version = req.query.version || 'latest';
        
        // 记录下载
        const download = new Download({
            platform,
            version,
            ip: req.ip,
            userAgent: req.get('User-Agent'),
            date: new Date()
        });
        await download.save();
        
        // 返回下载链接
        let fileName;
        switch(platform) {
            case 'windows':
                fileName = 'emerging-1.0.0-win64.zip';
                break;
            case 'linux':
                fileName = 'emerging-1.0.0-linux64.tar.gz';
                break;
            case 'macos':
                fileName = 'emerging-1.0.0-macos64.tar.gz';
                break;
            default:
                return res.status(400).json({
                    success: false,
                    message: '不支持的平台'
                });
        }
        
        const downloadUrl = `/downloads/${fileName}`;
        
        res.json({
            success: true,
            downloadUrl,
            fileName,
            size: '15.2 MB',
            checksum: 'sha256: a1b2c3...'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '获取下载链接失败'
        });
    }
};

// 实际文件下载
exports.downloadFile = async (req, res) => {
    try {
        const fileName = req.params.fileName;
        const filePath = path.join(__dirname, '../../downloads', fileName);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({
                success: false,
                message: '文件不存在'
            });
        }
        
        res.download(filePath);
    } catch (error) {
        res.status(500).json({
            success: false,
            message: '下载失败'
        });
    }
};