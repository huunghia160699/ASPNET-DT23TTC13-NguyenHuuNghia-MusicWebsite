-- 1. TẠO DATABASE
CREATE DATABASE MusicWebDB;
GO
USE MusicWebDB;
GO

-- =============================================
-- PHẦN 1: TẠO CẤU TRÚC BẢNG (STRUCTURE)
-- =============================================

-- 1. Bảng Người dùng
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    Password NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(100),
    Avatar NVARCHAR(255) DEFAULT '/Assets/Images/default-avatar.png',
    Role NVARCHAR(20) DEFAULT 'User' -- 'Admin' hoặc 'User'
);

-- 2. Bảng Nghệ sĩ
CREATE TABLE Artists (
    ArtistID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Image NVARCHAR(255) DEFAULT '/Assets/Images/default-artist.png',
    Bio NVARCHAR(MAX) DEFAULT N'Chưa có thông tin giới thiệu.'
);

-- 3. Bảng Bài hát
CREATE TABLE Songs (
    SongID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    ArtistID INT FOREIGN KEY REFERENCES Artists(ArtistID),
    Url NVARCHAR(255) NOT NULL,
    Image NVARCHAR(255),        
    Duration INT DEFAULT 0,     -- Thời lượng (giây)
    ViewCount INT DEFAULT 0,    -- Lượt nghe
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 4. Bảng Yêu thích (Favorites)
-- Bảng này đóng vai trò tạo ra "Danh sách bài hát yêu thích" cho từng User
CREATE TABLE Favorites (
    UserID INT NOT NULL,
    SongID INT NOT NULL,
    AddedAt DATETIME DEFAULT GETDATE(),
    
    -- Khóa chính phức hợp: Một người chỉ like 1 bài 1 lần
    CONSTRAINT PK_Favorites PRIMARY KEY (UserID, SongID),
    
    -- Khóa ngoại: Xóa User hoặc Song thì tự động xóa dòng like tương ứng
    CONSTRAINT FK_Favorites_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_Favorites_Songs FOREIGN KEY (SongID) REFERENCES Songs(SongID) ON DELETE CASCADE
);
GO

-- =============================================
-- PHẦN 2: THÊM DỮ LIỆU MẪU (SEED DATA)
-- =============================================

-- A. Thêm User Admin và User chính
INSERT INTO Users (Username, Password, FullName, Role) 
VALUES ('admin', '123', N'Administrator', 'Admin'), 
       ('nghia', '123', N'Nghĩa Dev', 'User');

-- B. Thêm 5 User ảo (Để test hệ thống xếp hạng, lượt xem)
DECLARE @i INT = 1;
WHILE @i <= 5
BEGIN
    DECLARE @UserName NVARCHAR(50) = 'user' + CAST(@i AS NVARCHAR(10));
    IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = @UserName)
    BEGIN
        INSERT INTO Users (Username, Password, FullName, Role, Avatar)
        VALUES (
            @UserName, 
            '123', 
            N'Khán giả số ' + CAST(@i AS NVARCHAR(10)), 
            'User',
            '/Assets/Images/default-avatar.png'
        );
    END
    SET @i = @i + 1;
END
PRINT N'Đã tạo xong 5 User ảo.';

-- C. Thêm Nghệ sĩ & Bài hát (20 Nghệ sĩ - Dữ liệu phong phú)
DECLARE @ArtID INT;

-- 1. SƠN TÙNG M-TP
INSERT INTO Artists (Name, Image) VALUES (N'Sơn Tùng M-TP', '/Assets/Images/Artists/st.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Cơn Mưa Ngang Qua', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cmna.jpg', 230),
(N'Em Của Ngày Hôm Qua', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ecnhq.jpg', 245),
(N'Chạy Ngay Đi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cnd.jpg', 250),
(N'Muộn Rồi Mà Sao Còn', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/mrmsc.jpg', 270),
(N'Chúng Ta Của Hiện Tại', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ctcht.jpg', 300);

-- 2. ĐEN VÂU
INSERT INTO Artists (Name, Image) VALUES (N'Đen Vâu', '/Assets/Images/Artists/den.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Mang Tiền Về Cho Mẹ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/mtvcm.jpg', 260),
(N'Lối Nhỏ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/loinho.jpg', 240),
(N'Đi Về Nhà', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/divenha.jpg', 215),
(N'Trốn Tìm', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/trontim.jpg', 255);

-- 3. HOÀNG THÙY LINH
INSERT INTO Artists (Name, Image) VALUES (N'Hoàng Thùy Linh', '/Assets/Images/Artists/htl.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'See Tình', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/seetinh.jpg', 185),
(N'Gieo Quẻ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/gieoque.jpg', 200),
(N'Để Mị Nói Cho Mà Nghe', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/demi.jpg', 220),
(N'Bo Xì Bo', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/boxibo.jpg', 190);

-- 4. MONO
INSERT INTO Artists (Name, Image) VALUES (N'MONO', '/Assets/Images/Artists/mono.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Waiting For You', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/wfy.jpg', 266),
(N'Em Là', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/emla.jpg', 210),
(N'Quên Anh Đi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/qad.jpg', 230);

-- 5. CHILLIES
INSERT INTO Artists (Name, Image) VALUES (N'Chillies', '/Assets/Images/Artists/chillies.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Mascara', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/mascara.jpg', 280),
(N'Vùng Ký Ức', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/vku.jpg', 260),
(N'Cứ Chill Thôi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cuchill.jpg', 240),
(N'Qua Khung Cửa Sổ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/qkcs.jpg', 250);

-- 6. MCK
INSERT INTO Artists (Name, Image) VALUES (N'MCK', '/Assets/Images/Artists/mck.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Chìm Sâu', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/chimsau.jpg', 190),
(N'Tại Vì Sao', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/taivisao.jpg', 210),
(N'Anh Đã Ổn Hơn', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/adoh.jpg', 220),
(N'Thôi Em Đừng Đi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/tedd.jpg', 230);

-- 7. TLINH
INSERT INTO Artists (Name, Image) VALUES (N'tlinh', '/Assets/Images/Artists/tlinh.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Gái Độc Thân', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/gdt.jpg', 200),
(N'Thích Quá Rùi Nà', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/tqrn.jpg', 180),
(N'Nếu Lúc Đó', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/nld.jpg', 260);

-- 8. SOOBIN
INSERT INTO Artists (Name, Image) VALUES (N'Soobin', '/Assets/Images/Artists/soobin.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Phía Sau Một Cô Gái', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/psmcg.jpg', 240),
(N'The Playah', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/playah.jpg', 300),
(N'Tháng Năm', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/thangnam.jpg', 220),
(N'BlackJack', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/blackjack.jpg', 210);

-- 9. BINZ
INSERT INTO Artists (Name, Image) VALUES (N'Binz', '/Assets/Images/Artists/binz.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Bigcityboi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/bcb.jpg', 230),
(N'They Said', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/theysaid.jpg', 210),
(N'Gene', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/gene.jpg', 220),
(N'Don''t Break My Heart', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/dbmh.jpg', 240);

-- 10. MỸ TÂM
INSERT INTO Artists (Name, Image) VALUES (N'Mỹ Tâm', '/Assets/Images/Artists/mytam.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Đúng Cũng Thành Sai', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/dcts.jpg', 250),
(N'Hẹn Ước Từ Hư Vô', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/huthv.jpg', 260),
(N'Người Hãy Quên Em Đi', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/nhqed.jpg', 230),
(N'Đâu Chỉ Riêng Em', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/dcre.jpg', 245);

-- 11. JUSTATEE
INSERT INTO Artists (Name, Image) VALUES (N'JustaTee', '/Assets/Images/Artists/justatee.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Thằng Điên', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/thangdien.jpg', 240),
(N'Đã Lỡ Yêu Em Nhiều', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/dlyen.jpg', 250),
(N'Forever Alone', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/fa.jpg', 220);

-- 12. MIN
INSERT INTO Artists (Name, Image) VALUES (N'MIN', '/Assets/Images/Artists/min.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Trên Tình Bạn Dưới Tình Yêu', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ttbdty.jpg', 230),
(N'Có Em Chờ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/coemcho.jpg', 240),
(N'Ghen', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ghen.jpg', 210),
(N'Cà Phê', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/caphe.jpg', 220);

-- 13. VŨ.
INSERT INTO Artists (Name, Image) VALUES (N'Vũ.', '/Assets/Images/Artists/vu.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Bước Qua Nhau', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/bqn.jpg', 250),
(N'Lạ Lùng', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/lalung.jpg', 260),
(N'Đông Kiếm Em', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/dke.jpg', 240),
(N'Bước Qua Mùa Cô Đơn', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/bqmcd.jpg', 270);

-- 14. TRÚC NHÂN
INSERT INTO Artists (Name, Image) VALUES (N'Trúc Nhân', '/Assets/Images/Artists/trucnhan.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Sáng Mắt Chưa', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/smc.jpg', 230),
(N'Thật Bất Ngờ', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/tbn.jpg', 220),
(N'Có Không Giữ Mất Đừng Tìm', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ckgmdt.jpg', 240);

-- 15. AMEE
INSERT INTO Artists (Name, Image) VALUES (N'AMEE', '/Assets/Images/Artists/amee.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Anh Nhà Ở Đâu Thế', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/anodt.jpg', 210),
(N'Đen Đá Không Đường', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ddkd.jpg', 200),
(N'Sao Anh Chưa Về Nhà', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/sacvn.jpg', 220),
(N'Ưng Quá Chừng', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/uqc.jpg', 180);

-- 16. WREN EVANS
INSERT INTO Artists (Name, Image) VALUES (N'Wren Evans', '/Assets/Images/Artists/wren.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Thích Em Hơi Nhiều', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/tehn.jpg', 190),
(N'Gặp May', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/gapmay.jpg', 200),
(N'Cơn Đau', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/condau.jpg', 210);

-- 17. LOW G
INSERT INTO Artists (Name, Image) VALUES (N'Low G', '/Assets/Images/Artists/lowg.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Chán Gái 707', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cg707.jpg', 180),
(N'Cắt Kéo', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/catkeo.jpg', 190),
(N'Simp Gái 808', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/sg808.jpg', 200);

-- 18. HIEUTHUHAI
INSERT INTO Artists (Name, Image) VALUES (N'HIEUTHUHAI', '/Assets/Images/Artists/hieuthuhai.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Cua', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cua.jpg', 190),
(N'Bật Nhạc Lên', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/bnl.jpg', 210),
(N'Vệ Tinh', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/vetinh.jpg', 220),
(N'Ngủ Một Mình', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/nmm.jpg', 230);

-- 19. ERIK
INSERT INTO Artists (Name, Image) VALUES (N'ERIK', '/Assets/Images/Artists/erik.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Sau Tất Cả', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/stc.jpg', 240),
(N'Chạm Đáy Nỗi Đau', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/cdnd.jpg', 250),
(N'Em Không Sai Chúng Ta Sai', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ekscts.jpg', 260);

-- 20. ĐỨC PHÚC
INSERT INTO Artists (Name, Image) VALUES (N'Đức Phúc', '/Assets/Images/Artists/ducphuc.jpg');
SET @ArtID = SCOPE_IDENTITY();
INSERT INTO Songs (Title, ArtistID, Url, Image, Duration) VALUES 
(N'Hơn Cả Yêu', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/hcy.jpg', 240),
(N'Ánh Nắng Của Anh', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/anca.jpg', 230),
(N'Ngày Đầu Tiên', @ArtID, '/Assets/Songs/song1.mp3', '/Assets/Images/Songs/ndt.jpg', 250);

PRINT N'Đã khởi tạo Database và bài hát thành công!';




-- D. Dữ liệu mẫu thủ công cho Admin và User chính (Để test chức năng Yêu thích)
-- Giả sử ID 1 là admin, ID 2 là nghia
INSERT INTO Favorites (UserID, SongID) VALUES (2, 1); -- Nghĩa like bài 1
INSERT INTO Favorites (UserID, SongID) VALUES (2, 2); -- Nghĩa like bài 2
INSERT INTO Favorites (UserID, SongID) VALUES (2, 5); -- Nghĩa like bài 5
GO
