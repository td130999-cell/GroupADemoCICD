# Sử dụng Nginx Alpine nhẹ (chỉ khoảng 20MB)
FROM nginx:alpine

# Copy mã nguồn HTML vào thư mục web root của Nginx
COPY index.html /usr/share/nginx/html/index.html

# Mở cổng 80
EXPOSE 80

# Chạy Nginx
CMD ["nginx", "-g", "daemon off;"]