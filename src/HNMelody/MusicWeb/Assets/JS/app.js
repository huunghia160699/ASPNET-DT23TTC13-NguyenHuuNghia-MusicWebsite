// Key dùng để lưu cài đặt vào LocalStorage
const PLAYER_STORAGE_KEY = 'HN_MELODY_SETTING';

const app = {
    // ================= 1. TRẠNG THÁI ỨNG DỤNG (STATE) =================
    currentIndex: 0,        // Chỉ số bài hát hiện tại
    isPlaying: false,       // Trạng thái phát nhạc
    isRandom: false,        // Trạng thái phát ngẫu nhiên
    isRepeat: false,        // Trạng thái lặp lại
    isDragging: false,      // Trạng thái đang kéo thanh tua nhạc

    // Lấy cấu hình đã lưu, nếu không có thì tạo object rỗng
    config: JSON.parse(localStorage.getItem(PLAYER_STORAGE_KEY)) || {},

    songs: [],              // Danh sách bài hát gốc (Tất cả)
    searchSongs: [],        // Danh sách bài hát tìm kiếm
    favorites: [],          // Mảng chứa ID các bài hát yêu thích [1, 5, 10...]
    currentTab: 'all',      // Tab hiện tại: 'all', 'search', 'fav'

    user: null,             // Thông tin người dùng đăng nhập
    authMode: 'login',      // Chế độ xác thực: 'login' hoặc 'register'

    // ================= 2. CÁC PHẦN TỬ HTML (DOM) =================
    // --- Trình phát nhạc ---
    audio: document.getElementById('audio'),
    cdThumb: document.getElementById('cdThumb'),
    cdThumbInner: document.querySelector('.vinyl-inner'), // Ảnh đĩa than
    heroTitle: document.getElementById('heroTitle'),      // Tên bài hát lớn
    heroArtist: document.getElementById('heroArtist'),    // Tên nghệ sĩ

    // --- Các nút điều khiển ---
    btnPlay: document.getElementById('btnPlay'),
    btnNext: document.getElementById('btnNext'),
    btnPrev: document.getElementById('btnPrev'),
    btnRandom: document.getElementById('btnShuffle'),
    btnRepeat: document.getElementById('btnRepeat'),

    // --- Thanh tiến trình ---
    progressFill: document.querySelector('.progress-fill'),   // Phần thanh đã chạy
    progressTrack: document.querySelector('.progress-track'), // Toàn bộ thanh tua
    currentTimeEl: document.getElementById('currentTime'),    // Thời gian hiện tại
    durationEl: document.getElementById('duration'),          // Tổng thời gian

    // --- Khu vực danh sách bài hát ---
    allSongsContainer: document.getElementById('allSongsContainer'),
    searchResultContainer: document.getElementById('searchResultContainer'),
    favSongsContainer: document.getElementById('favSongsContainer'),

    // --- Tìm kiếm và Tab ---
    tabSearch: document.getElementById('tabSearch'),
    tabAll: document.getElementById('tabAll'),
    searchInput: document.getElementById('searchInput'),
    bgBlur: document.getElementById('bgBlur'), // Ảnh nền mờ

    // --- Đăng nhập / Đăng ký ---
    modal: document.getElementById('authModal'),
    btnLoginBtn: document.getElementById('btnLoginBtn'),
    userProfile: document.getElementById('userProfile'),
    userFullName: document.getElementById('userFullName'),
    userAvatar: document.getElementById('userAvatar'),

    // Các ô nhập liệu
    inpFullname: document.getElementById('authFullname'),
    inpUser: document.getElementById('authUsername'),
    inpPass: document.getElementById('authPassword'),
    groupFullname: document.getElementById('groupFullname'),
    btnSubmit: document.getElementById('btnAuthSubmit'),
    authMsg: document.getElementById('authMsg'),


    // ================= 3. QUẢN LÝ CẤU HÌNH =================

    // Lưu cài đặt vào LocalStorage
    setConfig: function (key, value) {
        this.config[key] = value;
        localStorage.setItem(PLAYER_STORAGE_KEY, JSON.stringify(this.config));
    },

    // Tải cài đặt khi khởi động
    loadConfig: function () {
        this.isRandom = this.config.isRandom || false;
        this.isRepeat = this.config.isRepeat || false;

        // Cập nhật trạng thái hiển thị của nút
        this.btnRandom.classList.toggle('is-active', this.isRandom);
        this.btnRepeat.classList.toggle('is-active', this.isRepeat);
    },

    // Định nghĩa thuộc tính currentSong để lấy bài hát hiện tại
    defineProperties: function () {
        Object.defineProperty(this, 'currentSong', {
            get: function () {
                // Nếu đang ở tab tìm kiếm thì lấy trong list tìm kiếm, ngược lại lấy list gốc
                // Tuy nhiên để đơn giản và tránh lỗi index, ta luôn tham chiếu vào this.songs 
                // vì index được đồng bộ khi loadSongs
                return this.songs[this.currentIndex];
            }
        });
    },


    // ================= 4. KHỞI CHẠY (START) =================
    start: function () {
        // 1. Tải cấu hình và định nghĩa thuộc tính
        this.loadConfig();
        this.defineProperties();

        // 2. Kiểm tra trạng thái đăng nhập
        const savedUser = localStorage.getItem('user');
        if (savedUser) {
            this.user = JSON.parse(savedUser);

            // Kiểm tra Role để set quyền (true = Admin)
            const isAdmin = (this.user.Role === 'Admin');
            this.loginSuccess(isAdmin);
        } else {
            // Nếu chưa đăng nhập, ẩn tab Yêu thích
            document.getElementById('tabFav').style.display = 'none';
        }

        // 3. Lắng nghe các sự kiện
        this.handleEvents();

        // 4. Lấy danh sách bài hát từ Server
        this.fetchSongs('');

        // 5. Chọn tab mặc định
        this.switchTab("all");

        // 6. Khởi tạo menu bộ lọc (Sort)
        this.setupCustomDropdown();
    },


    // ================= 5. XỬ LÝ XÁC THỰC (AUTH) =================

    openModal: function () {
        this.modal.classList.add('open');
        this.loadTestAccounts(); // Tải danh sách tài khoản mẫu (nếu có)
    },

    closeModal: function () {
        this.modal.classList.remove('open');
    },

    // Chuyển đổi giữa Đăng nhập và Đăng ký
    switchAuthMode: function (mode) {
        this.authMode = mode;
        const tabs = document.querySelectorAll('.auth-tab');

        // Cập nhật giao diện tab
        tabs[0].classList.toggle('active', mode === 'login');
        tabs[1].classList.toggle('active', mode === 'register');

        // Ẩn hiện các trường nhập liệu tương ứng
        if (mode === 'login') {
            this.groupFullname.classList.add('hidden');
            this.btnSubmit.innerText = "Đăng Nhập";
        } else {
            this.groupFullname.classList.remove('hidden');
            this.btnSubmit.innerText = "Đăng Ký";
        }
        this.authMsg.innerText = ""; // Xóa thông báo lỗi cũ
    },

    // Xử lý sự kiện nút Submit form Auth
    handleAuthSubmit: function (e) {
        if (e) e.preventDefault(); // Ngăn chặn reload trang

        const u = this.inpUser.value.trim();
        const p = this.inpPass.value.trim();
        const n = this.inpFullname.value.trim();

        if (!u || !p) {
            this.authMsg.innerText = "Vui lòng điền đầy đủ thông tin!";
            this.authMsg.style.color = "red";
            return;
        }

        const _this = this;

        // Xử lý Đăng nhập
        if (this.authMode === 'login') {
            fetch('Default.aspx/Login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username: u, password: p })
            })
                .then(res => res.json())
                .then(data => {
                    if (data.d) {
                        // data.d là chuỗi JSON user info trả về từ server
                        _this.user = JSON.parse(data.d);

                        // Gọi hàm xử lý thành công (Kiểm tra xem có phải Admin không)
                        const isAdmin = (_this.user.Role === 'Admin');
                        _this.loginSuccess(isAdmin);

                        alert("Đăng nhập thành công!");
                    } else {
                        _this.authMsg.innerText = "Sai tài khoản hoặc mật khẩu!";
                        _this.authMsg.style.color = "red";
                    }
                })
                .catch(err => console.log(err));
        } else {
            // Xử lý Đăng ký
            if (!n) { _this.authMsg.innerText = "Nhập họ tên!"; return; }

            fetch('Default.aspx/Register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ fullname: n, username: u, password: p })
            })
                .then(res => res.json())
                .then(data => {
                    if (data.d === 'exist') {
                        _this.authMsg.innerText = "Tài khoản đã tồn tại!";
                        _this.authMsg.style.color = "red";
                    } else {
                        alert("Đăng ký thành công! Hãy đăng nhập.");
                        _this.switchAuthMode('login');
                    }
                });
        }
    },

    // Xử lý khi đăng nhập thành công
    // redirect: có chuyển trang sang Admin ngay không
    loginSuccess: function (isAdmin = false) {
        // Lưu vào LocalStorage
        localStorage.setItem('user', JSON.stringify(this.user));

        // Nếu là Admin thì chuyển trang (chỉ khi login trực tiếp)
        // Lưu ý: Nếu F5 lại trang thì isAdmin vẫn true nhưng không nên redirect
        /* Nếu bạn muốn khi bấm Login -> Tự sang Admin: Bật đoạn dưới
           if (isAdmin && window.location.pathname.indexOf('Admin.aspx') === -1) {
               window.location.href = 'Admin.aspx';
               return;
           }
        */

        // Cập nhật giao diện Header
        this.btnLoginBtn.classList.add('hidden');
        this.userProfile.classList.remove('hidden');
        this.userFullName.innerText = this.user.FullName || this.user.fullname; // Tùy key server trả về
        this.userAvatar.src = this.user.Avatar || this.user.avatar || 'Assets/Images/default-avatar.png';

        // Nếu là Admin, thêm nút vào Menu dropdown
        if (isAdmin) {
            const dropdown = document.querySelector('.profile-dropdown');
            // Kiểm tra chưa có nút thì mới thêm để tránh trùng lặp
            if (dropdown && !dropdown.querySelector('.admin-link')) {
                const adminBtn = document.createElement('div');
                adminBtn.className = 'admin-link';
                adminBtn.innerHTML = '<i class="fa-solid fa-user-gear"></i> Quản trị';
                adminBtn.onclick = function () { window.location.href = "Admin.aspx"; };
                // Chèn lên đầu menu
                dropdown.insertBefore(adminBtn, dropdown.firstChild);
            }
        }

        this.closeModal();

        // Hiện Tab Yêu thích
        const tabFav = document.getElementById('tabFav');
        if (tabFav) tabFav.style.display = 'inline-block';

        // Tải danh sách bài đã like (để hiện tim đỏ)
        this.fetchFavorites();
    },

    // Đăng xuất
    logout: function () {
        // 1. Xóa sạch dữ liệu user
        this.user = null;
        localStorage.removeItem('user');

        // 2. Load lại trang để reset toàn bộ trạng thái JS
        window.location.reload();
    },

    // Tải danh sách tài khoản mẫu (Demo)
    loadTestAccounts: function () {
        const listContainer = document.getElementById('testAccountList');
        if (!listContainer || listContainer.innerHTML.trim() !== "") return;

        fetch('Default.aspx/GetTestAccounts', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(res => res.json())
            .then(data => {
                if (!data.d) return;
                const accs = JSON.parse(data.d);
                const html = accs.map(acc => `
                <div class="acc-item" onclick="app.fillLogin('${acc.u}', '${acc.p}')">
                    <img src="${acc.a}" onError="this.src='Assets/Images/default-avatar.png'">
                    <div class="acc-info">
                        <b>${acc.n}</b>
                        <span>@${acc.u}</span>
                    </div>
                </div>
            `).join('');
                listContainer.innerHTML = html;
            });
    },

    fillLogin: function (u, p) {
        this.switchAuthMode('login');
        this.inpUser.value = u;
        this.inpPass.value = p;
    },


    // ================= 6. LẤY DỮ LIỆU BÀI HÁT =================
    fetchSongs: function (keyword) {
        const _this = this;
        fetch('Default.aspx/GetSongs', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ keyword: keyword })
        })
            .then(res => res.json())
            .then(data => {
                const result = JSON.parse(data.d);

                if (keyword.trim() === '') {
                    // Trường hợp 1: Tải lần đầu (Lấy tất cả)
                    _this.songs = result;

                    // Khôi phục bài hát lần trước (nếu có) từ LocalStorage
                    const savedIndex = _this.config.currentIndex;
                    if (savedIndex !== undefined && savedIndex < _this.songs.length) {
                        _this.currentIndex = savedIndex;
                    } else {
                        _this.currentIndex = 0;
                    }

                    // Render danh sách Tất cả
                    _this.renderPlaylist(_this.songs, _this.allSongsContainer);

                    // Tải bài hát nhưng không tự động phát (false) để tránh ồn khi mới vào
                    _this.loadCurrentSong(false);

                } else {
                    // Trường hợp 2: Tìm kiếm
                    _this.searchSongs = result;
                    _this.renderPlaylist(_this.searchSongs, _this.searchResultContainer);
                    _this.switchTab('search');
                }
            })
            .catch(err => console.error("Lỗi Fetch Songs:", err));
    },

    // Hàm tải danh sách ID bài hát yêu thích
    fetchFavorites: function () {
        console.log(this.user)

        if (!this.user) return;

        fetch('Default.aspx/GetFavoriteSongIDs', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId: this.user.UserID })
        })
            .then(res => res.json())
            .then(data => {
                // Server trả về mảng ID ví dụ: [1, 5, 10]
                console.log(this.favorites)
                this.favorites = JSON.parse(data.d);

                // Render lại trang chủ (Tab All) để cập nhật trạng thái tim đỏ
                this.renderPlaylist(this.songs, this.allSongsContainer);

                // Nếu đang ở tab Fav thì render lại tab Fav luôn
                if (this.currentTab === 'fav') {
                    this.renderFavSongs();
                }
            });
    },

    // Hiển thị danh sách bài hát ra HTML (Dùng chung cho All, Search, Fav)
    renderPlaylist: function (data, target) {
        const htmls = data.map((song, index) => {

            // Logic kiểm tra yêu thích
            const isLiked = this.user && this.favorites.includes(song.id);
            const heartClass = isLiked ? 'fa-solid fa-heart active' : 'fa-regular fa-heart';

            // Tìm index thực sự trong mảng gốc this.songs để active bài đang hát chính xác
            // Vì khi ở tab Search hoặc Fav, index của map sẽ khác index của songs gốc
            const realIndex = this.songs.findIndex(s => s.id === song.id);
            const isActive = (realIndex === this.currentIndex);

            return `
            <li class="song-item ${isActive ? 'active' : ''}" data-index="${realIndex}" data-id="${song.id}">
                <div class="song-img">
                    <img src="${song.thumb}" alt="${song.title}">
                    <div class="disk-wave">
                        <span></span><span></span><span></span><span></span>
                    </div>
                </div>
                
                <div class="song-info">
                    <h4>${song.title}</h4>
                    <p>${song.artist}</p>
                    <div class="song-duration">
                        <span>${this.formatTime(song.duration)}</span>
                    </div>
                </div>

                <div class="btn-fav ${isLiked ? 'active' : ''}" data-id="${song.id}">
                    <i class="${heartClass}"></i>
                </div>
            </li>
        `;
        });

        target.innerHTML = htmls.length > 0
            ? htmls.join('')
            : '<div style="color:#aaa; padding:20px; font-size: 1.6rem; text-align: center;">Không tìm thấy bài hát nào</div>';
    },

    // Hàm render riêng cho tab Yêu thích
    renderFavSongs: function () {
        // Lọc các bài hát trong this.songs mà có ID nằm trong this.favorites
        const favList = this.songs.filter(song => this.favorites.includes(song.id));
        this.renderPlaylist(favList, this.favSongsContainer);
    },


    // ================= 7. XỬ LÝ SỰ KIỆN (EVENTS) =================
    handleEvents: function () {
        const _this = this;

        // --- A. Phát / Tạm dừng ---
        _this.btnPlay.onclick = function () {
            if (_this.isPlaying) _this.audio.pause();
            else _this.audio.play();
        };

        _this.audio.onplay = function () {
            _this.isPlaying = true;
            _this.btnPlay.innerHTML = '<i class="fa-solid fa-pause"></i>';
            _this.btnPlay.classList.add('playing');
            _this.cdThumb.classList.add('playing');

            document.querySelector(".song-item.active").classList.add("playing")
        };

        _this.audio.onpause = function () {
            _this.isPlaying = false;
            _this.btnPlay.innerHTML = '<i class="fa-solid fa-play"></i>';
            _this.btnPlay.classList.remove('playing');
            _this.cdThumb.classList.remove('playing');
            document.querySelector(".song-item.active").classList.remove("playing")
        };

        // --- B. Chuyển bài ---
        _this.btnNext.onclick = function () {
            if (_this.isRandom) _this.playRandomSong();
            else _this.nextSong();
            _this.scrollToActiveSong();
        };

        _this.btnPrev.onclick = function () {
            if (_this.isRandom) _this.playRandomSong();
            else _this.prevSong();
            _this.scrollToActiveSong();
        };

        // --- C. Chức năng Random / Repeat ---
        _this.btnRandom.onclick = function () {
            _this.isRandom = !_this.isRandom;
            _this.setConfig('isRandom', _this.isRandom);
            _this.btnRandom.classList.toggle('is-active', _this.isRandom);
        };

        _this.btnRepeat.onclick = function () {
            _this.isRepeat = !_this.isRepeat;
            _this.setConfig('isRepeat', _this.isRepeat);
            _this.btnRepeat.classList.toggle('is-active', _this.isRepeat);
        };

        // Xử lý khi kết thúc bài hát
        _this.audio.onended = function () {
            if (_this.isRepeat) {
                _this.audio.play();
            } else {
                _this.btnNext.click();
            }
        };

        // --- D. Tua nhạc (Seek) ---
        const handleSeek = (e) => {
            if (!_this.audio.duration) return;
            const rect = _this.progressTrack.getBoundingClientRect();
            // Tính % vị trí click chuột trên thanh
            const percent = Math.min(Math.max((e.clientX - rect.left) / rect.width, 0), 1);

            _this.progressFill.style.width = (percent * 100) + "%";
            _this.audio.currentTime = percent * _this.audio.duration;

            if (_this.currentTimeEl) {
                _this.currentTimeEl.innerText = _this.formatTime(_this.audio.currentTime);
            }
        };

        // Sự kiện chuột trên thanh tiến trình
        _this.progressTrack.addEventListener('mousedown', (e) => {
            _this.audio.pause(); // Tạm dừng để kéo mượt hơn
            _this.isDragging = true;
            handleSeek(e);
        });

        document.addEventListener('mousemove', (e) => {
            if (_this.isDragging) handleSeek(e);
        });

        document.addEventListener('mouseup', () => {
            if (_this.isDragging) {
                _this.isDragging = false;
                _this.audio.play();
            }
        });

        // Cập nhật thanh tiến trình theo thời gian thực
        _this.audio.ontimeupdate = function () {
            if (_this.isDragging) return;

            if (_this.audio.duration) {
                const progressPercent = (_this.audio.currentTime / _this.audio.duration) * 100;
                _this.progressFill.style.width = progressPercent + '%';

                if (_this.currentTimeEl) {
                    _this.currentTimeEl.innerText = _this.formatTime(_this.audio.currentTime);
                    _this.durationEl.innerText = _this.formatTime(_this.audio.duration);
                }
            }
        };

        // --- E. Chọn bài hát từ danh sách (Xử lý Play và Like) ---
        const contentSongs = document.querySelector('.content-songs');

        if (contentSongs) {
            contentSongs.onclick = function (e) {
                const songNode = e.target.closest('.song-item');
                const favBtn = e.target.closest('.btn-fav'); // Bắt sự kiện nút tim
                const optionBtn = e.target.closest('.option'); // Bắt sự kiện nút 3 chấm (nếu có)

                // Nếu click ra ngoài bài hát hoặc click vào nút option thì bỏ qua
                if (!songNode || optionBtn) return;

                // -----------------------------------------------------------
                // 1. XỬ LÝ KHI BẤM VÀO NÚT TIM (YÊU THÍCH)
                // -----------------------------------------------------------
                if (favBtn) {
                    e.stopPropagation(); // Chặn sự kiện nổi bọt để không phát nhạc

                    // Lấy ID bài hát từ data-id
                    const songId = favBtn.dataset.id;

                    // Gọi hàm xử lý like/unlike
                    _this.toggleFavorite(songId, favBtn);

                    return; // DỪNG LẠI NGAY, không chạy code phát nhạc
                }

                // -----------------------------------------------------------
                // 2. XỬ LÝ KHI BẤM VÀO BÀI HÁT (PHÁT NHẠC)
                // -----------------------------------------------------------
                if (songNode) {
                    const newIndex = Number(songNode.dataset.index);

                    // Cập nhật bài hát hiện tại
                    _this.currentIndex = newIndex;

                    // Tải thông tin và TỰ ĐỘNG PHÁT (true)
                    _this.loadCurrentSong(true);

                    // --- Xử lý riêng trường hợp đang ở Tab Tìm kiếm ---
                    const parentList = songNode.closest('.song-list');
                    if (parentList && parentList.id === 'searchResultContainer') {
                        // 1. Chuyển về tab Tất cả
                        _this.switchTab('all');

                        // 2. Xóa từ khóa tìm kiếm
                        _this.searchInput.value = "";

                        // 3. Cuộn đến bài hát đang phát (đợi 300ms cho Tab chuyển xong)
                        setTimeout(() => {
                            _this.scrollToActiveSong();
                        }, 300);
                    }
                }
            };
        }

        // --- F. Tìm kiếm (Live Search) ---
        let searchTimeout;
        _this.searchInput.oninput = function (e) {
            const keyword = e.target.value.trim();
            clearTimeout(searchTimeout);

            if (keyword === '') {
                _this.switchTab('all');
                return;
            }

            // Debounce: Đợi 0.5s sau khi ngừng gõ mới tìm kiếm
            searchTimeout = setTimeout(() => {
                _this.fetchSongs(keyword);
            }, 500);
        };
    },


    // ================= 8. CÁC HÀM HỖ TRỢ =================

    // Tải thông tin bài hát hiện tại lên Player
    loadCurrentSong: function (shouldPlay = false) {
        if (!this.currentSong) return;

        // Lưu vị trí bài hát vào storage để F5 không mất
        this.setConfig('currentIndex', this.currentIndex);

        // 1. Ẩn ảnh đĩa than và dừng nhạc cũ
        this.cdThumbInner.style.opacity = 0;
        this.cdThumb.getAnimations().forEach(anim => anim.pause());
        this.audio.pause();

        // Tạo độ trễ nhỏ để hiệu ứng chuyển bài mượt mà hơn
        setTimeout(() => {
            // 2. Cập nhật thông tin bài hát
            this.heroTitle.innerText = this.currentSong.title;
            this.heroArtist.innerText = this.currentSong.artist;
            this.cdThumbInner.style.backgroundImage = `url('${this.currentSong.thumb}')`;
            this.bgBlur.style.backgroundImage = `url('${this.currentSong.thumb}')`;
            this.audio.src = this.currentSong.src;

            if (this.currentSong.duration) {
                this.currentTimeEl.innerText = "00:00";
                this.durationEl.innerText = this.formatTime(this.currentSong.duration);
            }

            // 3. Cập nhật trạng thái active trong danh sách (đổi màu xanh)
            // Xóa active cũ
            const oldActive = document.querySelector('.song-item.active');
            if (oldActive) oldActive.classList.remove('active');

            // Thêm active mới (dùng data-index để chọn đúng bài)
            const newItems = document.querySelectorAll(`.song-item[data-index="${this.currentIndex}"]`);
            newItems.forEach(item => item.classList.add('active'));

            this.scrollToActiveSong();

            // 4. Hiện lại ảnh và phát nhạc nếu cần
            requestAnimationFrame(() => {
                this.cdThumbInner.style.opacity = 1;

                // Chỉ phát nhạc nếu tham số shouldPlay = true
                if (shouldPlay) {
                    try {
                        this.audio.play();
                    } catch (e) {
                        console.log("Trình duyệt chặn tự động phát");
                    }
                }
            });

        }, 300); // Độ trễ
    },

    nextSong: function () {
        this.currentIndex++;
        if (this.currentIndex >= this.songs.length) this.currentIndex = 0;
        this.loadCurrentSong(true);
    },

    prevSong: function () {
        this.currentIndex--;
        if (this.currentIndex < 0) this.currentIndex = this.songs.length - 1;
        this.loadCurrentSong(true);
    },

    playRandomSong: function () {
        let newIndex;
        do {
            newIndex = Math.floor(Math.random() * this.songs.length);
        } while (newIndex === this.currentIndex);
        this.currentIndex = newIndex;
        this.loadCurrentSong(true);
    },

    scrollToActiveSong: function () {
        setTimeout(() => {
            const activeSong = document.querySelector('.song-item.active');
            if (activeSong) {
                activeSong.scrollIntoView({
                    behavior: 'smooth',
                    block: 'center',
                });
            }
        }, 300);
    },

    formatTime: function (seconds) {
        if (!seconds) return "00:00";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins < 10 ? '0' + mins : mins}:${secs < 10 ? '0' + secs : secs}`;
    },

    // Hàm gọi API Thả tim/Hủy tim
    toggleFavorite: function (songId, btnElement) {
        // 1. Chưa đăng nhập thì bắt đăng nhập
        if (!this.user) {
            alert("Vui lòng đăng nhập để sử dụng tính năng Yêu thích!");
            this.modal.style.display = 'flex'; // Mở form login
            return;
        }

        // 2. Gọi Server xử lý (WebMethod)
        const url = 'Default.aspx/ToggleFavorite';
        const data = { userId: this.user.UserID, songId: parseInt(songId) };

        console.log("Đang gửi lên Server:", {
            userId: this.user.UserID,
            songId: parseInt(songId)
        });

        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
            .then(res => res.json())
            .then(result => {
                const isLiked = result.d; // Server trả về true (đã like) hoặc false (đã bỏ like)

                // 3. Cập nhật giao diện ngay lập tức (DOM)
                const icon = btnElement.querySelector('i');
                if (isLiked) {
                    btnElement.classList.add('active');
                    icon.classList.remove('fa-regular');
                    icon.classList.add('fa-solid', 'fa-heart');

                    // Thêm vào mảng favorites local
                    if (!this.favorites.includes(parseInt(songId))) this.favorites.push(parseInt(songId));
                } else {
                    btnElement.classList.remove('active');
                    icon.classList.remove('fa-solid', 'fa-heart');
                    icon.classList.add('fa-regular', 'fa-heart');

                    // Xóa khỏi mảng favorites local
                    this.favorites = this.favorites.filter(id => id !== parseInt(songId));
                }

                // Nếu đang ở Tab Yêu thích thì render lại để mất bài vừa bỏ tim ngay lập tức
                if (this.currentTab === 'fav') {
                    this.renderFavSongs();
                }
            })
            .catch(err => console.log(err));
    },

    // Xử lý sắp xếp bài hát
    handleSort: function (type) {
        // Lưu lại ID bài đang hát để không bị mất vị trí
        const currentSongID = this.currentSong ? this.currentSong.id : null;

        switch (type) {
            case 'name':
                this.songs.sort((a, b) => a.title.localeCompare(b.title));
                break;
            case 'views':
                this.songs.sort((a, b) => b.views - a.views);
                break;
            case 'favs':
                // Sắp xếp theo số lượng like (giả sử có trường favs trong object song)
                this.songs.sort((a, b) => (b.favs || 0) - (a.favs || 0));
                break;
            default:
                // Mặc định sắp xếp theo ID
                this.songs.sort((a, b) => a.id - b.id);
                break;
        }

        // Cập nhật lại chỉ số currentIndex sau khi mảng songs bị xáo trộn
        if (currentSongID) {
            this.currentIndex = this.songs.findIndex(s => s.id === currentSongID);
        }

        // Render lại danh sách
        this.renderPlaylist(this.songs, this.allSongsContainer);

        // Cuộn tới bài đang hát
        setTimeout(() => this.scrollToActiveSong(), 500);
    },

    // Khởi tạo menu bộ lọc (Dropdown)
    setupCustomDropdown: function () {
        const dropdown = document.querySelector('.custom-dropdown');
        const trigger = document.getElementById('dropdownTrigger');
        const selectedText = document.getElementById('selectedText');
        const items = document.querySelectorAll('.dropdown-item');
        const _this = this;

        if (!trigger) return;

        trigger.onclick = function (e) {
            e.stopPropagation();
            dropdown.classList.toggle('open');
        };

        items.forEach(item => {
            item.onclick = function () {
                document.querySelector('.dropdown-item.active').classList.remove('active');
                this.classList.add('active');
                selectedText.innerText = this.innerText;
                dropdown.classList.remove('open');

                _this.handleSort(this.dataset.value);
            };
        });

        document.addEventListener('click', function (e) {
            if (dropdown && !dropdown.contains(e.target)) {
                dropdown.classList.remove('open');
            }
        });
    },

    // Chuyển đổi Tab (Quan trọng: Đã sửa lại để gọi renderFavSongs)
    switchTab: function (tabName) {
        this.currentTab = tabName;

        // Active style cho tab
        document.querySelectorAll('.tab-item').forEach(tab => {
            tab.classList.toggle('active', tab.dataset.tab === tabName);
        });

        // Ẩn tất cả danh sách
        document.querySelectorAll(".song-list").forEach(list => list.classList.add("hidden"));

        if (tabName == "all") {
            this.allSongsContainer.classList.remove("hidden");
            this.tabSearch.classList.add("hidden");
        } else if (tabName == "search") {
            this.searchResultContainer.classList.remove("hidden");
            this.tabSearch.classList.remove("hidden");
        } else if (tabName == "fav") {
            this.favSongsContainer.classList.remove("hidden");
            // Render lại danh sách yêu thích khi bấm vào tab
            this.renderFavSongs();
        }
    },
};

// Khởi chạy ứng dụng khi tải xong DOM
document.addEventListener('DOMContentLoaded', function () {
    app.start();
});