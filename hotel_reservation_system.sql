-- hotel_reservation_system.sql
-- MySQL 8.x 酒店推荐预订管理系统数据库脚本

DROP DATABASE IF EXISTS hotel_reservation_system;
CREATE DATABASE hotel_reservation_system
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE hotel_reservation_system;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS room_types;
DROP TABLE IF EXISTS hotels;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. 用户表：普通用户和管理员共用
CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  username VARCHAR(50) NOT NULL COMMENT '用户名/昵称',
  phone VARCHAR(20) NOT NULL COMMENT '手机号，登录账号之一',
  email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  password_hash VARCHAR(255) NOT NULL COMMENT '加密后的密码，禁止存明文密码',
  role ENUM('CUSTOMER','ADMIN') NOT NULL DEFAULT 'CUSTOMER' COMMENT '用户角色：CUSTOMER普通用户，ADMIN管理员',
  status ENUM('NORMAL','DISABLED','CANCELLED') NOT NULL DEFAULT 'NORMAL' COMMENT '用户状态：NORMAL正常，DISABLED禁用，CANCELLED已注销',
  gender ENUM('MALE','FEMALE','UNKNOWN') NOT NULL DEFAULT 'UNKNOWN' COMMENT '性别',
  avatar_url VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
  last_login_time DATETIME DEFAULT NULL COMMENT '最后登录时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_phone (phone),
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表，普通用户和管理员共用';

-- 2. 酒店表
CREATE TABLE hotels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  hotel_name VARCHAR(100) NOT NULL COMMENT '酒店名称',
  hotel_type VARCHAR(50) NOT NULL COMMENT '酒店类型，如商务、度假、民宿',
  city VARCHAR(50) NOT NULL COMMENT '城市',
  address VARCHAR(255) NOT NULL COMMENT '详细地址',
  description TEXT COMMENT '酒店详细介绍',
  facilities JSON DEFAULT NULL COMMENT '酒店设施JSON，如停车场、WiFi、早餐',
  contact_phone VARCHAR(20) DEFAULT NULL COMMENT '酒店联系电话',
  cover_image_url VARCHAR(255) DEFAULT NULL COMMENT '酒店封面图片地址',
  rating DECIMAL(2,1) NOT NULL DEFAULT 0.0 COMMENT '综合评分，0.0到5.0',
  min_price DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '最低参考价格',
  is_reservable TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否可预订：1是，0否',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_hotels_city_type (city, hotel_type),
  KEY idx_hotels_name (hotel_name),
  KEY idx_hotels_rating (rating),
  KEY idx_hotels_price (min_price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='酒店表';

-- 3. 房型表
CREATE TABLE room_types (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  hotel_id BIGINT UNSIGNED NOT NULL COMMENT '所属酒店ID',
  room_type_name VARCHAR(100) NOT NULL COMMENT '房型名称，如大床房、双床房、套房',
  bed_type VARCHAR(50) DEFAULT NULL COMMENT '床型',
  capacity INT NOT NULL DEFAULT 1 COMMENT '可入住人数',
  total_rooms INT NOT NULL DEFAULT 0 COMMENT '该房型房间总数',
  available_rooms INT NOT NULL DEFAULT 0 COMMENT '当前可预订房间数，课程项目可先用此字段简化库存',
  price DECIMAL(10,2) NOT NULL COMMENT '每晚价格',
  breakfast_included TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否含早餐：1是，0否',
  description VARCHAR(500) DEFAULT NULL COMMENT '房型描述',
  status ENUM('AVAILABLE','UNAVAILABLE') NOT NULL DEFAULT 'AVAILABLE' COMMENT '房型状态',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_room_types_hotel_id (hotel_id),
  KEY idx_room_types_price (price),
  CONSTRAINT fk_room_types_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_room_types_rooms CHECK (total_rooms >= 0 AND available_rooms >= 0 AND available_rooms <= total_rooms),
  CONSTRAINT chk_room_types_price CHECK (price >= 0),
  CONSTRAINT chk_room_types_capacity CHECK (capacity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='房型表';

-- 4. 收藏表
CREATE TABLE collections (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  hotel_id BIGINT UNSIGNED NOT NULL COMMENT '酒店ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间/收藏时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_collections_user_hotel (user_id, hotel_id),
  KEY idx_collections_hotel_id (hotel_id),
  CONSTRAINT fk_collections_user_id FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_collections_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';

-- 5. 预订表
CREATE TABLE reservations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  reservation_no VARCHAR(32) NOT NULL COMMENT '订单编号',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '预订用户ID',
  hotel_id BIGINT UNSIGNED NOT NULL COMMENT '酒店ID',
  room_type_id BIGINT UNSIGNED NOT NULL COMMENT '房型ID',
  check_in_date DATE NOT NULL COMMENT '入住日期',
  check_out_date DATE NOT NULL COMMENT '离店日期',
  room_count INT NOT NULL DEFAULT 1 COMMENT '预订房间数',
  guest_count INT NOT NULL DEFAULT 1 COMMENT '入住人数',
  contact_name VARCHAR(50) NOT NULL COMMENT '联系人姓名',
  contact_phone VARCHAR(20) NOT NULL COMMENT '联系人手机号',
  total_amount DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
  status ENUM('PENDING_PAYMENT','PAID','CONFIRMED','CHECKED_IN','COMPLETED','CANCELLED','REJECTED','REFUNDING','REFUNDED') NOT NULL DEFAULT 'PENDING_PAYMENT' COMMENT '订单状态',
  remark VARCHAR(500) DEFAULT NULL COMMENT '用户备注',
  audit_admin_id BIGINT UNSIGNED DEFAULT NULL COMMENT '审核管理员ID',
  audit_time DATETIME DEFAULT NULL COMMENT '审核时间',
  audit_remark VARCHAR(500) DEFAULT NULL COMMENT '审核意见',
  cancel_time DATETIME DEFAULT NULL COMMENT '取消时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_reservations_no (reservation_no),
  KEY idx_reservations_user_id (user_id),
  KEY idx_reservations_hotel_id (hotel_id),
  KEY idx_reservations_room_type_id (room_type_id),
  KEY idx_reservations_status (status),
  KEY idx_reservations_dates (check_in_date, check_out_date),
  CONSTRAINT fk_reservations_user_id FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reservations_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reservations_room_type_id FOREIGN KEY (room_type_id) REFERENCES room_types(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_reservations_audit_admin_id FOREIGN KEY (audit_admin_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_reservations_date CHECK (check_out_date > check_in_date),
  CONSTRAINT chk_reservations_count CHECK (room_count > 0 AND guest_count > 0),
  CONSTRAINT chk_reservations_amount CHECK (total_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='预订表';

-- 6. 支付表
CREATE TABLE payments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  payment_no VARCHAR(32) NOT NULL COMMENT '支付流水号',
  reservation_id BIGINT UNSIGNED NOT NULL COMMENT '预订ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '支付用户ID',
  amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  payment_method ENUM('ALIPAY','WECHAT','BANK_CARD','SIMULATED') NOT NULL DEFAULT 'SIMULATED' COMMENT '支付方式',
  payment_status ENUM('UNPAID','PAID','REFUNDING','REFUNDED','FAILED') NOT NULL DEFAULT 'UNPAID' COMMENT '支付状态',
  paid_time DATETIME DEFAULT NULL COMMENT '支付成功时间',
  refund_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '退款金额',
  refund_time DATETIME DEFAULT NULL COMMENT '退款时间',
  transaction_no VARCHAR(64) DEFAULT NULL COMMENT '第三方交易号或模拟交易号',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_payments_no (payment_no),
  KEY idx_payments_reservation_id (reservation_id),
  KEY idx_payments_user_id (user_id),
  KEY idx_payments_status (payment_status),
  CONSTRAINT fk_payments_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservations(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_payments_user_id FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_payments_amount CHECK (amount >= 0 AND refund_amount >= 0 AND refund_amount <= amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付表';

-- 7. 评论表
CREATE TABLE posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '评论用户ID',
  hotel_id BIGINT UNSIGNED NOT NULL COMMENT '酒店ID',
  reservation_id BIGINT UNSIGNED DEFAULT NULL COMMENT '关联订单ID，入住完成后评论时使用',
  title VARCHAR(100) DEFAULT NULL COMMENT '评论标题',
  content TEXT NOT NULL COMMENT '评论内容',
  score INT NOT NULL COMMENT '评分，1到5',
  audit_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING' COMMENT '评论审核状态',
  audit_admin_id BIGINT UNSIGNED DEFAULT NULL COMMENT '审核管理员ID',
  audit_time DATETIME DEFAULT NULL COMMENT '审核时间',
  audit_remark VARCHAR(500) DEFAULT NULL COMMENT '审核意见',
  is_deleted TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否删除：1是，0否',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间/发布时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_posts_user_id (user_id),
  KEY idx_posts_hotel_id (hotel_id),
  KEY idx_posts_reservation_id (reservation_id),
  KEY idx_posts_audit_status (audit_status),
  CONSTRAINT fk_posts_user_id FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_posts_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_posts_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservations(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_posts_audit_admin_id FOREIGN KEY (audit_admin_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_posts_score CHECK (score BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='评论表';

-- 8. 通知表
CREATE TABLE notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '接收用户ID',
  reservation_id BIGINT UNSIGNED DEFAULT NULL COMMENT '关联预订ID',
  notification_type ENUM('RESERVATION_SUCCESS','PAYMENT_SUCCESS','ORDER_CANCELLED','REFUND_PROCESSING','REFUND_SUCCESS','POST_APPROVED','POST_REJECTED','SYSTEM','ORDER_CREATED','PAY_SUCCESS','ORDER_CONFIRMED','CHECKIN_REMINDER') NOT NULL DEFAULT 'SYSTEM' COMMENT '通知类型',
  channel ENUM('APP','SMS','EMAIL') NOT NULL DEFAULT 'APP' COMMENT '通知渠道',
  title VARCHAR(100) NOT NULL COMMENT '通知标题',
  content TEXT NOT NULL COMMENT '通知内容',
  status ENUM('UNREAD','READ') NOT NULL DEFAULT 'UNREAD' COMMENT '通知状态',
  read_time DATETIME DEFAULT NULL COMMENT '阅读时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间/发送时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_notifications_user_status (user_id, status),
  KEY idx_notifications_reservation_id (reservation_id),
  KEY idx_notifications_type (notification_type),
  CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_notifications_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservations(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='通知表';

-- 基础测试数据
INSERT INTO users
(id, username, phone, email, password_hash, role, status, gender)
VALUES
(1, '系统管理员', '13800000000', 'admin@example.com', '$2a$10$example_admin_hash', 'ADMIN', 'NORMAL', 'UNKNOWN'),
(2, '张三', '13900000001', 'zhangsan@example.com', '$2a$10$example_customer_hash', 'CUSTOMER', 'NORMAL', 'MALE'),
(3, '李四', '13900000002', 'lisi@example.com', '$2a$10$example_customer_hash', 'CUSTOMER', 'NORMAL', 'FEMALE');

INSERT INTO hotels
(id, hotel_name, hotel_type, city, address, description, facilities, contact_phone, cover_image_url, rating, min_price, is_reservable)
VALUES
(1, '杭州西湖湖景酒店', '度假', '杭州', '杭州市西湖区北山街1号', '靠近西湖景区，适合旅游入住。', JSON_ARRAY('免费WiFi','停车场','早餐','湖景房'), '0571-88880001', 'images/hangzhou_xihu.jpg', 4.8, 399.00, 1),
(2, '上海外滩商务酒店', '商务', '上海', '上海市黄浦区中山东一路88号', '靠近外滩和地铁站，适合商务出行。', JSON_ARRAY('免费WiFi','会议室','健身房'), '021-66660001', 'images/shanghai_waitan.jpg', 4.6, 499.00, 1),
(3, '紫峰大厦城市酒店', '商务', '南京', '南京市鼓楼区中山北路1号', '位于城市中心，交通便利。', JSON_ARRAY('免费WiFi','停车场','餐厅'), '025-55550001', 'images/zijin_tower.jpg', 4.5, 359.00, 1),
(4, '北京三里屯洲际酒店', '高档', '北京', '北京市朝阳区三里屯路1号', '潮流商圈核心，购物餐饮一应俱全。', JSON_ARRAY('免费WiFi','健身房','餐厅'), '010-65918888', 'images/beijing.jpg', 4.8, 899.00, 1),
(5, '广州珠江新城W酒店', '豪华', '广州', '广州市天河区珠江新城', '珠江新城CBD，现代设计感十足。', JSON_ARRAY('免费WiFi','泳池','餐厅'), '020-66288888', 'images/guangzhou.jpg', 4.8, 1188.00, 1),
(6, '深圳湾安达仕酒店', '高档', '深圳', '深圳市南山区科苑南路2600号', '深圳湾一线海景，品质住宿体验。', JSON_ARRAY('免费WiFi','海景房','早餐'), '0755-88889999', 'images/shenzhen.jpg', 4.6, 988.00, 1);

-- 清理测试脏数据（若服务器上存在）
-- DELETE FROM hotels WHERE hotel_name IN ('测试酒店', '无登录头');

INSERT INTO room_types
(id, hotel_id, room_type_name, bed_type, capacity, total_rooms, available_rooms, price, breakfast_included, description, status)
VALUES
(1, 1, '湖景大床房', '1张大床', 2, 20, 15, 399.00, 1, '可观看西湖景色', 'AVAILABLE'),
(2, 1, '家庭套房', '1张大床+1张单人床', 3, 10, 6, 699.00, 1, '适合家庭入住', 'AVAILABLE'),
(3, 2, '商务大床房', '1张大床', 2, 30, 22, 499.00, 1, '商务出行优选', 'AVAILABLE'),
(4, 3, '标准双床房', '2张单人床', 2, 25, 18, 359.00, 0, '经济舒适', 'AVAILABLE');

INSERT INTO collections
(id, user_id, hotel_id)
VALUES
(1, 2, 1),
(2, 2, 2),
(3, 3, 1);

INSERT INTO reservations
(id, reservation_no, user_id, hotel_id, room_type_id, check_in_date, check_out_date, room_count, guest_count, contact_name, contact_phone, total_amount, status, audit_admin_id, audit_time, audit_remark)
VALUES
(1, 'R202512010001', 2, 1, 1, '2025-12-20', '2025-12-22', 1, 2, '张三', '13900000001', 798.00, 'PAID', 1, '2025-12-01 10:30:00', '订单信息正常'),
(2, 'R202512010002', 3, 2, 3, '2025-12-24', '2025-12-25', 1, 1, '李四', '13900000002', 499.00, 'PENDING_PAYMENT', NULL, NULL, NULL);

INSERT INTO payments
(id, payment_no, reservation_id, user_id, amount, payment_method, payment_status, paid_time, refund_amount, transaction_no)
VALUES
(1, 'P202512010001', 1, 2, 798.00, 'SIMULATED', 'PAID', '2025-12-01 10:10:00', 0.00, 'SIM202512010001'),
(2, 'P202512010002', 2, 3, 499.00, 'SIMULATED', 'UNPAID', NULL, 0.00, NULL);

INSERT INTO posts
(id, user_id, hotel_id, reservation_id, title, content, score, audit_status, audit_admin_id, audit_time, audit_remark, is_deleted)
VALUES
(1, 2, 1, 1, '位置很好', '酒店离西湖很近，房间干净，服务也不错。', 5, 'APPROVED', 1, '2025-12-03 09:00:00', '内容正常', 0),
(2, 3, 2, NULL, '想了解早餐', '请问早餐几点开始？', 4, 'PENDING', NULL, NULL, NULL, 0);

INSERT INTO notifications
(id, user_id, reservation_id, notification_type, channel, title, content, status)
VALUES
(1, 2, 1, 'RESERVATION_SUCCESS', 'APP', '预订成功', '您的杭州西湖湖景酒店订单已提交成功。', 'READ'),
(2, 2, 1, 'PAYMENT_SUCCESS', 'APP', '支付成功', '您的订单已模拟支付成功，金额798.00元。', 'UNREAD'),
(3, 3, 2, 'SYSTEM', 'APP', '待支付提醒', '您的订单尚未支付，请及时处理。', 'UNREAD');

-- 推荐的建表执行顺序：
-- users -> hotels -> room_types -> collections -> reservations -> payments -> posts -> notifications
