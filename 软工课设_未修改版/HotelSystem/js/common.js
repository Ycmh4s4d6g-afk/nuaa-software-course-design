/**
 * 酒店推荐预订系统 - 统一导航与页脚
 * body 设置 data-nav 和 data-page-title 可覆盖默认
 */
(function () {
    var NAV = {
        public: [
            { href: 'index.html', label: '首页' },
            { href: 'hotelList.html', label: '查找酒店' },
            { href: 'reservationList.html', label: '我的预订' },
            { href: 'collectionList.html', label: '收藏夹' },
            { href: 'listPost.html', label: '评论' },
            { href: 'signin.html', label: '登录 / 注册', cls: 'nav-auth' },
            { href: 'adminSignin.html', label: '管理员入口' }
        ],
        user: [
            { href: 'index.html', label: '首页' },
            { href: 'customerIndex.html', label: '用户中心' },
            { href: 'hotelList.html', label: '查找酒店' },
            { href: 'reservationList.html', label: '我的预订' },
            { href: 'collectionList.html', label: '收藏夹' },
            { href: 'notificationList.html', label: '通知' },
            { href: 'listPost.html', label: '评论' },
            { href: 'signin.html', label: '退出登录' }
        ],
        admin: [
            { href: 'adminIndex.html', label: '后台首页' },
            { href: 'manageUser.html', label: '用户管理' },
            { href: 'manageHotel.html', label: '酒店管理' },
            { href: 'manageReservation.html', label: '订单管理' },
            { href: 'managePost.html', label: '评论管理' },
            { href: 'managePayment.html', label: '支付管理' },
            { href: 'manageCollection.html', label: '收藏管理' },
            { href: 'manageNotification.html', label: '通知管理' },
            { href: 'index.html', label: '前台首页' },
            { href: 'adminSignin.html', label: '退出登录' }
        ],
        auth: [
            { href: 'index.html', label: '首页' },
            { href: 'hotelList.html', label: '查找酒店' },
            { href: 'signin.html', label: '登录' },
            { href: 'signupCustomer.html', label: '注册' }
        ],
        minimal: [
            { href: 'index.html', label: '返回首页' }
        ]
    };

    var PAGE_NAV = {
        'index.html': 'public',
        'hotelList.html': 'public',
        'hotelDetail.html': 'public',
        'signin.html': 'auth',
        'signupCustomer.html': 'auth',
        'forgetPassword.html': 'auth',
        'adminSignin.html': 'minimal',
        'customerIndex.html': 'user',
        'getUserInfo.html': 'user',
        'changeUserInfo.html': 'user',
        'changePassword.html': 'user',
        'cancelUser.html': 'user',
        'reservationList.html': 'user',
        'reservationDetail.html': 'user',
        'editReservation.html': 'user',
        'createReservation.html': 'user',
        'createPayment.html': 'user',
        'paymentResult.html': 'user',
        'refundApply.html': 'user',
        'collectionList.html': 'user',
        'cancelCollection.html': 'user',
        'notificationList.html': 'user',
        'listPost.html': 'user',
        'displayPost.html': 'user',
        'editPost.html': 'user',
        'addPost.html': 'user',
        'adminIndex.html': 'admin',
        'manageUser.html': 'admin',
        'manageHotel.html': 'admin',
        'addHotel.html': 'admin',
        'editHotel.html': 'admin',
        'deleteHotel.html': 'admin',
        'manageRoomTypes.html': 'admin',
        'addRoomType.html': 'admin',
        'editRoomType.html': 'admin',
        'manageReservation.html': 'admin',
        'auditReservation.html': 'admin',
        'managePost.html': 'admin',
        'auditPost.html': 'admin',
        'deletePost.html': 'admin',
        'managePayment.html': 'admin',
        'manageNotification.html': 'admin',
        'manageCollection.html': 'admin'
    };

    var PAGE_TITLE = {
        'index.html': '酒店推荐预订系统',
        'hotelList.html': '酒店列表',
        'hotelDetail.html': '酒店详情',
        'signin.html': '用户登录',
        'signupCustomer.html': '用户注册',
        'forgetPassword.html': '找回密码',
        'adminSignin.html': '管理员登录',
        'customerIndex.html': '用户中心',
        'getUserInfo.html': '个人信息',
        'changeUserInfo.html': '修改资料',
        'changePassword.html': '修改密码',
        'cancelUser.html': '注销账户',
        'reservationList.html': '我的预订',
        'reservationDetail.html': '订单详情',
        'editReservation.html': '编辑预订',
        'createReservation.html': '创建预订',
        'createPayment.html': '支付订单',
        'paymentResult.html': '支付结果',
        'refundApply.html': '退款申请',
        'collectionList.html': '我的收藏',
        'cancelCollection.html': '取消收藏',
        'notificationList.html': '我的通知',
        'listPost.html': '评论中心',
        'displayPost.html': '评论详情',
        'editPost.html': '编辑评论',
        'addPost.html': '发布评论',
        'adminIndex.html': '管理后台',
        'manageUser.html': '用户管理',
        'manageHotel.html': '酒店管理',
        'addHotel.html': '新增酒店',
        'editHotel.html': '编辑酒店',
        'deleteHotel.html': '删除酒店',
        'manageRoomTypes.html': '房型管理',
        'addRoomType.html': '添加房型',
        'editRoomType.html': '编辑房型',
        'manageReservation.html': '订单管理',
        'auditReservation.html': '审核订单',
        'managePost.html': '评论管理',
        'auditPost.html': '审核评论',
        'deletePost.html': '删除评论',
        'managePayment.html': '支付管理',
        'manageNotification.html': '通知管理',
        'manageCollection.html': '收藏管理'
    };

    function currentFile() {
        var path = window.location.pathname;
        return path.substring(path.lastIndexOf('/') + 1) || 'index.html';
    }

    function buildHeader(navType, pageTitle) {
        var items = NAV[navType] || NAV.public;
        var isAdmin = navType === 'admin';
        var links = items.map(function (item) {
            var active = currentFile() === item.href ? ' active' : '';
            var cls = item.cls ? ' ' + item.cls : '';
            return '<a href="' + item.href + '" class="' + cls.trim() + active + '">' + item.label + '</a>';
        }).join('');

        return (
            '<div class="site-header' + (isAdmin ? ' admin' : '') + '" role="banner">' +
            '<div class="logo"><span>🏨</span><div>' + pageTitle + '</div></div>' +
            '<nav>' + links + '</nav>' +
            '</div>'
        );
    }

    function buildFooter() {
        return '<footer class="site-footer">酒店推荐预订系统 · 为您提供便捷的酒店预订服务</footer>';
    }

    function resolveNavType(body, file) {
        var explicit = body.getAttribute('data-nav');
        if (explicit) return explicit;
        var mapped = PAGE_NAV[file] || 'public';
        if (mapped === 'public' || mapped === 'auth') {
            var role = localStorage.getItem('role');
            var userId = localStorage.getItem('userId');
            if (userId && role === 'ADMIN') return 'admin';
            if (userId) return 'user';
        }
        return mapped;
    }

    function logoutUser() {
        localStorage.removeItem('userId');
        localStorage.removeItem('username');
        localStorage.removeItem('phone');
        localStorage.removeItem('role');
    }

    function bindLogout() {
        document.querySelectorAll('.site-header nav a').forEach(function (a) {
            if (a.textContent.indexOf('退出登录') >= 0) {
                a.addEventListener('click', function (e) {
                    e.preventDefault();
                    logoutUser();
                    location.href = 'signin.html';
                });
            }
        });
    }

    function init() {
        var body = document.body;
        var file = currentFile();
        var navType = resolveNavType(body, file);
        var pageTitle = body.getAttribute('data-page-title') || PAGE_TITLE[file] || '酒店推荐预订系统';

        var oldHeader = document.querySelector('.site-header') || document.querySelector('header');
        if (oldHeader) oldHeader.remove();

        var oldFooter = document.querySelector('footer');
        if (oldFooter) oldFooter.remove();

        body.insertAdjacentHTML('afterbegin', buildHeader(navType, pageTitle));
        body.insertAdjacentHTML('beforeend', buildFooter());
        bindLogout();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
