import SwiftUI

struct OrderFoodView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    private let initiallyShowingHistory: Bool

    init(initiallyShowingHistory: Bool = false) {
        self.initiallyShowingHistory = initiallyShowingHistory
        _showingOrders = State(initialValue: initiallyShowingHistory)
        _showingClosedOrders = State(initialValue: false)
    }

    @Environment(\.dismiss) private var dismiss
    @State private var restaurants: [FoodRestaurant] = []
    @State private var selectedRestaurant: FoodRestaurant?
    @State private var restaurantProfile: FoodRestaurantProfile?
    @State private var profileLoaded = false
    @State private var isLoadingProfile = false
    @State private var menuRequestID = UUID()
    @State private var ordersRequestID = UUID()
    @State private var showAddresses = false
    @State private var showCartAddresses = false
    @State private var showRestaurantDetails = false
    @State private var showCartReview = false
    @State private var orderDetails: FoodOrder?
    @State private var orderToCancel: FoodOrder?
    @State private var showCancelConfirmation = false
    @State private var pendingNotice: String?
    @State private var isSendingComplaint = false
    @State private var cancellingOrderIDs: Set<String> = []
    @State private var complaintProductID = ""
    @State private var noticeTitle = AppStrings.orderPlaced
    @State private var items: [FoodItem] = []
    @State private var categories: [FoodCategory] = []
    @State private var selectedCategoryId: String?
    @State private var selectedAddress: FoodAddress?
    @State private var quantities: [String: Int] = [:]
    @State private var isLoading = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var notice: String?
    @State private var showingOrders = false
    @State private var showingClosedOrders = false
    @State private var orders: [FoodOrder] = []
    @State private var ordersError: String?
    @State private var complaintOrder: FoodOrder?
    @State private var complaintDescription = ""

    private let blue = Color(hex: "174EA6")
    private let canvas = Color(.systemGroupedBackground)

    private func foodCard(radius: CGFloat = 12) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay { RoundedRectangle(cornerRadius: radius).strokeBorder(blue.opacity(0.08), lineWidth: 1) }
    }
    private var cartCount: Int { quantities.values.reduce(0, +) }
    private var cartTotal: Double {
        items.reduce(0) { $0 + $1.amount * Double(quantities[$1.id, default: 0]) }
    }

    private var visibleItems: [FoodItem] {
        items.filter { selectedCategoryId == nil || $0.categoryId == selectedCategoryId }
    }
    private var minimumOrder: Double {
        restaurantProfile?.minOrderAmount ?? Double(selectedRestaurant?.minOrderAmount ?? "") ?? 0
    }
    private var canOrder: Bool {
        profileLoaded && (restaurantProfile?.isOpen ?? false) && cartCount > 0 &&
        cartTotal >= minimumOrder && selectedAddress != nil && !isLoading
    }

    var body: some View {
        ZStack {
            canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                DiamaPayHeader(
                    title: showingOrders ? AppStrings.foodHistory2 : (selectedRestaurant?.name ?? AppStrings.orderFood),
                    headerColor: blue,
                    onBackToHome: {
                        if showingOrders {
                            if initiallyShowingHistory { dismiss() }
                            else { showingOrders = false; loadInitialData() }
                        }
                        else if selectedRestaurant != nil { selectedRestaurant = nil; restaurantProfile = nil; profileLoaded = false; menuRequestID = UUID(); items = []; categories = []; quantities = [:] }
                        else { dismiss() }
                    }
                )
                if showingOrders { historyActions } else { foodActions }
                if showingOrders {
                    ordersList
                } else if restaurants.isEmpty && isLoading {
                    ProgressView(AppStrings.findingRestaurants).frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let selectedRestaurant {
                    menu(for: selectedRestaurant)
                } else {
                    restaurantList
                }
                if cartCount > 0, selectedRestaurant != nil, !showingOrders { checkoutBar }
            }
        }
        .tint(blue)
        .navigationBarHidden(true)
        .task { if showingOrders { loadOrders() } else { loadInitialData() } }
        .alert(AppStrings.orderFood2, isPresented: Binding(get: { errorMessage != nil && complaintOrder == nil && !showCartReview }, set: { if !$0 { errorMessage = nil } })) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { errorMessage = nil }
        } message: { Text(AppStrings.option(errorMessage ?? "")) }
        .alert(noticeTitle, isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button(AppStrings.buttonTitle(AppStrings.done)) { notice = nil }
        } message: { Text(AppStrings.option(notice ?? "")) }
        .sheet(isPresented: $showAddresses) { FoodDeliveryAddressesView(selectedAddress: $selectedAddress) }
        .sheet(isPresented: $showCartReview, onDismiss: presentPendingNotice) { cartReview }
        .sheet(isPresented: $showRestaurantDetails) {
            if let restaurantProfile { FoodRestaurantDetailsView(profile: restaurantProfile) }
        }
        .sheet(item: $orderDetails) { FoodOrderDetailsView(order: $0) }
        .confirmationDialog(AppStrings.value("foodCancelOrderTitle"), isPresented: $showCancelConfirmation, titleVisibility: .visible, presenting: orderToCancel) { order in
            Button(AppStrings.value("foodCancelOrderAction"), role: .destructive) { cancel(order) }
            Button(AppStrings.cancel, role: .cancel) { }
        } message: { _ in Text(AppStrings.value("foodCancelOrderMessage")) }
        .sheet(item: $complaintOrder, onDismiss: presentPendingNotice) { order in complaintForm(for: order) }
    }

    private func presentPendingNotice() {
        if let pendingNotice {
            notice = pendingNotice
            self.pendingNotice = nil
        }
    }

    private var foodActions: some View {
        HStack(spacing: 10) {
            Button {
                if showingOrders {
                    showingOrders = false
                    loadInitialData()
                } else {
                    showingOrders = true
                    showingClosedOrders = false
                    loadOrders()
                }
            } label: {
                foodActionLabel(showingOrders ? AppStrings.menu : AppStrings.myOrders, icon: showingOrders ? "fork.knife" : "bag")
            }
            Button { showAddresses = true } label: {
                foodActionLabel(AppStrings.value("foodDeliveryAddresses"), icon: "mappin.and.ellipse")
            }
            NavigationLink { FoodComplaintsView() } label: {
                foodActionLabel(AppStrings.foodComplaints, icon: "bubble.left.and.bubble.right")
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(blue)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(canvas)
    }

    private func foodActionLabel(_ title: String, icon: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon).font(.system(size: 18))
            Text(title).font(.system(size: 12, weight: .medium)).multilineTextAlignment(.center)
        }
        .foregroundStyle(blue)
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(foodCard(radius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }

    private var cartReview: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    FoodDetailsHeader(title: selectedRestaurant?.name ?? AppStrings.restaurant, subtitle: AppStrings.valueItems(String(describing: cartCount)))
                    FoodDetailsSection(title: AppStrings.value("foodOrderItems")) {
                        ForEach(items.filter { quantities[$0.id, default: 0] > 0 }) { item in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(item.name ?? AppStrings.menuItem).font(.headline)
                                    Spacer()
                                    Text(String(format: "GMD %.2f", item.amount * Double(quantities[item.id, default: 0]))).font(.subheadline.weight(.semibold)).foregroundStyle(blue)
                                }
                                HStack {
                                    Button { change(item, by: -1) } label: { Image(systemName: "minus").frame(width: 44, height: 44).background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8)) }
                                        .accessibilityLabel(AppStrings.value("foodRemoveOne", arguments: [item.name ?? AppStrings.menuItem]))
                                    Text("\(quantities[item.id, default: 0])").monospacedDigit().frame(minWidth: 32)
                                    Button { change(item, by: 1) } label: { Image(systemName: "plus").frame(width: 44, height: 44).background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8)) }
                                        .accessibilityLabel(AppStrings.value("foodAddOne", arguments: [item.name ?? AppStrings.menuItem]))
                                    Spacer()
                                }.buttonStyle(.borderless)
                            }.padding(.vertical, 5)
                            Divider()
                        }
                        if cartCount == 0 { Text(AppStrings.value("foodCartEmpty")).foregroundStyle(.secondary) }
                    }
                    FoodDetailsSection(title: AppStrings.deliverTo) {
                        if let selectedAddress { Text(selectedAddress.displayName).font(.subheadline) }
                        Button { showCartAddresses = true } label: {
                            HStack {
                                Text(AppStrings.chooseDeliveryAddress)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.font(.subheadline.weight(.semibold)).padding(14)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    FoodDetailsSection(title: AppStrings.value("foodOrderTotal")) {
                        LabeledContent(AppStrings.value("foodSubtotal"), value: String(format: "GMD %.2f", cartTotal)).font(.headline).foregroundStyle(.primary)
                        Text(AppStrings.value("foodCheckoutDeliveryNote")).font(.caption).foregroundStyle(.secondary)
                        if minimumOrder > 0 && cartTotal < minimumOrder {
                            Text(AppStrings.value("foodMinimumOrder", arguments: [String(format: "%.2f", minimumOrder)])).foregroundStyle(.orange)
                        }
                        if profileLoaded && restaurantProfile?.isOpen != true { Text(AppStrings.closed).foregroundStyle(.orange) }
                        if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                        Button(action: submitOrder) {
                            HStack {
                                Spacer()
                                if isSubmitting { ProgressView().tint(.white) }
                                Text(isSubmitting ? AppStrings.placingOrder : AppStrings.value("foodConfirmOrder")).font(.headline)
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .frame(minHeight: 54)
                            .background(blue, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .opacity(canOrder && !isSubmitting ? 1 : 0.5)
                        .disabled(!canOrder || isSubmitting)
                    }
                }.padding(20)
            }
            .background(canvas)
            .disabled(isSubmitting)
            .navigationTitle(AppStrings.value("foodReviewCart"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.value("foodContinueShopping")) { showCartReview = false }.disabled(isSubmitting)
                }
            }
            .interactiveDismissDisabled(isSubmitting)
            .sheet(isPresented: $showCartAddresses) { FoodDeliveryAddressesView(selectedAddress: $selectedAddress) }
        }
        .tint(blue)
    }

    private var restaurantList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(AppStrings.restaurantsNearYou)
                    .font(.title2.weight(.semibold))
                    .padding(.vertical, 8)
                if isLoading && restaurants.isEmpty { ProgressView().frame(maxWidth: .infinity).padding(40) }
                else if restaurants.isEmpty {
                    emptyState(AppStrings.noRestaurantsAreAvailableRightNow, icon: "storefront")
                    Button(AppStrings.refresh) { loadRestaurants() }.frame(maxWidth: .infinity)
                }
                ForEach(restaurants) { restaurant in
                    Button { select(restaurant) } label: {
                        HStack(spacing: 14) {
                            restaurantLogo(restaurant.logoUrl)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(AppStrings.buttonTitle(restaurant.name ?? AppStrings.restaurant)).font(.system(size: 16, weight: .semibold)).foregroundStyle(.primary)
                                Text([restaurant.address1, restaurant.city].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1)
                                HStack(spacing: 5) { Circle().fill(restaurant.isOpen ? blue : .orange).frame(width: 7, height: 7); Text(AppStrings.buttonTitle(restaurant.isOpen ? AppStrings.openNow : AppStrings.closed)).font(.system(size: 11, weight: .medium)).foregroundStyle(restaurant.isOpen ? blue : .orange) }
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(.tertiary)
                        }
                        .padding(14).background(foodCard(radius: 14))
                    }.buttonStyle(.plain)
                }
            }.padding(18)
        }.refreshable { loadRestaurants() }
    }

    private func menu(for restaurant: FoodRestaurant) -> some View {
        VStack(spacing: 0) {
            if isLoading && items.isEmpty { ProgressView(AppStrings.loadingMenu).frame(maxWidth: .infinity, maxHeight: .infinity) }
            else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) { Text(restaurant.name ?? AppStrings.menu).font(.system(size: 21, weight: .bold)); Text(restaurant.city ?? restaurant.address1 ?? AppStrings.menu).font(.system(size: 12)).foregroundStyle(.secondary) }
                            Spacer()
                            Text(AppStrings.valueItems(String(describing: visibleItems.count))).font(.system(size: 12, weight: .medium)).foregroundStyle(blue).padding(.horizontal, 11).padding(.vertical, 7).background(blue.opacity(0.1), in: Capsule())
                        }.padding(.vertical, 12)
                        HStack {
                            Button { showRestaurantDetails = true } label: {
                                Label(AppStrings.value("foodRestaurantDetails"), systemImage: "info.circle")
                            }.disabled(restaurantProfile == nil)
                            Spacer()
                            Button { loadItems(restaurant) } label: { Label(AppStrings.refresh, systemImage: "arrow.clockwise") }.disabled(isLoading)
                        }.font(.subheadline)
                        if isLoadingProfile { ProgressView(AppStrings.value("foodCheckingAvailability")) }
                        if !profileLoaded && !isLoading && !isLoadingProfile {
                            Text(AppStrings.value("foodProfileRetry")).font(.caption).foregroundStyle(.orange)
                        }
                        if let profile = restaurantProfile {
                            Text(profile.isOpen ? AppStrings.openNow : AppStrings.closed)
                                .font(.subheadline).foregroundStyle(profile.isOpen ? blue : .orange)
                            if let reason = profile.temporaryClosureReason, !reason.isEmpty { Text(reason).font(.caption).foregroundStyle(.secondary) }
                            if let address = profile.address, !address.displayName.isEmpty { Text(address.displayName).font(.caption).foregroundStyle(.secondary) }
                            if let contact = profile.contact, !contact.isEmpty { Text(contact).font(.caption).foregroundStyle(.secondary) }
                            if let minutes = profile.preparationTime ?? profile.defaultPreparationTimeMin, !minutes.isEmpty {
                                Text(AppStrings.value("foodPrepTime", arguments: [minutes])).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        if minimumOrder > 0 {
                            Text(AppStrings.value("foodMinimumOrder", arguments: [String(format: "%.2f", minimumOrder)]))
                                .font(.caption).foregroundStyle(cartTotal < minimumOrder ? .orange : .secondary)
                        }
                        if !categories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    categoryChip(AppStrings.all, id: nil)
                                    ForEach(categories) { category in categoryChip(category.name ?? AppStrings.menu, id: category.categoryId) }
                                }
                            }
                        }
                        if visibleItems.isEmpty { emptyState(AppStrings.thisRestaurantHasNoMenuItemsAvailable, icon: "takeoutbag.and.cup.and.straw") }
                        ForEach(visibleItems) { item in
                            HStack(spacing: 12) {
                                restaurantLogo(item.imageUrl)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.name ?? AppStrings.menuItem).font(.system(size: 15, weight: .semibold))
                                    if let description = item.description, !description.isEmpty { Text(description).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2) }
                                    if !item.isAvailable {
                                        Text(AppStrings.value("foodItemUnavailable")).font(.caption).foregroundStyle(.orange)
                                    }
                                    Text(String(format: "GMD %.2f", item.amount)).font(.system(size: 13, weight: .semibold)).foregroundStyle(blue).padding(.top, 2)
                                }
                                Spacer(minLength: 4)
                                if quantities[item.id, default: 0] == 0 {
                                    Button { change(item, by: 1) } label: { Image(systemName: "plus").font(.system(size: 14, weight: .bold)).foregroundStyle(.white).frame(width: 34, height: 34).background(blue, in: Circle()) }
                                        .disabled(!item.isAvailable || !item.hasValidPrice || !profileLoaded || restaurantProfile?.isOpen != true)
                                } else {
                                    HStack(spacing: 12) {
                                        Button { change(item, by: -1) } label: { Image(systemName: "minus").foregroundStyle(blue) }
                                        Text("\(quantities[item.id, default: 0])").font(.system(size: 14, weight: .semibold)).monospacedDigit()
                                        Button { change(item, by: 1) } label: { Image(systemName: "plus").foregroundStyle(blue) }.disabled(!item.isAvailable || !profileLoaded || restaurantProfile?.isOpen != true)
                                    }.font(.system(size: 13, weight: .bold)).padding(.horizontal, 10).padding(.vertical, 8).background(blue.opacity(0.09), in: Capsule())
                                }
                            }.padding(14).background(foodCard(radius: 14))
                        }
                    }.padding(18)
                }.refreshable { loadItems(restaurant) }
            }
        }
    }

    private var checkoutBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse").foregroundStyle(blue)
                VStack(alignment: .leading, spacing: 2) { Text(AppStrings.deliverTo).font(.system(size: 10)).foregroundStyle(.secondary); Text(selectedAddress?.displayName.isEmpty == false ? selectedAddress!.displayName : AppStrings.chooseDeliveryAddress).font(.system(size: 12, weight: .medium)).foregroundStyle(.primary).lineLimit(1) }
                Spacer()
                Button(AppStrings.value("foodChooseAddress")) { showAddresses = true }
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(blue)
            }.padding(12).background(canvas, in: RoundedRectangle(cornerRadius: 14))
            Button { errorMessage = nil; showCartReview = true } label: {
                HStack {
                    Text(AppStrings.value("foodReviewCart")).font(.system(size: 15, weight: .semibold))
                    Text("\(cartCount)")
                        .font(.system(size: 12, weight: .bold)).monospacedDigit()
                        .padding(8).background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 9))
                    Spacer()
                    if isSubmitting { ProgressView().tint(.white) }
                    else {
                        Text(String(format: "GMD %.2f", cartTotal)).font(.system(size: 15, weight: .bold)).monospacedDigit()
                        Image(systemName: "arrow.right").font(.system(size: 13, weight: .semibold))
                    }
                }.foregroundStyle(.white).padding(.horizontal, 16).frame(minHeight: 56).background(blue, in: RoundedRectangle(cornerRadius: 17))
            }.disabled(isSubmitting || isLoading || cartCount == 0)
        }.padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 12).background(canvas).overlay(alignment: .top) { Divider() }
    }

    private func restaurantLogo(_ urlString: String?) -> some View {
        let url = urlString.flatMap { value -> URL? in
            guard let url = URL(string: value.trimmingCharacters(in: .whitespacesAndNewlines)),
                  ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
                  let host = url.host, !host.isEmpty else { return nil }
            return url
        }
        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .empty, .failure: logoPlaceholder
                    @unknown default: logoPlaceholder
                    }
                }
            } else {
                logoPlaceholder
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityHidden(true)
    }
    private var logoPlaceholder: some View { Image(systemName: "takeoutbag.and.cup.and.straw.fill").font(.system(size: 24)).foregroundStyle(blue).frame(maxWidth: .infinity, maxHeight: .infinity).background(blue.opacity(0.1)) }
    private func emptyState(_ text: String, icon: String) -> some View {
        VStack(spacing: 10) { Image(systemName: icon).font(.system(size: 30)).foregroundStyle(blue.opacity(0.7)); Text(text).font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center) }.frame(maxWidth: .infinity).padding(30).background(foodCard())
    }

    private var historyActions: some View {
        HStack(spacing: 20) {
            Button { showingOrders = false; loadInitialData() } label: {
                Label(AppStrings.menu, systemImage: "fork.knife")
            }
            Spacer(minLength: 0)
            Button { showAddresses = true } label: {
                Image(systemName: "mappin.and.ellipse")
                    .accessibilityLabel(AppStrings.value("foodDeliveryAddresses"))
            }
            NavigationLink { FoodComplaintsView() } label: {
                Image(systemName: "bubble.left.and.bubble.right")
                    .accessibilityLabel(AppStrings.foodComplaints)
            }
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(blue)
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
        .frame(minHeight: 54)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var ordersList: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                orderTab(AppStrings.active, active: !showingClosedOrders) { showingClosedOrders = false; loadOrders() }
                orderTab(AppStrings.past, active: showingClosedOrders) { showingClosedOrders = true; loadOrders() }
                Spacer(minLength: 12)
                Button { loadOrders() } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .foregroundStyle(blue)
                .accessibilityLabel(AppStrings.refresh)
                .disabled(isLoading)
            }
            .padding(.horizontal, 22)
            .background(Color(.secondarySystemGroupedBackground))
            Rectangle().fill(blue.opacity(0.1)).frame(height: 1)

            if isLoading {
                ProgressView().tint(blue).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let ordersError {
                historyEmptyState(ordersError, icon: "wifi.exclamationmark")
            } else if orders.isEmpty {
                historyEmptyState(AppStrings.yourOrdersWillAppearHere, icon: "bag")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(orders) { order in historyOrderCard(order) }
                    }
                    .padding(20)
                    .padding(.bottom, 12)
                }
                .refreshable { loadOrders() }
            }
        }
        .background(Color(hex: "F3F6FA"))
    }

    private func historyOrderCard(_ order: FoodOrder) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.orderValue(order.orderRef ?? order.orderId))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(hex: "152C4D"))
                        .textSelection(.enabled)
                    if let date = order.createdAt, !date.isEmpty {
                        Text(historyDate(date))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Text(AppStrings.option(order.status ?? "ORDERED"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(historyStatusColor(order.status))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(historyStatusColor(order.status).opacity(0.07), in: RoundedRectangle(cornerRadius: 6))
            }

            VStack(spacing: 10) {
                ForEach(order.items ?? []) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(item.qty ?? 0)×")
                            .font(.system(size: 13, weight: .medium).monospacedDigit())
                            .foregroundStyle(blue)
                            .frame(minWidth: 24, alignment: .leading)
                        Text(item.itemNameSnapshot ?? item.itemId)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "34465E"))
                        Spacer(minLength: 8)
                        Text(String(format: "GMD %.2f", item.lineTotal ?? 0))
                            .font(.system(size: 13).monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Rectangle().fill(blue.opacity(0.08)).frame(height: 1)
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.value("foodOrderTotal"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    if let fee = order.deliveryFee {
                        Text(AppStrings.value("foodDeliveryFee", arguments: [String(format: "%.2f", fee)]))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                Text(String(format: "GMD %.2f", order.totalAmount ?? 0))
                    .font(.system(size: 20, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color(hex: "152C4D"))
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { historyOrderActions(order) }
                VStack(alignment: .leading, spacing: 10) { historyOrderActions(order) }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(blue.opacity(0.09), lineWidth: 1) }
    }

    @ViewBuilder
    private func historyOrderActions(_ order: FoodOrder) -> some View {
        Button { orderDetails = order } label: {
            HStack(spacing: 8) {
                Text(AppStrings.buttonTitle(AppStrings.details))
                Image(systemName: "arrow.up.right").font(.system(size: 10, weight: .semibold))
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(minHeight: 40)
            .background(blue, in: RoundedRectangle(cornerRadius: 8))
        }
        Button(AppStrings.getHelp) {
            complaintDescription = ""; complaintProductID = ""; errorMessage = nil; complaintOrder = order
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(blue)
        .frame(minHeight: 40)
        if !showingClosedOrders && ["CREATED", "CONFIRMED"].contains(order.status?.uppercased() ?? "") {
            Button(AppStrings.cancel, role: .destructive) { orderToCancel = order; showCancelConfirmation = true }
                .font(.system(size: 13, weight: .medium))
                .frame(minHeight: 40)
                .disabled(cancellingOrderIDs.contains(order.orderId))
        }
    }

    private func historyStatusColor(_ status: String?) -> Color {
        switch status?.uppercased() {
        case "CANCELLED", "CANCELED", "REJECTED", "FAILED": return Color(hex: "835252")
        case "DELIVERED", "COMPLETED": return Color(hex: "456078")
        default: return blue
        }
    }

    private func historyDate(_ value: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = iso.date(from: value)
        if date == nil {
            iso.formatOptions = [.withInternetDateTime]
            date = iso.date(from: value)
        }
        if date == nil {
            let server = DateFormatter()
            server.locale = Locale(identifier: "en_US_POSIX")
            server.dateFormat = "yyyy-MM-dd HH:mm:ss"
            date = server.date(from: value)
        }
        guard let date else { return value }
        let display = DateFormatter()
        display.locale = Locale(identifier: localization.language.rawValue)
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }

    private func historyEmptyState(_ message: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(blue)
                .frame(width: 64, height: 64)
                .background(blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(AppStrings.refresh) { loadOrders() }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(blue)
                .padding(.horizontal, 20)
                .frame(minHeight: 44)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func orderTab(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 15, weight: active ? .semibold : .medium))
                    .foregroundStyle(active ? blue : Color.secondary)
                    .padding(.top, 14)
                Rectangle().fill(active ? blue : .clear).frame(height: 3)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private func categoryChip(_ title: String, id: String?) -> some View {
        Button { selectedCategoryId = id } label: {
            Text(AppStrings.buttonTitle(title)).font(.system(size: 12, weight: .semibold)).foregroundStyle(selectedCategoryId == id ? .white : blue).padding(.horizontal, 14).padding(.vertical, 8).background(selectedCategoryId == id ? blue : blue.opacity(0.1), in: Capsule())
        }.buttonStyle(.plain)
    }

    private func complaintForm(for order: FoodOrder) -> some View {
        FoodComplaintFormLayout(
            title: AppStrings.newComplaint,
            submitTitle: AppStrings.send,
            isSubmitting: isSendingComplaint,
            canSubmit: !complaintDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            onCancel: { complaintOrder = nil },
            onSubmit: { sendComplaint(for: order) }
        ) {
            FoodComplaintFormSection(title: AppStrings.order) {
                Text(AppStrings.orderValue(order.orderRef ?? order.orderId))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "152C4D"))
                if let status = order.status {
                    Text(AppStrings.option(status)).font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
            FoodComplaintFormSection(title: AppStrings.whatWentWrong) {
                Picker(AppStrings.value("foodComplaintItem"), selection: $complaintProductID) {
                    Text(AppStrings.value("foodWholeOrder")).tag("")
                    ForEach(order.items ?? []) { item in Text(item.itemNameSnapshot ?? item.itemId).tag(item.itemId) }
                }
            }
            FoodComplaintFormSection(title: AppStrings.describeTheIssue) {
                TextField(AppStrings.tellUsWhatHappened, text: $complaintDescription, axis: .vertical)
                    .lineLimit(5...9)
                    .font(.system(size: 15))
                    .lineSpacing(5)
            }
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle")
                    .font(.system(size: 13)).foregroundStyle(.red)
            }
        }
    }

    private func loadInitialData() {
        // Delivery addresses load in their own screen, when the customer needs them.
        loadRestaurants()
    }

    private func loadRestaurants() {
        isLoading = true
        APIClient.shared.listFoodRestaurants(request: makeListingRequest()) { result in
            Task { @MainActor in
                if !showingOrders { isLoading = false }
                switch result {
                case .success(let response) where response.respCode == "000": restaurants = response.result ?? []
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotLoadRestaurants
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func select(_ restaurant: FoodRestaurant) {
        selectedRestaurant = restaurant
        restaurantProfile = nil
        profileLoaded = false
        selectedCategoryId = nil
        quantities = [:]
        items = []
        categories = []
        loadItems(restaurant)
    }

    private func loadItems(_ restaurant: FoodRestaurant) {
        isLoading = true
        profileLoaded = false
        isLoadingProfile = true
        let requestID = UUID()
        menuRequestID = requestID
        let base = makeListingRequest()
        let request = FoodyRestaurantRequest(phoneNumber: base.phoneNumber, restaurantId: restaurant.restaurantId, requestId: base.requestId, requestDate: base.requestDate, entityId: base.entityId)
        APIClient.shared.getFoodRestaurantProfile(request: request) { result in
            Task { @MainActor in
                guard menuRequestID == requestID, selectedRestaurant?.id == restaurant.id else { return }
                isLoadingProfile = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    restaurantProfile = response.result
                    profileLoaded = response.result != nil
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotLoadRestaurants
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
        // Each independent request has its own reference, including concurrent menu/profile loads.
        let menuBase = makeListingRequest()
        let menuRequest = FoodyRestaurantRequest(phoneNumber: menuBase.phoneNumber, restaurantId: restaurant.restaurantId, requestId: menuBase.requestId, requestDate: menuBase.requestDate, entityId: menuBase.entityId)
        APIClient.shared.listFoodMenu(request: menuRequest) { result in
            Task { @MainActor in
                guard menuRequestID == requestID, selectedRestaurant?.id == restaurant.id else { return }
                if !showingOrders { isLoading = false }
                switch result {
                case .success(let response) where response.respCode == "000":
                    categories = (response.result ?? []).sorted { (Int($0.displayOrder ?? "") ?? 0) < (Int($1.displayOrder ?? "") ?? 0) }
                    var seen: Set<String> = []
                    items = categories.flatMap { $0.items ?? [] }.filter { seen.insert($0.id).inserted }
                        .sorted { (Int($0.displayOrder ?? "") ?? 0) < (Int($1.displayOrder ?? "") ?? 0) }
                    quantities = quantities.filter { id, _ in items.contains { $0.id == id && $0.isAvailable && $0.hasValidPrice } }
                    if let selectedCategoryId, !categories.contains(where: { $0.id == selectedCategoryId }) { self.selectedCategoryId = nil }
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotLoadTheMenu
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadOrders() {
        isLoading = true
        orders = []
        ordersError = nil
        let request = makeListingRequest()
        let requestID = UUID()
        ordersRequestID = requestID
        let completion: (Result<FoodyResponse<[FoodOrder]>, Error>) -> Void = { result in
            Task { @MainActor in
                guard showingOrders, ordersRequestID == requestID else { return }
                isLoading = false
                switch result {
                case .success(let response) where response.respCode == "000": orders = response.result ?? []
                case .success(let response) where response.respCode == "009": orders = []
                case .success(let response): ordersError = response.message ?? AppStrings.value("foodOrdersLoadFailed")
                case .failure(let error): ordersError = error.localizedDescription
                }
            }
        }
        if showingClosedOrders { APIClient.shared.listClosedFoodOrders(request: request, completion: completion) }
        else { APIClient.shared.listActiveFoodOrders(request: request, completion: completion) }
    }

    private func cancel(_ order: FoodOrder) {
        guard let restaurantId = order.restaurantId, !cancellingOrderIDs.contains(order.orderId) else { return }
        cancellingOrderIDs.insert(order.orderId)
        let base = makeListingRequest()
        let request = FoodOrderActionRequest(phoneNumber: base.phoneNumber, orderId: order.orderId, restaurantId: restaurantId, requestId: base.requestId, requestDate: base.requestDate, entityId: base.entityId)
        APIClient.shared.cancelFoodOrder(request: request) { result in
            Task { @MainActor in cancellingOrderIDs.remove(order.orderId); switch result { case .success(let response) where response.respCode == "000": loadOrders(); case .success(let response): errorMessage = response.message ?? AppStrings.couldNotCancelThisOrder; case .failure(let error): errorMessage = error.localizedDescription } }
        }
    }

    private func sendComplaint(for order: FoodOrder) {
        guard let restaurantId = order.restaurantId, !isSendingComplaint, !complaintDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSendingComplaint = true
        let base = makeListingRequest()
        let request = FoodComplaintRequest(phoneNumber: base.phoneNumber, orderId: order.orderId, restaurantId: restaurantId, description: complaintDescription.trimmingCharacters(in: .whitespacesAndNewlines), reason: "CUSTOMER_SUPPORT", complaintType: "ORDER", productId: complaintProductID, bank: UserDataManager.shared.getBankCode().isEmpty ? "00100" : UserDataManager.shared.getBankCode(), requestId: base.requestId, requestDate: base.requestDate, entityId: base.entityId)
        APIClient.shared.addFoodComplaint(request: request) { result in
            Task { @MainActor in isSendingComplaint = false; switch result { case .success(let response) where response.respCode == "000": complaintOrder = nil; noticeTitle = AppStrings.complaintSubmitted; pendingNotice = response.message ?? AppStrings.yourMessageHasBeenSent; case .success(let response): errorMessage = response.message ?? AppStrings.couldNotSendYourMessage; case .failure(let error): errorMessage = error.localizedDescription } }
        }
    }

    private func change(_ item: FoodItem, by amount: Int) {
        guard amount < 0 || (profileLoaded && item.isAvailable && item.hasValidPrice && restaurantProfile?.isOpen == true) else { return }
        let next = quantities[item.id, default: 0] + amount
        if next <= 0 { quantities.removeValue(forKey: item.id) } else { quantities[item.id] = next }
    }

    private func submitOrder() {
        guard !isSubmitting, canOrder, let restaurant = selectedRestaurant, let address = selectedAddress else { return }
        isSubmitting = true
        let base = makeListingRequest()
        let lines = items.compactMap { item -> FoodOrderLineRequest? in
            let quantity = quantities[item.id, default: 0]
            guard quantity > 0,
                  let unitPrice = Decimal(string: String(item.amount), locale: Locale(identifier: "en_US_POSIX")) else { return nil }
            return FoodOrderLineRequest(itemId: item.itemId, quantity: quantity, totalPrice: unitPrice * Decimal(quantity))
        }
        guard !lines.isEmpty else { isSubmitting = false; return }
        let request = FoodOrderRequest(phoneNumber: base.phoneNumber, restaurantId: restaurant.restaurantId, deliveryAddressId: address.addressId, itemsList: lines, bank: UserDataManager.shared.getBankCode().isEmpty ? "00100" : UserDataManager.shared.getBankCode(), requestId: base.requestId, requestDate: base.requestDate, entityId: base.entityId)
        APIClient.shared.placeFoodOrder(request: request) { result in
            Task { @MainActor in
                isSubmitting = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    showCartReview = false
                    quantities = [:]
                    noticeTitle = AppStrings.orderPlaced
                    pendingNotice = response.message ?? response.result ?? AppStrings.yourOrderHasBeenReceived
                    showingOrders = true
                    showingClosedOrders = false
                    loadOrders()
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotPlaceYourOrder
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func makeListingRequest() -> FoodyListingRequest {
        let formatter = DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss")
        let date = Date()
        return FoodyListingRequest(phoneNumber: UserDataManager.shared.getPhoneNumber(), requestId: DateFormatter.with(format: "yyMMdd").string(from: date) + String(format: "%06d", Int.random(in: 0..<1_000_000)), requestDate: formatter.string(from: date), entityId: UserDataManager.shared.getPhoneNumber())
    }
}
