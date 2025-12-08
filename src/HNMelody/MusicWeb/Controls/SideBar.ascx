<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SideBar.ascx.cs" Inherits="MusicWeb.Controls.SideBarControl" %>

<div class="logo">
    <i class="fa-solid fa-circle-play"></i>NCT Music
</div>

<ul class="sidebar-menu-list" id="sidebarMenu">

    <asp:Repeater ID="rptSidebar" runat="server">
        <ItemTemplate>
            <li class="sidebar-click-item <%# (bool)Eval("IsActive") ? "active" : "" %>">

                <a href='<%# Eval("Url") %>'>
                    <i class='fa-solid <%# Eval("Icon") %>'></i>
                    <span><%# Eval("Text") %></span>
                </a>

            </li>
        </ItemTemplate>
    </asp:Repeater>

</ul>

<div class="sidebar-library-section">
    <div class="sidebar-title">
        <p>MY LIBRARY</p>
    </div>
    <ul class="sidebar-library-list">

        <asp:Repeater ID="rptSidebarLibrary" runat="server">
            <ItemTemplate>
                <li class="sidebar-click-item <%# (bool)Eval("IsActive") ? "active" : "" %>">

                    <a href='<%# Eval("Url") %>'>
                        <i class='fa-solid <%# Eval("Icon") %>'></i>
                        <span><%# Eval("Text") %></span>
                         <%# Eval("Text").ToString() == "My playlist" ? "<i class='fa-solid fa-chevron-down toggle-arrow'></i>" : "" %>
                    </a>

                </li>
            </ItemTemplate>
        </asp:Repeater>

    </ul>
    <ul class="sidebar-playlist">
        <li class="sidebar-playlist-item">
            <a href="#">Nhạc buồn</a>
        </li>
        <li class="sidebar-playlist-item">
            <a href="#">Nhạc buồn</a>
        </li>
        <li class="sidebar-playlist-item">
            <a href="#">Nhạc buồn</a>
        </li>
    </ul>
</div>



<div class="sidebar-user" id="sidebarUser">
    <div class="sidebar-user-avatar">
        <span>H</span>
    </div>

    <div class="sidebar-user-info">
        <h4 class="sidebar-user-name">Huu Nghia</h4>
        <p class="sidebar-user-status">Gói miễn phí</p>
    </div>

    <div class="sidebar-user-action">
        <i class="fa-solid fa-chevron-right"></i>
    </div>
    <!--  -->

    <div class="sidebar-user-popup" id="sidebarUserPopup">
        <div class="sidebar-popup-header">
            <h3 class="p-name">Huu Nghia</h3>
            <p class="p-email">huunghia.160699@gmail.com</p>
        </div>

        <ul class="sidebar-popup-menu">
            <li class="sidebar-popup-menu-item">
                <span>Chất lượng nhạc</span>
                <span class="value">LOSSLESS <i class="fa-solid fa-chevron-down"></i>
                </span>
            </li>
            <li class="sidebar-popup-menu-item">
                <span>Ngôn ngữ</span>
                <span class="value">VN <i class="fa-solid fa-chevron-down"></i>
                </span>
            </li>
            <li class="sidebar-popup-menu-item" onclick="toggleTheme()">
                <span>Giao diện</span>
                <span class="value">Tối <i class="fa-solid fa-chevron-down"></i>
                </span>
            </li>
            <li class="sidebar-popup-menu-item">
                <span>Kết nối thiết bị</span>
                <i class="fa-solid fa-mobile-screen"></i>
            </li>
        </ul>

        <div class="sidebar-popup-banner">
            <h4>Nâng cấp gói VIP ngay</h4>
            <p>
                Nghe nhạc không quảng cáo, chất lượng cao nhất và lưu trữ không
              giới hạn.
            </p>
        </div>

        <button class="sidebar-btn-logout" onclick="location.href='Login.aspx'">
            Đăng xuất
        </button>

        <div class="sidebar-popup-footer">
            <a href="#">Quyền riêng tư</a> • <a href="#">Điều khoản</a>
        </div>
    </div>
</div>

