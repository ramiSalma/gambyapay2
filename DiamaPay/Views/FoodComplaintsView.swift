import SwiftUI

struct FoodComplaintsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var complaints: [FoodComplaintRecord] = []
    @State private var orders: [FoodOrder] = []
    @State private var selectedOrder: FoodOrder?
    @State private var selectedType = AppStrings.original("foodQuality")
    @State private var description = ""
    @State private var selectedProductID = ""
    @State private var orderDetails: FoodOrder?
    @State private var isLoadingOrders = false
    @State private var ordersLoadError: String?
    @State private var isLoading = true
    @State private var isSubmitting = false
    @State private var showForm = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var pendingSuccessMessage: String?

    private let blue = Color(hex: "174EA6")
    private let complaintTypes = [AppStrings.original("foodQuality"), AppStrings.original("missingItem"), AppStrings.original("lateDelivery"), AppStrings.original("incorrectOrder"), AppStrings.original("restaurantService"), AppStrings.original("other")]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                DiamaPayHeader(title: AppStrings.foodComplaints, headerColor: blue)
                HStack {
                    NavigationLink { OrderFoodView(initiallyShowingHistory: true) } label: {
                        Label(AppStrings.myOrders, systemImage: "bag")
                    }
                    Spacer()
                    Button { loadData() } label: { Label(AppStrings.refresh, systemImage: "arrow.clockwise") }
                        .disabled(isLoading || isLoadingOrders)
                }.font(.subheadline).padding(16)
                if isLoading {
                    Spacer()
                    ProgressView().tint(blue)
                    Text(AppStrings.loadingComplaints).font(.system(size: 14)).foregroundStyle(.secondary).padding(.top, 10)
                    Spacer()
                } else if complaints.isEmpty {
                    ScrollView {
                        VStack(spacing: 14) {
                            emptyState
                            fileComplaintEntry
                        }.padding(20)
                    }.refreshable { loadData() }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            fileComplaintEntry
                            ForEach(complaints) { record in complaintCard(record) }
                        }.padding(18)
                    }.refreshable { loadData() }
                }
            }
        }
        .navigationBarHidden(true)
        .task { loadData() }
        .sheet(isPresented: $showForm, onDismiss: {
            successMessage = pendingSuccessMessage
            pendingSuccessMessage = nil
        }) { complaintForm }
        .sheet(item: $orderDetails) { FoodOrderDetailsView(order: $0) }
        .alert(AppStrings.foodComplaints2, isPresented: Binding(get: { errorMessage != nil && !showForm }, set: { if !$0 { errorMessage = nil } })) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { errorMessage = nil }
        } message: { Text(AppStrings.option(errorMessage ?? "")) }
        .alert(AppStrings.complaintSubmitted, isPresented: Binding(get: { successMessage != nil }, set: { if !$0 { successMessage = nil } })) {
            Button(AppStrings.buttonTitle(AppStrings.done)) { successMessage = nil }
        } message: { Text(AppStrings.option(successMessage ?? "")) }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.exclamationmark.bubble.right").font(.system(size: 34)).foregroundStyle(blue)
            Text(AppStrings.noFoodComplaintsYet).font(.system(size: 18, weight: .semibold))
            Text(AppStrings.ifSomethingWentWrongWithAFoodOrderTellUs).font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(28).background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var fileComplaintEntry: some View {
        VStack(spacing: 8) {
            Button { selectedProductID = ""; errorMessage = nil; showForm = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 20))
                    Text(AppStrings.buttonTitle(AppStrings.fileAFoodServiceComplaint)).font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white).padding(16).background(blue, in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain).disabled(orders.isEmpty || isLoadingOrders)
            if isLoadingOrders {
                ProgressView().frame(maxWidth: .infinity)
            } else if let ordersLoadError {
                Text(ordersLoadError).font(.caption).foregroundStyle(.red)
                Button(AppStrings.retry) { loadData() }
            } else if orders.isEmpty {
                Text(AppStrings.placeAFoodOrderFirstToFileAComplaintAbout).font(.system(size: 12)).foregroundStyle(.secondary)
                NavigationLink(AppStrings.orderFood) { OrderFoodView() }
            }
        }
    }

    private func complaintCard(_ record: FoodComplaintRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(record.complaint?.complaintType ?? AppStrings.foodService).font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(AppStrings.option(record.complaint?.status ?? "SUBMITTED"))
                    .font(.system(size: 10, weight: .bold)).foregroundStyle(blue).padding(.horizontal, 9).padding(.vertical, 6).background(blue.opacity(0.1), in: Capsule())
            }
            if let orderRef = record.order?.orderRef ?? record.complaint?.orderId {
                Label(AppStrings.orderValue(String(describing: orderRef)), systemImage: "bag").font(.system(size: 12)).foregroundStyle(.secondary)
            }
            if let text = record.complaint?.description, !text.isEmpty { Text(text).font(.system(size: 14)).foregroundStyle(.primary) }
            ForEach([record.complaint?.merchantResponse, record.complaint?.supportResponse].compactMap { $0 }.filter { !$0.isEmpty }, id: \.self) { response in
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.response).font(.system(size: 11, weight: .semibold)).foregroundStyle(blue)
                    Text(response).font(.system(size: 13)).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(11).background(blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 11))
            }
            if let order = record.order {
                Button(AppStrings.value("foodOrderDetails")) { orderDetails = order }.font(.subheadline)
            }
            if let createdAt = record.complaint?.createdAt, !createdAt.isEmpty { Text(createdAt).font(.system(size: 11)).foregroundStyle(.tertiary) }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading).background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 15))
    }

    private var complaintForm: some View {
        FoodComplaintFormLayout(
            title: AppStrings.newComplaint,
            submitTitle: AppStrings.submit,
            isSubmitting: isSubmitting,
            canSubmit: selectedOrder != nil && !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onCancel: { showForm = false },
            onSubmit: submitComplaint
        ) {
            FoodComplaintFormSection(title: AppStrings.order) {
                Menu {
                    ForEach(orders) { order in
                        Button(AppStrings.buttonTitle(AppStrings.valueValue2(order.orderRef ?? order.orderId, order.status ?? AppStrings.order))) {
                            selectedOrder = order; selectedProductID = ""
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(selectedOrder.map { AppStrings.orderValue($0.orderRef ?? $0.orderId) } ?? AppStrings.selectAnOrder)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(hex: "152C4D"))
                            if let status = selectedOrder?.status {
                                Text(AppStrings.option(status)).font(.system(size: 12)).foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.up.chevron.down").font(.system(size: 12, weight: .medium))
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            FoodComplaintFormSection(title: AppStrings.whatWentWrong) {
                Picker(AppStrings.value("foodComplaintItem"), selection: $selectedProductID) {
                    Text(AppStrings.value("foodWholeOrder")).tag("")
                    ForEach(selectedOrder?.items ?? []) { item in
                        Text(item.itemNameSnapshot ?? item.itemId).tag(item.itemId)
                    }
                }
                .disabled(selectedOrder == nil)
                Divider().overlay(blue.opacity(0.05))
                Picker(AppStrings.complaintType, selection: $selectedType) {
                    ForEach(complaintTypes, id: \.self) { Text(AppStrings.option($0)).tag($0) }
                }
            }
            FoodComplaintFormSection(title: AppStrings.describeTheIssue) {
                TextField(AppStrings.tellUsWhatHappened, text: $description, axis: .vertical)
                    .lineLimit(5...9)
                    .font(.system(size: 15))
                    .lineSpacing(5)
            }
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.system(size: 13)).foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func loadData() {
        guard !isLoadingOrders else { return }
        isLoadingOrders = true
        ordersLoadError = nil
        loadComplaints()
        let request = makeRequest()
        APIClient.shared.listActiveFoodOrders(request: request) { result in
            let activeOrders: [FoodOrder]
            switch result {
            case .success(let response) where response.respCode == "000": activeOrders = response.result ?? []
            case .success(let response):
                activeOrders = []
                DispatchQueue.main.async { self.ordersLoadError = response.message ?? AppStrings.value("foodOrdersLoadFailed") }
            case .failure(let error):
                activeOrders = []
                DispatchQueue.main.async { self.ordersLoadError = error.localizedDescription }
            }
            APIClient.shared.listClosedFoodOrders(request: self.makeRequest()) { closedResult in
                let closedOrders: [FoodOrder]
                switch closedResult {
                case .success(let response) where response.respCode == "000": closedOrders = response.result ?? []
                case .success(let response):
                    closedOrders = []
                    DispatchQueue.main.async { self.ordersLoadError = response.message ?? AppStrings.value("foodOrdersLoadFailed") }
                case .failure(let error):
                    closedOrders = []
                    DispatchQueue.main.async { self.ordersLoadError = error.localizedDescription }
                }
                DispatchQueue.main.async {
                    self.isLoadingOrders = false
                    let uniqueOrders = Dictionary((activeOrders + closedOrders).map { ($0.orderId, $0) }, uniquingKeysWith: { first, _ in first })
                    self.orders = Array(uniqueOrders.values).sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
                    self.selectedOrder = self.orders.first
                    self.selectedProductID = ""
                }
            }
        }
    }

    private func loadComplaints() {
        isLoading = true
        APIClient.shared.listFoodComplaints(request: makeRequest()) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    complaints = response.result ?? []
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotLoadFoodComplaints
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func submitComplaint() {
        guard !isSubmitting, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let order = selectedOrder, let restaurantId = order.restaurantId else { return }
        isSubmitting = true
        let base = makeRequest()
        let request = FoodComplaintRequest(
            phoneNumber: base.phoneNumber,
            orderId: order.orderId,
            restaurantId: restaurantId,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            reason: selectedType,
            complaintType: selectedType,
            productId: selectedProductID,
            bank: UserDataManager.shared.getBankCode().isEmpty ? "00100" : UserDataManager.shared.getBankCode(),
            requestId: base.requestId,
            requestDate: base.requestDate,
            entityId: base.entityId
        )
        APIClient.shared.addFoodComplaint(request: request) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    showForm = false
                    description = ""
                    pendingSuccessMessage = response.message ?? AppStrings.yourComplaintHasBeenSubmitted
                    loadComplaints()
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotSubmitYourComplaint
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func makeRequest() -> FoodyListingRequest {
        let now = Date()
        return FoodyListingRequest(
            phoneNumber: UserDataManager.shared.getPhoneNumber(),
            requestId: DateFormatter.with(format: "yyMMdd").string(from: now) + String(format: "%06d", Int.random(in: 0..<1_000_000)),
            requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: now),
            entityId: UserDataManager.shared.getPhoneNumber()
        )
    }
}

/// Shared presentation for new complaints and order-specific support.
struct FoodComplaintFormLayout<Content: View>: View {
    let title: String
    let submitTitle: String
    let isSubmitting: Bool
    let canSubmit: Bool
    let onCancel: () -> Void
    let onSubmit: () -> Void
    @ViewBuilder let content: Content
    private let blue = Color(hex: "174EA6")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) { content }
                    .padding(20)
                    .disabled(isSubmitting)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(hex: "F3F6FA"))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.secondarySystemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.buttonTitle(AppStrings.cancel), action: onCancel)
                        .font(.system(size: 15))
                        .disabled(isSubmitting)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: onSubmit) {
                    HStack(spacing: 10) {
                        if isSubmitting { ProgressView().tint(.white) }
                        Text(AppStrings.buttonTitle(isSubmitting ? AppStrings.sending : submitTitle))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(canSubmit && !isSubmitting ? blue : blue.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit || isSubmitting)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground))
                .overlay(alignment: .top) { Rectangle().fill(blue.opacity(0.08)).frame(height: 1) }
            }
        }
        .tint(blue)
        .interactiveDismissDisabled(isSubmitting)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct FoodComplaintFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: "34465E"))
            VStack(alignment: .leading, spacing: 14) { content }
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(Color(hex: "174EA6").opacity(0.09), lineWidth: 1) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
