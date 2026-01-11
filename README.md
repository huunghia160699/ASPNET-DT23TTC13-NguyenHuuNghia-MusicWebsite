# 🎵 HN-Melody – Website Nghe Nhạc Trực Tuyến

<div align="center">

![ASP.NET](https://img.shields.io/badge/ASP.NET-WebForms-512bd4?style=flat-square&logo=dotnet)
![SQL Server](https://img.shields.io/badge/Database-SQL_Server-red?style=flat-square&logo=microsoftsqlserver)
![JavaScript](https://img.shields.io/badge/Frontend-Vanilla_JS-yellow?style=flat-square&logo=javascript)

**HN-Melody** là website nghe nhạc trực tuyến được xây dựng bằng **ASP.NET WebForms**, tập trung tối ưu hóa trải nghiệm người dùng thông qua kỹ thuật **AJAX** (không reload trang) và giao diện hiện đại.

</div>

---

## 📑 Mục Lục

- [Giới Thiệu](#-giới-thiệu)
- [Chức Năng Chính](#-chức-năng-chính)
- [Kỹ Thuật Nổi Bật](#-kỹ-thuật-nổi-bật)
- [Cài Đặt & Chạy Dự Án](#-cài-đặt--chạy-dự-án)
- [Tác Giả](#-tác-giả)

---

## 📖 Giới Thiệu

HN-Melody là đồ án môn Chuyên đề ASP.NET, mô phỏng các chức năng cốt lõi của một nền tảng nghe nhạc số.
Hệ thống khắc phục nhược điểm "tải lại trang" (Postback) truyền thống của WebForms bằng cách sử dụng **WebMethod** kết hợp **Fetch API**, mang lại trải nghiệm mượt mà tương tự các ứng dụng Single Page Application (SPA).

### 🎯 Mục tiêu đồ án

- Áp dụng kiến thức **ASP.NET WebForms** và **ADO.NET**.
- Xử lý bất đồng bộ (**AJAX**) để nghe nhạc liên tục.
- Quản lý dữ liệu tập trung bằng **SQL Server**.
- Rèn luyện tư duy thuật toán với **JavaScript thuần**.

---

## 🚀 Chức Năng Chính

### 🎧 Dành Cho Người Dùng (User)

- **Trình phát nhạc (Player):**
  - Đầy đủ tính năng: Play, Pause, Next, Previous, Random (Ngẫu nhiên), Repeat (Lặp lại).
  - Thanh tiến trình (Seek): Tua nhạc mượt mà.
  - Tự động chuyển bài khi kết thúc.
- **Danh sách bài hát:**
  - Hiển thị danh sách bài hát với ảnh bìa xoay (Animation).
  - Hiệu ứng sóng nhạc (Visualizer) khi bài hát đang phát.
- **Tìm kiếm (Live Search):** Tìm kiếm bài hát/nghệ sĩ ngay lập tức không cần chuyển trang.
- **Yêu thích (Favorites):** Thả tim để lưu bài hát vào danh sách cá nhân (Yêu cầu đăng nhập).
- **Hệ thống tài khoản:** Đăng ký, Đăng nhập, Ghi nhớ phiên làm việc.

### 🛠️ Dành Cho Quản Trị Viên (Admin)

- **Dashboard:** Giao diện quản trị riêng biệt.
- **Quản lý Bài hát:** Thêm mới, cập nhật thông tin, xóa bài hát.
- **Quản lý Nghệ sĩ:** Thêm/Sửa/Xóa thông tin nghệ sĩ.
- **Phân quyền:** Bảo mật trang Admin, chỉ tài khoản Role 'Admin' mới truy cập được.

---

## 🏗 Kỹ Thuật Nổi Bật

Dự án không sử dụng các thư viện có sẵn (như jQuery hay Bootstrap JS) mà tập trung vào **Code thuần** để tối ưu hiệu năng:

1.  **Backend (ASP.NET):**
    - Sử dụng **WebMethod (Static)** để tạo API nội bộ.
    - Kết nối CSDL bằng **ADO.NET** (`SqlConnection`, `SqlCommand`).
2.  **Frontend (JavaScript):**
    - Xử lý logic Player bằng `HTML5 Audio API`.
    - Gọi dữ liệu bất đồng bộ bằng `Fetch API`.
    - Lưu cấu hình (Volume, Repeat...) vào `LocalStorage`.
3.  **Database:**
    - Thiết kế chuẩn hóa, sử dụng các ràng buộc khóa ngoại (Foreign Key) để đảm bảo toàn vẹn dữ liệu.

---

## ⚙️ Cài Đặt & Chạy Dự Án

### 🔧 Yêu Cầu

- Visual Studio 2019 / 2022.
- SQL Server 2019 trở lên.
- .NET Framework 4.7.2.

### 📌 Các Bước Thực Hiện

**Bước 1: Clone dự án**

```bash
git clone [https://github.com/huunghia160699/ASPNET-DT23TTC13-NguyenHuuNghia-MusicWebsite.git](https://github.com/huunghia160699/ASPNET-DT23TTC13-NguyenHuuNghia-MusicWebsite.git)
```

**Bước 2: Cấu hình Database**

1. Mở SQL Server Management Studio (SSMS).
2. Chạy file script: `Database/MusicWebDB_FullScript.sql` (File này sẽ tạo DB và dữ liệu mẫu).

**Bước 3: Cấu hình kết nối**

1. Mở file `Web.config` trong Visual Studio.
2. Tìm thẻ `<connectionStrings>` và sửa lại `Data Source` cho đúng tên máy bạn:

```xml
<connectionStrings>
  <add name="MusicWebDB"
       connectionString="Data Source=.;Initial Catalog=MusicWebDB;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**Bước 4: Chạy dự án**

- Nhấn **F5** hoặc nút **IIS Express** trên Visual Studio.
- Tài khoản Admin mặc định: `admin` / `123`.

---

## 👨‍💻 Tác Giả

**Nguyễn Hữu Nghĩa**

- **Lớp:** DT23TTC13
- **Email:** huunghia.160699@gmail.com

---

<div align="center">
  <i>Đồ án môn Chuyên đề ASP.NET</i>
</div>
