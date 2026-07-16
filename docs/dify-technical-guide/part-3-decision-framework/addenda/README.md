# Use-case addenda

> **Stable-core baseline:** Dify Community Edition `1.15.0`  
> **Ngày cập nhật:** `2026-07-16`  
> **Trạng thái:** Template governance; chưa có addendum doanh nghiệp cụ thể  
> **Owner:** Product Architecture và chủ use case tương ứng

## Mục đích

Addendum ghi các quyết định chỉ đúng cho một use case, business domain hoặc workload. Nó mở rộng bộ tài liệu mà không sao chép kiến trúc, security, operations và decision framework chung.

Tạo addendum khi doanh nghiệp đã chốt ít nhất business owner, persona/consumer, data boundary và scenario cần đánh giá. Nếu các đầu vào này chưa có, dùng Chương 17–18 để hoàn tất discovery trước.

## Điều kiện tạo addendum

Mỗi addendum phải có:

- business owner, technical owner và reviewer;
- use-case pattern chính theo Chương 17;
- baseline Dify/source/docs/plugin và ngày kiểm chứng;
- business flow, system of record và decision/action authority;
- data source, classification, ACL, retention, delete và residency;
- model/provider, knowledge, tool, plugin và external dependency;
- SLI/SLO/RPO/RTO, evaluation set, cost inputs và production exit criteria;
- threat/control, failure/rollback/DR và residual-risk owners;
- evidence IDs hoặc `RUNTIME-PENDING` cho test chưa chạy.

Không tạo addendum chỉ để lưu prompt thử nghiệm, meeting note hoặc bản sao một chương nền.

## Quy tắc tham chiếu stable core

- Link đến chương sở hữu nội dung; chỉ ghi delta của use case.
- Không định nghĩa lại service topology, license text, provider mechanism, backup principle hoặc validation label.
- Nếu evidence use case làm thay đổi kết luận stable core, mở issue/change request cho chương gốc trước; addendum không được lặng lẽ ghi kết luận mâu thuẫn.
- Mọi claim nhạy version vẫn dùng Source ID trong source register chung hoặc đăng ký Source ID mới.
- Diagram business/data flow có thể dùng Mermaid; tên trust zone, store và external party phải rõ.
- Secret, credential, production sample và unredacted conversation không được đưa vào Markdown/Git.
- Sau khi baseline Dify đổi, addendum phải qua impact review; chưa review thì ghi `Version revalidation required`.

## Quy ước đặt tên

Tên file:

```text
uc-<domain-ngan>-<muc-tieu-ngan>.md
```

Ví dụ:

```text
uc-it-support-knowledge-assistant.md
uc-finance-invoice-triage.md
```

Không đưa tên người, mã khách hàng, dữ liệu mật hoặc ngày ngẫu nhiên vào filename. Nếu có nhiều revision, version được quản lý trong metadata/change history, không nhân bản file `final-v2-final`.

## Template addendum

Mỗi file mới dùng cấu trúc dưới đây. Metadata phải được điền trước G0 của addendum; mục chưa có evidence ghi rõ owner và `RUNTIME-PENDING`, không để trống.

```markdown
# Use case: Tên ngắn mô tả outcome

> Stable-core baseline: Dify Community Edition 1.15.0
> Addendum version: 0.1.0
> Ngày kiểm chứng: YYYY-MM-DD thực tế
> Business owner: tên/vai trò thực tế
> Technical owner: tên/vai trò thực tế
> Validation status: Design reviewed hoặc mức evidence thực tế

## Executive decision

## Business flow

## Dữ liệu và tích hợp

## Application design

## SLO và tiêu chí đánh giá

## Threats và controls

## Sizing và cost drivers

## Operations, rollback và DR

## POC/pilot và rollout

## Assumptions, gaps và exit criteria

## Nguồn tham khảo
```

### Business flow

Ghi actor, trigger, current process/baseline, desired outcome, system of record, human decision và exception/escalation. Mermaid sequence/flow chỉ nên mô tả business boundary; link Chương 02 cho platform topology.

### Dữ liệu và tích hợp

Lập bảng source/owner/classification/ACL/freshness/delete/residency. Ghi consumer/provider/tool/API, identity propagation, quota, timeout, idempotency và compensation. Không coi metadata filter, prompt hoặc workspace credential là authorization boundary.

### Application design

Chọn Workflow/Chatflow/Agent/RAG/API pattern, giải thích vì sao, ghi DSL hash/dependency manifest và mức automation. Agent write action phải có downstream authorization, approval, audit, budget và kill switch.

### SLO và tiêu chí đánh giá

Ghi baseline, target, hard gates, golden-set version, representative/negative/adversarial/failure slices, p50/p95/p99 khi phù hợp, cost/successful task và evidence location. Không thay target sau khi xem kết quả mà không version contract.

### Threats và controls

Ghi trust zones, abuse/misuse, prompt/document/tool injection, data exfiltration, privilege, dependency/supply chain và log/retention risk; mỗi threat có preventive/detective/recovery control, test ID và owner.

### Sizing và cost drivers

Ghi request/concurrency, tokens/context, ingest/update, retrieval, storage, provider/GPU, observability, network, backup/DR và effort. Dùng công thức Chương 19; không đưa giá “mẫu” thành forecast.

### Rollout và exit criteria

Đi theo stage-gate Chương 18. Nêu pilot population, support/on-call, canary, quota, kill switch, rollback/restore, go/revise/hold/stop và production gaps có budget/owner.

### Nguồn tham khảo

Ưu tiên link stable core và Source ID đã đăng ký. Nguồn business nội bộ phải dùng identifier/kho có quyền truy cập, data classification và owner; không copy nội dung nhạy cảm vào addendum.
