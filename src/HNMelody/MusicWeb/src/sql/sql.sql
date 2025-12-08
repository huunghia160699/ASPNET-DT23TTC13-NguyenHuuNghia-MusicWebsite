CREATE DATABASE MusicWebDB

USE MusicWebDB

-- TẠO BẢNG:
--1. BẢNG THỂ LOẠI
CREATE TABLE TheLoai (
	MaTheLoai INT PRIMARY KEY IDENTITY(1,1),
	TenTheLoai NVARCHAR(50) NOT NULL
)
--2. BẢNG BÀI HÁT
CREATE TABLE BaiHat (
    MaBaiHat INT PRIMARY KEY IDENTITY(1,1),      -- Mã tự tăng
    TenBaiHat NVARCHAR(100) NOT NULL,            -- Tên bài
    CaSi NVARCHAR(200),                          -- Lưu được chuỗi dài: "Đen Vâu ft. Min"
    LinkNhac NVARCHAR(500),                      -- Đường dẫn file nhạc (.mp3)
    AnhBia NVARCHAR(500),                        -- Đường dẫn ảnh bìa (.jpg)
    LoiBaiHat NTEXT,                             -- Lời bài hát (để AI đọc)
    MaTheLoai INT,                               -- Khóa ngoại liên kết thể loại
    NgayDang DATETIME DEFAULT GETDATE(),         -- Ngày đăng bài
    
    -- Tạo liên kết khóa ngoại sang bảng TheLoai
    FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai)
);
-- THÊM DỮ LIỆU:
--1. BẢNG THỂ LOẠI
INSERT INTO TheLoai(TenTheLoai)
VALUES 
    (N'Nhạc Trẻ (V-Pop)'),
    (N'Trữ Tình (Bolero)'),
    (N'Rap / Hip-Hop'),
    (N'EDM / Remix'),
    (N'Rock Việt'),
    (N'Âu Mỹ (US-UK)'),
    (N'Nhạc Hàn (K-Pop)'),
    (N'Lo-fi / Chill')

--2. BẢNG BÀI HÁT
INSERT INTO BaiHat(TenBaiHat, CaSi, LinkNhac, AnhBia, MaTheLoai)
VALUES
    (N'Anh đã lạc vào', N'Green', 'anh-da-lac-vao', 'anh-da-lac-vao', 1)
-- XEM KẾT QUẢ
SELECT * FROM TheLoai;

SELECT * FROM BaiHat;