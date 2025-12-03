# Đồ án: HN-Melody - Nền Tảng Nghe Nhạc Trực Tuyến Tích Hợp AI

![ASP.NET](https://img.shields.io/badge/ASP.NET-WebForms-purple) ![.NET Framework](https://img.shields.io/badge/.NET_Framework-4.7.2-blue) ![IDE](https://img.shields.io/badge/IDE-Visual_Studio_2022-violet) ![Database](https://img.shields.io/badge/SQL-Server-red) ![AI](https://img.shields.io/badge/AI-Integrated-green)

> **"Melody of Life - Giai điệu cuộc sống"**

---

## 1. Thông tin sinh viên

- **Họ và tên:** Nguyễn Hữu Nghĩa
- **MSSV:** 170123789
- **Lớp:** DT23TTC13
- **Email liên hệ:** huunghia.160699@gmail.com
- **Giảng viên hướng dẫn:**
- **Môn học:** Chuyên đề ASP.NET

---

## 2. Giới thiệu dự án

**HN-Melody** là hệ thống nghe nhạc trực tuyến đa nền tảng, tập trung vào trải nghiệm người dùng tối ưu với giao diện hiện đại (Dark/Light Mode). Điểm nổi bật là việc tích hợp **Trí tuệ nhân tạo (AI)** để cá nhân hóa trải nghiệm và tương tác thông minh.

**Mục tiêu dự án:**

1.  **Nâng cao trải nghiệm:** Xây dựng giao diện Immersive UI (Đắm chìm), thân thiện và mượt mà.
2.  **Ứng dụng AI:** Đưa AI vào việc gợi ý nhạc, chatbot hỗ trợ và phân tích cảm xúc.
3.  **Thực tiễn:** Áp dụng kiến thức ASP.NET Web Forms, ADO.NET và SQL Server vào sản phẩm thực tế.

---

## 3. Chức năng hệ thống (ý tưởng)

### A. 🎧 Dành cho Người dùng (User)

- **Phát nhạc thông minh:** Trình phát HTML5 hỗ trợ Lossless/320kbps, chế độ Mini-player chạy nền.
- **Cá nhân hóa AI:**
  - **Mood-based:** AI tự động chọn nhạc theo cảm xúc hiện tại.
  - **Gợi ý thông minh:** Đề xuất bài hát dựa trên lịch sử nghe và sở thích.
- **Tương tác & Tiện ích:**
  - **Thông báo đẩy:** Nhận tin khi nghệ sĩ yêu thích ra bài mới.
  - **Video âm nhạc (MV):** Xem MV chất lượng cao.
  - **Lyrics đồng bộ:** Lời bài hát chạy Karaoke.
  - **Playlist cá nhân:** Tạo, sửa, xóa và lưu danh sách phát riêng.
  - **Tiện ích khác:** Hẹn giờ tắt nhạc, Tải nhạc Offline, Đa ngôn ngữ, Dark/Light Mode.

### B. 🛠️ Dành cho Quản trị viên (Admin)

- **Quản lý nội dung:** CRUD (Thêm/Sửa/Xóa) Bài hát, Album, Playlist, MV, Nghệ sĩ.
- **Quản lý hệ thống:**
  - **Gửi thông báo:** Soạn và gửi thông báo đến toàn bộ người dùng.
  - **Phân quyền:** Admin, Moderator, Content Manager.
- **Báo cáo & Thống kê:** Biểu đồ lượt nghe, xu hướng tìm kiếm, doanh thu.
- **Kiểm thử A/B:** Thử nghiệm giao diện để tối ưu trải nghiệm.

---

## 4. Công nghệ sử dụng

Dự án được xây dựng dựa trên các công nghệ cốt lõi của Microsoft kết hợp với các tiêu chuẩn Web hiện đại:

### 💻 Backend (Xử lý phía máy chủ)

- **Ngôn ngữ:** C# (C-Sharp).
- **Framework:** ASP.NET Web Forms (.NET Framework 4.7.2).
- **Kiến trúc:** 3-Layer (Presentation, BLL, DAL) hoặc Code-behind đơn giản.
- **Thư viện AI:** OpenAI API (tích hợp qua HTTP Client), ML.NET (thư viện tích hợp sẵn).

### 🎨 Frontend (Giao diện người dùng)

- **Ngôn ngữ:** HTML5, CSS3.
- **Scripting:** JavaScript (Vanilla JS) để xử lý trình phát nhạc và hiệu ứng giao diện.
- **UI/UX:** Thiết kế theo phong cách Immersive (Đắm chìm), hỗ trợ Dark Mode bằng CSS Variables.
- **Icon:** FontAwesome 6.

### 🗄️ Database (Cơ sở dữ liệu)

- **Hệ quản trị:** Microsoft SQL Server (2019/2022).
- **Công nghệ kết nối:** ADO.NET (Sử dụng SqlDataSource và Code-behind).
- **Truy vấn:** T-SQL (Stored Procedures, Triggers).

### 🛠️ Công cụ phát triển

- **IDE:** Microsoft Visual Studio 2022.
- **Quản lý mã nguồn:** Git & GitHub.
- **Quản lý CSDL:** SQL Server Management Studio (SSMS).

---

## 5. Cài đặt & Triển khai

Để chạy được dự án trên máy cá nhân, vui lòng làm theo các bước sau:

### Yêu cầu hệ thống

- Visual Studio 2019 hoặc 2022 (Cài đặt workload: _ASP.NET and web development_).
- SQL Server 2019 hoặc 2022 (Express/Developer).
- .NET Framework 4.7.2 trở lên.

### Các bước cài đặt

1.  **Clone Repository:**
    ```bash
    git clone https://github.com/huunghia160699/ASPNET-DT23TTC13-NguyenHuuNghia-MusicWebsite.git
    ```
2.  **Cấu hình Database:**

    - Mở SSMS, kết nối vào SQL Server.
    - Chạy file script `src/Database/MusicWebDB_FullScript.sql` để tạo CSDL và dữ liệu mẫu.
    - Mở file `src/MusicWeb/Web.config`, cập nhật chuỗi kết nối:

    ```xml
    <add name="MusicWebDB" connectionString="Data Source=YOUR_SERVER_NAME;Initial Catalog=MusicWebDB;Integrated Security=True;" providerName="System.Data.SqlClient" />
    ```

    _(Thay `YOUR_SERVER_NAME` bằng tên server của bạn, ví dụ: `LOCALHOST\SQLEXPRESS`)_.

3.  **Chạy ứng dụng:**
    - Mở file solution `src/HNMelody.sln` bằng Visual Studio.
    - Nhấn **F5** để khởi chạy.
    - Tài khoản Admin mặc định: `admin` / `123456`.

---

## 6. Tiến độ thực hiện (Cập nhật hàng tuần)

| Tuần  | Thời gian     | Nội dung công việc                                                            | Trạng thái |
| :---- | :------------ | :---------------------------------------------------------------------------- | :--------- |
| **1** | 01/12 - 07/12 | - Khởi tạo dự án, GitHub, Database<br>- Dựng giao diện Master Page, Trang chủ | Đang làm   |
| **2** | 08/12 - 14/12 | - Chức năng Nghe nhạc (Player)<br>- Đăng nhập/Đăng ký                         | Dự kiến    |
| **3** | 15/12 - 21/12 | - Trang Admin (CRUD Bài hát, Thể loại)<br>- Quản lý Playlist                  | Dự kiến    |
| **4** | 22/12 - 28/12 | - Tìm kiếm thông minh<br>- Tính năng Yêu thích, Lịch sử                       | Dự kiến    |
| **5** | 29/12 - 04/01 | - **Tích hợp AI** (Gợi ý, Chatbot)<br>- Kiểm thử toàn bộ                      | Dự kiến    |
| **6** | 05/01 - 11/01 | - Viết báo cáo, Slide thuyết trình<br>- Đóng gói nộp bài                      | Dự kiến    |

---

## 7. Hình ảnh minh họa

_(Phần này sẽ được cập nhật ảnh chụp màn hình thực tế của sản phẩm)_

- **Giao diện Trang chủ (Dark Mode):**
  _(Chèn ảnh tại đây)_

- **Trình phát nhạc (Player):**
  _(Chèn ảnh tại đây)_

---

_© 2025 - Đồ án Chuyên đề ASP.NET - Nguyễn Hữu Nghĩa_
