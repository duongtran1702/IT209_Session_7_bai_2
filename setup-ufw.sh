#!/bin/bash
# ==============================================================================
# Script Name : setup-ufw.sh
# Description : Cau hinh tuong lua UFW cho cum dich vu da cong (Multi-port)
# Author      : Trần Trí Dương (duongtran1702)
# Student ID  : duongtran1702 | Email: duong170226@gmail.com
# Course      : IT209 - Session 07 - Bai tap 2
# ==============================================================================

set -euo pipefail

echo "========================================================================"
echo " [BÀI 2] THIẾT LẬP VÀ QUẢN TRỊ TƯỜNG LỬA UFW CHO CỤM DỊCH VỤ MULTI-PORT"
echo "========================================================================"

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Kịch bản này cần được chạy với quyền root (sudo)." >&2
   exit 1
fi

# 1. Cài đặt ufw nếu chưa có
if ! command -v ufw &>/dev/null; then
    echo "[INFO] Đang cài đặt gói ufw..."
    apt-get update -y && apt-get install -y ufw
fi

# 2. Đặt lại cấu hình UFW về trạng thái ban đầu để tránh luật rác (tùy chọn)
echo "[INFO] Đặt lại các quy tắc UFW mặc định..."
ufw --force reset

# 3. Khai báo các chính sách mặc định (Default Policies)
# Chặn toàn bộ lưu lượng đi vào hệ thống (Inbound traffic)
echo "[INFO] Thiết lập chính sách: Deny incoming traffic..."
ufw default deny incoming

# Cho phép toàn bộ lưu lượng từ hệ thống đi ra ngoài (Outbound traffic)
echo "[INFO] Thiết lập chính sách: Allow outgoing traffic..."
ufw default allow outgoing

# 4. Cấu hình mở các cổng dịch vụ theo yêu cầu
# Cổng 22/tcp: SSH để quản trị từ xa (Bắt buộc mở đầu tiên để tránh bị khóa ngoài - Lockout)
echo "[INFO] Cho phép cổng 22/tcp (SSH)..."
ufw allow 22/tcp comment 'SSH Remote Administration'

# Cổng 80/tcp: Nginx Web Server phục vụ web tĩnh & reverse proxy
echo "[INFO] Cho phép cổng 80/tcp (HTTP Web)..."
ufw allow 80/tcp comment 'Nginx HTTP Web Service'

# Cổng 8082/tcp: Ứng dụng Spring Boot
echo "[INFO] Cho phép cổng 8082/tcp (Spring Boot App)..."
ufw allow 8082/tcp comment 'Spring Boot Application Direct Access'

# LƯU Ý BẢO MẬT: Cổng 3306/tcp (MySQL) KHÔNG ĐƯỢC MỞ CHO INTERNET.
# MySQL chỉ được phép lắng nghe nội bộ 127.0.0.1 hoặc trong mạng riêng.
echo "[SECURITY] Cổng 3306/tcp (MySQL Database) KHÔNG được thêm vào danh sách allow."
echo "           Lưu lượng từ Internet tới cổng 3306 sẽ bị DROP/DENY bởi chính sách mặc định."

# 5. Kích hoạt tường lửa UFW
echo "[INFO] Đang kích hoạt tường lửa UFW..."
ufw --force enable

# 6. Kiểm tra trạng thái tường lửa chi tiết
echo "========================================================================"
echo " [KIỂM TRA HOÀN TẤT - sudo ufw status verbose]"
echo "========================================================================"
ufw status verbose

echo "========================================================================"
echo " [DANH SÁCH QUY TẮC ĐƯỢC ĐÁNH SỐ - sudo ufw status numbered]"
echo "========================================================================"
ufw status numbered
