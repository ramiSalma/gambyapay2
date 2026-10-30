import SwiftUI

struct FoodRestaurantDetailsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    let profile: FoodRestaurantProfile

      var body: some View {
          NavigationStack {
              ScrollView {
                  VStack(spacing: 18) {
                      FoodDetailsHeader(
                          title: profile.name ?? AppStrings.restaurant,
                          subtitle: profile.isOpen ? AppStrings.openNow : AppStrings.closed
                      )
                      FoodDetailsSection(title: AppStrings.value("foodRestaurantDetails")) {
                          Label(profile.isOpen ? AppStrings.openNow : AppStrings.closed, systemImage: "clock.fill")
                              .font(.subheadline.weight(.semibold))
                              .foregroundStyle(profile.isOpen ? FoodDetailsStyle.blue : .orange)
                          if let reason = profile.temporaryClosureReason, !reason.isEmpty { Text(reason).foregroundStyle(.secondary) }
                          if let address = profile.address, !address.displayName.isEmpty {
                              FoodDetailsInfo(text: address.displayName, icon: "mappin.and.ellipse")
                          }
                          if let contact = profile.contact, !contact.isEmpty {
                              if let url = URL(string: "tel:\(contact.filter { $0.isASCII && $0.isNumber })") {
                                Link(destination: url) { FoodDetailsInfo(text: contact, icon: "phone.fill") }
                            }
                          }
                           if let minutes = profile.preparationTime ?? profile.defaultPreparationTimeMin, !minutes.isEmpty {
                               FoodDetailsInfo(text: AppStrings.value("foodPrepTime", arguments: [minutes]), icon: "timer")
                           }
                           if let minimum = profile.minOrderAmount {
                               FoodDetailsInfo(text:         AppStrings.value("foodMinimumOrder", arguments: [String(format: "%.2f", minimum)]), icon: "bag.fill")
                           }
                    }
                    if let hours = profile.weeklySchedule, !hours.isEmpty {
                        FoodDetailsSection(title: AppStrings.value("foodOpeningHours")) {
                            ForEach(Array(hours.enumerated()), id: \.offset) { _, day in
                                LabeledContent(dayName(day.dayOfWeek)) {
                                    Text(day.isOpen?.uppercased() == "Y" ? "\(day.openingTime ?? "—") – \(day.closingTime ?? "—")" : AppStrings.closed)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(day.isOpen?.uppercased() == "Y" ? FoodDetailsStyle.blue : .secondary)
                                }
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    if let days = profile.specialDays, !days.isEmpty {
                        FoodDetailsSection(title: AppStrings.value("foodSpecialDays")) {
                            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(day.date ?? "—").fontWeight(.medium)
                                    Text(day.isOpen?.uppercased() == "Y" ? "\(day.openingTime ?? "—") – \(day.closingTime ?? "—")" : AppStrings.closed)
                                        .foregroundStyle(.secondary)
                                    if let reason = day.reason, !reason.isEmpty { Text(reason).font(.caption).foregroundStyle(.secondary) }
                                }
                            }
                        }
                    }
                }.padding(20)
            }
            .background(FoodDetailsStyle.canvas)
            .navigationTitle(AppStrings.value("foodRestaurantDetails"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(AppStrings.done) { dismiss() } } }
        }
        .tint(FoodDetailsStyle.blue)
    }

    private func dayName(_ code: String?) -> String {
        let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        guard let code, let index = days.firstIndex(of: code.uppercased()) else { return code ?? "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: localization.language.rawValue)
        return formatter.weekdaySymbols[index]
    }
}

struct FoodOrderDetailsView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    let order: FoodOrder

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    FoodDetailsHeader(
                        title: AppStrings.orderValue(order.orderRef ?? order.orderId),
                        subtitle: AppStrings.option(order.status ?? "—")
                    )
                    FoodDetailsSection(title: AppStrings.order) {
                        LabeledContent(AppStrings.value("foodOrderReference"), value: order.orderRef ?? order.orderId)
                        LabeledContent(AppStrings.value("foodOrderStatus"), value: AppStrings.option(order.status ?? "—"))
                        if let payment = order.paymentStatus, !payment.isEmpty {
                            LabeledContent(AppStrings.value("foodPaymentStatus"), value: AppStrings.option(payment))
                        }
                        if let date = order.createdAt, !date.isEmpty { Text(date).foregroundStyle(.secondary) }
                    }
                    FoodDetailsSection(title: AppStrings.value("foodOrderItems")) {
                        ForEach(order.items ?? []) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.itemNameSnapshot ?? item.itemId).font(.system(size: 16, weight: .semibold))
                                HStack {
                                    Text("\(item.qty ?? 0) × \(money(item.unitPrice))")
                                    Spacer()
                                    Text(money(item.lineTotal)).fontWeight(.semibold).foregroundStyle(FoodDetailsStyle.blue)
                                }.font(.subheadline).foregroundStyle(.secondary)
                            }.padding(.vertical, 5)
                        }
                    }
                    FoodDetailsSection(title: AppStrings.value("foodOrderTotal")) {
                        if let fee = order.deliveryFee {
                            LabeledContent(AppStrings.value("foodDeliveryFeeLabel"), value: money(fee))
                        }
                        LabeledContent(AppStrings.value("foodOrderTotal"), value: money(order.totalAmount))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(FoodDetailsStyle.blue)
                            .padding(.top, 6)
                    }
                }.padding(20)
            }
            .background(FoodDetailsStyle.canvas)
            .navigationTitle(AppStrings.value("foodOrderDetails"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(AppStrings.done) { dismiss() } } }
        }
        .tint(FoodDetailsStyle.blue)
    }

    private func money(_ amount: Double?) -> String {
        amount.map { String(format: "GMD %.2f", $0) } ?? "—"
    }
}

enum FoodDetailsStyle {
    static let blue = Color(hex: "174EA6")
    static let canvas = Color(.systemGroupedBackground)
}

struct FoodDetailsHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 2)
                .fill(FoodDetailsStyle.blue)
                .frame(width: 4, height: 46)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

struct FoodDetailsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FoodDetailsStyle.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(FoodDetailsStyle.blue.opacity(0.045))
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(FoodDetailsStyle.blue.opacity(0.08), lineWidth: 1)
        }
    }
}

struct FoodDetailsInfo: View {
    let text: String
    let icon: String

    var body: some View {
        Label {
            Text(text).foregroundStyle(.primary)
        } icon: {
            Image(systemName: icon).foregroundStyle(FoodDetailsStyle.blue).frame(width: 22)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
