using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MusicWeb.Controls
{
    public partial class SideBarControl : System.Web.UI.UserControl
    {
        public class SidebarMenuItem
        {
            public string Text { get; set; }
            public string Icon { get; set; }
            public string Url { get; set; }
            public bool IsActive { get; set; }
        }

        private void LoadSidebarMenu()
        {
            // 2. Tạo danh sách dữ liệu
            List<SidebarMenuItem> SidebarMenuList = new List<SidebarMenuItem>
            {
                new SidebarMenuItem { Text = "Discovery", Icon = "fa-chart-simple", Url = "#", IsActive = true }, 
                new SidebarMenuItem { Text = "For You", Icon = "fa-chart-line", Url = "#", IsActive = false },
                new SidebarMenuItem { Text = "Me", Icon = "fa-user", Url = "#", IsActive = false },
                new SidebarMenuItem { Text = "Radio", Icon = "fa-radio", Url = "#", IsActive = false }
            };

            // 3. Đổ dữ liệu vào Repeater
            rptSidebar.DataSource = SidebarMenuList;
            rptSidebar.DataBind();

            List<SidebarMenuItem> SidebarLibraryList = new List<SidebarMenuItem>
            {
                new SidebarMenuItem { Text = "Favorite Songs", Icon = "fa-heart", Url = "#", IsActive = false },
                new SidebarMenuItem { Text = "Recently played", Icon = "fa-clock-rotate-left", Url = "#", IsActive = false },
                new SidebarMenuItem { Text = "My playlist", Icon = "fa fa-music", Url = "#", IsActive = false },
            };

            rptSidebarLibrary.DataSource = SidebarLibraryList;
            rptSidebarLibrary.DataBind();

        }
        protected void Page_Load( object sender, EventArgs e )
        {
            if (!IsPostBack)
            {
                LoadSidebarMenu();
            }
        }
    }
}