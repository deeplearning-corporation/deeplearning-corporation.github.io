// 移动端菜单
document.addEventListener('DOMContentLoaded', function() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const navMenu = document.querySelector('.nav-menu');

    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', function() {
            navMenu.classList.toggle('active');
        });
    }

    // 点击菜单项后关闭菜单
    const navLinks = document.querySelectorAll('.nav-menu a');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
        });
    });

    // 代码标签页切换
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabPanels = document.querySelectorAll('.tab-panel');

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            // 移除所有active类
            tabBtns.forEach(b => b.classList.remove('active'));
            tabPanels.forEach(p => p.classList.remove('active'));

            // 添加active类到当前按钮
            btn.classList.add('active');

            // 显示对应的面板
            const tabId = btn.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });

    // 复制命令到剪贴板
    window.copyToClipboard = function(text) {
        navigator.clipboard.writeText(text).then(() => {
            const btn = event.currentTarget;
            const originalText = btn.innerHTML;
            btn.innerHTML = '<i class="fas fa-check"></i> 已复制';
            setTimeout(() => {
                btn.innerHTML = originalText;
            }, 2000);
        }).catch(err => {
            console.error('复制失败:', err);
        });
    };

    // 滚动时导航栏样式变化
    window.addEventListener('scroll', () => {
        const navbar = document.querySelector('.navbar');
        if (window.scrollY > 50) {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.backgroundColor = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.1)';
        }
    });

    // 统计数字动画
    const stats = document.querySelectorAll('.stat-number');
    if (stats.length > 0) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateNumber(entry.target);
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });

        stats.forEach(stat => observer.observe(stat));
    }

    function animateNumber(element) {
        const target = parseInt(element.innerText.replace(/[^0-9]/g, ''));
        const suffix = element.innerText.replace(/[0-9]/g, '');
        let current = 0;
        const increment = target / 50;
        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                element.innerText = target + suffix;
                clearInterval(timer);
            } else {
                element.innerText = Math.floor(current) + suffix;
            }
        }, 20);
    }

    // 平滑滚动
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});