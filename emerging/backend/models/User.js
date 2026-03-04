const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        minlength: 3,
        maxlength: 30
    },
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    avatar: {
        type: String,
        default: '/static/images/default-avatar.png'
    },
    role: {
        type: String,
        enum: ['user', 'contributor', 'admin'],
        default: 'user'
    },
    bio: {
        type: String,
        maxlength: 500
    },
    website: String,
    github: String,
    twitter: String,
    location: String,
    company: String,
    emailVerified: {
        type: Boolean,
        default: false
    },
    emailVerificationToken: String,
    passwordResetToken: String,
    passwordResetExpires: Date,
    lastLogin: Date,
    loginCount: {
        type: Number,
        default: 0
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// 索引
userSchema.index({ username: 1 });
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });

// 虚拟字段
userSchema.virtual('isAdmin').get(function() {
    return this.role === 'admin';
});

userSchema.virtual('isContributor').get(function() {
    return ['contributor', 'admin'].includes(this.role);
});

// 方法：返回公开信息
userSchema.methods.toPublicJSON = function() {
    return {
        id: this._id,
        username: this.username,
        avatar: this.avatar,
        bio: this.bio,
        role: this.role,
        createdAt: this.createdAt
    };
};

// 方法：返回私有信息（供用户自己查看）
userSchema.methods.toPrivateJSON = function() {
    return {
        id: this._id,
        username: this.username,
        email: this.email,
        avatar: this.avatar,
        bio: this.bio,
        role: this.role,
        website: this.website,
        github: this.github,
        twitter: this.twitter,
        location: this.location,
        company: this.company,
        emailVerified: this.emailVerified,
        lastLogin: this.lastLogin,
        createdAt: this.createdAt
    };
};

const User = mongoose.model('User', userSchema);

module.exports = User;