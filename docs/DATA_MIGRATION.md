# TÀI LIỆU MIGRATION HỆ THỐNG TỪ THIỆN

## Mục lục
1. [Mục đích & Phạm vi](#1-mục-đích--phạm-vi)
2. [Kiến trúc chuyển đổi](#2-kiến-trúc-chuyển-đổi)
3. [Quy trình chuyển đổi chi tiết](#3-quy-trình-chuyển-đổi-chi-tiết)
4. [Tích hợp API & Cơ sở dữ liệu](#4-tích-hợp-api--cơ-sở-dữ-liệu)
5. [Tích hợp giao diện người dùng](#5-tích-hợp-giao-diện-người-dùng)
6. [An toàn & Tuân thủ](#6-an-toàn--tuân-thủ)
7. [Quản lý rủi ro & tình huống khẩn cấp](#7-quản-lý-rủi-ro--tình-huống-khẩn-cấp)
8. [Tiêu chí thành công & xác thực](#8-tiêu-chí-thành-công--xác-thực)
9. [Thời gian & tài nguyên](#9-thời-gian--tài-nguyên)
10. [Sơ đồ tổng quan & kỹ thuật](#10-sơ-đồ-tổng-quan--kỹ-thuật)
11. [Kết luận](#11-kết-luận)

---

## 1. Mục đích & Phạm vi

### 1.1 Mục đích chuyển đổi
- Chuyển đổi toàn bộ dữ liệu từ hệ thống từ thiện hiện tại sang blockchain Avalanche C-Chain.
- Nâng cao tính minh bạch, khả năng kiểm chứng và tự động hóa quy trình quyên góp.

### 1.2 Phạm vi dữ liệu
- **Người dùng:** >10,000 tài khoản
- **Chiến dịch:** >3,000 chiến dịch
- **Giao dịch quyên góp:** >12,500 giao dịch (2023-2025)
- **Giao dịch rút tiền:** >180 giao dịch
- **Tệp phương tiện:** Hình ảnh, video, tài liệu

### 1.3 Hệ thống đích
- **Blockchain:** Avalanche C-Chain (Fuji Testnet)
- **Smart Contracts:** Campaign.sol, Manager.sol, CurrencyConvert.sol, Token.sol
- **API Backend:** MetaFi Charity API v1
- **Frontend:** React App tích hợp blockchain

---

## 2. Kiến trúc chuyển đổi

### 2.1 Tổng quan kiến trúc
```
Hệ thống Cũ → Đường ống Chuyển đổi → Blockchain + API DB → Ứng dụng Web
```

### 2.2 Thành phần chính
- **Nguồn:** MySQL/PostgreSQL, file storage, xác thực người dùng
- **Pipeline:** Trích xuất, xác thực, deploy contract, đồng bộ API
- **Đích:** Smart contract độc lập, token VND, MongoDB, AWS S3, React

### 2.3 Luồng dữ liệu chuyển đổi
1. Trích xuất
2. Biến đổi
3. Triển khai
4. Giao dịch blockchain
5. Đồng bộ API
6. Xác minh

---

## 3. Quy trình chuyển đổi chi tiết

### 3.1 Chuẩn bị
- Kiểm toán, sao lưu, thiết lập môi trường, trích xuất dữ liệu

### 3.2 Triển khai blockchain
- Deploy token, contract chuyển đổi, quản lý, tạo ví, ánh xạ user

### 3.3 Chuyển đổi dữ liệu
- Gọi donate/withdraw, mapping, đồng bộ API, upload media

### 3.4 Xác minh
- Đối soát số dư, giao dịch, kiểm thử chức năng

---

## 4. Tích hợp API & Cơ sở dữ liệu

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

## 5. Tích hợp giao diện người dùng

- Hiển thị badge xác minh blockchain, liên kết explorer, lịch sử quyên góp, trạng thái migration, dashboard xác minh quản trị.

---

## 6. An toàn & Tuân thủ

- Mã hóa dữ liệu, quản lý khóa, kiểm toán, tuân thủ GDPR, xác minh đa cấp, kiểm soát truy cập, đa chữ ký.

---

## 7. Quản lý rủi ro & tình huống khẩn cấp

- Backup, rollback, khôi phục, cảnh báo, hỗ trợ người dùng, đào tạo đội ngũ.

---

## 8. Tiêu chí thành công & xác thực

- 100% dữ liệu chuyển đổi, không sai lệch tài chính, lỗi giao dịch <0.1%, xác minh người dùng >95%, tăng niềm tin người dùng.

---

## 9. Thời gian & tài nguyên

- **Tổng thời gian:** 7 tuần (chuẩn bị, triển khai, chuyển đổi, xác minh)
- **Nhân sự:** 3-4 dev blockchain, 2 QA, 1 PM
- **Hạ tầng:** Avalanche testnet, AWS, API

---

## 10. Sơ đồ tổng quan & kỹ thuật

### 10.1 Sơ đồ Kiến trúc Migration
*Minh họa các thành phần chính và mối liên hệ trong toàn bộ hệ thống migration.*
```mermaid
graph TD
    A[Hệ thống Cũ] --> B[Đường ống Chuyển đổi]
    B --> C[Blockchain + API Database]
    C --> D[Ứng dụng Web]
    
    subgraph "Hệ thống Cũ"
        A1[MySQL Database]
        A2[File Storage]
        A3[User Authentication]
    end
    
    subgraph "Migration Pipeline"
        B1[Data Extraction]
        B2[Data Validation]
        B3[Contract Deployment]
        B4[Transaction Migration]
    end
    
    subgraph "Blockchain Layer"
        C1[Smart Contracts]
        C2[Token VND]
        C3[Transaction History]
    end
    
    subgraph "API & Database"
        C4[MongoDB]
        C5[AWS S3]
        C6[API Backend]
    end
    
    subgraph "Frontend"
        D1[React App]
        D2[Wallet Integration]
        D3[User Interface]
    end
    
    A1 --> B1
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> C1
    B4 --> C2
    C1 --> C4
    C2 --> C4
    C3 --> C4
    C4 --> C6
    C6 --> D1
    D1 --> D2
    D2 --> D3
```

### 10.2 Sơ đồ Luồng Dữ liệu Chi tiết
*Trình tự các bước xử lý dữ liệu từ hệ thống cũ sang blockchain và frontend.*
```mermaid
sequenceDiagram
    participant OS as Hệ thống Cũ
    participant MP as Migration Pipeline
    participant BC as Blockchain
    participant API as API Database
    participant FE as Frontend
    
    Note over OS,FE: Giai đoạn 1: Chuẩn bị
    OS->>MP: 1. Trích xuất dữ liệu
    MP->>MP: 2. Xác thực & Biến đổi
    MP->>BC: 3. Triển khai Token VND
    MP->>BC: 4. Triển khai Manager Contract
    
    Note over OS,FE: Giai đoạn 2: Triển khai Campaign
    loop Cho mỗi Campaign
        MP->>BC: 5. Deploy Campaign.sol
        BC->>MP: 6. Contract Address
        MP->>API: 7. Lưu mapping
    end
    
    Note over OS,FE: Giai đoạn 3: Migration Transactions
    loop Cho mỗi Donation
        MP->>BC: 8. Execute donate()
        BC->>MP: 9. Transaction Hash
        MP->>API: 10. Sync donation record
    end
    
    loop Cho mỗi Withdrawal
        MP->>BC: 11. Execute withdraw()
        BC->>MP: 12. Transaction Hash
        MP->>API: 13. Sync withdrawal record
    end
    
    Note over OS,FE: Giai đoạn 4: Xác minh
    MP->>BC: 14. Verify balances
    MP->>API: 15. Cross-check data
    API->>FE: 16. Update interface
    FE->>FE: 17. Display verification badges
```

### 10.3 Sơ đồ Migration Timeline (Gantt)
*Quản lý thời gian, các giai đoạn và dependencies của migration.*
```mermaid
gantt
    title Migration Timeline
    dateFormat  YYYY-MM-DD
    section Chuẩn bị
    Kiểm toán dữ liệu    :done, audit, 2024-01-01, 2024-01-07
    Sao lưu hệ thống     :done, backup, 2024-01-08, 2024-01-10
    Thiết lập môi trường  :done, setup, 2024-01-11, 2024-01-14
    
    section Triển khai Blockchain
    Deploy Token VND      :deploy, 2024-01-15, 2024-01-16
    Deploy Manager        :deploy, 2024-01-17, 2024-01-18
    Deploy Campaigns      :deploy, 2024-01-19, 2024-01-25
    
    section Migration Dữ liệu
    User Migration        :migration, 2024-01-26, 2024-02-02
    Campaign Migration    :migration, 2024-02-03, 2024-02-09
    Donation Migration    :migration, 2024-02-10, 2024-02-16
    Withdrawal Migration  :migration, 2024-02-17, 2024-02-23
    
    section Xác minh
    Data Verification     :verify, 2024-02-24, 2024-02-28
    User Testing          :test, 2024-02-29, 2024-03-05
    Performance Testing   :test, 2024-03-06, 2024-03-10
    
    section Go Live
    Production Launch     :launch, 2024-03-11, 2024-03-12
    Monitoring           :monitor, 2024-03-13, 2024-03-20
```

### 10.5 Sơ đồ Luồng Xử lý Donation Migration
*Quy trình từng bước xử lý migration cho từng donation.*
```mermaid
flowchart TD
    A[Bắt đầu Migration Donations] --> B[Lấy danh sách donations từ DB cũ]
    B --> C[Sắp xếp theo thời gian]
    C --> D[Lấy donation đầu tiên]
    
    D --> E{Kiểm tra user wallet?}
    E -->|Chưa có| F[Tạo wallet cho user]
    E -->|Đã có| G[Lấy wallet address]
    F --> G
    
    G --> H[Mint VND token tương ứng]
    H --> I[Approve token cho Campaign contract]
    I --> J[Gọi Campaign.donate]
    
    J --> K{Transaction thành công?}
    K -->|Không| L[Retry với gas cao hơn]
    K -->|Có| M[Lưu transaction hash]
    L --> J
    
    M --> N[Sync với API database]
    N --> O[Cập nhật mapping legacy_id -> tx_hash]
    O --> P{Còn donations nào không?}
    P -->|Có| Q[Lấy donation tiếp theo]
    P -->|Không| R[Hoàn thành]
    
    Q --> D
    
    style A fill:#e1f5fe
    style R fill:#e8f5e8
    style F fill:#fff3e0
    style L fill:#ffebee
```

### 10.6 Sơ đồ Verification Process
*Đảm bảo tính chính xác, đối soát dữ liệu giữa hệ thống cũ và blockchain.*
```mermaid
flowchart TD
    A[Bắt đầu Verification] --> B[Tổng hợp dữ liệu từ DB cũ]
    B --> C[Tổng hợp dữ liệu từ Blockchain]
    
    C --> D{So sánh<br/>tổng donations?}
    D -->|Khác| E[Ghi log discrepancy]
    D -->|Giống| F[Kiểm tra từng campaign]
    E --> F
    
    F --> G{So sánh<br/>balances từng campaign?}
    G -->|Khác| H[Phân tích chi tiết]
    G -->|Giống| I[Kiểm tra user balances]
    H --> I
    
    I --> J{So sánh<br/>donations từng user?}
    J -->|Khác| K[Tạo báo cáo lỗi]
    J -->|Giống| L[Kiểm tra transaction mapping]
    K --> L
    
    L --> M{Kiểm tra<br/>tx mapping?}
    M -->|Lỗi| N[Cập nhật mapping]
    M -->|OK| O[Verification hoàn thành]
    N --> O
    
    O --> P[Tạo báo cáo cuối cùng]
    P --> Q[Cập nhật status = VERIFIED]
    
    style A fill:#e1f5fe
    style Q fill:#e8f5e8
    style E fill:#fff3e0
    style H fill:#fff3e0
    style K fill:#ffebee
    style N fill:#fff3e0
```

### 10.7 Sơ đồ Cấu trúc Dữ liệu API
*Minh họa cấu trúc bảng dữ liệu chính của API backend.*
```mermaid
erDiagram
    USERS {
        string user_id PK
        string email
        string wallet_address
        string private_key_encrypted
        string seed_phrase_encrypted
        uint256 vnd_balance
        datetime created_at
        datetime updated_at
        string migration_status
    }
    
    CAMPAIGNS {
        string campaign_id PK
        string legacy_campaign_id
        string blockchain_contract_address
        string manager_contract_address
        string admin_wallet_address
        string name
        string description
        uint256 target_amount
        uint256 current_amount
        bool is_active
        datetime created_at
        string creation_tx_hash
        string verification_status
    }
    
    DONATIONS {
        string donation_id PK
        string campaign_id FK
        string user_id FK
        string donor_wallet_address
        string token_address
        string token_symbol
        uint256 amount_original
        uint256 amount_wei
        string blockchain_tx_hash
        string bank_transaction_id
        string message
        datetime donation_time
        uint256 block_number
        uint256 gas_used
        uint256 tx_fee
        string status
        bool migration_source
        string explorer_url
    }
    
    WITHDRAWALS {
        string withdrawal_id PK
        string campaign_id FK
        string recipient_wallet_address
        uint256 amount
        string blockchain_tx_hash
        datetime withdrawal_time
        string status
        string reason
    }
    
    MIGRATION_LOGS {
        string log_id PK
        string entity_type
        string entity_id
        string action
        string status
        string error_message
        datetime created_at
        string operator_id
    }
    
    USERS ||--o{ DONATIONS : makes
    CAMPAIGNS ||--o{ DONATIONS : receives
    CAMPAIGNS ||--o{ WITHDRAWALS : processes
    USERS ||--o{ MIGRATION_LOGS : tracked_by
    CAMPAIGNS ||--o{ MIGRATION_LOGS : tracked_by
```


### 10.8 Sơ đồ Monitoring Dashboard
*Theo dõi tiến độ migration, sức khỏe hệ thống và độ chính xác dữ liệu.*
```mermaid
graph TD
    subgraph "REAL-TIME METRICS"
        A[Tiến độ Migration] --> A1[Campaigns: 85%]
        A --> A2[Donations: 92%]
        A --> A3[Users: 78%]
        A --> A4[Withdrawals: 95%]
    end
    
    subgraph "SYSTEM HEALTH"
        B[Sức khỏe Hệ thống] --> B1[Blockchain: Online]
        B --> B2[API: Healthy]
        B --> B3[Database: Normal]
        B --> B4[Frontend: Active]
    end
    
    subgraph "DATA ACCURACY"
        C[Độ chính xác Dữ liệu] --> C1[Donations: 99.8%]
        C --> C2[Balances: 100%]
        C --> C3[Transactions: 99.9%]
        C --> C4[User Mapping: 100%]
    end
    
    subgraph "ERROR MONITORING"
        D[Giám sát Lỗi] --> D1[Failed TX: 0.1%]
        D --> D2[Gas Issues: 0.05%]
        D --> D3[API Errors: 0.02%]
        D --> D4[User Issues: 0.08%]
    end
    
    subgraph "PERFORMANCE METRICS"
        E[Hiệu suất] --> E1[Avg TX Time: 2.3s]
        E --> E2[Gas Price: 25 Gwei]
        E --> E3[Success Rate: 99.9%]
        E --> E4[Uptime: 99.95%]
    end
    
    subgraph "ALERTS & NOTIFICATIONS"
        F[Cảnh báo] --> F1[High Gas Price]
        F --> F2[Failed Transactions]
        F --> F3[System Downtime]
        F --> F4[Data Discrepancy]
    end
    
    subgraph "VERIFICATION STATUS"
        G[Trạng thái Xác minh] --> G1[Campaigns: Verified]
        G --> G2[Donations: Verified]
        G --> G3[Users: Verified]
        G --> G4[Balances: Verified]
    end
    
    style A fill:#e3f2fd
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#ffebee
    style E fill:#f3e5f5
    style F fill:#fff8e1
    style G fill:#e0f2f1
```

### 10.9 Sơ đồ Emergency Recovery Plan
*Quy trình xử lý sự cố, rollback và khôi phục migration.*
```mermaid
flowchart TD
    A[Phát hiện sự cố] --> B{Phân loại sự cố}
    
    B -->|Lỗi dữ liệu| C[Kiểm tra tính toàn vẹn]
    B -->|Lỗi blockchain| D[Kiểm tra network]
    B -->|Lỗi API| E[Kiểm tra backend]
    B -->|Lỗi user access| F[Kiểm tra authentication]
    B -->|Lỗi performance| G[Kiểm tra resources]
    
    C --> H{Dữ liệu có bị corrupt?}
    D --> I{Blockchain có hoạt động?}
    E --> J{API có respond?}
    F --> K{User có login được?}
    G --> L{System có overload?}
    
    H -->|Có| M[Rollback to checkpoint]
    H -->|Không| N[Repair data]
    I -->|Không| O[Switch to backup node]
    I -->|Có| P[Check gas price]
    J -->|Không| Q[Restart API service]
    J -->|Có| R[Check database]
    K -->|Không| S[Reset user session]
    K -->|Có| T[Check permissions]
    L -->|Có| U[Scale up resources]
    L -->|Không| V[Optimize queries]
    
    M --> W[Restore from backup]
    N --> X[Validate data integrity]
    O --> Y[Update node config]
    P --> Z[Adjust gas strategy]
    Q --> AA[Monitor API health]
    R --> BB[Check DB connection]
    S --> CC[Clear cache]
    T --> DD[Update user roles]
    U --> EE[Add more servers]
    V --> FF[Optimize code]
    
    W --> GG{Recovery thành công?}
    X --> GG
    Y --> HH{Node hoạt động?}
    Z --> II{Gas price ổn?}
    AA --> JJ{API stable?}
    BB --> KK{DB connected?}
    CC --> LL{User access OK?}
    DD --> LL
    EE --> MM{Performance OK?}
    FF --> MM
    
    GG -->|Có| NN[Thông báo team]
    GG -->|Không| OO[Escalate to senior]
    HH -->|Có| PP[Update routing]
    HH -->|Không| QQ[Use fallback node]
    II -->|Có| RR[Continue migration]
    II -->|Không| SS[Pause migration]
    JJ -->|Có| TT[Resume operations]
    JJ -->|Không| UU[Debug API]
    KK -->|Có| VV[Continue sync]
    KK -->|Không| WW[Restore DB]
    LL -->|Có| XX[Resume user access]
    LL -->|Không| YY[Investigate auth]
    MM -->|Có| ZZ[Monitor performance]
    MM -->|Không| AAA[Add more resources]
    
    NN --> BBB[Update status]
    OO --> CCC[Senior intervention]
    PP --> BBB
    QQ --> BBB
    RR --> BBB
    SS --> DDD[Wait for gas drop]
    TT --> BBB
    UU --> EEE[Fix API issues]
    VV --> BBB
    WW --> FFF[Restore from snapshot]
    XX --> BBB
    YY --> GGG[Fix auth system]
    ZZ --> BBB
    AAA --> HHH[Deploy more instances]
    
    BBB --> III[Log incident]
    CCC --> III
    DDD --> III
    EEE --> III
    FFF --> III
    GGG --> III
    HHH --> III
    
    III --> JJJ[Post-mortem analysis]
    JJJ --> KKK[Update procedures]
    KKK --> LLL[Train team]
    LLL --> MMM[Prevent future issues]
    
    style A fill:#ffebee
    style M fill:#ffebee
    style O fill:#ffebee
    style Q fill:#ffebee
    style S fill:#ffebee
    style U fill:#ffebee
    style OO fill:#ffebee
    style EEE fill:#ffebee
    style FFF fill:#ffebee
    style GGG fill:#ffebee
    style HHH fill:#ffebee
    
    style NN fill:#e8f5e8
    style PP fill:#e8f5e8
    style RR fill:#e8f5e8
    style TT fill:#e8f5e8
    style VV fill:#e8f5e8
    style XX fill:#e8f5e8
    style ZZ fill:#e8f5e8
    style BBB fill:#e8f5e8
    style MMM fill:#e8f5e8
```


### 10.15 Sơ đồ Hỗ trợ Người dùng sau Migration
*Quy trình hỗ trợ, xác minh và giải đáp cho người dùng sau migration.*
```mermaid
flowchart TD
    A[User gặp vấn đề] --> B{Kiểm tra loại vấn đề}
    
    B -->|Không đăng nhập được| C[Hướng dẫn tạo wallet mới]
    B -->|Không thấy donation| D[Kiểm tra transaction hash]
    B -->|Số dư không đúng| E[Đối soát với blockchain]
    B -->|Không hiểu blockchain| F[Hướng dẫn sử dụng]
    B -->|Lỗi kỹ thuật| G[Chuyển cho dev team]
    B -->|Quên mật khẩu| H[Reset wallet credentials]
    B -->|Không thấy campaign| I[Kiểm tra campaign mapping]
    
    C --> J[Gửi email hướng dẫn]
    D --> K[Kiểm tra explorer]
    E --> L[So sánh với DB cũ]
    F --> M[Gửi video tutorial]
    G --> N[Tạo ticket support]
    H --> O[Gửi reset link]
    I --> P[Kiểm tra campaign status]
    
    J --> Q{User hiểu chưa?}
    K --> R{Transaction có tồn tại?}
    L --> S{Số dư có khớp?}
    M --> T{User cần hỗ trợ thêm?}
    N --> U[Dev team xử lý]
    O --> V{Reset thành công?}
    P --> W{Campaign có migrated?}
    
    Q -->|Chưa| X[Gọi điện hỗ trợ]
    Q -->|Rồi| Y[Hoàn thành]
    R -->|Có| Z[Hiển thị transaction]
    R -->|Không| AA[Kiểm tra migration log]
    S -->|Có| BB[Xác nhận với user]
    S -->|Không| CC[Điều tra lỗi]
    T -->|Có| DD[Chat support trực tiếp]
    T -->|Không| EE[Hoàn thành]
    U --> FF[Fix bug và update]
    V -->|Có| GG[Gửi new credentials]
    V -->|Không| HH[Manual reset process]
    W -->|Có| II[Hiển thị campaign]
    W -->|Không| JJ[Notify admin]
    
    X --> KK[Giải thích chi tiết]
    Z --> LL[User xác nhận]
    AA --> MM[Kiểm tra lại migration]
    BB --> NN[User hài lòng]
    CC --> OO[Rollback nếu cần]
    DD --> PP[Giải đáp thắc mắc]
    FF --> QQ[Thông báo user]
    GG --> RR[User test login]
    HH --> SS[Admin intervention]
    II --> TT[User verify campaign]
    JJ --> UU[Manual campaign setup]
    
    KK --> Y
    LL --> Y
    MM --> Z
    NN --> Y
    OO --> BB
    PP --> EE
    QQ --> Y
    RR --> VV{Login thành công?}
    SS --> WW[Manual wallet setup]
    TT --> XX{Campaign hiển thị?}
    UU --> YY[Campaign activated]
    
    VV -->|Có| Y
    VV -->|Không| ZZ[Escalate to senior]
    WW --> Y
    XX -->|Có| Y
    XX -->|Không| AAA[Debug campaign display]
    YY --> Y
    
    ZZ --> BBB[Senior support call]
    AAA --> CCC[Fix display issue]
    
    BBB --> Y
    CCC --> Y
    
    style A fill:#ffebee
    style Y fill:#e8f5e8
    style EE fill:#e8f5e8
    style NN fill:#e8f5e8
    style N fill:#fff3e0
    style U fill:#fff3e0
    style OO fill:#ffebee
    style ZZ fill:#ffebee
    style AAA fill:#ffebee
```

---

## 11. Kết luận

Chuyển đổi dữ liệu sang blockchain là bước tiến lớn về minh bạch, tin cậy, tự động hóa cho nền tảng từ thiện. Thành công không chỉ ở kỹ thuật mà còn ở sự tin tưởng, xác minh và trải nghiệm người dùng.

