# Hướng dẫn kỹ thuật Dify AI self-hosted

> **Baseline Community Edition:** Dify `1.15.0`  
> **Docs snapshot:** `release/1.15.0 @ 57a492d8063d1583c582b4c0444fb838c6dd3027`  
> **Ngày chốt baseline:** `2026-07-16`  
> **Trạng thái tài liệu:** `Draft vòng 1 hoàn tất cho 00–19 và phụ lục A–E; static QA tích hợp đạt, specialist/runtime review còn mở`  
> **Owner:** Nhóm biên soạn kỹ thuật  
> **Validation hiện tại:** 116 nguồn đã đăng ký và được citation; 20/20 chương đạt heading contract; 29 Mermaid block trong bộ guide đã static-check nhưng chưa render trên wiki đích; lab runtime chưa hoàn tất

## Cách dùng bộ tài liệu

Bắt đầu tại [phạm vi, phiên bản và giả định](00-scope-version-and-assumptions.md), sau đó chọn learning path phù hợp. Các file theo chương là nguồn chuẩn; bản ghép chỉ được tạo trong quy trình phát hành.

### Tiến độ hiện tại

| Trạng thái | Chương |
|---|---|
| Draft vòng 1 | 00–19 |
| Phụ lục đã soạn | A So sánh nhanh, B Glossary, C Configuration checklists, D Troubleshooting, E References |
| Governance/template đã soạn | F Change log, use-case addenda template, working registers và release checklist |
| Static QA đã đạt | Source/citation ID, heading, fence, local link, immutable Dify docs link, mojibake và Mermaid pattern checks |
| Chờ runtime/specialist review | Compose/Kubernetes/provider/backup-DR/POC labs; Mermaid render; Legal/Security/Platform/Operations/FinOps sign-off |

Các procedure cần daemon, cluster, provider credential, corpus, tool hoặc business input đều mang nhãn `RUNTIME-PENDING` hoặc gap ID. Không dùng trạng thái draft/static QA làm production sign-off. Bản ghép `dify-research-final.md` chỉ được sinh sau khi đạt release gates; các file theo chương hiện là nguồn chuẩn.

## Điều kiện tiên quyết

- Kiến thức nền về HTTP/API, container, PostgreSQL, Redis và khái niệm cơ bản của LLM/RAG.
- Để thực hành Compose: một host/VM phù hợp, tối thiểu 2 CPU và 4 GiB RAM; Docker Compose `2.24.0+` theo tài liệu Dify. Cấu hình thực hành khuyến nghị sẽ được xác định sau benchmark. [S-007]
- Để thực hành production: quyền truy cập Kubernetes test cluster, DNS/TLS, storage class, secret manager và model provider credential; các phần này chưa phải prerequisite để đọc Phần 1.
- Không dùng credential hoặc dữ liệu doanh nghiệp thật trong ví dụ/lab chưa được Security phê duyệt.

## Learning paths

### Đọc để hiểu

1. [00. Phạm vi, phiên bản và giả định](00-scope-version-and-assumptions.md)
2. [01. Tổng quan Dify](part-1-foundations/01-dify-overview.md)
3. [02. Kiến trúc hệ thống](part-1-foundations/02-system-architecture.md)
4. [06. Quản lý model](part-1-foundations/06-model-management.md)
5. [10. Editions và license](part-1-foundations/10-editions-license.md)
6. [B. Glossary](appendices/b-glossary.md)

### Đọc để triển khai/vận hành

1. [00. Phạm vi, phiên bản và giả định](00-scope-version-and-assumptions.md)
2. [02. Kiến trúc hệ thống](part-1-foundations/02-system-architecture.md)
3. [11. Docker Compose](part-2-deployment-playbook/11-docker-compose.md)
4. [14. Tích hợp model provider](part-2-deployment-playbook/14-model-provider-integration.md)
5. [13. Security hardening](part-2-deployment-playbook/13-security-hardening.md)
6. [12. Kubernetes/Helm HA](part-2-deployment-playbook/12-kubernetes-ha.md)
7. [09. LLMOps và observability](part-1-foundations/09-llmops-observability.md)
8. [15. Operations, backup, upgrade và DR](part-2-deployment-playbook/15-operations-backup-upgrade-dr.md)
9. [16. CI/CD và IaC](part-2-deployment-playbook/16-cicd-iac.md)
10. [C. Configuration checklists](appendices/c-configuration-checklists.md)
11. [D. Troubleshooting](appendices/d-troubleshooting.md)

### Đọc để ra quyết định

1. [00. Phạm vi, phiên bản và giả định](00-scope-version-and-assumptions.md)
2. [01. Tổng quan Dify](part-1-foundations/01-dify-overview.md)
3. [10. Editions và license](part-1-foundations/10-editions-license.md)
4. [17. Các mẫu use case](part-3-decision-framework/17-use-case-patterns.md)
5. [18. Checklist POC/pilot](part-3-decision-framework/18-poc-pilot-checklist.md)
6. [19. Mô hình chi phí](part-3-decision-framework/19-cost-model.md)
7. [A. So sánh nhanh](appendices/a-quick-comparison.md)

## Mục lục

### Baseline

- [00. Phạm vi, phiên bản và giả định](00-scope-version-and-assumptions.md)

### Phần 1 — Nền tảng

- [01. Tổng quan Dify](part-1-foundations/01-dify-overview.md)
- [02. Kiến trúc hệ thống](part-1-foundations/02-system-architecture.md)
- [03. Workflow](part-1-foundations/03-workflow.md)
- [04. RAG](part-1-foundations/04-rag.md)
- [05. Agent](part-1-foundations/05-agent.md)
- [06. Quản lý model](part-1-foundations/06-model-management.md)
- [07. MCP](part-1-foundations/07-mcp.md)
- [08. Plugins](part-1-foundations/08-plugins.md)
- [09. LLMOps và observability](part-1-foundations/09-llmops-observability.md)
- [10. Editions và license](part-1-foundations/10-editions-license.md)

### Phần 2 — Deployment playbook

- [11. Docker Compose](part-2-deployment-playbook/11-docker-compose.md)
- [12. Kubernetes/Helm HA](part-2-deployment-playbook/12-kubernetes-ha.md)
- [13. Security hardening](part-2-deployment-playbook/13-security-hardening.md)
- [14. Tích hợp model provider](part-2-deployment-playbook/14-model-provider-integration.md)
- [15. Operations, backup, upgrade và DR](part-2-deployment-playbook/15-operations-backup-upgrade-dr.md)
- [16. CI/CD và IaC](part-2-deployment-playbook/16-cicd-iac.md)

### Phần 3 — Decision framework

- [17. Các mẫu use case](part-3-decision-framework/17-use-case-patterns.md)
- [18. Checklist POC/pilot](part-3-decision-framework/18-poc-pilot-checklist.md)
- [19. Mô hình chi phí](part-3-decision-framework/19-cost-model.md)
- [Use-case addenda](part-3-decision-framework/addenda/README.md)

### Phụ lục

- [A. So sánh nhanh](appendices/a-quick-comparison.md)
- [B. Glossary](appendices/b-glossary.md)
- [C. Configuration checklists](appendices/c-configuration-checklists.md)
- [D. Troubleshooting](appendices/d-troubleshooting.md)
- [E. References](appendices/e-references.md)
- [F. Change log](appendices/f-change-log.md)

## Quy ước biên soạn

- Citation nội tuyến: `[S-###]`.
- Sơ đồ: fenced block `mermaid`, nhúng trong chương liên quan.
- Trường chưa có evidence phải ghi rõ owner và nhãn `RUNTIME-PENDING` hoặc gap ID; không để ô trống mơ hồ.
- Trạng thái nghiên cứu và kiểm chứng được theo dõi trong [docs/working](../working/chapter-status.md).
- `Official-source verified` không đồng nghĩa với `RUNTIME-VALIDATED`; mỗi chương phải ghi đúng mức bằng chứng hiện có.
- Nội dung Enterprise/Cloud là snapshot từ nguồn sản phẩm công khai tại ngày truy cập, không được suy diễn thành capability đã runtime-test.
