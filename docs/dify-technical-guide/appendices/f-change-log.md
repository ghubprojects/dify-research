# F. Change log

> **Version áp dụng:** Dify Community `1.15.0`  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Trạng thái xác minh:** `Working draft 0.3.0`  
> **Reviewer:** Cross-review vòng 1 đã thực hiện; specialist/editorial/runtime review còn mở

## Quy ước phiên bản tài liệu

- `0.x`: nghiên cứu/draft, chưa được coi là production playbook.
- `1.0`: vượt G5, hoàn tất runtime validation và review bắt buộc.
- Patch tài liệu: sửa lỗi/nguồn không đổi baseline.
- Minor tài liệu: thêm chương/addendum hoặc mở rộng procedure không đổi baseline.
- Major tài liệu: đổi Dify baseline hoặc thay đổi reference architecture quan trọng.

## Lịch sử thay đổi

| Version tài liệu | Ngày | Thay đổi | Validation/Gate |
|---|---|---|---|
| 0.1.0 | 2026-07-16 | Tạo scaffold 19 chương; khóa product/docs baseline; tạo source/claim/decision/validation register | Sprint 0, G0 đang thực hiện |
| 0.2.0 | 2026-07-16 | Hoàn tất draft vòng 1 cho 00, 01, 02, 03, 07, 08, 10 và 11; bổ sung 12 Mermaid block, workflow/Compose test matrix và 47-source evidence register | G0 hoàn tất; static QA đạt; G1/G2 review và runtime validation pending |
| 0.3.0 | 2026-07-16 | Hoàn tất draft vòng 1 cho 00–19 và A–E; mở rộng lên 116 nguồn, 76 claim, 52 gap, 184 configuration control và 29 Mermaid block trong guide. Cross-review sửa MCP trust boundary, tool credential wording, migration concurrency lock, backup/config recovery set, PostgreSQL restore và Kubernetes state/placement topology. | Static QA tích hợp đạt; runtime, Mermaid render, specialist/Legal/FinOps/editorial review và G5 còn pending |

## Thay đổi baseline

| Từ | Sang | Lý do | Impact analysis | Trạng thái |
|---|---|---|---|---|
| Chưa có | Dify Community `1.15.0` | Latest stable tại ngày kickoff | Toàn bộ source/config phải pin tag; Enterprise tách snapshot | Accepted |

## Thay đổi cần tái kiểm chứng

- MCP client/server scope và authentication.
- Plugin daemon/runtime architecture.
- License text và edition entitlements.
- Compose service/image/env/migration.
- Kubernetes/Helm provenance và compatibility.
- Backup/restore/upgrade path.
