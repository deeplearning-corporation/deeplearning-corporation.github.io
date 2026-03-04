const mongoose = require('mongoose');

const downloadSchema = new mongoose.Schema({
    platform: {
        type: String,
        required: true,
        enum: ['windows', 'linux', 'macos', 'source']
    },
    version: {
        type: String,
        required: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    ip: String,
    userAgent: String,
    country: String,
    city: String,
    referer: String,
    date: {
        type: Date,
        default: Date.now,
        required: true
    },
    success: {
        type: Boolean,
        default: true
    },
    fileSize: Number,
    downloadSpeed: Number,
    downloadTime: Number
}, {
    timestamps: true
});

// 索引
downloadSchema.index({ date: -1 });
downloadSchema.index({ platform: 1, date: -1 });
downloadSchema.index({ version: 1 });
downloadSchema.index({ userId: 1 });

// 统计方法
downloadSchema.statics.getDailyStats = async function(days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    
    return this.aggregate([
        {
            $match: {
                date: { $gte: startDate }
            }
        },
        {
            $group: {
                _id: {
                    year: { $year: "$date" },
                    month: { $month: "$date" },
                    day: { $dayOfMonth: "$date" },
                    platform: "$platform"
                },
                count: { $sum: 1 }
            }
        },
        {
            $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
        }
    ]);
};

downloadSchema.statics.getPlatformStats = async function() {
    return this.aggregate([
        {
            $group: {
                _id: "$platform",
                count: { $sum: 1 },
                lastDownload: { $max: "$date" }
            }
        }
    ]);
};

downloadSchema.statics.getVersionStats = async function() {
    return this.aggregate([
        {
            $group: {
                _id: "$version",
                count: { $sum: 1 }
            }
        },
        {
            $sort: { count: -1 }
        }
    ]);
};

const Download = mongoose.model('Download', downloadSchema);

module.exports = Download;