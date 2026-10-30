import SwiftUI

private enum CrowdfundingTheme {
    static let blue = Color(hex: "174EA6")
    static let accent = Color(hex: "0086B5")
    static let text = Color(hex: "555F6D")
}

struct CrowdfundingView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var query = ""
    @State private var groups: [CrowdfundingGroup] = []
    @State private var isLoading = false
    @State private var loadError: String?
    @State private var showCreate = false

    private var filteredGroups: [CrowdfundingGroup] {
        groups.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) || ($0.description ?? "").localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            StandingInstructionHeader(title: copy("Crowdfunding", "Financement participatif")) { dismiss() }
            HStack(spacing: 0) {
                tab(copy("Groups", "Groupes"), index: 0)
                tab(copy("Invites", "Invitations"), index: 1)
            }
            .padding(.top, 8)
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass").font(.system(size: 20))
                TextField(selectedTab == 0 ? copy("Search groups...", "Rechercher des groupes...") : copy("Search invites...", "Rechercher des invitations..."), text: $query)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()
            }
            .foregroundColor(CrowdfundingTheme.text)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "F0F0F0")))
            .shadow(color: .black.opacity(0.09), radius: 2, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            ScrollView {
                LazyVStack(spacing: 14) {
                    if isLoading {
                        ProgressView().padding(.top, 24)
                    } else if selectedTab == 0 {
                        if let loadError {
                            status(loadError, retry: true)
                        } else {
                            ForEach(filteredGroups) { group in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(group.name).font(.system(size: 17, weight: .bold)).foregroundColor(CrowdfundingTheme.blue)
                                    if let description = group.description, !description.isEmpty {
                                        Text(description).font(.system(size: 14))
                                    }
                                    HStack {
                                        if let count = group.memberCount {
                                            Label("\(count)", systemImage: "person.2")
                                        }
                                        Spacer()
                                        if let policy = group.approvalPolicy {
                                            Text(copy("Approval", "Approbation") + " \(NSDecimalNumber(decimal: policy).stringValue)%")
                                        }
                                    }
                                    .font(.system(size: 12))
                                }
                                .foregroundColor(CrowdfundingTheme.text)
                                .padding(18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "EEEEEE")))
                            }
                        }
                    } else {
                        status(copy("Invitations are not available from the current service.", "Les invitations ne sont pas disponibles avec le service actuel."), retry: false)
                    }
                }
                .padding(16)
                .padding(.bottom, 80)
            }
            .refreshable { if selectedTab == 0 { loadGroups() } }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {}, onHome: { dismiss() })
        }
        .overlay(alignment: .bottomTrailing) {
            Button { showCreate = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(CrowdfundingTheme.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 5, y: 6)
            }
            .accessibilityLabel(copy("Create New Group", "Créer un groupe"))
            .padding(.trailing, 17)
            .padding(.bottom, 90)
        }
        .background(
            NavigationLink(isActive: $showCreate) {
                CrowdfundingCreateGroupView()
            } label: { EmptyView() }
        )
        .navigationBarHidden(true)
        .tint(CrowdfundingTheme.blue)
        .preferredColorScheme(.light)
        .onAppear { loadGroups() }
    }

    private func tab(_ title: String, index: Int) -> some View {
        Button {
            selectedTab = index
            query = ""
        } label: {
            VStack(spacing: 10) {
                Text(AppStrings.buttonTitle(title))
                    .font(.system(size: 16, weight: selectedTab == index ? .bold : .regular))
                    .foregroundColor(selectedTab == index ? CrowdfundingTheme.accent : CrowdfundingTheme.text)
                Rectangle()
                    .fill(selectedTab == index ? CrowdfundingTheme.accent : .clear)
                    .frame(width: 64, height: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
    }

    private func status(_ message: String, retry: Bool) -> some View {
        VStack(spacing: 12) {
            Text(message).font(.system(size: 14)).multilineTextAlignment(.center)
            if retry {
                Button(AppStrings.buttonTitle(copy("Retry", "Réessayer")), action: loadGroups)
            }
        }
        .foregroundColor(CrowdfundingTheme.text)
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
    }

    private func loadGroups() {
        guard !isLoading else { return }
        let phone = UserDataManager.shared.getPhoneNumber()
        guard !phone.isEmpty else {
            loadError = AppStrings.numeroDeTelephoneNonDisponible
            return
        }
        isLoading = true
        loadError = nil
        APIClient.shared.listCrowdfundingGroups(phoneNumber: phone) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response): groups = response
                case .failure:
                    loadError = copy("Failed to load groups", "Impossible de charger les groupes")
                }
            }
        }
    }

    private func copy(_ english: String, _ french: String) -> String {
        localization.language == .french ? french : english
    }
}

struct CrowdfundingCreateGroupView: View {
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var policyIndex = 2.0
    @State private var showPolicyInfo = false
    @State private var showAlert = false
    @State private var message = ""
    private let policies = [10, 25, 50, 75, 100]
    private var selectedPolicy: Int { policies[Int(policyIndex.rounded())] }

    var body: some View {
        VStack(spacing: 0) {
            StandingInstructionHeader(title: "EWALLET") { dismiss() }
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 10) {
                        Text(copy("Create New Group", "Créer un groupe"))
                            .font(.system(size: 22, weight: .bold))
                        Rectangle().fill(Color.white).frame(width: 85, height: 3)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)
                    .background(CrowdfundingTheme.accent)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.16), radius: 6, y: 3)

                    card(copy("Name", "Nom")) {
                        TextField(copy("Enter Name", "Saisir le nom"), text: $name)
                            .standingField()
                            .onChange(of: name) { name = String(name.prefix(30)) }
                        counter(name.count, maximum: 30)
                    }
                    card(copy("Description", "Description")) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .onChange(of: description) { description = String(description.prefix(500)) }
                            if description.isEmpty {
                                Text(copy("Enter Description", "Saisir la description"))
                                    .padding(.horizontal, 12)
                                    .padding(.top, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .frame(height: 158)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(CrowdfundingTheme.text, lineWidth: 1.2))
                        counter(description.count, maximum: 500)
                    }
                    card(copy("Approval Policy", "Politique d’approbation"), info: true) {
                        HStack(spacing: 8) {
                            Text(copy("Selected:", "Sélection :"))
                            Text("\(selectedPolicy)%").bold().foregroundColor(CrowdfundingTheme.accent)
                        }
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                        Slider(value: $policyIndex, in: 0...4, step: 1)
                            .tint(CrowdfundingTheme.accent)
                            .padding(.horizontal, 10)
                            .accessibilityLabel(copy("Approval percentage", "Pourcentage d’approbation"))
                            .accessibilityValue("\(selectedPolicy)%")
                        HStack {
                            ForEach(Array(policies.enumerated()), id: \.offset) { index, policy in
                                if index > 0 { Spacer() }
                                Text("\(policy)%").font(.system(size: 13))
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    Button(action: createGroup) {
                        Text(copy("Create", "Créer"))
                            .font(.system(size: 18, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .frame(width: 160, height: 50)
                            .background(CrowdfundingTheme.blue)
                            .cornerRadius(9)
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
                .padding(.horizontal, 16)
                .padding(.top, 17)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {}, onHome: { dismiss() })
        }
        .navigationBarHidden(true)
        .tint(CrowdfundingTheme.blue)
        .preferredColorScheme(.light)
        .alert(copy("Approval Policy", "Politique d’approbation"), isPresented: $showPolicyInfo) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {}
        } message: {
            Text(copy("The percentage of group members required to approve a group decision.", "Le pourcentage des membres du groupe requis pour approuver une décision du groupe."))
        }
        .alert(AppStrings.information, isPresented: $showAlert) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) {}
        } message: { Text(message) }
    }

    private func card<Content: View>(_ title: String, info: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(CrowdfundingTheme.blue)
                    Rectangle().fill(CrowdfundingTheme.accent).frame(width: 64, height: 2)
                }
                Spacer()
                if info {
                    Button { showPolicyInfo = true } label: {
                        Image(systemName: "info.circle.fill").font(.system(size: 18))
                    }
                    .accessibilityLabel(copy("About approval policy", "À propos de la politique d’approbation"))
                }
            }
            content()
        }
        .font(.system(size: 15))
        .foregroundColor(CrowdfundingTheme.text)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "F3F3F3")))
        .shadow(color: .black.opacity(0.17), radius: 3, y: 4)
    }

    private func counter(_ count: Int, maximum: Int) -> some View {
        Text("\(count)/\(maximum)")
            .font(.system(size: 11))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, -8)
    }

    private func createGroup() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = copy("Enter a group name.", "Saisissez le nom du groupe.")
        } else if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = copy("Enter a group description.", "Saisissez la description du groupe.")
        } else {
            message = copy("Group creation is not available from the current service yet. Your form has been kept.", "La création de groupe n’est pas encore disponible avec le service actuel. Votre formulaire a été conservé.")
        }
        showAlert = true
    }

    private func copy(_ english: String, _ french: String) -> String {
        localization.language == .french ? french : english
    }
}
