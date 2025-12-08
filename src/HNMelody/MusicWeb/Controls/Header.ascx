<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="MusicWeb.Controls.Header" %>

<div class="top-header-left">
    <div class="nav-arrows">
        <button class="btn-arrow">
            <i class="fa-solid fa-chevron-left"></i>
        </button>
        <button class="btn-arrow">
            <i class="fa-solid fa-chevron-right"></i>
        </button>
    </div>

    <div class="search-wrapper">
        <div class="search-bar">
            <div class="search-icon">
                <i class="fa-solid fa-magnifying-glass"></i>
            </div>
            <input
                type="text"
                id="searchInput"
                placeholder="Tìm kiếm bài hát, nghệ sĩ..."
                autocomplete="off"
                spellcheck="false"
                onfocus="showSearch()"
                onblur="hideSearchDelayed()" />
            <i
                class="fa-solid fa-xmark close-icon"
                onclick="clearSearch()"></i>
        </div>

        <div id="searchDropdown" class="search-dropdown">
            <div class="search-section">
                <h4 class="section-title">Từ khóa liên quan</h4>
                <ul class="keyword-list">
                    <li>
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <a href="#">anh trai say hi</a>
                    </li>
                    <li>
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <a href="#">ari</a>
                    </li>
                    <li>
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <a href="#">anh đã không biết cách yêu em</a>
                    </li>
                    <li>
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <a href="#">alan walker</a>
                    </li>
                </ul>
            </div>

            <div class="search-section">
                <h4 class="section-title">Gợi ý kết quả</h4>
                <div class="suggestion-list">
                    <a href="#" class="suggest-item">
                        <img src="" alt="Song" />
                        <div class="info">
                            <span class="name">Anh Đã Không Biết Cách Yêu Em</span>
                            <span class="sub">Quang Đăng Trần</span>
                        </div>
                    </a>

                    <a href="#" class="suggest-item">
                        <img
                            src=""
                            alt="Artist"
                            style="border-radius: 50%" />
                        <div class="info">
                            <span class="name">ANH TRAI "SAY HI"</span>
                            <span class="sub">Nghệ sĩ • 48K quan tâm</span>
                        </div>
                    </a>

                    <a href="#" class="suggest-item">
                        <img
                            src=""
                            alt="Song" />
                        <div class="info">
                            <span class="name">Anh Thua Anh Ta</span>
                            <span class="sub">Gia Huy Singer</span>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
<!--  -->
<div class="header-actions">
    <button class="btn-icon"><i class="fa-solid fa-upload"></i></button>
    <button class="btn-vip">
        <i class="fa-solid fa-crown"></i>FREEVIP
    </button>
    <button class="btn-vip-center">VIP Center</button>
    <button class="btn-login-header">Log in</button>
    <button class="btn-icon"><i class="fa-solid fa-gear"></i></button>
</div>

