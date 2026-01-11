<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="HNMelody.Admin" %>

<!DOCTYPE html>
<html lang="vi">
<head runat="server">
    <title>Quản trị viên - HN Melody</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="Assets/CSS/style.css" />
    <link rel="stylesheet" href="Assets/CSS/Admin.css" />

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" EnablePageMethods="true" />
        <div id="bgBlur"></div>

        <div class="admin-tabs-container">
            <div class="admin-header-left">
                <h2 class="admin-logo">QUẢN TRỊ VIÊN</h2>

                <a href="Default.aspx" class="btn-back-home">
                    <i class="fa-solid fa-arrow-left"></i>Trang chủ
        </a>
            </div>

            <div class="admin-tabs">
                <button type="button" class="tab-btn active" onclick="admin.switchTab('song')">🎵 BÀI HÁT</button>
                <button type="button" class="tab-btn" onclick="admin.switchTab('artist')">🎤 CA SĨ</button>
            </div>
        </div>

        <div class="admin-container">

            <div class="admin-form">

                <div id="panelSong">
                    <h3 id="formTitle">🎵 THÊM BÀI HÁT</h3>
                    <input type="hidden" id="txtId" value="0">
                    <div class="form-group">
                        <label>Tên bài hát</label>
                        <input type="text" id="txtTitle" placeholder="Ví dụ: Em của ngày hôm qua">
                    </div>
                    <div class="form-group">
                        <label>Ca sĩ</label>
                        <select id="ddlArtist"></select>
                    </div>
                    <div class="form-group">
                        <label>Link nhạc (URL)</label>
                        <input type="text" id="txtUrl" placeholder="baihat.mp3">
                    </div>
                    <div class="form-group">
                        <label>Link ảnh (Image)</label>
                        <input type="text" id="txtImg" placeholder="anh.jpg">
                    </div>
                    <div class="form-group">
                        <label>Thời lượng (Giây)</label>
                        <input type="number" id="txtDur" placeholder="VD: 245">
                    </div>
                    <button type="button" id="btnSave" class="btn-new" onclick="admin.saveSong()">LƯU BÀI HÁT</button>
                    <button type="button" class="btn-reset" onclick="admin.resetForm()">NHẬP MỚI</button>
                </div>

                <div id="panelArtist" class="hidden">
                    <h3 id="formArtistTitle">🎤 THÊM CA SĨ</h3>
                    <input type="hidden" id="txtArtistId" value="0">
                    <div class="form-group">
                        <label>Tên ca sĩ / Nghệ sĩ</label>
                        <input type="text" id="txtArtistName" placeholder="Ví dụ: Sơn Tùng M-TP">
                    </div>
                    <button type="button" id="btnSaveArtist" class="btn-new" onclick="admin.saveArtist()">LƯU CA SĨ</button>
                    <button type="button" class="btn-reset" onclick="admin.resetArtistForm()">NHẬP MỚI</button>
                </div>

            </div>

            <div class="admin-table">

                <div id="tableSongWrapper">
                    <h3 class="table-title">DANH SÁCH BÀI HÁT</h3>
                    <table>
                        <thead>
                            <tr>
                                <th onclick="admin.sort('id')"># <i id="icon-id" class="fa-solid fa-sort"></i></th>
                                <th>Ảnh</th>
                                <th onclick="admin.sort('title')">Tên bài <i id="icon-title" class="fa-solid fa-sort"></i></th>
                                <th onclick="admin.sort('artist')">Ca sĩ <i id="icon-artist" class="fa-solid fa-sort"></i></th>

                                <th>Thời lượng</th>
                                <th>Link Nhạc</th>
                                <th>Link Ảnh</th>

                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody"></tbody>
                    </table>
                </div>

                <div id="tableArtistWrapper" class="hidden">
                    <h3 class="table-title">DANH SÁCH CA SĨ</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên Nghệ Sĩ</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="tableArtistBody"></tbody>
                    </table>
                </div>

            </div>
        </div>
    </form>
    <script src="Assets/JS/admin.js"></script>
</body>
</html>
