## Link Video: https://drive.google.com/file/d/1z1wW9Onz1amHk9TwoZzkBr96gEDj5f-3/view?usp=sharing

## Giới thiệu
**Simple Offline Music Player** là một ứng dụng nghe nhạc **offline** được xây dựng bằng **Flutter**, cho phép người dùng phát nhạc trực tiếp từ các file audio lưu trữ trên thiết bị.

Ứng dụng tập trung vào:
- Quản lý phát nhạc
- Đọc thư viện nhạc cục bộ từ thiết bị
- Mini player + màn hình Now Playing
- Shuffle / Repeat
- Phát nhạc nền (background playback)
- Lưu trạng thái phát nhạc và tuỳ chọn người dùng

---

## Tính năng chính

### Music Library
- Quét và hiển thị **toàn bộ bài hát** trong thiết bị
- Sắp xếp theo tiêu đề
- Hiển thị tên bài hát, nghệ sĩ, thời lượng

### Audio Playback
- Play / Pause
- Next / Previous
- Seek (kéo thanh thời gian)
- Điều chỉnh Volume
- Phát nhạc khi app chạy nền

### Playback Modes
- Shuffle (phát ngẫu nhiên)
- Repeat:
  - Off
  - Repeat All
  - Repeat One

### UI / UX
- Home Screen (Danh sách bài hát)
- Mini Player (luôn hiển thị khi đang phát)
- Now Playing Screen (full controls)
- Giao diện tối (Dark theme – Spotify style)

### Persistence
- Lưu:
  - Trạng thái Shuffle
  - Chế độ Repeat
  - Volume
  - Bài hát phát gần nhất

---

## 🛠 Công nghệ sử dụng

| Công nghệ | Mục đích |
|---------|---------|
| Flutter | Xây dựng UI & logic |
| Provider | State management |
| just_audio | Phát nhạc |
| on_audio_query | Truy cập thư viện nhạc |
| permission_handler | Xin quyền hệ thống |
| shared_preferences | Lưu trạng thái |
| rxdart | Kết hợp stream |


---


Đã kiểm tra:

* Play / Pause / Next / Previous
* Seek bài hát
* Shuffle & Repeat
* Phát nhạc nền
* Lưu trạng thái sau khi restart app
* Xử lý khi không có quyền hoặc không có nhạc
