const admin = {
    songs: [],
    artists: [], // Mảng chứa ca sĩ
    currentSortCol: '',
    isSortDesc: false,

    start: function () {
        this.loadArtists(); // Load danh sách ca sĩ (cho dropdown & bảng)
        this.loadSongs();   // Load bài hát
    },

    // --- 1. CHUYỂN TAB ---
    switchTab: function (tabName) {
        const btns = document.querySelectorAll('.tab-btn');
        const panelSong = document.getElementById('panelSong');
        const panelArtist = document.getElementById('panelArtist');
        const tableSong = document.getElementById('tableSongWrapper');
        const tableArtist = document.getElementById('tableArtistWrapper');

        if (tabName === 'song') {
            // Active nút
            btns[0].classList.add('active'); btns[1].classList.remove('active');

            // Hiện Song, Ẩn Artist
            panelSong.classList.remove('hidden');
            panelArtist.classList.add('hidden');
            tableSong.classList.remove('hidden');
            tableArtist.classList.add('hidden');
        } else {
            // Active nút
            btns[1].classList.add('active'); btns[0].classList.remove('active');

            // Hiện Artist, Ẩn Song
            panelArtist.classList.remove('hidden');
            panelSong.classList.add('hidden');
            tableArtist.classList.remove('hidden');
            tableSong.classList.add('hidden');
        }
    },

    // --- 2. QUẢN LÝ BÀI HÁT (Giữ nguyên logic cũ) ---
    loadSongs: function () {
        const _this = this;
        fetch('Admin.aspx/GetAdminSongs', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }
        })
            .then(res => res.json())
            .then(data => {
                _this.songs = JSON.parse(data.d);
                _this.sort('id'); // Mặc định sort bài hát theo ID
            });
    },

    // Hàm phụ: Đổi giây sang phút:giây (VD: 70 -> 01:10)
    formatTime: function (seconds) {
        if (!seconds) return "00:00";
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return `${m < 10 ? '0' + m : m}:${s < 10 ? '0' + s : s}`;
    },

    // Sửa lại hàm renderTable
    renderTable: function (list) {
        if (!list || list.length === 0) {
            document.getElementById('tableBody').innerHTML = '<tr><td colspan="8" style="text-align:center">Chưa có dữ liệu</td></tr>';
            return;
        }

        const html = list.map((s) => `
            <tr>
                <td>${s.id}</td>
                <td><img src="${s.img}" onerror="this.src='Assets/Images/default-song.jpg'"></td>
                <td><b>${s.title}</b></td>
                <td>${s.artName}</td>
                
                <td>${this.formatTime(s.dur)}</td>
                <td class="text-truncate" title="${s.url}">${s.url}</td>
                <td class="text-truncate" title="${s.img}">${s.img}</td>

                <td>
                    <button type="button" class="btn-action btn-edit" onclick="admin.editSong(${s.id})">Sửa</button>
                    <button type="button" class="btn-action btn-del" onclick="admin.deleteSong(${s.id})">Xóa</button>
                </td>
            </tr>
        `).join('');
        document.getElementById('tableBody').innerHTML = html;
    },

    // --- 3. QUẢN LÝ CA SĨ (MỚI) ---

    // Tải danh sách ca sĩ (Dùng chung cho Dropdown ở Form Bài Hát và Bảng Ca Sĩ)
    loadArtists: function () {
        const _this = this;
        fetch('Admin.aspx/GetArtists', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }
        })
            .then(res => res.json())
            .then(data => {
                _this.artists = JSON.parse(data.d);

                // A. Đổ vào Dropdown (Form bài hát)
                const options = _this.artists.map(a => `<option value="${a.id}">${a.name}</option>`).join('');
                document.getElementById('ddlArtist').innerHTML = options;

                // B. Đổ vào Bảng (Tab Ca sĩ)
                _this.renderArtistTable(_this.artists);
            });
    },

    renderArtistTable: function (list) {
        const html = list.map(a => `
            <tr>
                <td>${a.id}</td>
                <td><b>${a.name}</b></td>
                <td>
                    <button type="button" class="btn-action btn-edit" onclick="admin.editArtist(${a.id})">Sửa</button>
                    <button type="button" class="btn-action btn-del" onclick="admin.deleteArtist(${a.id})">Xóa</button>
                </td>
            </tr>
        `).join('');
        document.getElementById('tableArtistBody').innerHTML = html;
    },

    // Lưu ca sĩ
    saveArtist: function () {
        // 1. Lấy giá trị từ ô input (Kiểm tra kỹ ID trong file Admin.aspx có đúng là txtArtistId và txtArtistName không)
        const idVal = document.getElementById('txtArtistId').value;
        const nameVal = document.getElementById('txtArtistName').value;

        // 2. Kiểm tra dữ liệu
        if (!nameVal || nameVal.trim() === "") {
            alert("Chưa nhập tên ca sĩ!");
            return;
        }

        // 3. Gọi API
        fetch('Admin.aspx/SaveArtist', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            // QUAN TRỌNG: id phải là Số (Number), name là Chuỗi
            body: JSON.stringify({ id: Number(idVal), name: nameVal.trim() })
        })
            .then(res => res.json())
            .then(resData => {
                if (resData.d === 'ok') {
                    alert("Lưu thành công!");
                    this.resetArtistForm();
                    this.loadArtists(); // Load lại cả dropdown và bảng
                } else {
                    alert("Lỗi Server: " + resData.d);
                }
            })
            .catch(err => {
                console.error(err); // Xem lỗi chi tiết ở Console (F12)
                alert("Lỗi kết nối! Xem console để biết chi tiết.");
            });
    },

    // Sửa ca sĩ
    editArtist: function (id) {
        const a = this.artists.find(x => x.id === id);
        if (a) {
            document.getElementById('txtArtistId').value = a.id;
            document.getElementById('txtArtistName').value = a.name;
            document.getElementById('formArtistTitle').innerText = "✏️ SỬA CA SĨ: " + a.name;
            document.getElementById('btnSaveArtist').innerText = "CẬP NHẬT";
        }
    },

    // Reset Form Ca sĩ
    resetArtistForm: function () {
        document.getElementById('txtArtistId').value = 0;
        document.getElementById('txtArtistName').value = "";
        document.getElementById('formArtistTitle').innerText = "🎤 THÊM CA SĨ";
        document.getElementById('btnSaveArtist').innerText = "LƯU CA SĨ";
    },

    // Xóa Ca sĩ
    deleteArtist: function (id) {
        if (!confirm("Bạn có chắc muốn xóa ca sĩ này?")) return;

        fetch('Admin.aspx/DeleteArtist', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: id })
        })
            .then(res => res.json())
            .then(resData => {
                if (resData.d === 'ok') {
                    this.loadArtists();
                } else {
                    // Nếu backend trả về lỗi (do đang có bài hát), nó sẽ hiện alert ở đây
                    alert(resData.d);
                }
            });
    },

    // --- CÁC HÀM CŨ CỦA BÀI HÁT (Giữ nguyên logic editSong, deleteSong, sort...) ---

    editSong: function (idSong) {
        const s = this.songs.find(x => x.id === idSong);
        if (!s) return;

        document.getElementById('txtId').value = s.id;
        document.getElementById('txtTitle').value = s.title;
        document.getElementById('txtDur').value = s.dur;
        document.getElementById('ddlArtist').value = s.artId;

        // --- XỬ LÝ ĐƯỜNG DẪN: Chỉ hiện tên file ---
        // Ví dụ: /Assets/Music/LacTroi.mp3 -> Chỉ hiện LacTroi.mp3
        let cleanUrl = s.url.replace('/Assets/Songs/', '');
        let cleanImg = s.img.replace('/Assets/Images/Songs/', '');

        document.getElementById('txtUrl').value = cleanUrl;
        document.getElementById('txtImg').value = cleanImg;
        // ------------------------------------------

        document.getElementById('formTitle').innerText = "✏️ SỬA BÀI HÁT: " + s.id;
        document.getElementById('btnSave').innerText = "CẬP NHẬT";

        // Scroll lên form
        document.querySelector('.admin-form').scrollIntoView({ behavior: 'smooth' });
    },

    resetForm: function () {
        document.getElementById('txtId').value = 0;
        document.getElementById('txtTitle').value = "";
        document.getElementById('txtUrl').value = "";
        document.getElementById('txtImg').value = "";
        document.getElementById('txtDur').value = "";
        document.getElementById('formTitle').innerText = "🎵 THÊM BÀI HÁT";
        document.getElementById('btnSave').innerText = "LƯU BÀI HÁT";
    },

    saveSong: function () {
        // Lấy giá trị thô từ ô input
        let rawUrl = document.getElementById('txtUrl').value.trim();
        let rawImg = document.getElementById('txtImg').value.trim();

        // --- TỰ ĐỘNG THÊM ĐƯỜNG DẪN ---
        // Nếu người dùng nhập "baihat.mp3" -> Thành "/Assets/Music/baihat.mp3"
        // Nếu đã nhập đầy đủ hoặc là link online (http...) thì giữ nguyên

        // 1. Xử lý Link Nhạc
        if (rawUrl && !rawUrl.startsWith('http') && !rawUrl.startsWith('/')) {
            rawUrl = '/Assets/Music/' + rawUrl;
        }

        // 2. Xử lý Link Ảnh
        if (rawImg && !rawImg.startsWith('http') && !rawImg.startsWith('/')) {
            rawImg = '/Assets/Images/Songs/' + rawImg;
        }
        // -----------------------------

        const data = {
            id: Number(document.getElementById('txtId').value),
            title: document.getElementById('txtTitle').value,
            artistId: Number(document.getElementById('ddlArtist').value),
            url: rawUrl, // Dùng biến đã xử lý
            img: rawImg, // Dùng biến đã xử lý
            duration: Number(document.getElementById('txtDur').value) || 0
        };

        if (!data.title || !data.url) {
            alert("Vui lòng nhập tên và link nhạc!");
            return;
        }

        fetch('Admin.aspx/SaveSong', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        })
            .then(res => res.json())
            .then(resData => {
                if (resData.d === 'ok') {
                    alert("Thành công!");
                    this.resetForm();
                    this.loadSongs();
                    this.sort("id");
                } else {
                    alert(resData.d);
                }
            });
    },
    formatTime: function (seconds) {
        if (!seconds) return "00:00";
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return `${m < 10 ? '0' + m : m}:${s < 10 ? '0' + s : s}`;
    },
    deleteSong: function (id) {
        if (!confirm("Xóa bài hát này?")) return;
        fetch('Admin.aspx/DeleteSong', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: id })
        })
            .then(res => res.json())
            .then(resData => {
                if (resData.d === 'ok') this.loadSongs();
                else alert(resData.d);
            });
    },

    // Sort logic (Giữ nguyên)
    sort: function (colName) {
        if (this.currentSortCol === colName) this.isSortDesc = !this.isSortDesc;
        else { this.currentSortCol = colName; this.isSortDesc = false; }

        this.songs.sort((a, b) => {
            let valA, valB;
            if (colName === 'id') { valA = a.id; valB = b.id; }
            else if (colName === 'title') { valA = a.title.toLowerCase(); valB = b.title.toLowerCase(); }
            else if (colName === 'artist') { valA = a.artName.toLowerCase(); valB = b.artName.toLowerCase(); }

            if (valA < valB) return this.isSortDesc ? 1 : -1;
            if (valA > valB) return this.isSortDesc ? -1 : 1;
            return 0;
        });
        this.renderTable(this.songs);
        this.updateSortIcons();
    },

    updateSortIcons: function () {
        ['id', 'title', 'artist'].forEach(col => {
            const icon = document.getElementById('icon-' + col);
            if (icon) { icon.className = 'fa-solid fa-sort'; icon.style.opacity = 0.3; }
        });
        const activeIcon = document.getElementById('icon-' + this.currentSortCol);
        if (activeIcon) {
            activeIcon.style.opacity = 1;
            activeIcon.className = this.isSortDesc ? 'fa-solid fa-sort-down' : 'fa-solid fa-sort-up';
        }
    },
};

document.addEventListener('DOMContentLoaded', function () {
    admin.start();
});