# Validation log

## Quy ước nhãn

- `Official-source verified`
- `Config validated`
- `Design reviewed`
- `RUNTIME-PENDING`
- `RUNTIME-VALIDATED`

## Kết quả kiểm chứng

| Validation ID | Chương | Ngày | Môi trường/baseline | Procedure hoặc artifact | Kết quả kỳ vọng | Kết quả thực tế | Evidence | Nhãn xác minh | Owner | Follow-up |
|---|---|---|---|---|---|---|---|---|---|---|
| V-001 | 00, 15 | 2026-07-16 | GitHub official release | Kiểm tra release `1.15.0`, timestamp, release notes và migration section | Release chính thức, không draft/prerelease | Release tồn tại; published 2026-06-25; release page marked Latest tại thời điểm kiểm tra | S-001, S-024 | Official-source verified | Lead author | Recheck tại G5 |
| V-002 | 00 | 2026-07-16 | GitHub repository | Resolve tag/short SHA tới full commit | Có immutable product commit | `3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c` | S-002 | Official-source verified | Lead author | Không |
| V-003 | 00 | 2026-07-16 | Dify docs repository | Kiểm tra branch `release/1.15.0` và HEAD | Có versioned docs snapshot | Branch tồn tại/protected; HEAD `57a492d8063d1583c582b4c0444fb838c6dd3027` | S-020, S-025 | Official-source verified | Lead author | Dùng commit URL thay branch URL trong final |
| V-004 | 00, 02, 11, 13 | 2026-07-16 | Static config at product tag 1.15.0 | Parse `docker-compose.yaml` và `.env.example` | Xác định service/image/dependency/volume/endpoint mặc định | 1201-line Compose; core/dependency/profile và default endpoint đã inventory | S-005, S-006 | Config validated | Platform author | Runtime lab `V-Compose-PENDING` |
| V-005 | 02, 11 | 2026-07-16 | Nginx template at product tag 1.15.0 | Đối chiếu path routing | Frontend/API/websocket/plugin boundary rõ | Route map đã xác nhận từ template | S-010 | Config validated | Platform author | Smoke test HTTP/WebSocket |
| V-006 | 11 | 2026-07-16 | Windows host hiện tại | Chạy `docker version` và `docker compose version` | Docker client/daemon/Compose sẵn sàng | Client `29.2.1`; Compose `v5.0.2`; daemon không chạy; Docker config báo access denied trong sandbox | Local command output | Config validated | Lab owner | G-002: khởi động daemon và xử lý quyền config |
| V-007 | 10 | 2026-07-16 | LICENSE at tag 1.15.0 | Đọc toàn văn điều kiện bổ sung | Có exact wording để Legal review | Xác nhận multi-tenant/workspace và frontend logo/copyright conditions | S-004 | Official-source verified | Legal owner | Legal classification/sign-off trước deployment |
| V-008 | 12 | 2026-07-16 | Official docs + `langgenius` GitHub org search | Tìm public Community Helm/Kubernetes artifact | Xác định provenance chart | Docs nêu K8s/Helm cho Enterprise; tìm thấy repo tooling/chart Enterprise, chưa thấy Community chart official | S-008, S-019, S-022, S-023 | Design reviewed | Platform architect | Vendor confirmation/Community chart evaluation |
| V-009 | 02, 03 | 2026-07-16 | Source at product tag 1.15.0 | Trace dispatch cho app generation blocking/streaming và Redis event subscription | Phân biệt inline, queued streaming, background và scheduled path | Completion/Chat/Agent và blocking Workflow/Chatflow chạy inline; streaming Workflow/Chatflow enqueue worker sau khi subscription sẵn sàng | S-034, S-035, S-036, S-037 | Official-source verified | Platform author | Runtime trace blocking/streaming |
| V-010 | 00–19, appendices và governance | 2026-07-16 | Local Markdown source tree | Kiểm tra source/citation/control ID, table shape, heading contract, relative link, immutable docs URL và fence balance | Không missing/duplicate ID; không link local hỏng; fence cân bằng | 37 Markdown files; 116 source IDs và 116 source được citation; 0 missing/duplicate citation ID; 0 malformed source row; 0 duplicate source URL; 0 broken local link; 0 odd fence; 20/20 chương có đúng 1 H1 + 11 H2; 184 control IDs unique; 29 Mermaid block trong guide + 1 trong plan | Local QA output | Config validated | Lead author | Render 29 guide diagrams trên renderer đích |
| V-011 | 02, 12, 14–16, 19, Appendix A/E | 2026-07-16 | Official/primary source review | Mở rộng và đối chiếu nguồn Kubernetes, model serving, backup/DR, CI supply chain, FinOps/comparison và MCP core path | Claim mới có primary source; URL/ID không trùng và Appendix E bao phủ register | Source register tăng lên 116 nguồn; MCP core path được tách khỏi plugin-daemon path bằng source tag-pinned [S-119][S-120] | Source register + Appendix E | Official-source verified | Lead author | Recheck current web docs tại G5 |
| V-012 | Toàn bộ Mermaid | 2026-07-16 | Local renderer preflight | Xác định khả năng render Mermaid tự động | Có Mermaid CLI hoặc renderer đích | Node `v24.13.1`, npm `11.8.0`; `mmdc` chưa được cài, vì vậy mới static-check 29 guide diagrams, chưa render | Local command output | RUNTIME-PENDING | Lead author/Publishing owner | Render bằng đúng Mermaid version của wiki/target trước G5 |
