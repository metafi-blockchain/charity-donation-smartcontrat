# TÀI LIỆU MIGRATION HỆ THỐNG TỪ THIỆN

## 1. MỤC ĐÍCH VÀ PHẠM VI

### 1.1 Mục đích chuyển đổi
- Chuyển đổi toàn bộ dữ liệu từ hệ thống từ thiện hiện tại sang hệ thống hợp đồng thông minh blockchain trên mạng Avalanche C-Chain.
- Nâng cao tính minh bạch và khả năng kiểm chứng của các hoạt động quyên góp.

### 1.2 Phạm vi dữ liệu cần chuyển đổi
- **Người dùng:** Hơn 10,000 tài khoản người dùng với thông tin cá nhân
- **Chiến dịch:** Hơn 3,000 chiến dịch từ thiện đã và đang hoạt động
- **Giao dịch quyên góp:** Hơn 12,500 giao dịch quyên góp từ năm 2023-2025
- **Giao dịch rút tiền:** Hơn 180 giao dịch rút tiền của quản trị viên các chiến dịch
- **Tệp phương tiện:** Hình ảnh, video và tài liệu đính kèm

### 1.3 Hệ thống đích
- **Blockchain:** Avalanche C-Chain (Mạng thử nghiệm Fuji)
- **Hợp đồng thông minh:** `Campaign.sol`, `Manager.sol`, `CurrencyConvert.sol`, `Token.sol`
- **API Backend:** MetaFi Charity API phiên bản 1
- **Giao diện người dùng:** Ứng dụng React với tích hợp blockchain

---

## 2. KIẾN TRÚC CHUYỂN ĐỔI

### 2.1 Tổng quan kiến trúc

```
Hệ thống Cũ → Đường ống Chuyển đổi → Blockchain + Cơ sở dữ liệu API → Ứng dụng Web
```

### 2.2 Các thành phần chính

#### Hệ thống Cũ (Nguồn)
- Cơ sở dữ liệu MySQL/PostgreSQL chứa dữ liệu hiện tại
- Lưu trữ tệp cho tài nguyên phương tiện
- Xác thực người dùng và quản lý phiên làm việc

#### Đường ống Chuyển đổi (Xử lý)
- Công cụ trích xuất và xác thực dữ liệu
- Script deploy contract `Campaign.sol` độc lập cho từng chiến dịch
- Thực thi và giám sát giao dịch donate/withdraw
- Đồng bộ hóa dữ liệu với cơ sở dữ liệu API

#### Hệ thống Đích (Đích đến)
- Các smart contract `Campaign.sol` độc lập trên blockchain Avalanche
- Token VND (ERC20) với tỷ giá 1:1
- Cơ sở dữ liệu MongoDB cho API backend
- Lưu trữ AWS S3 cho tệp phương tiện
- Giao diện React với tích hợp blockchain

### 2.3 Luồng dữ liệu chuyển đổi
1. **Trích xuất:** Xuất dữ liệu từ hệ thống cũ
2. **Biến đổi:** Chuyển đổi định dạng và xác thực dữ liệu
3. **Triển khai:** Triển khai hợp đồng thông minh
4. **Tải:** Thực hiện giao dịch blockchain
5. **Đồng bộ:** Đồng bộ dữ liệu với cơ sở dữ liệu API
6. **Xác minh:** Kiểm tra tính chính xác

---

## 3. QUY TRÌNH CHUYỂN ĐỔI CHI TIẾT

### 3.1 Giai đoạn chuẩn bị

#### 3.1.1 Phân tích và đánh giá dữ liệu nguồn
- Kiểm toán chất lượng dữ liệu hệ thống cũ
- Xác định các vấn đề không nhất quán và tính toàn vẹn dữ liệu
- Tạo báo cáo chất lượng dữ liệu và kế hoạch khắc phục
- Sao lưu toàn bộ dữ liệu hệ thống cũ

#### 3.1.2 Thiết lập môi trường chuyển đổi
- Thiết lập kết nối mạng thử nghiệm Avalanche Fuji
- Chuẩn bị địa chỉ ví cho các hoạt động quản trị
- Cấu hình giá gas và tham số giao dịch
- Thiết lập cơ sở hạ tầng giám sát và ghi nhật ký

#### 3.1.3 Trích xuất và biến đổi dữ liệu
- Xuất dữ liệu người dùng với mã hóa thích hợp cho thông tin nhạy cảm
- Trích xuất thông tin chiến dịch với tham chiếu phương tiện
- Lấy lịch sử quyên góp với ánh xạ giao dịch ngân hàng
- Tạo bản ghi rút tiền với quy trình phê duyệt

### 3.2 Giai đoạn triển khai blockchain

#### 3.2.1 Triển khai hợp đồng thông minh
- **Hợp đồng Token VND**
  - Triển khai hợp đồng token ERC20 với ký hiệu "VND"
  - Đặt nguồn cung ban đầu dựa trên tổng số dư trong hệ thống cũ
  - Cấu hình quyền tạo token cho quá trình chuyển đổi
- **Hợp đồng Chuyển đổi Tiền tệ**
  - Triển khai hợp đồng với cấu hình vai trò quản trị
  - Thiết lập tỷ lệ chuyển đổi: 1 VND = 1 token (tỷ lệ 1:1)
  - Cấu hình quyền cập nhật tỷ giá
- **Hợp đồng Quản lý**
  - Triển khai với tham chiếu đến hợp đồng Chuyển đổi Tiền tệ
  - Cấp vai trò `ADMIN_ROLE` cho tài khoản vận hành chuyển đổi
  - Thiết lập ghi nhật ký sự kiện cho theo dõi tạo chiến dịch

#### 3.2.2 Thiết lập người dùng và ví
- Tạo ví blockchain cho mỗi người dùng cũ
- Triển khai lưu trữ khóa riêng an toàn với mã hóa
- Tạo token VND tương ứng với số dư cũ
- Tạo bảng ánh xạ: `legacy_user_id` ↔ `blockchain_address`

#### 3.2.3 Triển khai hợp đồng chiến dịch độc lập
- Chạy script deploy contract `Campaign.sol` cho từng chiến dịch riêng biệt
- Mỗi chiến dịch sẽ có một smart contract `Campaign.sol` độc lập trên C-Chain
- Gán admin và manager tương ứng theo dữ liệu cũ
- Lưu trữ địa chỉ smart contract trong hệ thống backend và đồng bộ về frontend

### 3.3 Giai đoạn chuyển đổi dữ liệu

#### 3.3.1 Chiến lược chuyển đổi giao dịch
- **Chuyển đổi Quyên góp**
  - Chạy script thực hiện gọi hàm `donate(token, amount)` trên contract tương ứng
  - Xử lý quyên góp theo thứ tự thời gian
  - Thực hiện `approve()` trước mỗi giao dịch `donate()`
  - Lưu trữ các thông tin cần thiết: `user_address`, `token_address`, `amount`, `campaign_contract`, `timestamp`
  - Lưu lại mapping giữa transaction ngân hàng (bank transaction ID) và transaction hash trên blockchain
  - Đảm bảo các giao dịch chuyển đổi hợp lệ và có thể truy vết được
- **Chuyển đổi Rút tiền**
  - Xử lý rút tiền của quản trị viên theo trình tự lịch sử
  - Thực hiện `Campaign.withdraw()` với xác thực phù hợp
  - Ghi lại lý do rút tiền và quy trình phê duyệt
  - Duy trì dấu vết kiểm toán liên kết bản ghi cũ và blockchain

#### 3.3.2 Đồng bộ hóa cơ sở dữ liệu API
- Tạo bản ghi quyên góp qua điểm cuối `POST /api/v1/donations`
- Bao gồm cờ `migration_source` và tham chiếu blockchain
- Lưu trữ URL explorer cho xác minh giao dịch
- Duy trì khả năng tương thích ngược với ID giao dịch cũ

#### 3.3.3 Chuyển đổi phương tiện và metadata
- Tải hình ảnh/video chiến dịch lên AWS S3
- Cập nhật tham chiếu cơ sở dữ liệu từ đường dẫn cũ sang URL S3
- Duy trì quy trình xử lý và tối ưu hóa hình ảnh
- Tạo liên kết thư viện trong bản ghi chiến dịch

### 3.4 Giai đoạn xác minh

#### 3.4.1 Kiểm tra tính nhất quán dữ liệu
- **Xác minh Số dư**
  - Kiểm tra số dư tổng hợp trên các campaign
  - So sánh tổng quyên góp: tổng tiền chuyển khoản theo hệ thống cũ vs số dư blockchain
  - Kiểm tra số tiền rút: bản ghi cũ vs rút tiền blockchain
  - Xác minh tổng quyên góp của từng người dùng
  - Ghi nhận sai lệch nếu có để xử lý thủ công hoặc báo cáo
- **Xác minh Giao dịch**
  - Khớp mỗi giao dịch cũ với đối tác blockchain
  - Xác minh dấu thời gian và số tiền giao dịch
  - Kiểm tra phân bổ người quyên góp và chỉ định chiến dịch
  - Xác thực chuyển token và cập nhật số dư

#### 3.4.2 Kiểm thử chức năng
- Kiểm tra quy trình quyên góp với chiến dịch đã chuyển đổi
- Xác minh quyền rút tiền và quy trình
- Kiểm tra hiển thị chiến dịch và danh sách người quyên góp
- Xác thực lịch sử quyên góp hồ sơ người dùng

---

## 4. TÍCH HỢP API VÀ CẤU TRÚC CƠ SỞ DỮ LIỆU

### 4.1 Cấu trúc bản ghi quyên góp
```json
{
  "id": "mã_quyên_góp_duy_nhất",
  "campaign_id": "tham_chiếu_chiến_dịch", 
  "user_id": "id_người_quyên_góp",
  "donor_wallet_address": "0x...",
  "token_address": "0x...",
  "token_symbol": "VND",
  "amount_original": "số_tiền_quyên_góp",
  "amount_wei": "số_tiền_định_dạng_blockchain",
  "blockchain_tx_hash": "0x...",
  "bank_transaction_id": "tham_chiếu_cũ",
  "message": "tin_nhắn_người_quyên_góp",
  "donation_time": "thời_gian_ISO",
  "block_number": "khối_blockchain",
  "gas_used": "gas_giao_dịch",
  "tx_fee": "phí_gas",
  "status": "ĐÃ_XÁC_NHẬN",
  "migration_source": true,
  "explorer_url": "liên_kết_explorer_blockchain"
}
```

### 4.2 Cấu trúc ánh xạ chiến dịch
```json
{
  "legacy_campaign_id": "id_hệ_thống_cũ",
  "blockchain_contract_address": "0x...",
  "manager_contract_address": "0x...", 
  "admin_wallet_address": "0x...",
  "creation_tx_hash": "0x...",
  "migration_timestamp": "thời_gian_ISO",
  "verification_status": "ĐÃ_XÁC_MINH"
}
```

### 4.3 Ánh xạ ví người dùng
```json
{
  "legacy_user_id": "id_người_dùng_cũ",
  "blockchain_wallet_address": "0x...",
  "private_key_encrypted": "khóa_riêng_mã_hóa",
  "seed_phrase_encrypted": "cụm_từ_seed_mã_hóa",
  "initial_vnd_balance": "số_token_chuyển_đổi",
  "wallet_creation_tx": "0x...",
  "migration_status": "HOÀN_THÀNH"
}
```

---

## 5. TÍCH HỢP GIAO DIỆN NGƯỜI DÙNG

### 5.1 Cập nhật giao diện người dùng

#### 5.1.1 Cải tiến chi tiết chiến dịch
- Hiển thị huy hiệu xác minh blockchain cho chiến dịch đã chuyển đổi
- Hiển thị địa chỉ hợp đồng với liên kết đến explorer mạng thử nghiệm Fuji
- Thêm phần "Chuyển đổi Di sản" với dòng thời gian chuyển đổi
- Bao gồm công cụ xác minh giao dịch cho người dùng

#### 5.1.2 Trình bày lịch sử quyên góp
- Đánh dấu quyên góp đã chuyển đổi với huy hiệu "Hệ thống Cũ"
- Cung cấp liên kết explorer blockchain cho mỗi giao dịch
- Hiển thị ngày chuyển đổi và trạng thái xác minh
- Cho phép người dùng xác minh quyên góp một cách độc lập

#### 5.1.3 Phần chuyển đổi hồ sơ người dùng
- Hiển thị tóm tắt chuyển đổi với tổng số tiền
- Hiển thị địa chỉ ví blockchain và trạng thái kết nối
- Liệt kê quyên góp đã chuyển đổi với liên kết xác minh
- Cung cấp chứng chỉ chuyển đổi hoặc bằng chứng chuyển giao

### 5.2 Bảng điều khiển xác minh quản trị

#### 5.2.1 Công cụ giám sát chuyển đổi
- Theo dõi tiến độ chuyển đổi thời gian thực
- Giám sát tính nhất quán dữ liệu và cảnh báo
- Phát hiện lỗi giao dịch và cơ chế thử lại
- Khả năng xuất cho báo cáo kiểm toán

#### 5.2.2 Quy trình xác minh
- Trạng thái xác minh từng chiến dịch
- Theo dõi hoàn thành chuyển đổi người dùng
- Báo cáo đối chiếu tài chính
- Công cụ điều tra sự khác biệt

---

## 6. AN TOÀN VÀ TUÂN THỦ

### 6.1 Biện pháp bảo vệ dữ liệu
- Mã hóa dữ liệu nhạy cảm trong đường ống chuyển đổi
- Triển khai quản lý khóa an toàn cho ví blockchain
- Duy trì nhật ký kiểm toán cho tất cả hoạt động chuyển đổi
- Đảm bảo tuân thủ GDPR cho xử lý dữ liệu cá nhân

### 6.2 Kiểm soát độ chính xác tài chính
- Xác minh đa cấp cho dữ liệu tài chính
- Phân chia nhiệm vụ trong quy trình phê duyệt chuyển đổi
- Xác minh độc lập số dư blockchain
- Quy trình hoàn tác cho lỗi nghiêm trọng

### 6.3 Kiểm soát truy cập và quyền hạn
- Truy cập dựa trên vai trò cho hoạt động chuyển đổi
- Yêu cầu đa chữ ký cho giao dịch giá trị cao
- Token truy cập có thời hạn cho kịch bản chuyển đổi
- Ghi nhật ký toàn diện các hoạt động đặc quyền

---

## 7. QUẢN LÝ RỦI RO VÀ TÌNH HUỐNG KHẨN CẤP

### 7.1 Rủi ro đã xác định và giảm thiểu
- **Rủi ro Mất dữ liệu**
  - Giảm thiểu: Nhiều bản sao lưu và phương pháp chuyển đổi theo giai đoạn
  - Khôi phục: Khôi phục từ điểm sao lưu đã xác minh
- **Rủi ro Sự khác biệt Tài chính**
  - Giảm thiểu: Kiểm tra xác minh toàn diện và đối chiếu
  - Khôi phục: Quy trình điều tra và sửa chữa thủ công
- **Vấn đề Mạng Blockchain**
  - Giảm thiểu: Giám sát giá gas và cơ chế thử lại
  - Khôi phục: Gửi lại giao dịch với tham số đã điều chỉnh

### 7.2 Quy trình hoàn tác
- Tạo điểm kiểm tra tại các cột mốc chuyển đổi chính
- Khả năng triển khai lại hợp đồng thông minh
- Quy trình khôi phục cơ sở dữ liệu
- Kế hoạch thông báo và giao tiếp người dùng

### 7.3 Hỗ trợ sau chuyển đổi
- Giáo dục người dùng về xác minh blockchain
- Đào tạo đội hỗ trợ cho các truy vấn liên quan đến chuyển đổi
- Cập nhật tài liệu và hướng dẫn người dùng
- Giám sát liên tục hiệu suất hệ thống

---

## 8. TIÊU CHÍ THÀNH CÔNG VÀ XÁC THỰC

### 8.1 Tiêu chí thành công định lượng
- Tỷ lệ hoàn thành chuyển đổi dữ liệu 100%
- Không có sự khác biệt tài chính trong đối chiếu cuối cùng
- Tỷ lệ lỗi giao dịch <0.1% trong quá trình chuyển đổi
- Tỷ lệ thành công xác minh người dùng >95%

### 8.2 Chỉ số thành công định tính
- Niềm tin của người dùng vào xác minh blockchain
- Cải thiện nhận thức về tính minh bạch
- Giảm các truy vấn hỗ trợ về tính toàn vẹn dữ liệu
- Tăng cường tin tưởng vào hoạt động nền tảng

### 8.3 Giám sát sau chuyển đổi
- Xác minh liên tục dữ liệu blockchain
- Giám sát hiệu suất các hệ thống tích hợp
- Theo dõi việc áp dụng các tính năng xác minh của người dùng
- Đánh giá an toàn liên tục dữ liệu đã chuyển đổi

---

## 9. THỜI GIAN VÀ YÊU CẦU TÀI NGUYÊN

### 9.1 Thời gian ước tính
- **Giai đoạn Chuẩn bị:** 2 tuần
- **Triển khai Blockchain:** 1 tuần
- **Chuyển đổi Dữ liệu:** 3 tuần
- **Giai đoạn Xác minh:** 1 tuần
- **Tổng thời gian:** 7 tuần

### 9.2 Yêu cầu tài nguyên
- **Đội Kỹ thuật:** 3-4 nhà phát triển blockchain
- **Đội QA:** 2 kiểm thử viên cho xác minh
- **Quản lý Dự án:** 1 PM cho phối hợp
- **Cơ sở hạ tầng:** Credits mạng thử nghiệm Avalanche, tài nguyên AWS

### 9.3 Phụ thuộc và điều kiện tiên quyết
- Truy cập hệ thống cũ ổn định trong thời gian chuyển đổi
- Khả năng sẵn có và hiệu suất mạng Avalanche
- Giao tiếp người dùng và phối hợp quản lý thay đổi
- Phê duyệt quy định cho lưu trữ dữ liệu blockchain

---

## 10. KẾT LUẬN

Chuyển đổi dữ liệu sang hệ thống hợp đồng thông minh blockchain đại diện cho một chuyển đổi quan trọng trong việc nâng cao tính minh bạch và độ tin cậy của nền tảng từ thiện. Với kế hoạch toàn diện, xác minh nghiêm ngặt và các biện pháp an toàn mạnh mẽ, quá trình chuyển đổi sẽ thiết lập nền tảng vững chắc cho sự phát triển tương lai và niềm tin của người dùng.

Thành công của việc chuyển đổi sẽ được đo lường không chỉ bằng hoàn thành kỹ thuật mà còn bằng việc người dùng áp dụng các tính năng xác minh blockchain và cải thiện lòng tin vào hoạt động nền tảng. Giám sát và tối ưu hóa liên tục sẽ đảm bảo rằng hệ thống đã chuyển đổi mang lại giá trị nâng cao cho tất cả các bên liên quan.

