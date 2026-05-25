/**
 * API 请求封装。基址来自 js/config.js 中的 window.API_HOST
 */
const API_BASE = (!window.API_HOST || window.API_HOST === '/')
    ? '/api'
    : window.API_HOST.replace(/\/$/, '') + '/api';

/** 本地演示图片映射（与数据库酒店 id 对应） */
const HOTEL_IMAGES = {
    1: '杭州西湖.jpg',
    2: '上海外滩.jpg',
    3: '紫峰大厦.jpg'
};

function hotelImage(hotelId) {
    return HOTEL_IMAGES[hotelId] || '杭州西湖.jpg';
}

function saveLoginUser(data) {
    localStorage.setItem('userId', data.userId);
    localStorage.setItem('username', data.username || '');
    localStorage.setItem('phone', data.phone || '');
    localStorage.setItem('role', data.role || 'CUSTOMER');
}

function clearLoginUser() {
    localStorage.removeItem('userId');
    localStorage.removeItem('username');
    localStorage.removeItem('phone');
    localStorage.removeItem('role');
}

function getAuthHeaders() {
    const userId = localStorage.getItem('userId');
    const headers = { 'Content-Type': 'application/json' };
    if (userId) {
        headers['X-User-Id'] = userId;
    }
    return headers;
}

async function apiGet(path) {
    const res = await fetch(API_BASE + path);
    return res.json();
}

async function apiGetAuth(path) {
    const res = await fetch(API_BASE + path, { headers: getAuthHeaders() });
    return res.json();
}

async function apiPost(path, body) {
    const res = await fetch(API_BASE + path, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify(body)
    });
    return res.json();
}

async function apiPut(path, body) {
    const res = await fetch(API_BASE + path, {
        method: 'PUT',
        headers: getAuthHeaders(),
        body: body ? JSON.stringify(body) : undefined
    });
    return res.json();
}

async function apiDelete(path) {
    const res = await fetch(API_BASE + path, {
        method: 'DELETE',
        headers: getAuthHeaders()
    });
    return res.json();
}

function formatDateTime(s) {
    if (!s) return '';
    return String(s).replace('T', ' ').substring(0, 16);
}

function getQueryParam(name) {
    return new URLSearchParams(window.location.search).get(name);
}

function requireLogin() {
    if (!localStorage.getItem('userId')) {
        alert('请先登录');
        const redirect = location.pathname.split('/').pop() + location.search;
        location.href = 'signin.html?redirect=' + encodeURIComponent(redirect);
        return false;
    }
    return true;
}

function requireAdmin() {
    if (!requireLogin()) return false;
    if (localStorage.getItem('role') !== 'ADMIN') {
        alert('请使用管理员账号登录');
        location.href = 'adminSignin.html';
        return false;
    }
    return true;
}

const RESERVATION_STATUS = {
    PENDING_PAYMENT: { text: '待付款', color: '#dc2626' },
    PAID: { text: '已支付', color: '#2563eb' },
    CONFIRMED: { text: '已确认', color: '#2563eb' },
    CHECKED_IN: { text: '已入住', color: '#0891b2' },
    COMPLETED: { text: '已完成', color: '#22c55e' },
    CANCELLED: { text: '已取消', color: '#6b7280' },
    REJECTED: { text: '已驳回', color: '#dc2626' },
    REFUNDING: { text: '退款中', color: '#f97316' },
    REFUNDED: { text: '已退款', color: '#6b7280' }
};

function reservationStatusText(status) {
    return (RESERVATION_STATUS[status] || { text: status }).text;
}

function reservationStatusColor(status) {
    return (RESERVATION_STATUS[status] || { color: '#64748b' }).color;
}

const POST_AUDIT_STATUS = {
    PENDING: { text: '待审核', color: '#f97316' },
    APPROVED: { text: '已通过', color: '#22c55e' },
    REJECTED: { text: '已驳回', color: '#dc2626' }
};

function postAuditText(status) {
    return (POST_AUDIT_STATUS[status] || { text: status }).text;
}

function userRoleText(role) {
    if (role === 'ADMIN') return '管理员';
    if (role === 'CUSTOMER') return '普通用户';
    return role || '-';
}

function userStatusText(status) {
    if (status === 'NORMAL') return '正常';
    if (status === 'DISABLED') return '已禁用';
    if (status === 'CANCELLED') return '已注销';
    return status || '-';
}

const PAYMENT_STATUS = {
    UNPAID: { text: '待支付', color: '#dc2626' },
    PAID: { text: '已支付', color: '#2563eb' },
    REFUNDING: { text: '退款中', color: '#f97316' },
    REFUNDED: { text: '已退款', color: '#6b7280' },
    FAILED: { text: '失败', color: '#dc2626' }
};

function paymentStatusText(status) {
    return (PAYMENT_STATUS[status] || { text: status }).text;
}
