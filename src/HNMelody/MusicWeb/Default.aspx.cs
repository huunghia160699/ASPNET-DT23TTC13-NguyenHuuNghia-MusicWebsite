using System; // Thư viện cơ bản
using System.Collections.Generic; // Dùng cho List
using System.Data; // Làm việc với dữ liệu
using System.Data.SqlClient; // Kết nối SQL Server
using System.Web.Script.Serialization; // Convert object sang JSON
using System.Web.Services; // Dùng WebMethod
using System.Configuration; // Đọc connection string

namespace HNMelody
{
    // Code-behind cho trang Default.aspx
    public partial class Default : System.Web.UI.Page
    {
        // Hàm chạy khi trang load
        protected void Page_Load( object sender, EventArgs e ) { }

        // Hàm lấy chuỗi kết nối CSDL
        public static string GetConn()
        {
            return ConfigurationManager.ConnectionStrings["MusicWebDB"].ConnectionString;
        }

        // WebMethod: Lấy danh sách bài hát (có tìm kiếm)
        [WebMethod]
        public static string GetSongs( string keyword )
        {
            // Danh sách lưu bài hát
            List<object> songs = new List<object>();

            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                // Câu truy vấn lấy bài hát + ca sĩ + lượt thích
                string query = @"
                    SELECT s.SongID, s.Title, a.Name AS ArtistName, s.Url, s.Image, s.Duration, s.ViewCount,
                    (SELECT COUNT(*) FROM Favorites f WHERE f.SongID = s.SongID) as FavCount
                    FROM Songs s
                    JOIN Artists a ON s.ArtistID = a.ArtistID";

                // Nếu có từ khóa tìm kiếm
                if (!string.IsNullOrEmpty(keyword))
                {
                    keyword = keyword.Trim(); // Xóa khoảng trắng thừa

                    // Điều kiện lọc theo tên bài hát hoặc ca sĩ (không phân biệt dấu)
                    query += @" 
                        WHERE 
                            (s.Title COLLATE Latin1_General_CI_AI LIKE @kwFull) OR 
                            (a.Name COLLATE Latin1_General_CI_AI LIKE @kwFull)";

                    // Sắp xếp ưu tiên kết quả tìm kiếm
                    query += @" 
                        ORDER BY 
                        CASE 
                            WHEN s.Title COLLATE Latin1_General_CI_AI LIKE @kwStart THEN 1
                            WHEN a.Name COLLATE Latin1_General_CI_AI LIKE @kwStart THEN 2
                            WHEN s.Title COLLATE Latin1_General_CI_AI LIKE @kwFull THEN 3
                            ELSE 4 
                        END,
                        s.ViewCount DESC";
                }
                else
                {
                    // Không tìm kiếm thì sắp xếp theo lượt nghe
                    query += " ORDER BY s.ViewCount DESC";
                }

                // Tạo command SQL
                SqlCommand cmd = new SqlCommand(query, conn);

                if (!string.IsNullOrEmpty(keyword))
                {
                    // Tham số tìm "bắt đầu bằng"
                    cmd.Parameters.AddWithValue("@kwStart", keyword + "%");

                    // Tham số tìm "chứa"
                    cmd.Parameters.AddWithValue("@kwFull", "%" + keyword + "%");
                }

                // Mở kết nối CSDL
                conn.Open();

                // Đọc dữ liệu
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    // Thêm từng bài hát vào danh sách
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

            // Trả dữ liệu về dạng JSON
            return new JavaScriptSerializer().Serialize(songs);
        }

        // WebMethod: Xử lý đăng nhập
        [WebMethod]
        public static string Login( string username, string password )
        {
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                // Truy vấn kiểm tra tài khoản
                string query = "SELECT * FROM Users WHERE Username = @u AND Password = @p";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);

                // Mở kết nối
                conn.Open();

                SqlDataReader r = cmd.ExecuteReader();
                if (r.Read())
                {
                    // Tạo object user
                    var user = new
                    {
                        id = r["UserID"],
                        username = r["Username"],
                        fullname = r["FullName"],
                        avatar = r["Avatar"]
                    };

                    // Trả thông tin user dạng JSON
                    return new JavaScriptSerializer().Serialize(user);
                }
            }

            // Trả null nếu đăng nhập thất bại
            return null;
        }

        // WebMethod: Xử lý đăng ký tài khoản
        [WebMethod]
        public static string Register( string fullname, string username, string password )
        {
            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                conn.Open();

                // Kiểm tra trùng username
                SqlCommand check = new SqlCommand(
                    "SELECT COUNT(*) FROM Users WHERE Username = @u", conn);
                check.Parameters.AddWithValue("@u", username);

                if ((int)check.ExecuteScalar() > 0)
                    return "exist"; // Username đã tồn tại

                // Thêm tài khoản mới
                string query = "INSERT INTO Users (FullName, Username, Password) VALUES (@n, @u, @p)";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@n", fullname);
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@p", password);
                cmd.ExecuteNonQuery();

                return "success"; // Đăng ký thành công
            }
        }

        // WebMethod: Lấy danh sách tài khoản test
        [WebMethod]
        public static string GetTestAccounts()
        {
            // Danh sách user demo
            List<object> users = new List<object>();

            using (SqlConnection conn = new SqlConnection(GetConn()))
            {
                // Lấy 5 tài khoản đầu tiên
                string query = "SELECT TOP 5 Username, Password, FullName, Avatar FROM Users";
                SqlCommand cmd = new SqlCommand(query, conn);

                conn.Open();
                SqlDataReader r = cmd.ExecuteReader();
                while (r.Read())
                {
                    // Thêm user vào danh sách test
                    users.Add(new
                    {
                        u = r["Username"],
                        p = r["Password"], // Chỉ dùng cho môi trường demo
                        n = r["FullName"],
                        a = r["Avatar"]
                    });
                }
            }

            // Trả danh sách test account dạng JSON
            return new JavaScriptSerializer().Serialize(users);
        }
    }
}
