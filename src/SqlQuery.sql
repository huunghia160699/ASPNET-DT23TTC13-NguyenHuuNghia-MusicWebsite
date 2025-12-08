-- 1. Tạo Database mới (Nếu chưa có)
CREATE DATABASE MusicWebDB;
GO

USE MusicWebDB;
GO

-- 2. Bảng NGƯỜI DÙNG (Users)
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL, -- Mật khẩu đã mã hóa
    Email NVARCHAR(100) UNIQUE,
    FullName NVARCHAR(100),
    Avatar NVARCHAR(255) DEFAULT 'default_avatar.jpg',
    Role NVARCHAR(20) DEFAULT 'User', -- 'Admin', 'User'
    ThemePref NVARCHAR(10) DEFAULT 'Dark', -- 'Dark', 'Light'
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1 -- 1: Hoạt động, 0: Bị khóa
);
GO

-- 3. Bảng THỂ LOẠI (Genres)
CREATE TABLE Genres (
    GenreID INT PRIMARY KEY IDENTITY(1,1),
    GenreName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);
GO

-- 4. Bảng NGHỆ SĨ (Artists)
CREATE TABLE Artists (
    ArtistID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Bio NTEXT, -- Tiểu sử
    Image NVARCHAR(255) DEFAULT 'default_artist.jpg',
    FollowerCount INT DEFAULT 0
);
GO

-- 5. Bảng ALBUM (Albums) - Gom nhóm bài hát
CREATE TABLE Albums (
    AlbumID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    ArtistID INT FOREIGN KEY REFERENCES Artists(ArtistID),
    CoverImage NVARCHAR(255),
    ReleaseDate DATE
);
GO

-- 6. Bảng BÀI HÁT (Songs) - Bảng quan trọng nhất
CREATE TABLE Songs (
    SongID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    ArtistID INT FOREIGN KEY REFERENCES Artists(ArtistID), -- Ca sĩ chính
    GenreID INT FOREIGN KEY REFERENCES Genres(GenreID),
    AlbumID INT FOREIGN KEY REFERENCES Albums(AlbumID), -- Có thể Null nếu là Single
    
    FilePath NVARCHAR(255) NOT NULL, -- Đường dẫn file nhạc (.mp3)
    Image NVARCHAR(255),             -- Ảnh bìa riêng của bài (nếu có)
    Duration INT,                    -- Thời lượng (giây)
    Lyrics NTEXT,                    -- Lời bài hát (cho AI phân tích)
    
    Views INT DEFAULT 0,             -- Lượt nghe
    Likes INT DEFAULT 0,             -- Lượt thích
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 7. Bảng PLAYLIST (Danh sách phát cá nhân)
CREATE TABLE Playlists (
    PlaylistID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    Title NVARCHAR(100) NOT NULL,
    IsPublic BIT DEFAULT 0, -- 0: Riêng tư, 1: Công khai
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 8. Bảng CHI TIẾT PLAYLIST (Lưu bài hát trong playlist)
CREATE TABLE PlaylistDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    PlaylistID INT FOREIGN KEY REFERENCES Playlists(PlaylistID) ON DELETE CASCADE,
    SongID INT FOREIGN KEY REFERENCES Songs(SongID) ON DELETE CASCADE,
    AddedAt DATETIME DEFAULT GETDATE()
);
GO

-- 9. Bảng YÊU THÍCH (User Likes) - Để làm gợi ý nhạc
CREATE TABLE UserLikes (
    LikeID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    SongID INT FOREIGN KEY REFERENCES Songs(SongID),
    LikedAt DATETIME DEFAULT GETDATE()
);
GO


-- Thêm Thể loại
INSERT INTO Genres (GenreName) VALUES (N'Pop'), (N'Ballad'), (N'Rap/Hip-hop'), (N'EDM'), (N'Indie');

-- Thêm Nghệ sĩ
INSERT INTO Artists (Name, Image, Bio) VALUES 
(N'Sơn Tùng M-TP', 'artist_sontung.jpg', N'Hoàng tử mưa...'),
(N'Đen Vâu', 'artist_denvau.jpg', N'Rapper tử tế...'),
(N'MIN', 'artist_min.jpg', N'Ca sĩ trẻ...');

-- Thêm Bài hát (Giả sử ArtistID 1=Sơn Tùng, 2=Đen Vâu...)
INSERT INTO Songs (Title, ArtistID, GenreID, FilePath, Image, Lyrics) VALUES 
(N'Lạc Trôi', 1, 1, '~/Music/lactroi.mp3', '~/Images/song_lactroi.jpg', N'Người theo hương hoa...'),
(N'Mang Tiền Về Cho Mẹ', 2, 3, '~/Music/mangtien.mp3', '~/Images/song_mangtien.jpg', N'Mang tiền về cho mẹ...'),
(N'Trên Tình Bạn Dưới Tình Yêu', 3, 1, '~/Music/trentinhban.mp3', '~/Images/song_min.jpg', N'Ta biết nhau từ lâu...');

-- Thêm User Admin (Mật khẩu: 123456 - Lưu ý thực tế phải mã hóa)
INSERT INTO Users (Username, PasswordHash, Email, FullName, Role) VALUES 
('admin', '123456', 'admin@nct.vn', N'Quản Trị Viên', 'Admin'),
('user1', '123456', 'user1@gmail.com', N'Người Dùng 1', 'User');