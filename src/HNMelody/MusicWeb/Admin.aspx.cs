using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Serialization;
using System.Configuration;

namespace HNMelody // <--- QUAN TRỌNG: Thêm dòng này bao quanh class
{
    public partial class Admin : System.Web.UI.Page
    {
        // Hàm kết nối dùng chung (Copy từ Default sang cho nhanh)
        public static string GetConn()
        {
            return ConfigurationManager.ConnectionStrings["MusicWebDB"].ConnectionString;
        }

        protected void Page_Load( object sender, EventArgs e )
        {
            // Chỗ này sau này làm check login Admin, giờ cứ để trống đã
        }

        // 1. LẤY DANH SÁCH CA SĨ (Để đổ vào Dropdown cho dễ chọn)
        [WebMethod]
        public static string GetArtists()
        {
            List<object> data = new List<object>();
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("SELECT ArtistID, Name FROM Artists", conn);
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    data.Add(new { id = r["ArtistID"], name = r["Name"] });
                }
            }
            return new JavaScriptSerializer().Serialize(data);
        }

        // 2. LẤY DANH SÁCH BÀI HÁT (Để hiện lên bảng Admin)
        [WebMethod]
        public static string GetAdminSongs()
        {
            List<object> data = new List<object>();
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                // Lấy cả ID ca sĩ để lúc sửa còn biết đường chọn lại
                string query = @"SELECT s.SongID, s.Title, s.Url, s.Image, s.Duration, s.ArtistID, a.Name as ArtistName 
                             FROM Songs s JOIN Artists a ON s.ArtistID = a.ArtistID ORDER BY s.SongID DESC";

                conn.Open();
                SqlCommand cmd = new SqlCommand(query, conn);
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    data.Add(new
                    {
                        id = r["SongID"],
                        title = r["Title"],
                        url = r["Url"],
                        img = r["Image"],
                        dur = r["Duration"],
                        artId = r["ArtistID"],
                        artName = r["ArtistName"]
                    });
                }
            }
            return new JavaScriptSerializer().Serialize(data);
        }

        // 3. LƯU BÀI HÁT (XỬ LÝ CẢ THÊM MỚI VÀ CẬP NHẬT)
        [WebMethod]
        public static string SaveSong( int id, string title, int artistId, string url, string img, int duration )
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    string query = "";

                    // Nếu ID = 0 -> Là Thêm mới (INSERT)
                    if (id == 0)
                    {
                        query = "INSERT INTO Songs (Title, ArtistID, Url, Image, Duration, ViewCount) VALUES (@t, @a, @u, @i, @d, 0)";
                    }
                    // Nếu ID > 0 -> Là Cập nhật (UPDATE)
                    else
                    {
                        query = "UPDATE Songs SET Title=@t, ArtistID=@a, Url=@u, Image=@i, Duration=@d WHERE SongID=@id";
                    }

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@t", title);
                    cmd.Parameters.AddWithValue("@a", artistId);
                    cmd.Parameters.AddWithValue("@u", url);
                    cmd.Parameters.AddWithValue("@i", img);
                    cmd.Parameters.AddWithValue("@d", duration);
                    if (id > 0) cmd.Parameters.AddWithValue("@id", id);

                    cmd.ExecuteNonQuery();
                    return "ok";
                }
            }
            catch (Exception ex) { return "Lỗi: " + ex.Message; }
        }

        // 4. XÓA BÀI HÁT
        [WebMethod]
        public static string DeleteSong( int id )
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    // Phải xóa trong bảng Favorites trước nếu có ràng buộc khóa ngoại
                    SqlCommand cmdFav = new SqlCommand("DELETE FROM Favorites WHERE SongID = @id", conn);
                    cmdFav.Parameters.AddWithValue("@id", id);
                    cmdFav.ExecuteNonQuery();

                    // Sau đó mới xóa bài hát
                    SqlCommand cmd = new SqlCommand("DELETE FROM Songs WHERE SongID = @id", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                    return "ok";
                }
            }
            catch (Exception ex) { return "Lỗi: " + ex.Message; }
        }

        // 5. LƯU CA SĨ (Thêm hoặc Sửa)
        [WebMethod]
        public static string SaveArtist( int id, string name )
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    string query = "";
                    if (id == 0) // Thêm mới
                        query = "INSERT INTO Artists (Name) VALUES (@n)";
                    else // Sửa
                        query = "UPDATE Artists SET Name=@n WHERE ArtistID=@id";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@n", name);
                    if (id > 0) cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                    return "ok";
                }
            }
            catch (Exception ex) { return "Lỗi: " + ex.Message; }
        }

        // 6. XÓA CA SĨ
        [WebMethod]
        public static string DeleteArtist( int id )
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(GetConn()))
                {
                    conn.Open();
                    // Kiểm tra xem ca sĩ này có bài hát nào không? Nếu có thì KHÔNG ĐƯỢC XÓA (Ràng buộc khóa ngoại)
                    SqlCommand check = new SqlCommand("SELECT COUNT(*) FROM Songs WHERE ArtistID = @id", conn);
                    check.Parameters.AddWithValue("@id", id);
                    int count = (int)check.ExecuteScalar();

                    if (count > 0)
                    {
                        return "Không thể xóa! Ca sĩ này đang có " + count + " bài hát. Hãy xóa bài hát trước.";
                    }

                    // Nếu sạch sẽ rồi thì xóa
                    SqlCommand cmd = new SqlCommand("DELETE FROM Artists WHERE ArtistID = @id", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                    return "ok";
                }
            }
            catch (Exception ex) { return "Lỗi: " + ex.Message; }
        }

        //End
    }
}