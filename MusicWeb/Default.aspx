<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="MusicWeb._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <asp:SqlDataSource ID="srcNhac" runat="server" 
    ConnectionString="<%$ ConnectionStrings:MusicWebDB %>"
    SelectCommand="SELECT * FROM BaiHat">
</asp:SqlDataSource>

<div style="width: 100%; text-align: center;">
    <h2>KHO NHẠC CỦA NGHĨA</h2>
    
    <asp:DataList ID="dlNhac" runat="server" DataSourceID="srcNhac" 
        RepeatColumns="3" RepeatDirection="Horizontal" Width="100%">
        
        <ItemTemplate>
            <div style="border: 1px solid #ccc; margin: 10px; padding: 10px; border-radius: 10px; width: 250px;">
                
                <asp:Image ID="imgBia" runat="server" 
                    ImageUrl='<%# "~/src/thumbnail/" + Eval("AnhBia") + ".jpg" %>' 
                    Width="200px" Height="200px" style="object-fit: cover;" />
                <br /><br />

                <asp:Label ID="lblTen" runat="server" 
                    Text='<%# Eval("TenBaiHat") %>' 
                    Font-Bold="true" Font-Size="Large"></asp:Label>
                <br />

                <asp:Label ID="lblCaSi" runat="server" 
                    Text='<%# Eval("CaSi") %>' ForeColor="Gray"></asp:Label>
                <br /><br />

                <a href='Player.aspx?id=<%# Eval("MaBaiHat") %>' 
                   style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
                   🎧 NGHE NGAY
                </a>

            </div>
        </ItemTemplate>

    </asp:DataList>
</div>
    </main>

</asp:Content>
