<!--
    ================== TỔNG QUAN ==================

    File: Default.aspx
    Chức năng: Trang giao diện chính của website nghe nhạc HNMelody

    - Trang được xây dựng bằng ASP.NET WebForms.
    - Kết hợp HTML, CSS và JavaScript để tạo giao diện và xử lý tương tác.
    - Header hiển thị logo, slogan và chức năng đăng nhập/đăng ký.
    - Modal đăng nhập/đăng ký được xử lý bằng JavaScript, không load lại trang.
    - Player nhạc sử dụng thẻ <audio> của HTML5 để phát nhạc.
    - Có các chức năng: phát / tạm dừng / chuyển bài / lặp lại / trộn bài.
    - Thanh tìm kiếm cho phép người dùng tìm bài hát theo tên.
    - Danh sách bài hát có thể sắp xếp theo:
        + Mới nhất
        + Tên (A-Z)
        + Lượt nghe
        + Lượt thích
    - File CSS và JS được tách riêng để dễ quản lý và bảo trì.

    Sinh viên thực hiện: Nguyễn Hữu Nghĩa
    Môn học / Đồ án: Chuyên đề ASP.NET
    ======================================================
-->

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HNMelody.Default" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <!-- Cấu hình meta và tiêu đề trang -->
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>HNMelody - Giai điệu cuộc sống</title>

    <!-- Icon Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <!-- File CSS chính -->
    <link rel="stylesheet" href="Assets/CSS/style.css" />
</head>
<body>
    <form id="form1" runat="server">

        <!-- ScriptManager dùng cho PageMethods -->
        <asp:ScriptManager runat="server" EnablePageMethods="true" />

        <!-- Nền làm mờ phía sau -->
        <div id="bgBlur"></div>

        <!-- Khung ứng dụng chính -->
        <div class="app-container">

            <!-- Header: logo, slogan và đăng nhập -->
            <header class="top-header">

                <!-- Khu vực logo -->
                <div class="header-left">
                    <div class="logo">HN Melody</div>
                    <span class="slogan">Giai điệu cuộc sống</span>
                </div>

                <!-- Khu vực tài khoản người dùng -->
                <div class="header-right">

                    <!-- Nút đăng nhập -->
                    <button type="button" id="btnLoginBtn" class="login-btn" onclick="app.openModal()">
                        Đăng nhập
                    </button>

                    <!-- Thông tin user sau khi đăng nhập -->
                    <div id="userProfile" class="user-profile hidden">
                        <span id="userFullName">Tên User</span>
                        <img id="userAvatar" src="Assets/Images/default-avatar.jpg" alt="User" />

                        <!-- Menu user -->
                        <div class="profile-dropdown">
                            <div onclick="app.logout()">Đăng xuất</div>
                        </div>
                    </div>
                </div>

                <!-- Modal đăng nhập / đăng ký -->
                <div id="authModal" class="modal-overlay">
                    <div class="modal-content">
                        <span class="close-modal" onclick="app.closeModal()">&times;</span>

                        <!-- Tab chuyển đăng nhập / đăng ký -->
                        <div class="auth-tabs">
                            <div class="auth-tab active" onclick="app.switchAuthMode('login')">Đăng nhập</div>
                            <div class="auth-tab" onclick="app.switchAuthMode('register')">Đăng ký</div>
                        </div>

                        <!-- Form xác thực -->
                        <div class="auth-form">
                            <!-- Ô họ tên (chỉ hiện khi đăng ký) -->
                            <div class="form-group hidden" id="groupFullname">
                                <label>Họ và tên</label>
                                <input type="text" id="authFullname" placeholder="Nhập tên hiển thị...">
                            </div>

                            <!-- Ô tài khoản -->
                            <div class="form-group">
                                <label>Tài khoản</label>
                                <input type="text" id="authUsername" placeholder="Username...">
                            </div>

                            <!-- Ô mật khẩu -->
                            <div class="form-group">
                                <label>Mật khẩu</label>
                                <input type="password" id="authPassword" placeholder="Password...">
                            </div>

                            <!-- Nút xác nhận -->
                            <button type="button" id="btnAuthSubmit" onclick="app.handleAuthSubmit(event)">Đăng Nhập</button>

                            <!-- Thông báo đăng nhập -->
                            <p id="authMsg" class="auth-msg"></p>
                        </div>

                        <!-- Danh sách tài khoản test -->
                        <div class="test-accounts">
                            <h5>⚡ Tài khoản dùng thử</h5>
                            <div id="testAccountList" class="acc-list"></div>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Nội dung chính -->
            <main class="main-body">

                <!-- Player nhạc -->
                <section class="player-section">
                    <div class="player-card">

                        <!-- Đĩa nhạc xoay -->
                        <div class="vinyl-wrapper">
                            <div class="vinyl-disk" id="cdThumb">
                                <div class="vinyl-inner" style="background-image: url('Assets/Images/default-song.jpg')"></div>
                            </div>
                        </div>

                        <!-- Thông tin bài hát -->
                        <div class="player-info">
                            <h2 id="heroTitle">Tên bài hát</h2>
                            <p id="heroArtist">Tên tác giả</p>
                        </div>

                        <!-- Điều khiển phát nhạc -->
                        <div class="player-controls">
                            <!-- Thanh tiến trình -->
                            <div class="progress-container">
                                <span id="currentTime">--:--</span>
                                <div class="progress-track">
                                    <div class="progress-fill" id="progressFill">
                                        <div class="progress-thumb" id="progressThumb"></div>
                                    </div>
                                </div>
                                <span id="duration">--:--</span>
                            </div>

                            <!-- Các nút điều khiển -->
                            <div class="control-buttons">
                                <button type="button" class="btn-icon" id="btnShuffle"><i class="fa-solid fa-shuffle"></i></button>
                                <button type="button" class="btn-icon" id="btnPrev"><i class="fa-solid fa-backward-step"></i></button>
                                <button type="button" class="btn-play-big" id="btnPlay"><i class="fa-solid fa-play"></i></button>
                                <button type="button" class="btn-icon" id="btnNext"><i class="fa-solid fa-forward-step"></i></button>
                                <button type="button" class="btn-icon" id="btnRepeat"><i class="fa-solid fa-repeat"></i></button>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Khu vực danh sách bài hát -->
                <section class="content-section">

                    <!-- Tab, tìm kiếm và sắp xếp -->
                    <div class="content-tabs">
                        <!-- Tab tất cả -->
                        <div class="tab-item active" id="tabAll" data-tab="all" onclick="app.switchTab('all')">Tất cả bài hát</div>
                        <!-- Tab yêu thích -->
                        <div class="tab-item" id="tabFav" data-tab="fav" onclick="app.switchTab('fav')">Bài hát Yêu thích</div>
                        <!-- Tab tìm kiếm -->
                        <div class="tab-item hidden" id="tabSearch" data-tab="search" onclick="app.switchTab('search')">Kết quả tìm kiếm</div>

                        <!-- Ô tìm kiếm -->
                        <div class="search-bar">
                            <input type="text" id="searchInput" placeholder="Tìm kiếm..." />
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </div>

                        <!-- Dropdown sắp xếp -->
                        <div class="custom-dropdown">
                            <div class="dropdown-trigger" id="dropdownTrigger">
                                <span id="selectedText">Mới nhất</span>
                                <i class="fa-solid fa-chevron-down"></i>
                            </div>

                            <ul class="dropdown-menu" id="dropdownMenu">
                                <li class="dropdown-item active" data-value="default">Mới nhất</li>
                                <li class="dropdown-item" data-value="name">Tên (A-Z)</li>
                                <li class="dropdown-item" data-value="views">Nhiều người nghe nhất</li>
                                <li class="dropdown-item" data-value="favs">Nhiều lượt thích nhất</li>
                            </ul>
                        </div>
                    </div>

                    <!-- Danh sách bài hát -->
                    <div class="content-songs">
                        <!-- Tất cả bài hát -->
                        <ul class="song-list" data-title="all" id="allSongsContainer"></ul>

                        <!-- Kết quả tìm kiếm -->
                        <ul class="song-list" data-title="search" id="searchResultContainer"></ul>

                        <!-- Bài hát yêu thích -->
                        <ul class="song-list" data-title="fav" id="favSongsContainer"></ul>
                    </div>

                </section>
            </main>
        </div>

        <!-- Thẻ audio phát nhạc -->
        <audio id="audio" src=""></audio>
    </form>

    <!-- File JavaScript chính -->
    <script src="Assets/JS/app.js"></script>
</body>
</html>
