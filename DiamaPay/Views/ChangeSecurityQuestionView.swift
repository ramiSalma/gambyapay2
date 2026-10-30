import SwiftUI

struct ChangeSecurityQuestionView: View {
    var onReturnHome: (() -> Void)? = nil
    @ObservedObject private var localization = AppLanguageStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var currentAnswer = ""
    @State private var newAnswer = ""
    @State private var confirmAnswer = ""
    @State private var pin = ""
    @State private var selectedQuestion = ""
    @State private var questions: [SecurityQuestionItem] = []
    @State private var hasCurrentQuestion: Bool?
    @State private var currentQuestion: String?
    @State private var isSaving = false
    @State private var message = ""
    @State private var showMessage = false
    private let blue = Color(hex: "174EA6")
    private let cyan = Color(hex: "087FB3")

    var body: some View {
        VStack(spacing: 0) {
            DiamaPayHeader(title: AppStrings.changeSecurityQuestion, headerColor: blue)
            ScrollView {
                VStack(spacing: 18) {
                    card(title: AppStrings.value("currentQuestion"), icon: "questionmark.circle.fill", color: blue) {
                        Text(currentQuestion ?? AppStrings.value(hasCurrentQuestion == false ? "noSecurityQuestionSet" : "currentQuestionUnavailable"))
                            .font(.system(size: 14)).foregroundColor(.black)
                            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "E8F5E9"))
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                        answerField("currentAnswer", placeholder: "enterCurrentAnswer", text: $currentAnswer)
                            .disabled(hasCurrentQuestion != true || isSaving)
                            .opacity(hasCurrentQuestion == true ? 1 : 0.5)
                    }
                    card(title: AppStrings.value("newQuestion"), icon: "pencil", color: blue) {
                        VStack(alignment: .leading, spacing: 10) {
                            fieldLabel(AppStrings.selectAQuestion)
                            Menu {
                                ForEach(questions) { question in
                                    Button(AppStrings.buttonTitle(question.question)) { selectedQuestion = question.id }
                                }
                            } label: {
                                HStack {
                                    Text(questions.first(where: { $0.id == selectedQuestion })?.question ?? AppStrings.selectAQuestion)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                }
                                .font(.system(size: 16)).foregroundColor(.black)
                                .padding(.horizontal, 18).frame(minHeight: 52)
                                .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.gray.opacity(0.4)))
                            }
                        }
                        answerField("newAnswer", placeholder: "enterNewAnswer", text: $newAnswer)
                        answerField("confirmAnswer", placeholder: "confirmNewAnswer", text: $confirmAnswer)
                    }
                    card(title: AppStrings.value("securityVerification"), icon: "lock.fill", color: .orange) {
                        answerField("enterPinToConfirm", placeholder: "pinCode", text: $pin, numeric: true)
                    }
                    Button {
                        updateQuestion()
                    } label: {
                        Text(AppStrings.buttonTitle(isSaving ? AppStrings.processing : AppStrings.value("securityUpdate")))
                            .font(.system(size: 18, weight: .semibold)).tracking(2)
                            .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 46)
                            .background(cyan).clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.16), radius: 2, y: 3)
                    }
                    .disabled(hasCurrentQuestion == nil || isSaving || questions.isEmpty)
                    .opacity(hasCurrentQuestion == nil || isSaving ? 0.5 : 1)
                    .padding(.top, 12)
                }
                .padding(16).padding(.bottom, 20)
                .disabled(isSaving)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(onSponsors: {}, onQR: {}, onLimits: {}, onSettings: {}, selectedTab: "Settings", onHome: { dismiss() })
        }
        .navigationBarHidden(true).tint(blue)
        .onAppear { loadQuestions(); loadCurrentQuestion() }
        .alert(AppStrings.changeSecurityQuestion, isPresented: $showMessage) {
            Button(AppStrings.buttonTitle(AppStrings.ok), role: .cancel) { }
        } message: { Text(message) }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title).font(.system(size: 13)).foregroundColor(.gray)
    }

    private func answerField(_ title: String, placeholder: String, text: Binding<String>, numeric: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            fieldLabel(AppStrings.value(title))
            SecurityAnswerInput(placeholder: AppStrings.value(placeholder), text: text, numeric: numeric)
        }
    }

    private func card<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.system(size: 23, weight: .semibold)).foregroundColor(color)
                Text(title).font(.system(size: 18, weight: .bold))
                    .foregroundColor(color == .orange ? .orange : .black)
            }
            content()
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white).clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 2, y: 2)
    }

    private func loadCurrentQuestion() {
        hasCurrentQuestion = nil
        let user = UserDataManager.shared
        let bank = user.getBankCode()
        let request = WalletProfileRequest(walletNumber: user.getWalletNumber(),
                                           phoneNumber: user.getPhoneNumber(), source: "W",
                                           bank: bank.isEmpty ? "00100" : bank)
        APIClient.shared.getWalletProfile(request: request) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result, response.respCode == "000",
                   let profile = response.result {
                    let questionText = profile.securityQuestion?.question?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let questionID = profile.securityQuestion?.actualId?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    // Older profile responses omit hasSecurityQuestion. Resolve that
                    // successful response from its question metadata instead of staying loading.
                    let hasQuestion = profile.hasSecurityQuestion
                        ?? (!(questionText ?? "").isEmpty || !(questionID ?? "").isEmpty)
                    hasCurrentQuestion = hasQuestion
                    currentQuestion = hasQuestion ? questionText : nil
                    if !hasQuestion { currentAnswer = "" }
                } else {
                    message = AppStrings.value("currentQuestionLoadFailed")
                    showMessage = true
                }
            }
        }
    }

    private func updateQuestion() {
        guard let hasQuestion = hasCurrentQuestion, !isSaving else { return }
        // A wallet without a question does not need a current answer.
        if hasQuestion && currentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = AppStrings.value("enterCurrentAnswer")
            showMessage = true
            return
        }
        guard !selectedQuestion.isEmpty, !newAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              pin.isValidWalletPIN else {
            message = AppStrings.value("securityCompleteFields")
            showMessage = true
            return
        }
        guard newAnswer == confirmAnswer else {
            message = AppStrings.value("securityAnswersMismatch")
            showMessage = true
            return
        }
        let user = UserDataManager.shared
        let bank = user.getBankCode()
        let request = SecurityQuestionUpdateRequest(walletNumber: user.getWalletNumber(),
            phoneNumber: user.getPhoneNumber(), bank: bank.isEmpty ? "00100" : bank,
            secretQ: selectedQuestion, answer: newAnswer,
            currentAnswer: hasQuestion ? currentAnswer : nil, pin: pin)
        isSaving = true
        APIClient.shared.updateSecurityQuestion(request: request) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let response) where response.isSuccessful:
                    currentQuestion = questions.first(where: { $0.id == selectedQuestion })?.question
                    hasCurrentQuestion = true
                    currentAnswer = ""
                    newAnswer = ""
                    confirmAnswer = ""
                    pin = ""
                    if let onReturnHome { onReturnHome() } else { dismiss() }
                    return
                case .success(let response):
                    message = response.message ?? AppStrings.value("securityUpdateFailed")
                case .failure:
                    message = AppStrings.value("securityUpdateFailed")
                }
                showMessage = true
            }
        }
    }

    private func loadQuestions() {
        APIClient.shared.listSecurityQuestions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.isSuccessful else {
                        message = response.message ?? AppStrings.value("securityQuestionsLoadFailed")
                        showMessage = true
                        return
                    }
                    questions = (response.result ?? []).compactMap { item in
                        guard let item = item as? [String: Any],
                              let id = item["id"] as? String ?? item["questionId"] as? String, !id.isEmpty,
                              let question = item["wording"] as? String ?? item["question"] as? String,
                              !question.isEmpty else { return nil }
                        return SecurityQuestionItem(id: id, question: question, questionCode: item["questionCode"] as? String)
                    }
                    if questions.isEmpty {
                        message = AppStrings.value("securityQuestionsLoadFailed")
                        showMessage = true
                    }
                case .failure:
                    message = AppStrings.value("securityQuestionsLoadFailed")
                    showMessage = true
                }
            }
        }
    }
}

private struct SecurityAnswerInput: View {
    let placeholder: String
    @Binding var text: String
    var numeric = false
    @State private var visible = false

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if numeric { WalletPINField(placeholder, text: $text, isSecure: !visible) }
                else if visible { TextField(placeholder, text: $text) }
                else { SecureField(placeholder, text: $text) }
            }
            .keyboardType(numeric ? .numberPad : .default)
            .textInputAutocapitalization(.never).autocorrectionDisabled()
            .font(.system(size: 15)).foregroundColor(.black)
            Button { visible.toggle() } label: {
                Image(systemName: visible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 20)).foregroundColor(.gray)
            }
            .accessibilityLabel(visible ? "Hide answer" : "Show answer")
        }
        .padding(.horizontal, 16).frame(height: 55)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.75), lineWidth: 1))
        .onChange(of: text) {
            if numeric { text = String(text.filter { $0.isASCII && $0.isNumber }.prefix(4)) }
        }
    }
}
