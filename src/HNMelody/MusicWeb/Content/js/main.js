
"use strict";
const $ = document.querySelector.bind(document)
const $$ = document.querySelectorAll.bind(document)

const app = {

    // 1. Cấu hình chung (Lưu các biến dùng nhiều lần)
    config: {
        themeKey: "theme-pref", // Key lưu trong LocalStorage
        baseImageURL: "Images/",
        baseMusicURL: "Music/"
    },
    dom: {
        modalOverlay: $(".modalOverlay"),
        sidebarUserPopup: $("#sidebarUserPopup"),
        sidebar: $(".sidebar")

    },

    init: function () {
        //this.setupTheme();
        this.setupSearch();
        this.setupSidebar();
    },

    handleEvents: function () {
        // Xử lý khi click vào SIDEBAR
        this.dom.sidebar.onclick = e => {
            const target = e.target.closest(".sidebar-click-item, #sidebarUser");
            if (!target) return;

            switch (true) {
                case target.classList.contains("sidebar-click-item"):
                    document.querySelectorAll(".sidebar-click-item").forEach(item => item.classList.remove("active"));
                    target.classList.add("active");
                    break;

                case target.classList.contains("playlist-item"):
                    console.log("Clicked playlist item:", target);
                    // xử lý playlist
                    break;

                case target.classList.contains("login-prompt"):
                    console.log("Clicked login prompt");
                    // mở modal login
                    break;

                case target.id === "sidebarUser":
                    this.dom.sidebarUserPopup.classList.toggle("active")
                    this.dom.modalOverlay.classList.toggle('active')
                    break;
            }
        }

        // Xử lý khi click vào MODAL
        this.dom.modalOverlay.onclick = e => {
            this.dom.sidebarUserPopup.classList.toggle("active")
            this.dom.modalOverlay.classList.toggle('active')
        }

    },
    // 2. Các hàm xử lý Giao diện (UI)
    ui: {
        // Khởi tạo các sự kiện UI khi web vừa load
        

        // Xử lý Dark/Light Mode
        setupTheme: function () {
            const savedTheme = localStorage.getItem(app.config.themeKey);
            if (savedTheme === "light") {
                document.body.classList.add("light-mode");
                // Đổi icon mặt trời/mặt trăng ở đây nếu cần
            }
        },

        toggleTheme: function () {
            const isLight = document.body.classList.toggle("light-mode");
            localStorage.setItem(app.config.themeKey, isLight ? "light" : "dark");
        },

        // Xử lý Thanh tìm kiếm
        setupSearch: function () {
            const searchInput = document.getElementById("searchInput");
            if (!searchInput) return; // Nếu trang không có thanh tìm kiếm thì thoát

            searchInput.addEventListener("focus", () => {
                document.getElementById("searchDropdown").style.display = "block";
            });

            // ... (Các code xử lý search khác dán vào đây)
        },

        // Xử lý Sidebar active
        activateSidebarItem: function () {
            var items = document.querySelectorAll('.sidebar-click-item');
            items.forEach(function (item) {
                item.classList.remove('active');
            });

            element.classList.add('active');
        },

        toggleUserPopup: function () {
            const popup = document.getElementById("userPopup");
            if (popup) {
                // Nếu đang hiện thì ẩn, đang ẩn thì hiện
                popup.style.display = (popup.style.display === "block") ? "none" : "block";
            }
        },
    },

    start: function () {
        this.handleEvents()
    }
};

// ============================================================
// KÍCH HOẠT KHI TRANG WEB TẢI XONG (Entry Point)
// ============================================================
document.addEventListener("DOMContentLoaded", function () {

    app.start();


});





