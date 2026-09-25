-- Script tự động khởi tạo bảng và dữ liệu mẫu khi MySQL khởi động lần đầu
USE demo_db;

-- 1. Tạo bảng mẫu người dùng
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'tester',
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Chèn dữ liệu kiểm thử (Seed Data) cho QC kiểm tra ngay
INSERT INTO users (username, full_name, email, role, status) VALUES
('admin_qc', 'Quản Trị Viên Test', 'admin.qc@example.com', 'admin', 'active'),
('tester01', 'Nguyễn Văn QC', 'tester01@example.com', 'tester', 'active'),
('test_user_locked', 'Tài Khoản Khóa', 'locked@example.com', 'user', 'inactive')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);
