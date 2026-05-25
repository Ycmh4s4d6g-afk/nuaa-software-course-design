/**
 * 前端 API 地址配置（部署时修改 DEFAULT_HOST 即可）
 *
 * 本地：http://localhost:8080
 * 服务器：http://你的服务器IP:8080
 *
 * 临时调试：localStorage.setItem('API_HOST', 'http://x.x.x.x:8080'); location.reload();
 */
(function () {
    // 服务器部署（当前项目使用腾讯云 111.229.171.161）
    var DEFAULT_HOST = 'http://111.229.171.161:8080';
    // 本地开发时改为：var DEFAULT_HOST = 'http://localhost:8080';
    var fromStorage = localStorage.getItem('API_HOST');
    window.API_HOST = fromStorage || window.API_HOST || DEFAULT_HOST;
})();
