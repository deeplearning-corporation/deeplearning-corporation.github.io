// NetWorld 官方网站

document.addEventListener('DOMContentLoaded', function() {
    initStats();
    initDownload();
    initSmoothScroll();
});

// 统计数据
const stats = {
    downloads: 12345,
    players: 8901,
    rating: 4.8
};

function initStats() {
    document.getElementById('downloadCount').textContent = stats.downloads.toLocaleString();
    document.getElementById('playerCount').textContent = stats.players.toLocaleString();
    document.getElementById('avgRating').textContent = stats.rating;
}

// 下载功能
function downloadGame() {
    showNotification('⏳ 开始下载 game.zip...');
    
    // 模拟下载
    setTimeout(() => {
        // 实际下载链接
        const link = document.createElement('a');
        link.href = 'downloads/game.zip';
        link.download = 'game.zip';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        showNotification('✅ 下载完成！感谢支持', 'success');
        
        // 更新下载计数
        stats.downloads++;
        document.getElementById('downloadCount').textContent = stats.downloads.toLocaleString();
    }, 1000);
}

// Java帮助
function showJavaHelp() {
    showNotification('☕ 请访问 adoptium.net 下载 Java 17', 'info');
    window.open('https://adoptium.net/', '_blank');
}

// 通知系统
function showNotification(message, type = 'info') {
    const notification = document.getElementById('notification');
    notification.style.display = 'block';
    notification.textContent = message;
    notification.style.backgroundColor = type === 'success' ? '#4CAF50' : '#2196F3';
    
    setTimeout(() => {
        notification.style.display = 'none';
    }, 3000);
}

// 平滑滚动
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
}

// 导航栏激活状态
window.addEventListener('scroll', function() {
    const sections = document.querySelectorAll('section');
    const navLinks = document.querySelectorAll('.nav-menu a');
    
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop - 100;
        if (pageYOffset >= sectionTop) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === '#' + current) {
            link.classList.add('active');
        }
    });
});