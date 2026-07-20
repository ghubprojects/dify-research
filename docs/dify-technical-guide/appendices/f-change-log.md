# F. Change log

> **Version áp dụng:** Dify Community `1.15.0`  
> **Ngày kiểm chứng baseline:** `2026-07-16`; **version-drift check:** `2026-07-20`
> **Trạng thái xác minh:** `Working draft 0.3.4`
> **Reviewer:** Internal specialist/editorial/novice desk cross-review đã thực hiện; designated-owner sign-off và deployment runtime validation còn mở

## Quy ước phiên bản tài liệu

- `0.x`: nghiên cứu/draft, chưa vượt core `DOC-G5`.
- `1.0`: core guide vượt `DOC-G5` về content, evidence contract, static/render và editorial QA; metadata vẫn phải ghi rõ mọi `RUNTIME-PENDING`.
- `Deployment-validated` là trạng thái độc lập gắn với target profile/addendum và runtime/approval evidence; không được suy ra chỉ từ document version.
- Patch tài liệu: sửa lỗi/nguồn không đổi baseline.
- Minor tài liệu: thêm chương/addendum hoặc mở rộng procedure không đổi baseline.
- Major tài liệu: đổi Dify baseline hoặc thay đổi reference architecture quan trọng.

## Lịch sử thay đổi

| Version tài liệu | Ngày | Thay đổi | Validation/Gate |
|---|---|---|---|
| 0.1.0 | 2026-07-16 | Tạo scaffold 19 chương; khóa product/docs baseline; tạo source/claim/decision/validation register | Sprint 0, `DOC-G0` đang thực hiện |
| 0.2.0 | 2026-07-16 | Hoàn tất draft vòng 1 cho 00, 01, 02, 03, 07, 08, 10 và 11; bổ sung 12 Mermaid block, workflow/Compose test matrix và 47-source evidence register | `DOC-G0` hoàn tất; static QA đạt; `DOC-G1`/`DOC-G2` review và runtime validation pending |
| 0.3.0 | 2026-07-16 | Hoàn tất draft vòng 1 cho 00–19 và A–E; mở rộng lên 116 nguồn, 76 claim, 52 gap, 184 configuration control và 29 Mermaid block trong guide. Cross-review sửa MCP trust boundary, tool credential wording, migration concurrency lock, backup/config recovery set, PostgreSQL restore và Kubernetes state/placement topology. | Static QA tích hợp đạt; runtime, Mermaid render, specialist/Legal/FinOps/editorial review và `DOC-G5` còn pending |
| 0.3.1 | 2026-07-20 | Chạy version-drift check: đăng ký nguồn/commit Dify `1.16.0`, nâng hồ sơ lên 118 nguồn, 77 claim, 53 gap, 15 decision và 13 validation; giữ baseline `1.15.0` và mở impact review G-053. | Official-source verified; rebaseline/regression `1.16.0`, runtime, Mermaid render và specialist sign-off còn pending |
| 0.3.2 | 2026-07-20 | Tách core guide `Review-ready` khỏi target `Deployment-validated`; chuẩn hóa owner-bound template field, `DOC-G3-L` review-readiness và scope của gap deployment-specific. | Không nâng bất kỳ `RUNTIME-PENDING` nào thành validated; core specialist/editorial/Mermaid review và target runtime evidence vẫn pending |
| 0.3.3 | 2026-07-20 | Thêm release manifest, deterministic assembly, static QA và Mermaid render tooling; hồ sơ đạt 118 nguồn, 77 claim, 53 gap, 15 decision, 16 validation và 184 control. | Static/source/assembly QA đạt; 29/29 Mermaid render bằng CLI `11.16.0` + Edge `150.0.4078.65`; target wiki conformance, core specialist/editorial/novice review và deployment runtime evidence còn pending |
| 0.3.4 | 2026-07-20 | Hardening sau internal specialist/editorial/novice desk cross-review: sửa migration singleton, plugin-daemon/network boundary, staging/production critical section, learning path, gate namespace và phụ lục so sánh; bổ sung Anthropic/Azure/Bedrock, custom Tool plugin và Phoenix OTLP path; hồ sơ đạt 123 nguồn, 77 claim, 53 gap, 15 decision, 21 validation và 185 control. | Static/source/assembly QA và 29/29 Mermaid được chạy lại; Kubernetes deployable artifact, designated-owner sign-off, target-wiki conformance và deployment runtime evidence còn pending |

## Thay đổi baseline

| Từ | Sang | Lý do | Impact analysis | Trạng thái |
|---|---|---|---|---|
| Chưa có | Dify Community `1.15.0` | Latest stable tại ngày kickoff | Toàn bộ source/config phải pin tag; Enterprise tách snapshot | Accepted |
| Dify Community `1.15.0` | Dify Community `1.15.0` (giữ nguyên sau khi `1.16.0` phát hành) | Bảo toàn baseline tái lập; `1.16.0` có delta topology/env/migration/MCP/OpenAI cần review riêng | Không áp procedure `1.15.0` cho `1.16.0`; theo dõi G-053 và D-015 | Accepted; upgrade deferred |

## Thay đổi cần tái kiểm chứng

- MCP client/server scope và authentication.
- Plugin daemon/runtime architecture.
- License text và edition entitlements.
- Compose service/image/env/migration.
- Kubernetes/Helm provenance và compatibility.
- Backup/restore/upgrade path.
