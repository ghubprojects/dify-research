# 00. Phạm vi, phiên bản và giả định

> **Version áp dụng:** Community Edition `1.15.0`; Enterprise/Cloud theo snapshot nguồn công khai ngày truy cập  
> **Commit baseline:** `3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c`  
> **Docs snapshot:** `release/1.15.0 @ 57a492d8063d1583c582b4c0444fb838c6dd3027`  
> **Ngày kiểm chứng:** `2026-07-16`  
> **Trạng thái xác minh:** `Official-source verified` + `Config validated`; runtime lab đang chờ  
> **Reviewer:** Platform/Security/Legal review pending

## Mục tiêu

Chương này khóa baseline để mọi chương còn lại cùng mô tả một phiên bản Dify, cùng bộ nguồn và cùng mức kiểm chứng. Mục tiêu là tránh trộn hành vi của nhánh `main`, release cũ, Community Edition và Enterprise Edition.

Baseline trả lời bốn câu hỏi:

1. Phiên bản nào đang được nghiên cứu?
2. Nguồn nào đủ thẩm quyền để chứng minh claim?
3. Phần nào đã được kiểm tra runtime, phần nào mới kiểm tra cấu hình hoặc review thiết kế?
4. Thay đổi nào buộc tài liệu phải được tái kiểm chứng?

## Phạm vi và giả định

### Baseline sản phẩm

| Phạm vi | Baseline | Cách sử dụng trong tài liệu |
|---|---|---|
| Community Edition | Dify `1.15.0`, phát hành ngày 25/06/2026, commit `3aa26fb…`; trang release được GitHub đánh dấu `Latest` tại ngày kiểm chứng [S-001][S-002] | Baseline kỹ thuật chính cho source, Docker Compose, API/worker và năng lực self-host |
| Documentation | Repository `langgenius/dify-docs`, nhánh `release/1.15.0`, snapshot commit `57a492d8063d1583c582b4c0444fb838c6dd3027` [S-020][S-025] | Nguồn hướng dẫn chính thức tương ứng baseline; citation nội dung dùng commit immutable thay vì nhánh đang dịch chuyển |
| Enterprise Edition | Snapshot trang Enterprise/Pricing tại ngày 16/07/2026 [S-018][S-019] | Chỉ dùng cho feature/deployment matrix công khai; chưa có artifact Enterprise để runtime-test |
| Dify Cloud | Snapshot pricing/docs tại ngày truy cập [S-018] | Chỉ dùng để định vị và so sánh; không phải mục tiêu triển khai |

### Phạm vi nội dung

- Tier 1: kiến trúc, Compose, Kubernetes/Helm, security/license/compliance, model provider và operations.
- Tier 2: Workflow, RAG, Agent, MCP, Plugins và LLMOps ở mức đủ để bắt đầu implement.
- Tier 3: bốn mẫu use case, POC/pilot framework và cost model tham số hóa.
- Ngoài phạm vi: so sánh sâu với Flowise/n8n/LangChain/LangGraph; GPU sizing chi tiết trước khi chốt model; tư vấn pháp lý thay Legal.

### Giả định làm việc

- Tài liệu final viết bằng tiếng Việt, giữ tên component/setting tiếng Anh.
- Core Tier 1/2 phải ổn định; use case cụ thể được mở rộng bằng addendum.
- Không có một cấu hình production duy nhất khi SLA, tải, RPO/RTO, data classification và hạ tầng chưa chốt.
- Mọi ngưỡng người dùng là heuristic cho đến khi có workload model và load test.

## Cơ chế hoạt động

### Thứ tự ưu tiên evidence

1. Release/tag, source, manifest, license và docs chính thức đúng version.
2. Tài liệu chính thức của dependency/provider.
3. Lab evidence tái hiện được.
4. Nguồn thứ cấp chỉ bổ trợ; không làm bằng chứng duy nhất cho claim Tier 1.

### Nhãn xác minh

| Nhãn | Điều kiện sử dụng |
|---|---|
| `Official-source verified` | Claim có nguồn chính thức đúng baseline |
| `Config validated` | Cú pháp/config/manifest đã được kiểm tra nhưng chưa chạy end-to-end |
| `RUNTIME-VALIDATED` | Procedure đã chạy end-to-end trong môi trường đại diện và có expected/actual evidence |
| `Design reviewed` | Kiến trúc đã review nhưng chưa runtime-test |
| `Requires Legal confirmation` | Claim license/compliance cần Legal kết luận |

## Kiến trúc/luồng dữ liệu

Baseline Docker Compose chính thức gồm 6 core services (`api`, `api_websocket`, `worker`, `worker_beat`, `web`, `plugin_daemon`), 6 dependency mặc định (`weaviate`, `db_postgres`, `redis`, `nginx`, `ssrf_proxy`, `sandbox`) và một one-time task `init_permissions`. [S-007]

| Thành phần | Image/reference tại baseline | Ghi chú baseline |
|---|---|---|
| API / WebSocket / Worker / Beat | `langgenius/dify-api:1.15.0` | Chung image, khác `MODE`; worker chạy Celery [S-005][S-013] |
| Web frontend | `langgenius/dify-web:1.15.0` | Next.js frontend, tách runtime khỏi API [S-005] |
| Plugin daemon | `langgenius/dify-plugin-daemon:0.6.3-local` | Storage/DB plugin riêng về mặt logic [S-005][S-006] |
| Sandbox | `langgenius/dify-sandbox:0.2.15` | Code execution service [S-005][S-006] |
| PostgreSQL | `postgres:15-alpine` | Default operational database [S-005][S-006] |
| Redis | `redis:6-alpine` | Cache/message broker/backend theo cấu hình mặc định [S-006][S-011] |
| Weaviate | `semitechnologies/weaviate:1.27.0` | Default vector store [S-005][S-006] |
| Nginx / SSRF proxy / init task | `nginx:latest`, `ubuntu/squid:latest`, `busybox:latest` | Tag động; phải pin/digest trước production [S-005] |

## Hướng dẫn hoặc ví dụ triển khai

Trong Sprint 0/G1, chỉ thực hiện config inspection và chuẩn bị lab. Lệnh triển khai chính thức ở baseline là clone đúng tag, copy `docker/.env.example` thành `.env`, rồi chạy `docker compose up -d`. [S-003][S-007]

Không sử dụng `main` hoặc tag `latest` của Dify để viết procedure. Mọi lệnh trong chương 11 phải checkout `1.15.0` hoặc pin commit tương ứng.

## Quyết định và trade-off

- **Chọn `1.15.0` thay vì `main`:** tái hiện được và có release notes/migration guide. Đổi lại, tính năng xuất hiện sau ngày baseline nằm ngoài phạm vi cho đến đợt review tiếp theo.
- **Tách baseline Community và snapshot Enterprise:** tránh coi marketing capability Enterprise là thành phần có trong Community source.
- **Giữ Docker Compose làm reference runtime đầu tiên:** đây là phương thức self-host công khai được docs hướng dẫn trực tiếp. Kubernetes Community vẫn phải đóng gap về chart provenance; Enterprise công khai nêu Helm/Kubernetes. [S-008][S-019]
- **License dùng exact wording:** file `LICENSE` gọi đây là modified Apache License 2.0 với điều kiện bổ sung về multi-tenant và logo/copyright. Việc kết luận pháp lý “source-available” phải được Legal xác nhận; tài liệu kỹ thuật không tự thay Legal. [S-004]

## Security và operations implications

- `.env.example` chứa nhiều giá trị mặc định minh họa; mọi password, API key, signing key và plugin key phải được thay/rotate trước lab chia sẻ hoặc production. [S-006]
- Compose baseline còn dùng một số image tag `latest`; production artifact phải pin version/digest và có quy trình cập nhật.
- Release `1.15.0` có database migrations, environment-variable changes và bước backfill plugin auto-upgrade; chương upgrade phải dùng release notes thay vì chỉ `docker compose pull/up`. [S-001]
- Nguồn Enterprise công khai nêu SSO, fine-grained RBAC, audit logs và Helm chart; Community docs mô tả bốn built-in workspace roles nhưng custom granular roles thuộc Enterprise. [S-017][S-019]

## Failure modes và troubleshooting

| Failure mode | Dấu hiệu | Cách phòng ngừa trong tài liệu |
|---|---|---|
| Trộn docs latest với release | Tên biến, UI hoặc procedure không khớp | Citation phải trỏ nhánh/tag `1.15.0` |
| Trộn Community và Enterprise | Hứa tính năng không có trong Community | Mọi feature nhạy edition phải nằm trong capability matrix |
| Dùng image `latest` ở production | Cùng config nhưng runtime thay đổi | Pin digest/version trong reference production values |
| Bỏ qua migration/backfill | Upgrade lên nhưng schema/setting không đồng bộ | Bắt buộc đọc release notes và có preflight/rollback |
| Gọi phần design-reviewed là production-tested | Người đọc đánh giá sai độ tin cậy | Hiển thị nhãn validation ở đầu chương/procedure |

## Checklist xác nhận

- [x] Release/tag Community baseline được khóa.
- [x] Full commit SHA được ghi lại.
- [x] Nhánh docs tương ứng tồn tại và snapshot commit đã được khóa.
- [x] Compose, `.env.example`, Nginx routing, Celery entrypoint và license đã được đối chiếu.
- [ ] Docker daemon/lab runtime sẵn sàng.
- [ ] Compose clean install và smoke test hoàn tất.
- [ ] Kubernetes/Helm artifact/provenance cho Community được chốt.
- [ ] Enterprise feature matrix được vendor/Legal/Security review.
- [ ] Mermaid renderer đích được chốt.

## Giới hạn/version caveats

- `1.15.0` là latest stable tại thời điểm khóa baseline, không phải cam kết luôn là phiên bản mới nhất.
- Enterprise có release train/artifact riêng; chưa đủ evidence để ánh xạ version Enterprise sang Community `1.15.0`.
- Chưa có runtime evidence ở thời điểm viết chương này; các kết luận topology hiện là source/config based.
- Trước final phải chạy version-drift check; nếu có release mới, ghi delta về MCP, plugin, license, deployment và migrations.

## Nguồn tham khảo

- [S-001] Dify `1.15.0` release notes.
- [S-002] Commit bump version `1.15.0`.
- [S-004] License tại tag `1.15.0`.
- [S-005] Docker Compose tại tag `1.15.0`.
- [S-006] `.env.example` tại tag `1.15.0`.
- [S-007] Dify Docs: Deploy with Docker Compose, nhánh `release/1.15.0`.
- [S-008] Dify Docs: Deployment overview, nhánh `release/1.15.0`.
- [S-017] Dify Docs: Manage Members, nhánh `release/1.15.0`.
- [S-018] Dify pricing.
- [S-019] Dify Enterprise product page.
- [S-020] Dify Docs repository/versioning.
- [S-024] Dify `1.15.0` release API metadata.
- [S-025] Dify Docs branch metadata và snapshot SHA.
