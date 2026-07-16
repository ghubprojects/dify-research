# Brief: Nghiên cứu & Xây dựng Tài liệu Kỹ thuật Dify AI (Self-hosted) cho Doanh nghiệp

> Ghi chú: Use case cụ thể và hạ tầng self-host chưa được chốt. Brief này được thiết kế để **bao quát toàn bộ platform** nhưng vẫn có phân tầng độ sâu rõ ràng, tránh viết dàn trải vô tận. Khi use case/hạ tầng được chốt sau này, chỉ cần đào sâu thêm phần Tier 3 tương ứng — phần khung (Tier 1 & 2) không cần viết lại.

## 1. Vai trò & Bối cảnh

**Vai trò:** Senior AI infrastructure consultant, viết tài liệu kỹ thuật nội bộ cho một tổ chức đang đánh giá Dify để triển khai production.

**Bối cảnh:** Doanh nghiệp muốn tự vận hành (self-hosted) Dify vì lý do bảo mật/kiểm soát dữ liệu nội bộ. Use case cụ thể và hạ tầng triển khai chưa được xác định — tài liệu cần giúp người đọc (dev chưa từng dùng Dify) vừa hiểu nền tảng, vừa có đủ cơ sở để tự chọn use case và hạ tầng phù hợp cho từng dự án sau này.

**Người đọc mục tiêu:** Developer/kỹ sư nội bộ, chưa từng tiếp xúc Dify, cần hiểu sâu về mặt kỹ thuật để triển khai và vận hành thực tế — không phải chỉ đọc để biết khái niệm.

## 2. Mục tiêu (2 mục tiêu song song)

1. **Hiểu tường tận** — người đọc nắm được kiến trúc, cơ chế hoạt động, và giới hạn của Dify ở mức đủ sâu để đưa ra quyết định kỹ thuật độc lập (không chỉ "biết dùng" mà còn "biết vì sao").
2. **Ứng dụng chuyên nghiệp** — người đọc có thể tự triển khai, bảo mật, và vận hành một instance Dify production-grade mà không cần hỏi thêm.

## 3. Phạm vi & độ ưu tiên (phần quan trọng nhất — quyết định độ dài/chi tiết)

### Tier 1 — Bắt buộc đào sâu tối đa (áp dụng bất kể use case nào được chọn sau này)
- Kiến trúc tổng thể: API server, worker queue (Celery), frontend, vector DB, cache, storage — cách các thành phần này giao tiếp với nhau
- Triển khai self-host: cả 2 kịch bản (xem mục 4)
- Bảo mật, license & compliance: Community Edition vs Enterprise Edition, SSO/RBAC, audit log, network isolation
- Tích hợp model provider: API ngoài (OpenAI-compatible, Anthropic, Azure, Bedrock) và model tự host (Ollama/vLLM)
- Vòng đời vận hành: backup, upgrade, monitoring, disaster recovery

### Tier 2 — Đào sâu vừa phải (mỗi năng lực lõi ~1 chương, đủ để implement chứ không cần bao quát mọi tham số)
- RAG pipeline (ingestion, chunking, embedding, retrieval, lựa chọn vector DB)
- Workflow builder (visual DSL, node types, logic điều kiện)
- Agent framework (function calling, tool use, reasoning loop, giới hạn/guardrail)
- MCP (Model Context Protocol) — Dify vừa làm MCP client vừa expose workflow như MCP server
- Plugin marketplace & khả năng tự viết plugin
- LLMOps/observability (logging, tích hợp Langfuse/Opik/Arize Phoenix)

### Tier 3 — Overview theo use case (mỗi use case 1–2 trang, dùng làm "bản đồ" để chọn hướng đi sau này)
- Chatbot/trợ lý nội bộ (CSKH, HR, IT support)
- RAG tra cứu tài liệu/kiến thức công ty
- Agent tự động hoá quy trình nghiệp vụ
- Backend-as-a-Service: expose API AI cho sản phẩm/hệ thống nội bộ khác

### Ngoài phạm vi (trừ khi có yêu cầu bổ sung sau)
- So sánh sâu với Flowise/n8n/LangChain/LangGraph — chỉ cần 1 bảng so sánh ngắn ở phụ lục, không cần phân tích trade-off đầy đủ

## 4. Ràng buộc kỹ thuật & tổ chức

- **Hạ tầng chưa chốt →** tài liệu phải cover **cả 2** kịch bản triển khai, kèm bảng quyết định để chọn:

| Tiêu chí | Docker Compose (single-node) | Kubernetes/Helm (HA) |
|---|---|---|
| Phù hợp khi | POC, pilot, < ~50 người dùng | Production, cần HA/scale, nhiều team |
| Effort vận hành | Thấp | Cao, cần kinh nghiệm K8s |
| Khả năng mở rộng | Giới hạn (vertical scale) | Horizontal scale tốt |

- **Version:** ghi rõ version Dify tại thời điểm viết tài liệu; khuyến nghị review lại sau mỗi lần có major release (đặc biệt các thay đổi lớn như hỗ trợ MCP, plugin architecture).
- **License:** phải có mục riêng nói rõ self-hosted Community Edition dùng license dạng Apache-2.0 kèm điều kiện bổ sung (source-available, không phải open-source thuần) — để bộ phận pháp lý/procurement review được trước khi triển khai.
- **Định dạng nguồn:** Markdown (dễ đưa vào Confluence/wiki nội bộ), có mục lục, có thể tách file theo từng phần lớn.

## 5. Cấu trúc tài liệu final đề xuất (outline)

**Phần I — Kiến thức nền (đọc để hiểu)**
1. Dify là gì, định vị trong hệ sinh thái LLM application platform
2. Kiến trúc tổng thể & các thành phần hệ thống
3. Các năng lực lõi: Workflow / RAG / Agent / Model management / MCP / Plugin / LLMOps
4. Community Edition vs Enterprise Edition vs Cloud — khác biệt tính năng & license

**Phần II — Playbook triển khai (đọc để làm)**
5. Triển khai self-host: Docker Compose (quick start → cấu hình nâng cao)
6. Triển khai production: Kubernetes/Helm, HA, scaling, load balancing
7. Bảo mật: SSO/LDAP, RBAC, network isolation, secrets management, audit logging
8. Tích hợp model provider (API ngoài & model tự host)
9. RAG pipeline chi tiết: ingestion → chunking → embedding → retrieval, lựa chọn vector DB
10. Vòng đời vận hành: backup, upgrade, monitoring, disaster recovery
11. CI/CD & Infra-as-code cho Dify (nếu áp dụng)

**Phần III — Ứng dụng vào business (decision framework)**
12. 4 mẫu use case phổ biến + tiêu chí chọn mẫu nào cho dự án cụ thể
13. Checklist POC/pilot: từ ý tưởng đến demo
14. Ước tính chi phí: hạ tầng + model API + effort vận hành

**Phụ lục:** bảng so sánh nhanh với Flowise/n8n/LangChain, glossary thuật ngữ, danh sách tài liệu tham khảo chính thức

## 6. Tiêu chí thành công

Một dev nội bộ chưa từng biết Dify, sau khi đọc tài liệu, có thể:
- Giải thích được kiến trúc và cách Dify vận hành ở mức đủ sâu để trả lời câu hỏi kỹ thuật từ đồng nghiệp
- Tự deploy một instance self-host (cả bản POC lẫn định hướng production) mà không cần hỏi thêm
- Tự chọn được use case + hạ tầng phù hợp cho một dự án cụ thể của công ty, dựa trên decision framework trong tài liệu
