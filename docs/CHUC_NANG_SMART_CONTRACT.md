# TÀI LIỆU CHỨC NĂNG SMART CONTRACT TỪ THIỆN

## Tổng quan hệ thống

Hệ thống smart contract từ thiện được thiết kế để quản lý các chiến dịch quyên góp một cách minh bạch và phi tập trung trên blockchain. Hệ thống bao gồm 4 contract chính:

1. **Campaign.sol** - Quản lý chiến dịch từ thiện
2. **Manager.sol** - Quản lý nhiều chiến dịch
3. **CurrencyConvert.sol** - Chuyển đổi tỷ giá token
4. **Token.sol** - Token ERC20 mẫu

---

## 1. CAMPAIGN.SOL

### Mô tả
Contract chính quản lý một chiến dịch từ thiện, cho phép người dùng donate nhiều loại token, lưu lịch sử, rút tiền và phân quyền admin/manager.

### Cấu trúc dữ liệu

#### Biến chính
```solidity
string public name;                    // Tên chiến dịch
uint256 public startTime;              // Thời gian bắt đầu
uint256 public endTime;                // Thời gian kết thúc (0 = không có thời hạn)
address public admin;                  // Địa chỉ admin
address public manager;                // Địa chỉ manager
EnumerableSet.AddressSet donors;       // Danh sách người donate
ICurrencyConvert currencyConvert;      // Contract chuyển đổi tỷ giá
```

#### Struct
```solidity
struct Donation {
    address token;         // Địa chỉ token
    uint256 amount;        // Số lượng token
    uint256 amountConvert; // Số lượng quy đổi
    uint256 time;          // Thời gian donate
}
```

#### Mapping
```solidity
mapping(address => uint256) balances;                    // token => tổng số đã donate
mapping(address => uint256) withdraws;                   // token => số đã rút
mapping(address => uint256) userTotalDonations;          // user => tổng donate (quy đổi)
mapping(address => mapping(address => uint256)) userDonations; // user => token => số lượng
mapping(address => Donation[]) userDonationsDetail;      // user => chi tiết donate
```

### Chức năng chính

#### 1.1. donate(address _token, uint256 _amount)
**Mô tả:** Cho phép người dùng donate token hoặc ETH vào chiến dịch.

**Tham số:**
- `_token`: Địa chỉ token (address(0) = ETH)
- `_amount`: Số lượng token/ETH

**Quyền:** Bất kỳ ai (external)

**Logic:**
1. Kiểm tra thời gian chiến dịch (validCampaign modifier)
2. Nếu gửi ETH, sử dụng msg.value
3. Chuyển đổi tỷ giá qua CurrencyConvert
4. Transfer token từ người dùng vào contract
5. Cập nhật số dư, danh sách donors, lịch sử
6. Emit DonationEvent

**Ví dụ:**
```solidity
// Donate 100 USDT
campaign.donate(usdtAddress, 100);

// Donate 0.1 ETH
campaign.donate{value: 0.1 ether}(address(0), 0);
```

#### 1.2. withdraw(address _token, uint256 _amount)
**Mô tả:** Cho phép admin rút tiền từ chiến dịch.

**Tham số:**
- `_token`: Địa chỉ token cần rút
- `_amount`: Số lượng cần rút

**Quyền:** Chỉ admin (onlyAdmin modifier)

**Logic:**
1. Kiểm tra số dư khả dụng
2. Transfer token từ contract đến admin
3. Cập nhật số đã rút
4. Emit WithdrawEvent

**Ví dụ:**
```solidity
// Rút 1000 USDT
campaign.withdraw(usdtAddress, 1000);
```

#### 1.3. setupAdmin(address _admin)
**Mô tả:** Thay đổi admin của chiến dịch.

**Tham số:**
- `_admin`: Địa chỉ admin mới

**Quyền:** Chỉ manager (onlyManager modifier)

**Logic:**
1. Kiểm tra địa chỉ hợp lệ
2. Kiểm tra không trùng với admin hiện tại
3. Cập nhật admin mới
4. Emit SetupAdminEvent

**Ví dụ:**
```solidity
// Thay đổi admin
manager.setupAdmin(newAdminAddress);
```

#### 1.4. getDonors(uint256 _startIndex, uint256 _count)
**Mô tả:** Lấy danh sách người donate và số tiền đã donate.

**Tham số:**
- `_startIndex`: Vị trí bắt đầu
- `_count`: Số lượng cần lấy

**Quyền:** Bất kỳ ai (public)

**Trả về:**
- `address[]`: Danh sách địa chỉ người donate
- `uint256[]`: Số tiền đã donate (quy đổi)

**Ví dụ:**
```solidity
// Lấy 10 người donate đầu tiên
(address[] memory donors, uint256[] memory amounts) = campaign.getDonors(0, 10);
```

#### 1.5. getDonorsLength()
**Mô tả:** Lấy tổng số người đã donate.

**Quyền:** Bất kỳ ai (public view)

**Trả về:** `uint256` - Số lượng người donate

**Ví dụ:**
```solidity
uint256 totalDonors = campaign.getDonorsLength();
```

### Events

#### DonationEvent
```solidity
event DonationEvent(
    address user,           // Địa chỉ người donate
    address token,          // Địa chỉ token
    uint256 amount,         // Số lượng token
    uint256 amountConvert,  // Số lượng quy đổi
    uint256 time           // Thời gian donate
);
```

#### WithdrawEvent
```solidity
event WithdrawEvent(
    address admin,          // Địa chỉ admin
    address token,          // Địa chỉ token
    uint256 amount,         // Số lượng rút
    uint256 time           // Thời gian rút
);
```

#### SetupAdminEvent
```solidity
event SetupAdminEvent(
    address newAdmin,       // Admin mới
    address oldAdmin        // Admin cũ
);
```

---

## 2. MANAGER.SOL

### Mô tả
Contract quản lý nhiều chiến dịch từ thiện, cho phép tạo chiến dịch mới và phân quyền admin.

### Cấu trúc dữ liệu

#### Biến chính
```solidity
bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
EnumerableSet.AddressSet campaigns;    // Danh sách các chiến dịch
CurrencyConvert public currencyConvert; // Contract chuyển đổi tỷ giá
```

### Chức năng chính

#### 2.1. createCampaign(string calldata _name, uint256 _startTime, uint256 _endTime, address _admin)
**Mô tả:** Tạo chiến dịch từ thiện mới.

**Tham số:**
- `_name`: Tên chiến dịch
- `_startTime`: Thời gian bắt đầu
- `_endTime`: Thời gian kết thúc (0 = không có thời hạn)
- `_admin`: Địa chỉ admin của chiến dịch

**Quyền:** Chỉ admin (onlyAdmin modifier)

**Logic:**
1. Tạo contract Campaign mới
2. Thêm vào danh sách campaigns
3. Gán manager là address(this)

**Ví dụ:**
```solidity
// Tạo chiến dịch mới
manager.createCampaign(
    "Quyên góp từ thiện 2024",
    block.timestamp,
    block.timestamp + 30 days,
    adminAddress
);
```

#### 2.2. getCampaignsLength()
**Mô tả:** Lấy tổng số chiến dịch.

**Quyền:** Bất kỳ ai (public)

**Trả về:** `uint256` - Số lượng chiến dịch

**Ví dụ:**
```solidity
uint256 totalCampaigns = manager.getCampaignsLength();
```

#### 2.3. getCampaigns(uint256 _startIndex, uint256 _count)
**Mô tả:** Lấy danh sách các chiến dịch.

**Tham số:**
- `_startIndex`: Vị trí bắt đầu
- `_count`: Số lượng cần lấy

**Quyền:** Bất kỳ ai (external)

**Trả về:** `address[]` - Danh sách địa chỉ các chiến dịch

**Ví dụ:**
```solidity
// Lấy 5 chiến dịch đầu tiên
address[] memory campaigns = manager.getCampaigns(0, 5);
```

---

## 3. CURRENCYCONVERT.SOL

### Mô tả
Contract chuyển đổi tỷ giá token (giả lập), cho phép admin cập nhật tỷ giá các token.

### Cấu trúc dữ liệu

#### Biến chính
```solidity
bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
mapping(address => uint256) rates;    // token => tỷ giá
```

### Chức năng chính

#### 3.1. convert(address _token, uint256 _amount)
**Mô tả:** Chuyển đổi số lượng token theo tỷ giá.

**Tham số:**
- `_token`: Địa chỉ token
- `_amount`: Số lượng token

**Quyền:** Bất kỳ ai (external)

**Trả về:** `uint256` - Số lượng quy đổi

**Logic:**
```solidity
return rates[_token] * _amount;
```

**Ví dụ:**
```solidity
// Chuyển đổi 100 USDT (tỷ giá 25000)
uint256 converted = currencyConvert.convert(usdtAddress, 100);
// Kết quả: 2500000
```

#### 3.2. setupRate(address _token, uint256 _rate)
**Mô tả:** Cập nhật tỷ giá cho token.

**Tham số:**
- `_token`: Địa chỉ token
- `_rate`: Tỷ giá mới

**Quyền:** Chỉ admin (onlyAdmin modifier)

**Ví dụ:**
```solidity
// Cập nhật tỷ giá USDT = 25000
currencyConvert.setupRate(usdtAddress, 25000);
```

---

## 4. TOKEN.SOL

### Mô tả
Token ERC20 mẫu để test hệ thống, có chức năng mint token.

### Cấu trúc dữ liệu
```solidity
name: "AIPAD"
symbol: "AIPAD"
```

### Chức năng chính

#### 4.1. mint(uint256 _amount)
**Mô tả:** Tạo token mới cho người gọi hàm.

**Tham số:**
- `_amount`: Số lượng token cần tạo

**Quyền:** Bất kỳ ai (public)

**Ví dụ:**
```solidity
// Tạo 1000 token
token.mint(1000);
```

#### 4.2. mintTo(address _to, uint256 _amount)
**Mô tả:** Tạo token mới cho địa chỉ cụ thể.

**Tham số:**
- `_to`: Địa chỉ nhận token
- `_amount`: Số lượng token cần tạo

**Quyền:** Bất kỳ ai (public)

**Ví dụ:**
```solidity
// Tạo 1000 token cho địa chỉ khác
token.mintTo(otherAddress, 1000);
```

---

## PHÂN QUYỀN HỆ THỐNG

### Campaign.sol
- **Admin:** Có thể rút tiền từ chiến dịch
- **Manager:** Có thể thay đổi admin của chiến dịch
- **Người dùng:** Có thể donate vào chiến dịch

### Manager.sol
- **Admin:** Có thể tạo chiến dịch mới
- **Người dùng:** Có thể xem danh sách chiến dịch

### CurrencyConvert.sol
- **Admin:** Có thể cập nhật tỷ giá token
- **Người dùng:** Có thể chuyển đổi tỷ giá

---

## LUỒNG HOẠT ĐỘNG

### 1. Khởi tạo hệ thống
1. Deploy CurrencyConvert
2. Deploy Manager với CurrencyConvert
3. Setup tỷ giá các token qua CurrencyConvert

### 2. Tạo chiến dịch
1. Admin Manager gọi createCampaign()
2. Manager tạo contract Campaign mới
3. Campaign được thêm vào danh sách

### 3. Quyên góp
1. Người dùng approve token cho Campaign
2. Gọi donate() với token và số lượng
3. Campaign chuyển đổi tỷ giá và lưu lịch sử
4. Emit DonationEvent

### 4. Rút tiền
1. Admin Campaign gọi withdraw()
2. Campaign kiểm tra số dư khả dụng
3. Transfer token đến admin
4. Emit WithdrawEvent

---

## LƯU Ý BẢO MẬT

1. **Kiểm tra địa chỉ:** Tất cả địa chỉ phải khác address(0)
2. **Kiểm tra số lượng:** Số lượng donate phải > 0
3. **Kiểm tra thời gian:** Chiến dịch phải trong thời gian hoạt động
4. **Kiểm tra quyền:** Chỉ admin/manager mới được thực hiện các chức năng quan trọng
5. **Kiểm tra số dư:** Không được rút quá số dư khả dụng

---

## HẠN CHẾ HIỆN TẠI

1. Chưa có cơ chế hủy/đóng chiến dịch
2. Chưa có cơ chế phê duyệt donate
3. Chưa có cơ chế cập nhật tỷ giá tự động
4. Chưa có cơ chế pause/unpause token
5. Chưa có cơ chế burn token 