import SwiftUI

struct FoodDeliveryAddressesView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAddress: FoodAddress?
    @State private var addresses: [FoodAddress] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showEditor = false
    @State private var editingAddress: FoodAddress?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    FoodDetailsSection(title: AppStrings.deliveryAddress) {
                        Button {
                            editingAddress = nil
                            showEditor = true
                        } label: {
                            Label(AppStrings.addNewAddress, systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(FoodDetailsStyle.blue)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        }
                    }
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else if let errorMessage {
                        FoodDetailsSection(title: AppStrings.deliveryAddress) {
                            Text(errorMessage).foregroundStyle(.red)
                            Button(AppStrings.retry) { loadAddresses() }
                        }
                    } else if addresses.isEmpty {
                        Text(AppStrings.value("foodNoAddresses")).foregroundStyle(.secondary)
                    }
                    ForEach(addresses) { address in
                        FoodDetailsSection(title: address.label ?? AppStrings.deliveryAddress) {
                            Button {
                                selectedAddress = address
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: selectedAddress?.id == address.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(FoodDetailsStyle.blue)
                                        .font(.system(size: 24))
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(address.displayName).font(.subheadline.weight(.medium)).foregroundStyle(.primary)
                                        if address.isDefault {
                                            Text(AppStrings.value("foodDefaultAddress")).font(.caption.weight(.medium)).foregroundStyle(FoodDetailsStyle.blue).padding(.horizontal, 8).padding(.vertical, 4).background(FoodDetailsStyle.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 5))
                                        }
                                    }
                                }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                            }.buttonStyle(.plain)
                            Button {
                                editingAddress = address
                                showEditor = true
                            } label: {
                                Label(AppStrings.value("foodEditAddress"), systemImage: "pencil")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(FoodDetailsStyle.blue.opacity(selectedAddress?.id == address.id ? 0.5 : 0), lineWidth: 1.5)
                                .allowsHitTesting(false)
                        }
                    }
                }.padding(20)
            }
            .background(FoodDetailsStyle.canvas)
            .navigationTitle(AppStrings.value("foodDeliveryAddresses"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(AppStrings.done) { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { loadAddresses() } label: { Image(systemName: "arrow.clockwise") }
                        .accessibilityLabel(AppStrings.refresh).disabled(isLoading)
                }
            }
            .task { loadAddresses() }
            .refreshable { loadAddresses() }
            .sheet(isPresented: $showEditor) {
                FoodAddressEditorView(address: editingAddress, firstAddress: addresses.isEmpty) {
                    loadAddresses(preferredID: editingAddress?.id, selectNew: editingAddress == nil)
                }
            }
        }
        .tint(FoodDetailsStyle.blue)
    }

    private func loadAddresses(preferredID: String? = nil, selectNew: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        let previousIDs = Set(addresses.map(\.id))
        APIClient.shared.listFoodAddresses(request: FoodAddressEditorView.makeRequest()) { result in
            Task { @MainActor in
                isLoading = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    addresses = response.result ?? []
                    selectedAddress = addresses.first { $0.id == preferredID }
                        ?? addresses.first { selectNew && !previousIDs.contains($0.id) }
                        ?? addresses.first { $0.id == selectedAddress?.id }
                        ?? addresses.first { $0.isDefault } ?? addresses.first
                case .success(let response): errorMessage = response.message ?? AppStrings.value("foodAddressesLoadFailed")
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }
}

private struct FoodAddressEditorView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    let address: FoodAddress?
    let firstAddress: Bool
    let onSaved: () -> Void
    @State private var label = ""
    @State private var line1 = ""
    @State private var line2 = ""
    @State private var city = ""
    @State private var postalCode = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var isDefault = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var coordinatesValid: Bool {
        if latitude.isEmpty && longitude.isEmpty { return true }
        guard let lat = Double(latitude), let lon = Double(longitude) else { return false }
        return lat.isFinite && lon.isFinite && (-90...90).contains(lat) && (-180...180).contains(lon)
    }
    private var canSave: Bool {
        !line1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && coordinatesValid && !isSaving
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    FoodDetailsSection(title: AppStrings.deliveryAddress) {
                        TextField(AppStrings.labelHomeWork, text: $label)
                        TextField(AppStrings.streetAddress, text: $line1)
                        TextField(AppStrings.apartmentSuiteOptional, text: $line2)
                        TextField(AppStrings.city, text: $city)
                        TextField(AppStrings.value("foodPostalCode"), text: $postalCode)
                        Toggle(AppStrings.value("foodDefaultAddress"), isOn: $isDefault)
                    }
                    FoodDetailsSection(title: AppStrings.value("foodCoordinates")) {
                        TextField(AppStrings.value("foodLatitude"), text: $latitude).keyboardType(.numbersAndPunctuation)
                        TextField(AppStrings.value("foodLongitude"), text: $longitude).keyboardType(.numbersAndPunctuation)
                        if !coordinatesValid { Text(AppStrings.value("foodCoordinatesInvalid")).foregroundStyle(.red) }
                        Text(AppStrings.value("foodCoordinatesHelp")).font(.caption).foregroundStyle(.secondary)
                    }
                    if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                    Button(action: save) {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            Text(isSaving ? AppStrings.value("saving") : AppStrings.save).font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(FoodDetailsStyle.blue, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                }.padding(20)
                .textFieldStyle(.roundedBorder)
            }
            .background(FoodDetailsStyle.canvas)
            .disabled(isSaving)
            .navigationTitle(address == nil ? AppStrings.addNewAddress : AppStrings.value("foodEditAddress"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(AppStrings.cancel) { dismiss() }.disabled(isSaving) }
            }
            .onAppear {
                label = address?.label ?? AppStrings.home
                line1 = address?.addressLine1 ?? ""
                line2 = address?.addressLine2 ?? ""
                city = address?.city ?? ""
                postalCode = address?.postalCode ?? ""
                latitude = address?.latitude ?? ""
                longitude = address?.longitude ?? ""
                isDefault = address?.isDefault ?? firstAddress
            }
            .interactiveDismissDisabled(isSaving)
        }
        .tint(FoodDetailsStyle.blue)
    }

    private func save() {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil
        let base = Self.makeRequest()
        let completion: (Result<FoodyResponse<String>, Error>) -> Void = { result in
            Task { @MainActor in
                isSaving = false
                switch result {
                case .success(let response) where response.respCode == "000":
                    onSaved()
                    dismiss()
                case .success(let response): errorMessage = response.message ?? AppStrings.couldNotSaveThisAddress
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
        let street = line1.trimmingCharacters(in: .whitespacesAndNewlines)
        let town = city.trimmingCharacters(in: .whitespacesAndNewlines)
        if let address {
            let request = FoodUpdateAddressRequest(addressId: address.id, phoneNumber: base.phoneNumber, entityId: base.entityId, label: label, addressLine1: street, addressLine2: line2, city: town, countryCode: address.countryCode ?? "GM", postalCode: postalCode, latitude: latitude, longitude: longitude, defaultFlag: isDefault ? "Y" : "N", requestId: base.requestId, requestDate: base.requestDate)
            APIClient.shared.updateFoodAddress(request: request, completion: completion)
        } else {
            let request = FoodAddAddressRequest(phoneNumber: base.phoneNumber, label: label, addressLine1: street, addressLine2: line2, city: town, countryCode: "GM", postalCode: postalCode, latitude: latitude, longitude: longitude, defaultFlag: isDefault ? "Y" : "N", requestId: base.requestId, requestDate: base.requestDate, entityId: base.entityId)
            APIClient.shared.addFoodAddress(request: request, completion: completion)
        }
    }

    static func makeRequest() -> FoodyListingRequest {
        let now = Date()
        let phone = UserDataManager.shared.getPhoneNumber()
        return FoodyListingRequest(phoneNumber: phone, requestId: DateFormatter.with(format: "yyMMdd").string(from: now) + String(format: "%06d", Int.random(in: 0..<1_000_000)), requestDate: DateFormatter.with(format: "yyyy-MM-dd HH:mm:ss").string(from: now), entityId: phone)
    }
}
