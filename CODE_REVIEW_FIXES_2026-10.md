# Sửa lỗi sau review mã nguồn (10/2026) — nhánh `fix/code-review-2026-10`

Cấu hình làm theo sách *1C:Enterprise 8.3 Practical Developer's Guide* (bản PDF: https://drive.google.com/file/d/1X0uW1nnb8PXg-RwCLLlt5H_e2DzkdsnT/view?usp=sharing). Chưa chạy thử trên platform — đối chiếu listing trong sách và kiểm tra theo kịch bản rồi mới merge vào `master`.

| File | Lỗi | Sửa |
|---|---|---|
| `ExchangePlans/Branches/Forms/ListForm` | `WriteChangesAtServer()` gọi thiếu tham số bắt buộc → lỗi biên dịch | Truyền node đang chọn, bỏ qua node này |
| `ExchangePlans/Branches/ObjectModule.bsl` (mới) | `DataExchange` gọi `ReadMessageWithChanges` / `WriteMessageWithChanges` nhưng repo không có object module của exchange plan → "Object method not found" | Viết lại hai procedure theo Lesson 24 (`CreateMessageWriter`, `SelectChanges`, `CreateMessageReader`, `DeleteChangeRecords`, transaction khi đọc). **Cần đối chiếu sách**: tên file / thư mục trao đổi |
| `Documents/Services` `Posting` | Bút toán doanh thu Nợ 2000 / Có 9000 nằm trong nhánh vật tư → doanh thu dịch vụ không vào sổ (Trial balance lệch Sales) | Ghi doanh thu cho mọi dòng; bút toán giá vốn vẫn chỉ cho vật tư |
| `Documents/Services` `Posting` | Số dư đọc không có thời điểm → post lại chứng từ quá khứ (chế độ thường) tính giá vốn trên số dư hôm nay | Real-time: giữ số dư hiện tại như sách; chế độ thường: `New Boundary(PointInTime(), Excluding)` |
| `Documents/Services` `Posting` | Managed lock mode: `LockForUpdate` trên record set rỗng không khóa các vật tư được đọc | Thêm `DataLock` Exclusive theo Material trước khi đọc số dư; biến `VT` không dùng — bỏ |
| `Documents/InputOpeningMaterialBalances` `BeforeWrite` | Không kiểm tra `DataExchange.Load` khi nhận dữ liệu trao đổi | Thoát sớm |

**Chưa sửa:** content của exchange plan `Branches` thiếu `Primary`, `ChartOfAccounts`, `InputOpeningMaterialBalances` (cần quyết định trong Designer/EDT); `CostOfMaterials` không theo kho, lọc số dư theo Material thay vì cặp (Material, PropertySet) — lệch listing 15.6 của sách.

## Kịch bản kiểm tra
1. Services có 1 dòng vật tư + 1 dòng dịch vụ → Primary có 2 bút toán doanh thu + 1 bút toán giá vốn; Trial balance doanh thu = báo cáo Sales.
2. Nhập vật tư ngày 10 (giá 10), ngày 20 (giá 20). Post lại (chế độ thường) phiếu dịch vụ ngày 15 → giá vốn theo giá 10.
3. Hai node: Register changes ở danh sách node → Start data exchange ở node A rồi node B → dữ liệu xuất hiện bên kia, file message bị xóa sau khi đọc.
