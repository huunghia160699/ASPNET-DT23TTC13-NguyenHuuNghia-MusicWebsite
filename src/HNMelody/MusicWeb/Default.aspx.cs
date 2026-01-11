using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Configuration;

namespace HNMelody
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load( object sender, EventArgs e ) { }

        // Hàm lấy chuỗi kết nối (Đảm bảo Web.config tên là "MusicWebDB")
        public static string GetConn()
        {
            return ConfigurationManager.ConnectionStrings["MusicWebDB"].ConnectionString;
        }

        // 1. LẤY DANH SÁCH BÀI HÁT (Giữ nguyên logic của bạn, chỉ chuẩn hóa)
        [WebMethod]
        public static string GetSongs( string keyword )
        {
            List<object> songs = new List<object>();
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                string query = @"
                    SELECT s.SongID, s.Title, a.Name AS ArtistName, s.Url, s.Image, s.Duration, s.ViewCount,
                    (SELECT COUNT(*) FROM Favorites f WHERE f.SongID = s.SongID) as FavCount
                    FROM Songs s
                    JOIN Artists a ON s.ArtistID = a.ArtistID";

                if (!string.IsNullOrEmpty(keyword))
                {
                    keyword = keyword.Trim();
                    query += @" 
                        WHERE 
                            (s.Title COLLATE Latin1_General_CI_AI LIKE @kwFull) OR 
                            (a.Name COLLATE Latin1_General_CI_AI LIKE @kwFull)
                        ORDER BY 
                        CASE 
                            WHEN s.Title COLLATE Latin1_General_CI_AI LIKE @kwStart THEN 1
                            WHEN a.Name COLLATE Latin1_General_CI_AI LIKE @kwStart THEN 2
                            ELSE 3 
                        END, s.ViewCount DESC";
                }
                else
                {
                    query += " ORDER BY s.ViewCount DESC";
                }

                SqlCommand cmd = new SqlCommand(query, conn);
                if (!string.IsNullOrEmpty(keyword))
                {
                    cmd.Parameters.AddWithValue("@kwStart", keyword + "%");
                    cmd.Parameters.AddWithValue("@kwFull", "%" + keyword + "%");
                }

                conn.Open();
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    // QUAN TRỌNG: Tên thuộc tính ở đây phải khớp với app.js (id, title, artist...)
                    songs.Add(new
                    {
                        id = r["SongID"],
                        title = r["Title"],
                        artist = r["ArtistName"],
                        src = r["Url"],
                        thumb = r["Image"],
                        duration = r["Duration"],
                        views = r["ViewCount"],
                        favs = r["FavCount"]
                    });
                }
            }
            return new JavaScriptSerializer().Serialize(songs);
        }

        // 2. XỬ LÝ ĐĂNG NHẬP (SỬA LẠI ĐỂ KHỚP VỚI JS)
        [WebMethod]
        public static string Login( string username, string password )
        {
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                // Thêm lấy cột Role
                string query = "SELECT * FROM Users WHERE Username = @u AND Password = @p";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);

                conn.Open();
                SqlDataReader r = cmd.ExecuteReader();
                if (r.Read())
                {
                    // QUAN TRỌNG: Đổi tên thuộc tính thành Chữ Hoa (PascalCase) 
                    // để khớp với this.user.UserID trong app.js
                    var user = new
                    {
                        UserID = r["UserID"],      // Sửa id -> UserID
                        Username = r["Username"],  // Sửa username -> Username
                        FullName = r["FullName"],  // Sửa fullname -> FullName
                        Avatar = r["Avatar"],
                        Role = r["Role"]           // Bổ sung Role
                    };
                    return new JavaScriptSerializer().Serialize(user);
                }
            }
            return null;
        }

        // 3. ĐĂNG KÝ (Giữ nguyên)
        [WebMethod]
        public static string Register( string fullname, string username, string password )
        {
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                conn.Open();
                SqlCommand check = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Username = @u", conn);
                check.Parameters.AddWithValue("@u", username);

                if ((int)check.ExecuteScalar() > 0) return "exist";

                // Mặc định Role là User, Avatar mặc định
                string query = "INSERT INTO Users (FullName, Username, Password, Role, Avatar) VALUES (@n, @u, @p, 'User', '/Assets/Images/default-avatar.png')";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@n", fullname);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);
                cmd.ExecuteNonQuery();

                return "success";
            }
        }

        // 4. LẤY TÀI KHOẢN TEST (Giữ nguyên)
        [WebMethod]
        public static string GetTestAccounts()
        {
            List<object> users = new List<object>();
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                string query = "SELECT TOP 5 Username, Password, FullName, Avatar FROM Users";
                SqlCommand cmd = new SqlCommand(query, conn);
                conn.Open();
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    users.Add(new { u = r["Username"], p = r["Password"], n = r["FullName"], a = r["Avatar"] });
                }
            }
            return new JavaScriptSerializer().Serialize(users);
        }

        // 5. THẢ TIM (TOGGLE FAVORITE) - Đã thêm try-catch để bắt lỗi
        [WebMethod]
        public static bool ToggleFavorite( int userId, int songId )
        {
            try
            {
                bool isLiked = false;
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    // Kiểm tra tồn tại
                    string checkQuery = "SELECT COUNT(*) FROM Favorites WHERE UserID = @uid AND SongID = @sid";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                    checkCmd.Parameters.AddWithValue("@uid", userId);
                    checkCmd.Parameters.AddWithValue("@sid", songId);
                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        // Xóa (Unlike)
                        SqlCommand delCmd = new SqlCommand("DELETE FROM Favorites WHERE UserID = @uid AND SongID = @sid", conn);
                        delCmd.Parameters.AddWithValue("@uid", userId);
                        delCmd.Parameters.AddWithValue("@sid", songId);
                        delCmd.ExecuteNonQuery();
                        isLiked = false;
                    }
                    else
                    {
                        // Thêm (Like)
                        SqlCommand addCmd = new SqlCommand("INSERT INTO Favorites (UserID, SongID) VALUES (@uid, @sid)", conn);
                        addCmd.Parameters.AddWithValue("@uid", userId);
                        addCmd.Parameters.AddWithValue("@sid", songId);
                        addCmd.ExecuteNonQuery();
                        isLiked = true;
                    }
                }
                return isLiked;
            }
            catch (Exception)
            {
                // Nếu lỗi, trả về false (hoặc ghi log nếu cần)
                return false;
            }
        }

        // 6. LẤY DANH SÁCH ID YÊU THÍCH
        [WebMethod]
        public static string GetFavoriteSongIDs( int userId )
        {
            try
            {
                List<int> ids = new List<int>();
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand("SELECT SongID FROM Favorites WHERE UserID = @uid", conn);
                    cmd.Parameters.AddWithValue("@uid", userId);
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        ids.Add((int)reader["SongID"]);
                    }
                }
                return new JavaScriptSerializer().Serialize(ids);
            }
            catch (Exception)
            {
                return "[]"; // Trả mảng rỗng nếu lỗi
            }
        }
    }
}