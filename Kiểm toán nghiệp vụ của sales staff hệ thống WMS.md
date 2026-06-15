# **Báo Cáo Kiểm Toán Chuyên Sâu Khung Kiến Trúc Vận Hành: Hệ Thống B2C Omnichannel WMS Hub**

Báo cáo này cung cấp một đợt kiểm toán toàn diện, khắt khe và mang tính chiến lược đối với tài liệu thiết kế "Mô tả Chức năng Nghiệp vụ — SALES STAFF" thuộc dự án hệ thống B2C Omnichannel WMS Hub.1 Trọng tâm phân tích được đặt trực tiếp vào bối cảnh thực chiến khốc liệt của ngành hàng Phụ kiện thời trang, bao gồm các mặt hàng như kính mắt, cà vạt, khăn, và trang sức. Đây là một phân khúc bán lẻ đặc thù với tần suất đơn hàng khổng lồ, giá trị trung bình trên một đơn hàng (AOV \- Average Order Value) thấp nhưng số lượng mã sản phẩm (SKU) biến thể màu sắc và họa tiết cực kỳ phức tạp, kéo theo đó là tỷ lệ hoàn hàng (RMA) vô cùng nhạy cảm.  
Dưới góc nhìn của quản trị vận hành thương mại điện tử đa kênh, kiến trúc hiện hành đang bộc lộ sự pha trộn nguy hiểm giữa Hệ thống Quản lý Đơn hàng (OMS \- Order Management System) và Hệ thống Quản lý Kho (WMS \- Warehouse Management System). Thiết kế này dẫn đến sự sai lệch nghiêm trọng về vai trò của nhân sự, tạo ra các điểm nghẽn cổ chai (bottlenecks) có nguy cơ làm tê liệt toàn bộ luồng xử lý trong các ngày Mega Sale, và tiềm ẩn rủi ro bán vượt tồn kho (overselling) trên các nền tảng như Lazada, Shopee, và TikTok Shop.

## **1\. Đối Chiếu Thực Tế Vận Hành (Real-World Mapping)**

Sự thành bại của một doanh nghiệp bán lẻ đa kênh phụ thuộc vào khả năng tự động hóa luồng dữ liệu xuyên suốt giữa các điểm chạm (touchpoints) trên sàn thương mại điện tử và trung tâm xử lý đơn hàng (fulfillment center). Thiết kế tại tài liệu hiện hành đang đặt nhân sự Sales Staff vào vị trí điều hướng thủ công toàn bộ luồng đơn hàng, một cách tiếp cận hoàn toàn đi ngược lại với các nguyên lý quản trị chuỗi cung ứng hiện đại và Khái niệm Quản lý Đơn hàng Phân tán (Distributed Order Management \- DOM).2

### **1.1. Thực Tiễn Vận Hành Của Nhân Sự Sales Staff (E-commerce Admin)**

Trong các doanh nghiệp bán lẻ thực chiến, một ngày làm việc của E-commerce Admin, hay Sales Staff phụ trách đa kênh, không bao giờ xoay quanh việc click "Duyệt" cho hàng ngàn đơn hàng hợp lệ.4 Với đặc thù ngành phụ kiện thời trang, nơi một chiến dịch Mega Sale như 11/11 hoặc Black Friday có thể mang về từ 5.000 đến 20.000 đơn hàng mỗi ngày, việc phụ thuộc vào thao tác thủ công là một thảm họa về mặt năng suất.  
Nhiệm vụ cốt lõi của E-commerce Admin trong một mô hình vận hành chuẩn hóa bao gồm các trọng trách chiến lược và xử lý ngoại lệ, thay vì đóng vai trò như một cỗ máy duyệt đơn. Công việc thực sự của họ diễn ra như sau:  
Đầu tiên là quản trị ngoại lệ (Exception Management). Khi hệ thống tự động đã xử lý 95% khối lượng đơn hàng trơn tru, Sales Staff sẽ can thiệp vào 5% các đơn hàng bị hệ thống từ chối hoặc cảnh báo lỗi.4 Các lỗi này bao gồm địa chỉ khách hàng không hợp lệ, thiếu thông tin để xuất hóa đơn theo yêu cầu của sàn (ví dụ như TikTok Shop yêu cầu hóa đơn cho một số luồng nhất định trước khi giao hàng 5), hoặc lỗi API từ phía đơn vị vận chuyển (ĐVVC).  
Tiếp đến là công tác đồng bộ danh mục sản phẩm và ánh xạ SKU (Catalog & SKU Mapping). Trong ngành phụ kiện, đội ngũ Marketing liên tục tung ra các bộ sưu tập mới, tạo các combo khuyến mãi trực tiếp trên Seller Center của Shopee, Lazada, hoặc TikTok. Sales Staff phải đảm bảo các mã Channel\_SKU này được ánh xạ chính xác với Master\_SKU trong kho trước khi chiến dịch bắt đầu để hệ thống tự động có thể tính toán tồn kho.1  
Một nhiệm vụ sống còn khác là điều phối chiến lược Tồn kho Đệm (Buffer Stock Strategy). Trong những giờ cao điểm của Flash Sale, Sales Staff phải giám sát tốc độ bán (sales velocity) để cấu hình linh hoạt lượng tồn kho an toàn, qua đó chống lại độ trễ API (latency) của các sàn và ngăn ngừa thảm họa bán vượt mức tồn kho cho phép.6 Cuối cùng, họ phải quản lý các quy tắc kinh doanh phức tạp như xử lý hàng tặng kèm (GWP \- Gift with Purchase) và các cơ chế tách, gom đơn hàng dựa trên các chương trình khuyến mãi đặc trưng của ngành thời trang.

### **1.2. Phân Tích Độ Lệch Pha Trong 6 Module Nghiệp Vụ Hiện Hành**

Kiến trúc trong tài liệu đang thiết kế hệ thống theo hướng làm phức tạp hóa vấn đề thông qua việc "thủ công hóa" các quy trình kỹ thuật số vốn cần được xử lý tự động bởi máy chủ.1

* **Sự Nhầm Lẫn Về "Cầu Nối Duy Nhất":** Việc quy định ở Module 1 rằng "Mọi đơn trước khi xuất kho đều phải qua tay Sales" 1 là một tư duy hệ thống nguyên thủy. Một hệ thống WMS/OMS hiện đại phải hoạt động trên nguyên lý tự động hóa luồng quy tắc (Rule Engine).4 Hệ thống phải tự động kiểm tra ma trận quy tắc bao gồm: trạng thái thanh toán (thành công hoặc COD), tồn kho khả dụng (Available-to-Promise \- ATP lớn hơn 0), và tính hợp lệ của đơn. Nếu thỏa mãn, hệ thống tự động đẩy phiếu xuất xuống kho (Outbound Order). Con người chỉ đóng vai trò giám sát, không phải là người cản trở dòng chảy của dữ liệu.  
* **Trách Nhiệm Sinh Mã Vận Đơn (AWB) Và In Tem:** Việc Module 2.3 và 2.4 giao phó trách nhiệm tạo mã vận đơn (Tracking Number) và in tem vận chuyển cho Sales Staff tại giao diện Dashboard là một sai lầm chết người trong vận hành vật lý.1 Đối với kho phụ kiện, nơi các mặt hàng như nhẫn, khuyên tai có kích thước rất nhỏ và cực kỳ dễ nhầm lẫn, tem vận chuyển phải được in theo thời gian thực tại bàn đóng gói (Pack Station) ngay sau khi nhân viên kho quét mã vạch (barcode) của sản phẩm.8 Nếu Sales Staff in sẵn 5.000 tờ tem tại văn phòng và cầm xuống kho, việc dán nhầm tem giữa đơn hàng mua kính râm đen và kính râm đồi mồi là điều chắc chắn xảy ra, đẩy tỷ lệ hoàn hàng (RMA) lên mức không thể kiểm soát.

Bảng dưới đây tóm tắt sự sai lệch cấu trúc giữa thiết kế hiện tại và tiêu chuẩn vận hành thương mại điện tử đa kênh thực tế:

| Tính Năng Nghiệp Vụ (Theo Tài Liệu) | Thiết Kế Hiện Tại | Tiêu Chuẩn Vận Hành Thực Chiến | Mức Độ Rủi Ro Đối Với Doanh Nghiệp |
| :---- | :---- | :---- | :---- |
| **Duyệt Đơn Hàng Mới** | Sales Staff click duyệt thủ công từng đơn qua UI. | Tự động hóa qua hệ thống Rule Engine của OMS.4 | Rất Cao (Tạo nút thắt cổ chai, trễ SLA). |
| **Sinh Mã Vận Đơn (Tracking)** | Sales tạo mã qua giao diện trước khi đóng gói. | Warehouse kích hoạt qua máy quét mã vạch tại Pack Station. | Rất Cao (Sai lệch luồng vật lý và API). |
| **In Tem Vận Chuyển (Label)** | Sales in hàng loạt tại máy in văn phòng. | Warehouse in theo thời gian thực tại máy in mã vạch. | Rất Cao (Gây nhầm lẫn chéo, tăng RMA). |
| **Đồng Bộ Đơn Hàng Từ Sàn** | Lazada tự động bằng Scheduler, Shopee/TikTok thủ công. | 100% tự động qua Webhook / Push API.9 | Đặc Biệt Nghiêm Trọng (Overselling). |

## **2\. Bắt Lỗi Logic Và Tính "Ngây Thơ" Của Hệ Thống (Naive Logic Audit)**

Dưới lăng kính khắt khe của hoạt động thương mại điện tử quy mô lớn, thiết kế hiện hành chứa đựng những lỗ hổng logic ngây thơ, đe dọa trực tiếp đến khả năng sinh lời, chi phí vận hành, và điểm hiệu chuẩn (Seller Metrics) của doanh nghiệp trên các sàn TMĐT.

### **2.1. Nút Thắt Cổ Chai (Bottlenecks) Tại Phễu Xử Lý Đơn Hàng**

Chức năng POST /sales/order-action với action=approve được mô tả là "chức năng cốt lõi nhất của Sales".1 Giao diện yêu cầu nhân viên phải mở từng đơn hàng ở trạng thái PENDING, chọn kho xử lý từ trình đơn thả xuống (dropdown), chờ hệ thống kiểm tra tồn kho cho từng SKU, và cuối cùng mới được duyệt.1  
Hãy đặt luồng thiết kế này vào một bài kiểm tra thực tế: Chiến dịch Mega Sale 11/11. Trong sự kiện này, việc 5.000 đơn hàng đổ về hệ thống chỉ trong vòng 2 giờ đầu tiên (từ 0:00 đến 2:00 sáng) là một kịch bản bình thường đối với các cửa hàng phụ kiện top đầu. Giả định một nhân viên Sales Staff thao tác cực kỳ điêu luyện, mất khoảng 10 giây để xử lý trọn vẹn một đơn hàng (bao gồm click mở, chọn kho, và xác nhận). Để duyệt 5.000 đơn hàng, nhân viên này sẽ cần tới xấp xỉ 13,8 giờ thao tác liên tục không ngừng nghỉ.  
Hậu quả của việc này là hàng nghìn đơn hàng sẽ nằm kẹt ở Tab 1 (Đơn cần duyệt) trong khi bộ phận kho (Warehouse) hoàn toàn không có việc để làm vì phiếu xuất kho (Outbound Order) chưa được hệ thống sinh ra.1 Khi luồng công việc cuối cùng cũng đến được kho, thời gian đóng gói sẽ vượt qua SLA (Service Level Agreement) lấy hàng của các ĐVVC. Sàn TMĐT sẽ lập tức phạt điểm vận hành của gian hàng do tỷ lệ giao hàng trễ (Late Shipment Rate), dẫn đến hậu quả trực tiếp là mất hiển thị (shadowban) sản phẩm trong các ngày sale tiếp theo.  
**Chiến Lược Phòng Thủ (Defense Strategy):** Hệ thống bắt buộc phải loại bỏ sự can thiệp thủ công trong luồng "happy path" (luồng lý tưởng) và triển khai một Cơ chế Định tuyến Đơn hàng Tự động (Auto-Routing Distributed Order Management).3 Khi đơn hàng được đồng bộ từ sàn về qua API, hệ thống tự động kiểm tra qty\_available. Nếu đủ hàng và không có cờ cảnh báo gian lận, hệ thống ngay lập tức trừ tồn kho mềm (Soft-Allocate) 1 và chuyển thẳng trạng thái thành PICKING, đồng thời đẩy dữ liệu xuống màn hình PDA của nhân viên kho. Tab "Đơn cần duyệt" của Sales Staff chỉ nên chứa các đơn hàng rơi vào trạng thái ngoại lệ (ví dụ: thiếu tồn kho, không tìm thấy ánh xạ SKU).

### **2.2. Thiếu Sót Các Tính Năng Cốt Lõi (Missing Features) Trong Ngành Phụ Kiện**

Đặc thù của ngành phụ kiện thời trang là hành vi mua sắm ngẫu hứng (impulse buying). Khách hàng hiếm khi mua một chiếc nhẫn duy nhất; họ thường nhặt thêm một cặp khuyên tai, một chiếc dây chuyền, và một chiếc kẹp tóc vào cùng một giỏ hàng.  
Tài liệu hiện hành quy định một quy tắc kinh doanh (business rule) mang tính hủy diệt: "Nếu bất kỳ SKU nào thiếu → fail toàn bộ đơn (atomic — không duyệt một phần)".1 Đây là một tư duy lập trình cơ sở dữ liệu (Database Transaction) bị áp đặt sai lầm vào logic kinh doanh. Nếu một khách hàng mua 10 món phụ kiện trị giá 2 triệu đồng, nhưng chỉ vì hệ thống thiếu mất 1 chiếc kẹp tóc trị giá 20.000 đồng, việc hệ thống từ chối toàn bộ 9 món còn lại là hành động trực tiếp phá hoại doanh thu và trải nghiệm khách hàng.  
Thêm vào đó, tài liệu hoàn toàn bỏ quên khả năng xử lý Hàng tặng kèm (Gift with Purchase \- GWP) và các gói Combo ảo (Virtual Bundles). Trong ngành phụ kiện, các chiến dịch như "Mua kính râm tặng khăn lau chuyên dụng và hộp da" là nền tảng của chiến lược Marketing. Hệ thống hiện tại không có cơ chế nào để nhận diện một Channel\_SKU đại diện cho một Combo và bung (explode) nó ra thành các Master\_SKU thành phần để nhân viên kho biết đường nhặt hàng.  
**Chiến Lược Phòng Thủ (Defense Strategy):**

* **Kiến trúc Tách Đơn (Order Splitting):** Hệ thống phải tích hợp logic tách đơn hàng được hỗ trợ bởi các sàn. Ví dụ, API của TikTok Shop cung cấp các endpoint như VerifyOrderSplit và ConfirmOrderSplit.12 Nếu trong 10 món hàng có 1 món bị thiếu tồn kho, hệ thống tự động tách đơn hàng gốc thành hai đơn nội bộ: Order\_A (chứa 9 món có sẵn, tự động duyệt chuyển xuống kho) và Order\_B (chứa 1 món thiếu, chuyển sang trạng thái Backorder chờ hàng về, hoặc kích hoạt API hủy một phần đơn hàng với lý do "Hết hàng").  
* **BOM (Bill of Materials) Cho Combo Khuyến Mãi:** Mở rộng Module 3 (SKU Mapping) để cho phép ánh xạ 1 Mã sàn (Channel\_SKU) với một danh sách các Mã nội bộ (Master\_SKU) kèm theo hệ số số lượng. Khi đơn hàng đổ về, hệ thống tự động phân rã Combo thành các mặt hàng vật lý để tạo phiếu xuất kho chính xác.

### **2.3. Rủi Ro Đồng Bộ Và Ảo Tưởng Về Quản Trị Tồn Kho Khả Dụng (ATP)**

Đây là lỗ hổng mang tính hệ thống nguy hiểm nhất trong tài liệu hiện tại, đe dọa trực tiếp đến uy tín của cửa hàng trên các sàn TMĐT. Tài liệu quy định cơ chế khóa mềm (Soft Allocation) diễn ra khi "Sales duyệt đơn HOẶC Scheduler tự sync đơn Lazada".1 Điều này đồng nghĩa với việc, đối với các nền tảng phải nhập đơn thủ công như Shopee hay TikTok Shop, tồn kho trên hệ thống hoàn toàn không được trừ cho đến khi nhân viên rảnh tay đẩy file vào hệ thống.  
Sự ngây thơ thứ hai nằm ở nguyên lý "Sàn sẽ chặn không cho người dùng đặt sản phẩm nếu hết hàng". Về lý thuyết điều này đúng, các nền tảng thương mại điện tử như Shopee hay Lazada sẽ ẩn nút mua hàng hoặc chuyển trạng thái sản phẩm thành "Out of Stock" (OOS) nếu số lượng tồn kho đẩy lên sàn bằng 0\. Tuy nhiên, vấn đề nằm ở khoảng trống thời gian (Data Latency).13 Nếu một chiếc kính phiên bản giới hạn chỉ còn đúng 1 chiếc trong kho vật lý, và cùng lúc đó có một khách hàng trên Shopee và một khách hàng trên TikTok cùng bấm mua, cả hai giao dịch đều sẽ thành công trên sàn do hệ thống nội bộ chưa kịp đẩy thông báo "số lượng \= 0" lên các nền tảng qua API.13  
Tài liệu cũng đề cập đến cấu hình Tồn kho đệm (Buffer Stock) ở Module 4 nhưng lại thừa nhận đây là một "trường chết" chưa được dùng trong tính toán.1 Khi tồn kho thực tế bị sai lệch so với tồn kho khả dụng (ATP), và không có tồn kho đệm bảo vệ, hệ thống sẽ rơi vào vòng xoáy Overselling (Bán vượt mức tồn kho).15 Doanh nghiệp sẽ buộc phải hủy hàng loạt đơn hàng, dẫn đến hình phạt khóa gian hàng từ nền tảng.  
**Chiến Lược Phòng Thủ (Defense Strategy):**

* **Cập Nhật Tồn Kho Theo Thời Gian Thực (Real-time Inventory Push):** Hủy bỏ hoàn toàn việc import thủ công. Tất cả các kênh phải sử dụng cơ chế Webhook và Real-time API để ghi nhận luồng đơn hàng ngay trong đơn vị tính bằng mili-giây.6 Ngay khi đơn hàng được đặt trên bất kỳ sàn nào, luồng Soft-Allocation phải được thực thi ở tầng cơ sở dữ liệu (Database Layer), ngay lập tức kích hoạt trigger tính toán lại qty\_available và đẩy số liệu tồn kho mới lên toàn bộ các nền tảng còn lại qua các API đồng bộ tồn kho.  
* **Kích Hoạt Thuật Toán Buffer Stock Chống Trễ:** Buffer Stock không thể là một biến số vô giá trị. Thuật toán đẩy tồn kho lên sàn phải được sửa đổi thành: Tồn kho đẩy lên sàn \= qty\_on\_hand \- holding \- buffer\_stock. Tồn kho đệm (ví dụ: 5 đơn vị) sẽ đóng vai trò như một bộ đệm giảm xóc. Khi lượng ATP trên hệ thống WMS giảm xuống bằng hoặc nhỏ hơn 5, hệ thống sẽ tự động push giá trị 0 lên các sàn TMĐT.7 Điều này đảm bảo sàn sẽ tự động "chặn" người dùng đặt mua trước khi doanh nghiệp thực sự cạn kiệt những sản phẩm cuối cùng do độ trễ mạng gây ra.

## **3\. Thử Lửa Hệ Thống Bằng Các Kịch Bản Ngoại Lệ (Edge Cases Testing)**

Sự ưu việt của một hệ thống quản trị đơn hàng đa kênh không được đo lường qua những "luồng đi lý tưởng" (happy paths), mà qua sức chịu đựng của nó trước những điểm đứt gãy của chuỗi cung ứng kỹ thuật số.

### **3.1. Kịch Bản 1: Unmapped SKU (Mã Sàn Không Tồn Tại Trong Hệ Thống)**

**Bối Cảnh Vận Hành:** Ngành phụ kiện thời trang đòi hỏi sự linh hoạt tuyệt đối trong các chiến dịch tiếp thị. Đội ngũ Marketing có thể tự ý tạo một bộ sưu tập cà vạt mới trực tiếp trên Seller Center của Lazada lúc 23:45 cho sự kiện Flash Sale lúc 0:00, tạo ra một Channel\_SKU hoàn toàn mới nhưng quên báo cho đội ngũ Vận hành (Operations) để thực hiện ánh xạ trong Module 3\.1 Khi đơn hàng đổ về qua API từ Lazada, hệ thống WMS nội bộ gặp phải một mã sản phẩm xa lạ.  
**Phân Tích Lỗ Hổng:** Dựa trên luồng thiết kế của Module 5 (Đồng bộ Tự động Lazada) 1, hệ thống sẽ nỗ lực tìm kiếm Master\_SKU tương ứng để thực hiện trừ tồn kho mềm (Soft-allocate). Khi truy vấn cơ sở dữ liệu trả về kết quả NULL, luồng tiến trình (scheduler thread) có nguy cơ gặp lỗi ngoại lệ (Fatal Exception), làm sập tiến trình đồng bộ của toàn bộ các đơn hàng Lazada khác trong chu kỳ 5 phút đó. Tệ hơn nữa, hệ thống có thể lặng lẽ bỏ qua đơn hàng này, khiến khách hàng đặt mua thành công trên Lazada nhưng kho nội bộ hoàn toàn "mù" thông tin, dẫn đến trễ hạn giao hàng.  
**Chiến Lược Phòng Thủ (Defense Strategy):** Hệ thống phải triển khai một cơ chế Vùng Cách Ly (Quarantine Zone). Khi luồng đồng bộ đơn hàng bắt gặp một Channel\_SKU chưa được ánh xạ, hệ thống không được phép từ chối đơn hàng hay làm sập tiến trình. Thay vào đó, đơn hàng này phải được lưu vào một bảng cách ly trong cơ sở dữ liệu và chuyển sang một trạng thái đặc biệt: PENDING\_MAPPING.  
Trên Dashboard của Sales Staff, một cảnh báo cờ đỏ (Red Flag Alert) sẽ lập tức nhấp nháy, yêu cầu sự can thiệp khẩn cấp. Giao diện xử lý ngoại lệ sẽ hiển thị chi tiết mã lạ này, cho phép Sales Staff thực hiện gán ghép (map) nhanh Channel\_SKU kia vào một Master\_SKU hiện có trong kho, hoặc tự động tạo ra một Master\_SKU mới nếu đây là sản phẩm chưa từng tồn tại. Ngay khi ánh xạ được lưu thành công, hệ thống tự động kích hoạt lại trigger để cấp phát tồn kho mềm và đẩy đơn hàng trở lại luồng xử lý tự động (Auto-routing) bình thường mà không cần Sales Staff phải quay lại tab duyệt đơn.

### **3.2. Kịch Bản 2: Race Condition (Xung Đột Thời Gian Khách Hủy Và Sales Duyệt)**

**Bối Cảnh Vận Hành:** Race Condition là một khái niệm kinh điển trong thiết kế hệ thống phân tán. Khách hàng bấm nút "Hủy đơn" trên Lazada ĐÚNG VÀO LÚC Sales Staff đang thao tác trên giao diện Dashboard, vừa bấm nút Duyệt và hệ thống đang xử lý chuyển đổi trạng thái sang chờ in tem (PICKING).  
**Phân Tích Lỗ Hổng:** Theo thiết kế ở Module 2 1, Sales Staff thực hiện hành động dựa trên giao diện UI tải dữ liệu tĩnh của quá khứ. Khi Sales Staff bấm duyệt, lệnh POST /sales/order-action cập nhật trạng thái cơ sở dữ liệu thành PICKING. Tuy nhiên, chỉ vài mili-giây trước đó, một Webhook từ Lazada đã được đẩy về hệ thống mang theo tín hiệu Hủy đơn từ người mua (Buyer Cancellation). Nếu cơ sở dữ liệu không được thiết kế chặt chẽ với cơ chế kiểm soát tương tranh (Concurrency Control), đơn hàng sẽ rơi vào trạng thái mâu thuẫn lượng tử: Trong hệ thống nội bộ, nó vừa tạo phiếu xuất kho để nhân viên nhặt hàng; nhưng trên nền tảng thương mại điện tử, nó đã bị hủy và tiền đã được hoàn lại cho khách hàng. Hậu quả là kho vẫn đóng gói và giao hàng cho đơn vị vận chuyển, khiến doanh nghiệp mất trắng cả hàng hóa lẫn chi phí vận chuyển.  
**Chiến Lược Phòng Thủ (Defense Strategy):** Hệ thống phải triển khai hai lớp bảo mật dữ liệu nghiêm ngặt:

1. **Kiểm Tra Chéo Trước Khi Cam Kết (Pre-flight Status Check):** Trước khi hàm action=approve thực thi câu lệnh SQL UPDATE trạng thái đơn hàng và tạo phiếu xuất, hệ thống bắt buộc phải thực hiện một lệnh gọi API chớp nhoáng đến nền tảng (ví dụ: endpoint v2.order.get\_order\_detail của Shopee 16 hoặc GetOrder của TikTok 17) để xác minh trạng thái thời gian thực (real-time status) của đơn hàng đó trên sàn là gì.  
2. **Khóa Lạc Quan Cơ Sở Dữ Liệu (Optimistic Locking):** Ứng dụng kỹ thuật Optimistic Locking tại tầng Data Access Object (DAO) bằng cách sử dụng trường version hoặc cột updated\_at. Nếu Webhook báo hủy đã ghi đè trạng thái của đơn hàng trong cơ sở dữ liệu trước lệnh duyệt của Sales Staff dù chỉ 1 mili-giây, lệnh duyệt sẽ bị từ chối tự động với thông báo lỗi: "Thao tác thất bại: Trạng thái đơn hàng đã bị thay đổi bởi nền tảng hoặc khách hàng". Đồng thời, hệ thống tự động hoàn tác (rollback) mọi lượng tồn kho đã được cấp phát mềm (holding) để trả lại vào rổ khả dụng.

### **3.3. Kịch Bản 3: Out of Stock Đột Ngột Và Hủy Ngược (Reverse Cancellation)**

**Bối Cảnh Vận Hành:** Sales Staff (hoặc hệ thống tự động) đã xác nhận đơn hàng thành công, trừ tồn kho mềm, và trạng thái nội bộ đã chuyển sang PICKING. Tuy nhiên, khi nhân viên kho (Warehouse Staff) mang thiết bị PDA đi vào các kệ hàng vật lý để lấy hàng (pick), họ phát hiện ra rằng chiếc kính mắt màu đồi mồi duy nhất còn lại trên kệ đã bị gãy càng (hàng lỗi hỏng vật lý \- Damaged Goods). Thực tế là không còn hàng để giao, mặc dù dữ liệu hệ thống ghi nhận là còn.  
**Phân Tích Lỗ Hổng:** Trong thiết kế hiện tại, hoàn toàn không có khái niệm "Hard Allocation \- Cấp phát cứng" được hiện thực hóa 1, và cũng không có bất kỳ luồng quy trình nào hỗ trợ việc Hủy ngược từ Kho (Reverse-Reject). Như đã đề cập trước đó, hệ thống sàn không thể chặn người dùng đặt sản phẩm này vì thời điểm họ đặt, tồn kho đẩy lên sàn vẫn lớn hơn 0\. Khi sự kiện thiếu hàng vật lý xảy ra, Warehouse Staff hoàn toàn không có công cụ báo lỗi hoặc giao tiếp ngược lại với Sales Staff trên hệ thống. Đơn hàng sẽ bị treo mãi mãi ở trạng thái PICKING, dẫn đến án phạt "Tỷ lệ giao hàng trễ" từ sàn TMĐT.  
**Chiến Lược Phòng Thủ (Defense Strategy):** Hệ thống phải trao quyền xử lý ngoại lệ vật lý cho nhân viên kho và thiết lập luồng API Hủy từ phía nhà bán (Seller-Initiated Cancellation):

* **Quy Trình Short-Pick & Cập Nhật Tồn Kho Vật Lý:** Bổ sung tính năng "Exception Pick" (Nhặt hàng ngoại lệ) trên màn hình làm việc của Warehouse Staff. Khi nhân viên kho quét mã và báo cáo hàng hỏng, hệ thống lập tức trừ trực tiếp vào trường qty\_on\_hand (tồn thực tế) của SKU đó, biến giá trị tồn kho về 0 để đồng bộ lập tức lên các sàn nhằm ngăn ngừa khách hàng khác tiếp tục mua.  
* **Kích Hoạt API Hủy Đơn / Xử Lý Bù Trừ:** Tùy thuộc vào chính sách của từng nền tảng, hệ thống WMS sẽ tự động gọi API xin hủy đơn về sàn.  
  * Với **TikTok Shop**, hệ thống sẽ sử dụng API POST /return\_refund/202309/cancellations (Cancel Order) cho phép nhà bán hủy đơn ở trạng thái AWAITING\_SHIPMENT.10  
  * Với **Shopee**, hệ thống gọi API v2.order.cancel\_order 16 kèm mã lý do OOS (Out of Stock).  
  * Trong trường hợp đơn hàng có nhiều sản phẩm, hệ thống phải tự động giải phóng lượng holding (cấp phát mềm) cho các mặt hàng khác trong cùng đơn hàng đó để chúng ngay lập tức quay trở lại rổ Tồn kho khả dụng (ATP).

## **4\. Thiết Kế Lại Luồng API Vận Chuyển Đa Sàn (Logistics API Re-Architecture)**

Một trong những sai lầm kiến trúc trầm trọng nhất của tài liệu hiện tại là việc trao quyền định đoạt luồng logistics (tạo tracking, in tem) cho Sales Staff thao tác tại môi trường văn phòng thông qua Module 2.3 và 2.4.1  
Quyền lực sinh mã vận đơn (Tracking Number) hoàn toàn thuộc về Đơn vị vận chuyển (ĐVVC) của các Sàn TMĐT. Không một hệ thống WMS nội bộ nào được phép tự áp đặt thuật toán "tự sinh mã random" 1 để ép sàn phải chấp nhận. Hơn thế nữa, quy trình vật lý đòi hỏi mã vận đơn và tem nhãn (Shipping Label) chỉ được phép sinh ra và in tại Bàn đóng gói (Pack Station) trong kho, ngay sau khi nhân viên đóng gói hoàn tất việc quyét mã vạch sản phẩm để đối chiếu (Cross-check) với đơn hàng.  
Kiến trúc tích hợp API vận chuyển phải được cấu trúc lại cho từng sàn như sau, và chuyển giao giao diện thao tác về cho Warehouse Staff:

### **4.1. Luồng Tích Hợp API Vận Chuyển Shopee**

Khi nhân viên kho quét mã vạch sản phẩm thành công tại bàn đóng gói, hệ thống WMS phải ngầm gọi chuỗi API của Shopee theo trình tự thời gian thực:

1. Gọi v2.logistics.get\_shipping\_parameter để lấy các thông số vận chuyển cần thiết (như chi nhánh drop-off, mã số nhận diện, thông tin non-integrated nếu có).8  
2. Sau khi lấy được tham số, hệ thống lập tức gọi v2.logistics.ship\_order để khởi tạo yêu cầu lấy hàng (arrange pickup/dropoff) đối với ĐVVC.16  
3. Do việc sinh mã có thể phụ thuộc vào hệ thống của bên thứ 3 (3PL), hệ thống WMS cần có cơ chế polling nhẹ nhàng gọi API v2.logistics.get\_tracking\_number cho đến khi mã số tracking thực sự được trả về.20  
4. Ngay khi nhận mã tracking, WMS truyền lệnh xuống máy in mã vạch tại bàn đóng gói để in tem dán trực tiếp lên bưu kiện. Đồng thời, trạng thái đơn hàng trên sàn sẽ tự động chuyển sang PROCESSED hoặc LOGISTICS\_REQUEST\_CREATED.16

### **4.2. Luồng Tích Hợp API Vận Chuyển Lazada**

Quy trình của Lazada tuân thủ một luồng nghiêm ngặt về việc chuẩn bị hàng hóa (Ready to Ship \- RTS):

1. Hệ thống WMS sử dụng SetStatustoPackedByMarketplace để truyền mã sản phẩm và nhà cung cấp dịch vụ vận chuyển lên sàn. Seller Center của Lazada sẽ phản hồi lại bằng mã Tracking Number.23  
2. WMS tiếp tục gọi GetDocuments để tải về định dạng file PDF chuẩn của tem vận chuyển (Airway Bill) và in ra tại máy in.23  
3. **Hành động chốt:** Sau khi kiện hàng đã được dán tem và bọc kín, nhân viên kho quét mã vạch trên tem một lần cuối cùng. WMS lập tức bắn API SetStatustoReadyToShip lên Lazada để cập nhật trạng thái đơn hàng thành RTS.23 Đây là bước bắt buộc để báo cho ĐVVC đến kho lấy hàng.

### **4.3. Luồng Tích Hợp API Vận Chuyển TikTok Shop**

TikTok Shop sở hữu cơ chế API khắt khe nhất liên quan đến chứng từ tài chính trước khi giao hàng:

1. Để lấy mã vận đơn và sắp xếp vận chuyển, WMS phải gọi API ShipPackage hoặc cập nhật thông tin qua UpdatePackageShippingInfo.12  
2. Tuy nhiên, một quy tắc nghiệp vụ ngặt nghèo của TikTok (đặc biệt trong các mô hình giao dịch xuyên biên giới hoặc mô hình quản lý hóa đơn nghiêm ngặt) là chứng từ/hóa đơn phải được tải lên trước. Nếu hệ thống WMS cố gắng gọi lệnh Ship mà chưa hoàn thành bước này, TikTok Shop sẽ ném ra mã lỗi 21004006 (Failed to ship. Please ensure an invoice is uploaded before shipping) hoặc 21004019\.5  
3. Do đó, kiến trúc hệ thống phải được nâng cấp để tự động tạo (generate) hóa đơn điện tử hoặc phiếu xuất kho nội bộ, gọi API upload chứng từ lên TikTok Shop, và sau đó mới thực thi lệnh gọi ShipPackage để nhận mã tracking về in ấn.

### **4.4. Quản Trị Hủy Đơn Từ Phía Người Mua (Buyer Cancellation Handling)**

Sự phức tạp của thương mại điện tử còn nằm ở "cửa sổ ân hạn" (Grace Period), nơi khách hàng có quyền tự ý hủy đơn. Thiết kế phải có khả năng lắng nghe và phản hồi các Webhook này một cách hoàn hảo, thay vì mù quáng in tem đóng gói:

* **TikTok Shop (Luật 1 Giờ):** Trong 1 giờ đầu tiên sau khi đặt, người mua có quyền hủy tự động. Sau 1 giờ, lệnh hủy trở thành yêu cầu chờ phê duyệt (Buyer Request Cancel).26 Webhook Order Status Change của TikTok phải được map trực tiếp để đình chỉ tạm thời (Hold) phiếu xuất kho vật lý trong hệ thống WMS.27 Nếu kho chưa đóng gói, hệ thống tự động gọi API Approve Cancellation.10  
* **Shopee (Yêu cầu Hủy):** API handle\_buyer\_cancellation 16 phải được tích hợp trên Dashboard. Khi Webhook nhận trạng thái IN CANCEL 22, hệ thống WMS lập tức khóa lệnh nhặt hàng. Nếu hàng đã nhặt xong và đang nằm ở khu vực chờ giao (PACKED), Sales Staff sẽ dựa vào dữ liệu thực tế này để quyết định từ chối yêu cầu hủy của khách, ép đơn hàng vào trạng thái giao thành công để bảo vệ chi phí vận hành.

Bảng dưới đây tóm tắt ma trận phân quyền và thiết kế lại luồng API vận chuyển:

| Nền Tảng TMĐT | API Gọi Lấy Tracking | API Chuyển Trạng Thái Giao Hàng (RTS) | Tác Nhân Kích Hoạt Thực Tế | Điều Kiện Tiên Quyết / Lỗi Phổ Biến |
| :---- | :---- | :---- | :---- | :---- |
| **Shopee** | get\_shipping\_parameter → ship\_order 16 | Tự động sau khi gọi lệnh ship\_order thành công. | Warehouse Staff (Tại Pack Station) | Phải xử lý trạng thái IN CANCEL 22 trước khi ship. |
| **Lazada** | SetStatustoPackedByMarketplace 24 | SetStatustoReadyToShip 24 | Warehouse Staff (Tại Pack Station) | Phải tải định dạng PDF tem qua GetDocuments.23 |
| **TikTok Shop** | ShipPackage / UpdatePackageShippingInfo 12 | Xác nhận khi lệnh ShipPackage thành công. | Warehouse Staff (Tại Pack Station) | Lỗi 21004006 nếu chưa tải lên chứng từ/hóa đơn.5 |

## **5\. Tái Thiết Lập Vòng Đời Đơn Hàng Và Chiến Lược Phòng Thủ (Strategic Defense)**

Dựa trên những lỗ hổng đã được bóc tách, vòng đời trạng thái đơn hàng (Order Status Lifecycle) ở Module 4 1 phải được viết lại hoàn toàn để tách bạch rõ ranh giới giữa luồng xử lý dữ liệu của Hệ thống Quản trị Đơn hàng (OMS) và luồng xử lý vật lý của Hệ thống Quản lý Kho (WMS).  
Sự thay đổi vòng đời này sẽ là vũ khí cốt lõi để bảo vệ bản thiết kế trước những câu hỏi hóc búa của hội đồng bảo vệ, chứng minh hệ thống đạt chuẩn vận hành đa kênh Enterprise:

1. **PENDING (Chờ xử lý):** Đơn hàng mới đồng bộ tự động 100% qua Webhook từ mọi sàn. Hệ thống (không phải con người) tự động kiểm tra tồn kho đệm, phân tích gian lận và đánh giá ánh xạ SKU.  
2. **PENDING\_MAPPING (Lỗi Ánh xạ \- Trạng thái mới):** Đơn hàng có chứa SKU mới chưa được nhận diện. Đây là thời điểm duy nhất Sales Staff can thiệp để nối mã.  
3. **READY\_FOR\_PICKING (Đã Duyệt Tự động \- Trạng thái mới):** OMS đã tự động thực thi Cấp phát mềm (Soft-Allocate) 1 và tự động đẩy phiếu xuất (Outbound Order) xuống WMS. Chức năng duyệt thủ công bằng tay hoàn toàn bị loại bỏ.  
4. **PICKING (Đang Lấy hàng):** Nhân viên kho nhận danh sách nhặt hàng được gom nhóm theo đường đi tối ưu (Wave Picking) trên thiết bị PDA, thay vì nhặt lẻ tẻ từng đơn.  
5. **PACKED & READY\_TO\_SHIP (Đóng gói & Chờ Giao):** Tại trạm đóng gói, mã vạch vật lý của sản phẩm được quét. WMS lập tức giao tiếp với API vận chuyển của Shopee, Lazada, TikTok để lấy Tracking Number, in tem, và phản hồi trạng thái RTS về nền tảng. Thời điểm này, lượng Cấp phát mềm (holding) được chuyển đổi thành **Cấp phát cứng (Hard Allocation)**, tức là trừ vĩnh viễn vào tồn kho thực tế (qty\_on\_hand).1  
6. **SHIPPED / DELIVERED:** Trạng thái được cập nhật thông qua việc lắng nghe Webhook từ phía Đơn vị vận chuyển.1  
7. **EXCEPTION (Xử lý Ngoại lệ \- Trạng thái mới):** Khi kho báo hết hàng đột ngột, phát hiện hàng hỏng vật lý, hoặc khi khách hàng gửi yêu cầu hủy đơn qua API. OMS sẽ cô lập các đơn này, trả quyền quyết định về giao diện Dashboard để Sales Staff thao tác hủy đơn hoặc thương lượng với người mua.

**Kết Luận Chiến Lược:** Bản tài liệu "Mô tả Chức năng Nghiệp vụ — SALES STAFF" 1 ở trạng thái hiện tại là một bản thiết kế mang tính hướng nội (inward-looking), cố gắng áp đặt các quy trình giấy tờ thủ công của thế kỷ trước lên một hệ sinh thái thương mại điện tử kết nối API theo thời gian thực. Bằng cách định nghĩa lại vai trò của Sales Staff sang quản trị ngoại lệ, chuyển giao luồng vận chuyển (Logistics) về cho bộ phận kho (Warehouse), và triển khai mạnh mẽ các cơ chế đồng bộ tự động dựa trên Rule Engine và Webhook, hệ thống "B2C Omnichannel WMS Hub" mới thực sự đủ sức mạnh để xử lý khối lượng giao dịch khổng lồ của ngành phụ kiện thời trang, đồng thời bảo vệ vững chắc biên lợi nhuận của doanh nghiệp trong kỷ nguyên bán lẻ kỹ thuật số.

#### **Nguồn trích dẫn**

1. Mô tả Chức năng Nghiệp vụ — SALES STAFF  
2. What Is Omnichannel Order Management? Full Guide \- AutoStore, truy cập vào tháng 6 15, 2026, [https://www.autostoresystem.com/insights/mastering-omnichannel-order-management-full-guide](https://www.autostoresystem.com/insights/mastering-omnichannel-order-management-full-guide)  
3. 10 Omnichannel Order Management FAQs \- Fluent Commerce, truy cập vào tháng 6 15, 2026, [https://fluentcommerce.com/resources/blog/10-omnichannel-order-management-faqs/](https://fluentcommerce.com/resources/blog/10-omnichannel-order-management-faqs/)  
4. Ecommerce Order Management: End-to-End Flow & OMS Checklist \- Virto Commerce, truy cập vào tháng 6 15, 2026, [https://virtocommerce.com/blog/what-is-order-management-system](https://virtocommerce.com/blog/what-is-order-management-system)  
5. fulfillment/202309/packages/{package\_id}/ship \- TikTok Shop Partner Center, truy cập vào tháng 6 15, 2026, [https://partner.tiktokshop.com/docv2/page/ship-package-202309](https://partner.tiktokshop.com/docv2/page/ship-package-202309)  
6. The best ecommerce APIs for growth and scalability, truy cập vào tháng 6 15, 2026, [https://www.algolia.com/blog/ecommerce/ecommerce-apis-guide-to-scaling-online-stores-in-2025](https://www.algolia.com/blog/ecommerce/ecommerce-apis-guide-to-scaling-online-stores-in-2025)  
7. Retail \- Legacy API Integration \- OpenLegacy, truy cập vào tháng 6 15, 2026, [https://www.openlegacy.com/solutions/industry/retail](https://www.openlegacy.com/solutions/industry/retail)  
8. v2.logistics.get\_shipping\_parameter \- Documentation \- Shopee Open Platform, truy cập vào tháng 6 15, 2026, [https://open.shopee.com/documents/v2/v2.logistics.get\_shipping\_parameter?module=95\&type=1](https://open.shopee.com/documents/v2/v2.logistics.get_shipping_parameter?module=95&type=1)  
9. Sales Channel Open API Overview \- OMS4, truy cập vào tháng 6 15, 2026, [https://oms.y3.sg/doc/openapi/sales-channel/overview.html](https://oms.y3.sg/doc/openapi/sales-channel/overview.html)  
10. Cancel Order \- TikTok Shop Partner Center, truy cập vào tháng 6 15, 2026, [https://partner.tiktokshop.com/docv2/page/cancel-order-202309](https://partner.tiktokshop.com/docv2/page/cancel-order-202309)  
11. Omnichannel Order Management System powered by AI \- Grid Dynamics, truy cập vào tháng 6 15, 2026, [https://www.griddynamics.com/blog/omnichannel-order-management-system](https://www.griddynamics.com/blog/omnichannel-order-management-system)  
12. tiktok package \- github.com/jianjungki/tiktok \- Go Packages, truy cập vào tháng 6 15, 2026, [https://pkg.go.dev/github.com/jianjungki/tiktok](https://pkg.go.dev/github.com/jianjungki/tiktok)  
13. Overselling Across Channels: Causes, Risks, and How to Prevent It \- EcomTalks, truy cập vào tháng 6 15, 2026, [https://ecomtalks.webflow.io/blog/overselling-across-channels](https://ecomtalks.webflow.io/blog/overselling-across-channels)  
14. Real-Time Inventory Synchronization: Why It Matters for E-commerce Operations \- Anchanto, truy cập vào tháng 6 15, 2026, [https://anchanto.com/real-time-inventory-synchronization/](https://anchanto.com/real-time-inventory-synchronization/)  
15. Stop Overselling: Inventory Buffers & Safety Stock \- Nventory.io, truy cập vào tháng 6 15, 2026, [https://nventory.io/blog/stop-overselling-technical-guide](https://nventory.io/blog/stop-overselling-technical-guide)  
16. Order Management \- Developer Guide \- Shopee Open Platform, truy cập vào tháng 6 15, 2026, [https://open.shopee.com/developer-guide/229](https://open.shopee.com/developer-guide/229)  
17. TikTok for SFCC: Order Management, truy cập vào tháng 6 15, 2026, [https://seller-us.tiktok.com/university/essay?knowledge\_id=2556841776514859](https://seller-us.tiktok.com/university/essay?knowledge_id=2556841776514859)  
18. Return, refund, and cancel API overview \- TikTok Shop Partner Center, truy cập vào tháng 6 15, 2026, [https://partner.tiktokshop.com/docv2/page/return-refund-and-cancel-api-overview](https://partner.tiktokshop.com/docv2/page/return-refund-and-cancel-api-overview)  
19. api/v2/logistics/ship\_order \- Documentation \- Shopee Open Platform, truy cập vào tháng 6 15, 2026, [https://open.shopee.com/documents/v2/v2.logistics.ship\_order?module=95\&type=1](https://open.shopee.com/documents/v2/v2.logistics.ship_order?module=95&type=1)  
20. v2.logistics.batch\_ship\_order \- Documentation \- Shopee Open Platform, truy cập vào tháng 6 15, 2026, [https://open.shopee.com/documents/v2/v2.logistics.batch\_ship\_order?module=95\&type=1](https://open.shopee.com/documents/v2/v2.logistics.batch_ship_order?module=95&type=1)  
21. api/v2/logistics/get\_tracking\_number \- Documentation \- Shopee Open Platform, truy cập vào tháng 6 15, 2026, [https://open.shopee.com/documents/v2/v2.logistics.get\_tracking\_number?module=95\&type=1](https://open.shopee.com/documents/v2/v2.logistics.get_tracking_number?module=95&type=1)  
22. Shopee Chat \- Documentations | Qiscus, truy cập vào tháng 6 15, 2026, [https://documentation.qiscus.com/app-center/shopee](https://documentation.qiscus.com/app-center/shopee)  
23. 文档中心 \- 淘宝开放平台, truy cập vào tháng 6 15, 2026, [https://open.alitrip.com/docs/doc.htm?treeId=499\&articleId=108143\&docType=1](https://open.alitrip.com/docs/doc.htm?treeId=499&articleId=108143&docType=1)  
24. Process flow \- Announcement, truy cập vào tháng 6 15, 2026, [https://lazada-sellercenter.readme.io/docs/process-flow](https://lazada-sellercenter.readme.io/docs/process-flow)  
25. 1.Normal order (local store/Marketplace Ease Mode seller) fulfillment process \- Lazada Open Platform, truy cập vào tháng 6 15, 2026, [https://open.lazada.com/apps/doc/doc?nodeId=43453\&docId=121328](https://open.lazada.com/apps/doc/doc?nodeId=43453&docId=121328)  
26. Order API overview \- TikTok Shop Partner Center, truy cập vào tháng 6 15, 2026, [https://partner.tiktokshop.com/docv2/page/650b1b4bbace3e02b76d1011](https://partner.tiktokshop.com/docv2/page/650b1b4bbace3e02b76d1011)  
27. ord-cancel-buyer \- TikTok Shop Partner Center, truy cập vào tháng 6 15, 2026, [https://partner.tiktokshop.com/openlearn/guide/usecase?parent\_id=7256668359046563585](https://partner.tiktokshop.com/openlearn/guide/usecase?parent_id=7256668359046563585)  
28. Available Shopee APIs \- Celigo Help Center, truy cập vào tháng 6 15, 2026, [https://docs.celigo.com/hc/en-us/articles/18977971017883-Available-Shopee-APIs](https://docs.celigo.com/hc/en-us/articles/18977971017883-Available-Shopee-APIs)