const searchInput = document.getElementById("searchInput");
const searchDropdown = document.getElementById("searchDropdown");
const closeIcon = document.querySelector(".close-icon");
const searchBar = document.querySelector(".search-bar");

// Hiện khi focus
function showSearch() {
  searchDropdown.style.display = "block";
  setTimeout(() => {
    searchDropdown.style.opacity = "1";
    searchDropdown.style.visibility = "visible";
  }, 200);
}

// Ẩn khi click ra ngoài (Delayed để kịp bấm vào link)
function hideSearchDelayed() {
  searchDropdown.style.opacity = "0";
  searchDropdown.style.visibility = "hidden";
  setTimeout(() => {
    searchDropdown.style.display = "none";
  }, 200);
}

// Xử lý nút X

// Xóa chữ khi bấm X
function clearSearch() {
  searchInput.value = "";
  closeIcon.style.display = "none";
  searchInput.focus();
}
document.addEventListener("DOMContentLoaded", function () {
  const greetingElement = document.getElementById("greetingText");

  // 1. Hàm lấy câu chào theo giờ
  function getGreeting() {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return "Good Morning ☀️";
    if (hour >= 12 && hour < 18) return "Good Afternoon 🌤️";
    return "Good Evening 🌙";
  }

  // 2. Hàm tách chữ và tạo HTML
  function renderText() {
    const text = getGreeting();
    greetingElement.innerHTML = ""; // Xóa cũ

    // Tách từng ký tự ra
    [...text].forEach((char, index) => {
      if (char === " ") {
        // Nếu là khoảng trắng
        const span = document.createElement("span");
        span.className = "space";
        greetingElement.appendChild(span);
      } else {
        // Nếu là chữ cái
        const span = document.createElement("span");
        span.innerText = char;
        span.className = "char";
        // Gán biến CSS để tính độ trễ (delay) cho từng chữ
        span.style.animationDelay = `${index * 0.05}s`;
        greetingElement.appendChild(span);
      }
    });
  }

  // 3. Hàm kích hoạt hiệu ứng Wave
  function triggerWave() {
    const chars = document.querySelectorAll(".char");

    // Thêm class 'waving' để chạy animation
    chars.forEach((char) => {
      char.classList.remove("waving"); // Reset trước
      void char.offsetWidth; // Hack để trình duyệt nhận diện reset
      char.classList.add("waving"); // Chạy lại
    });
  }

  // --- KHỞI CHẠY ---
  renderText(); // 1. Hiện chữ lên ngay lập tức

  // 2. Chạy hiệu ứng lần đầu tiên sau 1 giây (cho người dùng kịp nhìn)
  setTimeout(triggerWave, 1000);

  // 3. Cài đặt lặp lại mỗi 60 giây (60000 ms)
  setInterval(triggerWave, 60000);
});

function toggleUserPopup() {
  var popup = document.getElementById("userPopup");

  if (popup.style.display === "block") {
    popup.style.display = "none";
  } else {
    popup.style.display = "block";
  }
}

// Bấm ra ngoài thì đóng popup
document.addEventListener("click", function (event) {
  var popup = document.getElementById("userPopup");
  var btn = document.getElementById("userBtn");

  // Nếu cái được click KHÔNG PHẢI là popup VÀ KHÔNG PHẢI là nút avatar
  if (!popup.contains(event.target) && !btn.contains(event.target)) {
    popup.style.display = "none";
  }
});
