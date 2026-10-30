import SwiftUI
import Combine

/// Central UI copy. Runtime values are inserted only after translation.
enum AppStrings {
    struct Entry {
        let source: String
        let language: String
        var french: String? = nil

        var hasLinguisticContent: Bool {
            let literal = source.replacingOccurrences(of: "__ARG_[0-9]+__", with: "", options: .regularExpression)
            return literal.unicodeScalars.contains { CharacterSet.letters.contains($0) }
        }
    }

    static let catalog: [String: Entry] = [
        "loginWelcome": Entry(source: "Welcome Back", language: "en", french: "Bon retour"),
        "loginSubtitle": Entry(source: "Sign in to continue", language: "en", french: "Connectez-vous pour continuer"),
        "loginSignIn": Entry(source: "Sign In", language: "en", french: "Se connecter"),
        "loginPINLabel": Entry(source: "PIN Code", language: "en", french: "Code PIN"),
        "foodLoadingRestaurants": Entry(source: "Loading restaurants", language: "en", french: "Chargement des restaurants"),
        "foodLoadingRestaurant": Entry(source: "Loading restaurant details", language: "en", french: "Chargement du restaurant"),
        "foodLoadingMenu": Entry(source: "Loading the menu", language: "en", french: "Chargement du menu"),
        "foodLoadingAddresses": Entry(source: "Loading delivery addresses", language: "en", french: "Chargement des adresses"),
        "foodSavingAddress": Entry(source: "Saving the delivery address", language: "en", french: "Enregistrement de l’adresse"),
        "foodPlacingOrder": Entry(source: "Placing your order", language: "en", french: "Envoi de la commande"),
        "foodCancellingOrder": Entry(source: "Cancelling your order", language: "en", french: "Annulation de la commande"),
        "foodLoadingOrders": Entry(source: "Loading your orders", language: "en", french: "Chargement des commandes"),
        "foodSendingComplaint": Entry(source: "Sending your complaint", language: "en", french: "Envoi de la réclamation"),
        "foodLoadingComplaints": Entry(source: "Loading complaints", language: "en", french: "Chargement des réclamations"),
        "foodOperationFailed": Entry(source: "__ARG_0__: __ARG_1__", language: "en", french: "__ARG_0__ : __ARG_1__"),
        "foodErrorReference": Entry(source: "Reference: __ARG_0__", language: "en", french: "Référence : __ARG_0__"),
        "foodCheckingAvailability": Entry(source: "Checking restaurant availability…", language: "en", french: "Vérification de la disponibilité du restaurant…"),
        "foodNoAddresses": Entry(source: "Add a delivery address to use when ordering food.", language: "en", french: "Ajoutez une adresse de livraison pour vos commandes."),
        "foodDeliveryAddresses": Entry(source: "Delivery addresses", language: "en", french: "Adresses de livraison"),
        "foodAddressesLoadFailed": Entry(source: "Could not load delivery addresses. Please try again.", language: "en", french: "Impossible de charger les adresses. Veuillez réessayer."),
        "foodPostalCode": Entry(source: "Postal code (optional)", language: "en", french: "Code postal (facultatif)"),
        "foodLatitude": Entry(source: "Latitude", language: "en", french: "Latitude"),
        "foodLongitude": Entry(source: "Longitude", language: "en", french: "Longitude"),
        "foodCoordinates": Entry(source: "Delivery coordinates (optional)", language: "en", french: "Coordonnées de livraison (facultatives)"),
        "foodCoordinatesHelp": Entry(source: "If you know the location coordinates, enter both latitude and longitude.", language: "en", french: "Si vous connaissez les coordonnées, saisissez la latitude et la longitude."),
        "foodCoordinatesInvalid": Entry(source: "Enter both coordinates: latitude from −90 to 90, longitude from −180 to 180.", language: "en", french: "Saisissez les deux coordonnées : latitude de −90 à 90, longitude de −180 à 180."),
        "foodOpeningHours": Entry(source: "Opening hours", language: "en", french: "Horaires d’ouverture"),
        "foodSpecialDays": Entry(source: "Special opening days", language: "en", french: "Horaires exceptionnels"),
        "foodRestaurantDetails": Entry(source: "Restaurant details", language: "en", french: "Détails du restaurant"),
        "foodOrderReference": Entry(source: "Reference", language: "en", french: "Référence"),
        "foodOrderStatus": Entry(source: "Order status", language: "en", french: "État de la commande"),
        "foodPaymentStatus": Entry(source: "Payment status", language: "en", french: "État du paiement"),
        "foodOrderItems": Entry(source: "Order items", language: "en", french: "Articles commandés"),
        "foodDeliveryFeeLabel": Entry(source: "Delivery fee", language: "en", french: "Frais de livraison"),
        "foodOrderTotal": Entry(source: "Order total", language: "en", french: "Total de la commande"),
        "foodOrderDetails": Entry(source: "Order details", language: "en", french: "Détails de la commande"),
        "foodCancelOrderTitle": Entry(source: "Cancel this order?", language: "en", french: "Annuler cette commande ?"),
        "foodCancelOrderAction": Entry(source: "Cancel order", language: "en", french: "Annuler la commande"),
        "foodCancelOrderMessage": Entry(source: "Confirm that you want to cancel this order.", language: "en", french: "Confirmez que vous souhaitez annuler cette commande."),
        "foodProfileRetry": Entry(source: "Restaurant availability could not be verified. Refresh the menu to try again.", language: "en", french: "Impossible de vérifier la disponibilité du restaurant. Actualisez le menu pour réessayer."),
        "foodItemUnavailable": Entry(source: "Currently unavailable", language: "en", french: "Actuellement indisponible"),
        "foodChooseAddress": Entry(source: "Choose address", language: "en", french: "Choisir une adresse"),
        "foodReviewCart": Entry(source: "Review order", language: "en", french: "Vérifier la commande"),
        "foodRemoveOne": Entry(source: "Remove one __ARG_0__", language: "en", french: "Retirer un article : __ARG_0__"),
        "foodAddOne": Entry(source: "Add one __ARG_0__", language: "en", french: "Ajouter un article : __ARG_0__"),
        "foodCartEmpty": Entry(source: "Your cart is empty. Continue shopping to add food.", language: "en", french: "Votre panier est vide. Continuez vos achats pour ajouter des articles."),
        "foodSubtotal": Entry(source: "Food subtotal", language: "en", french: "Sous-total des articles"),
        "foodCheckoutDeliveryNote": Entry(source: "This is the food subtotal. Any delivery fee will appear in your order details.", language: "en", french: "Il s’agit du sous-total des articles. Les frais de livraison éventuels figureront dans les détails de la commande."),
        "foodConfirmOrder": Entry(source: "Confirm and place order", language: "en", french: "Confirmer et commander"),
        "foodContinueShopping": Entry(source: "Continue shopping", language: "en", french: "Continuer les achats"),
        "foodOrdersLoadFailed": Entry(source: "Could not load your food orders. Please try again.", language: "en", french: "Impossible de charger vos commandes. Veuillez réessayer."),
        "foodPrepTime": Entry(source: "Preparation: __ARG_0__ min", language: "en", french: "Préparation : __ARG_0__ min"),
        "foodMinimumOrder": Entry(source: "Minimum order: GMD __ARG_0__", language: "en", french: "Commande minimum : GMD __ARG_0__"),
        "foodDeliveryFee": Entry(source: "Delivery fee: GMD __ARG_0__", language: "en", french: "Frais de livraison : GMD __ARG_0__"),
        "foodEditAddress": Entry(source: "Edit delivery address", language: "en", french: "Modifier l’adresse de livraison"),
        "foodDefaultAddress": Entry(source: "Default delivery address", language: "en", french: "Adresse de livraison par défaut"),
        "foodComplaintItem": Entry(source: "Item", language: "en", french: "Article"),
        "foodWholeOrder": Entry(source: "Whole order", language: "en", french: "Commande entière"),
        "noSecurityQuestionSet": Entry(source: "No security question is set.", language: "en", french: "Aucune question de sécurité n’est définie."),
        "currentQuestionLoadFailed": Entry(source: "Unable to load your current security question. Reopen this screen to try again.", language: "en", french: "Impossible de charger votre question actuelle. Rouvrez cet écran pour réessayer."),
        "securityQuestionUpdated": Entry(source: "Your security question has been updated.", language: "en", french: "Votre question de sécurité a été mise à jour."),
        "securityUpdateFailed": Entry(source: "Unable to update your security question. Please try again.", language: "en", french: "Impossible de modifier votre question de sécurité. Veuillez réessayer."),
        "biometryAvailable": Entry(source: "Biometry Available", language: "en", french: "Biométrie disponible"),
        "enableBiometricLogin": Entry(source: "Enable biometric login", language: "en", french: "Activer la connexion biométrique"),
        "biometricLoginDescription": Entry(source: "Once enabled, you can log in quickly using your fingerprint or facial recognition instead of entering your PIN.", language: "en", french: "Une fois activée, connectez-vous rapidement avec votre empreinte digitale ou la reconnaissance faciale au lieu de saisir votre PIN."),
        "biometricSensors": Entry(source: "Biometric authentication uses your device’s secure sensors", language: "en", french: "L’authentification biométrique utilise les capteurs sécurisés de votre appareil"),
        "biometricPrivacy": Entry(source: "Your biometric data is never transmitted to our servers", language: "en", french: "Vos données biométriques ne sont jamais transmises à nos serveurs"),
        "biometricFallback": Entry(source: "You can always use your PIN if biometry fails", language: "en", french: "Vous pouvez toujours utiliser votre PIN si la biométrie échoue"),
        "biometricSharedDevice": Entry(source: "Disable this feature if you share your device", language: "en", french: "Désactivez cette fonction si vous partagez votre appareil"),
        "currentQuestion": Entry(source: "Current question", language: "en", french: "Question actuelle"),
        "currentQuestionUnavailable": Entry(source: "Your current question is not available.", language: "en", french: "Votre question actuelle n’est pas disponible."),
        "currentAnswer": Entry(source: "Current answer", language: "en", french: "Réponse actuelle"),
        "enterCurrentAnswer": Entry(source: "Enter your current answer", language: "en", french: "Saisissez votre réponse actuelle"),
        "newQuestion": Entry(source: "New question", language: "en", french: "Nouvelle question"),
        "newAnswer": Entry(source: "New answer", language: "en", french: "Nouvelle réponse"),
        "enterNewAnswer": Entry(source: "Enter your new answer", language: "en", french: "Saisissez votre nouvelle réponse"),
        "confirmAnswer": Entry(source: "Confirm answer", language: "en", french: "Confirmez la réponse"),
        "confirmNewAnswer": Entry(source: "Confirm your new answer", language: "en", french: "Confirmez votre nouvelle réponse"),
        "securityVerification": Entry(source: "Security verification", language: "en", french: "Vérification de sécurité"),
        "enterPinToConfirm": Entry(source: "Enter your PIN code to confirm", language: "en", french: "Saisissez votre code PIN pour confirmer"),
        "securityUpdate": Entry(source: "Update", language: "en", french: "Mettre à jour"),
        "securityCompleteFields": Entry(source: "Please complete all fields and select a question.", language: "en", french: "Veuillez remplir tous les champs et sélectionner une question."),
        "securityAnswersMismatch": Entry(source: "The answers do not match.", language: "en", french: "Les réponses ne correspondent pas."),
        "securityUpdateUnavailable": Entry(source: "Updating your security question is not yet available. Please contact support.", language: "en", french: "La modification de votre question de sécurité n’est pas encore disponible. Veuillez contacter l’assistance."),
        "securityQuestionsLoadFailed": Entry(source: "Unable to load security questions. Please try again later.", language: "en", french: "Impossible de charger les questions de sécurité. Veuillez réessayer plus tard."),
        "rechargePayBills": Entry(source: "Pay your bills", language: "en", french: "Payez vos factures"),
        "rechargeBillProviders": Entry(source: "Bill providers", language: "en", french: "Fournisseurs de factures"),
        "rechargeMoreBillers": Entry(source: "More billers will be available later...", language: "en", french: "D’autres fournisseurs seront disponibles prochainement..."),
        "rechargeMeterRequired": Entry(source: "Meter number is required", language: "en", french: "Le numéro de compteur est obligatoire"),
        "rechargeAccountRequired": Entry(source: "Account/customer number is required", language: "en", french: "Le numéro de compte/client est obligatoire"),
        "rechargePay": Entry(source: "Pay", language: "en", french: "Payer"),
        "rechargeEnquire": Entry(source: "Enquire", language: "en", french: "Consulter"),
        "rechargeMeterNumber": Entry(source: "Enter meter number", language: "en", french: "Saisir le numéro de compteur"),
        "rechargeWaterAccount": Entry(source: "Enter water account/customer number", language: "en", french: "Saisir le numéro de compte/client eau"),
        "rechargeNotConnected": Entry(source: "This service is not connected yet. No payment has been made.", language: "en", french: "Ce service n’est pas encore connecté. Aucun paiement n’a été effectué."),
        "rechargeInvalidAmount": Entry(source: "Enter an amount greater than zero.", language: "en", french: "Saisissez un montant supérieur à zéro."),
        "rechargeInvalidPhone": Entry(source: "Enter a valid recipient phone number.", language: "en", french: "Saisissez un numéro de téléphone valide."),
        "rechargeChooseSaved": Entry(source: "Choose a saved number.", language: "en", french: "Choisissez un numéro enregistré."),
        "rechargeNoSaved": Entry(source: "No saved numbers yet. Enter a number to save it here.", language: "en", french: "Aucun numéro enregistré. Saisissez un numéro pour l’enregistrer ici."),
        "rechargeSaveNumber": Entry(source: "Save this number", language: "en", french: "Enregistrer ce numéro"),
        "rechargeEnterAmount": Entry(source: "Enter amount", language: "en", french: "Saisir le montant"),
        "rechargeProducts": Entry(source: "List of products", language: "en", french: "Liste des produits"),
        "rechargeContacts": Entry(source: "Contacts", language: "en", french: "Contacts"),
        "rechargeSaved": Entry(source: "Saved", language: "en", french: "Enregistrés"),
        "rechargeRecipientNumber": Entry(source: "Recipient Number", language: "en", french: "Numéro du destinataire"),
        "rechargeRecipientDetails": Entry(source: "Recipient Details", language: "en", french: "Détails du destinataire"),
        "rechargeProviderDetails": Entry(source: "Provider Details", language: "en", french: "Détails du fournisseur"),
        "deactivationCashOut": Entry(source: "Cash out", language: "en", french: "Retrait en agence"),
        "deactivationLinkedAccount": Entry(source: "Linked bank account", language: "en", french: "Compte bancaire lié"),
        "deactivationTransferHelp": Entry(source: "Choose how to receive your remaining balance", language: "en", french: "Choisissez comment recevoir votre solde restant"),
        "deactivationTransferTitle": Entry(source: "Balance Transfer Method", language: "en", french: "Méthode de transfert du solde"),
        "deactivationSelectReason": Entry(source: "Select a reason", language: "en", french: "Sélectionner une raison"),
        "deactivationReasonTitle": Entry(source: "Deactivation reason", language: "en", french: "Raison de la désactivation"),
        "deactivationIntro": Entry(source: "Close your wallet permanently and transfer your balance", language: "en", french: "Fermez définitivement votre portefeuille et transférez votre solde"),
        "language": Entry(source: "Language", language: "en", french: "Langue"),
        "welcomeBack": Entry(source: "Welcome Back to", language: "en", french: "Bienvenue sur"),
        "walletTagline": Entry(source: "Your Secure Digital Wallet", language: "en", french: "Votre portefeuille numérique sécurisé"),
        "phoneNumber": Entry(source: "Phone Number", language: "en", french: "Numéro de téléphone"),
        "pin": Entry(source: "PIN", language: "en", french: "Code PIN"),
        "loggingIn": Entry(source: "LOGGING IN...", language: "en", french: "CONNEXION..."),
        "login": Entry(source: "Login", language: "en", french: "Connexion"),
        "forgotPin": Entry(source: "Forgot PIN?", language: "en", french: "Code PIN oublié ?"),
        "noAccount": Entry(source: "No Account?", language: "en", french: "Pas de compte ?"),
        "signUp": Entry(source: "Sign Up", language: "en", french: "S’inscrire"),
        "ok": Entry(source: "OK", language: "en", french: "OK"),
        "error": Entry(source: "Error", language: "en", french: "Erreur"),
        "hello": Entry(source: "Hello,", language: "en", french: "Bonjour,"),
        "availableBalance": Entry(source: "Available Balance", language: "en", french: "Solde disponible"),
        "transactionHistory": Entry(source: "Transaction History", language: "en", french: "Historique des transactions"),
        "quickAccess": Entry(source: "QUICK ACCESS", language: "en", french: "ACCÈS RAPIDE"),
        "transferToWallet": Entry(source: "Transfer to Wallet", language: "en", french: "Transfert vers un portefeuille"),
        "walletToAccount": Entry(source: "Wallet to Account", language: "en", french: "Portefeuille vers compte"),
        "accountToWallet": Entry(source: "Account to Wallet", language: "en", french: "Compte vers portefeuille"),
        "bills": Entry(source: "Bills", language: "en", french: "Factures"),
        "qrPayment": Entry(source: "QR Payment", language: "en", french: "Paiement QR"),
        "promotions": Entry(source: "PROMOTIONS", language: "en", french: "PROMOTIONS"),
        "noPromotions": Entry(source: "No promotions available", language: "en", french: "Aucune promotion disponible"),
        "home": Entry(source: "Home", language: "en", french: "Accueil"),
        "sponsors": Entry(source: "Sponsors", language: "en", french: "Parrains"),
        "limits": Entry(source: "Limits", language: "en", french: "Limites"),
        "settings": Entry(source: "Settings", language: "en", french: "Paramètres"),
        "orderFood": Entry(source: "Order Food", language: "en", french: "Commander un repas"),
        "fastDelivery": Entry(source: "Fast local delivery", language: "en", french: "Livraison locale rapide"),
        "securitySettings": Entry(source: "Security Settings", language: "en", french: "Paramètres de sécurité"),
        "securityQuestion": Entry(source: "Security question", language: "en", french: "Question de sécurité"),
        "securityQuestionHelp": Entry(source: "To update your security question, please contact customer support.", language: "en", french: "Pour modifier votre question de sécurité, veuillez contacter le service client."),
        "requirePin": Entry(source: "Require PIN for every transaction", language: "en", french: "Exiger le code PIN pour chaque transaction"),
        "pinBypassHelp": Entry(source: "When disabled, you can complete up to 5 transactions without entering your PIN after the first verification", language: "en", french: "Si cette option est désactivée, vous pouvez effectuer jusqu’à 5 transactions sans saisir votre code PIN après la première vérification."),
        "transactionsWithoutPin": Entry(source: "Transactions without PIN", language: "en", french: "Transactions sans code PIN"),
        "pinAlwaysRequired": Entry(source: "A PIN is required for every transaction.", language: "en", french: "Un code PIN est requis pour chaque transaction."),
        "fiveTransactionsLeft": Entry(source: "You can complete 5 more transactions without entering your PIN", language: "en", french: "Vous pouvez effectuer encore 5 transactions sans saisir votre code PIN."),
        "changePin": Entry(source: "Change PIN", language: "en", french: "Modifier le code PIN"),
        "changeSecurityQuestion": Entry(source: "Change security question", language: "en", french: "Modifier la question de sécurité"),
        "biometricAuthentication": Entry(source: "Biometric Authentication", language: "en", french: "Authentification biométrique"),
        "biometricHelp": Entry(source: "Use fingerprint or face unlock", language: "en", french: "Utiliser l’empreinte digitale ou la reconnaissance faciale"),
        "importantInformation": Entry(source: "Important Information", language: "en", french: "Informations importantes"),
        "pinResetRule": Entry(source: "Your PIN is required after 5 consecutive transactions or when security settings change", language: "en", french: "Votre code PIN est requis après 5 transactions consécutives ou lors d’une modification des paramètres de sécurité."),
        "keepPinSecure": Entry(source: "Always keep your PIN secure and never share it with anyone", language: "en", french: "Gardez toujours votre code PIN secret et ne le partagez avec personne."),
        "counterReset": Entry(source: "The transaction counter resets to 0 each time you enter your PIN", language: "en", french: "Le compteur de transactions revient à 0 chaque fois que vous saisissez votre code PIN."),
        "disableBypass": Entry(source: "You can disable PIN bypass at any time in these settings", language: "en", french: "Vous pouvez désactiver cette option à tout moment dans ces paramètres."),
        "profileSection": Entry(source: "PROFILE", language: "en", french: "PROFIL"),
        "myProfile": Entry(source: "My Profile", language: "en", french: "Mon profil"),
        "beneficiaries": Entry(source: "My Beneficiaries", language: "en", french: "Mes bénéficiaires"),
        "loansSection": Entry(source: "LOANS", language: "en", french: "PRÊTS"),
        "requestLoan": Entry(source: "Request a Loan", language: "en", french: "Demander un prêt"),
        "myLoans": Entry(source: "My Loan Requests", language: "en", french: "Mes demandes de prêt"),
        "loanHelp": Entry(source: "FAQs / Terms and Conditions", language: "en", french: "FAQ / Conditions générales"),
        "transfersSection": Entry(source: "TRANSFERS", language: "en", french: "TRANSFERTS"),
        "moneyVoucher": Entry(source: "Money Voucher", language: "en", french: "Mise à disposition"),
        "mobileMoney": Entry(source: "Mobile Money", language: "en", french: "Monnaie mobile"),
        "qrTransfer": Entry(source: "QR Transfer", language: "en", french: "Transfert QR"),
        "crowdFunding": Entry(source: "Crowd Funding", language: "en", french: "Financement participatif"),
        "standingInstructions": Entry(source: "Standing Instructions", language: "en", french: "Virements permanents"),
        "foodSection": Entry(source: "FOOD SERVICES", language: "en", french: "RESTAURATION"),
        "foodHistory": Entry(source: "Food history", language: "en", french: "Historique des commandes"),
        "complaints": Entry(source: "Complaints", language: "en", french: "Réclamations"),
        "rechargesSection": Entry(source: "RECHARGES", language: "en", french: "RECHARGES"),
        "phoneCredit": Entry(source: "Phone Credit", language: "en", french: "Crédit téléphonique"),
        "buyData": Entry(source: "Buy Data", language: "en", french: "Acheter des données"),
        "billPayment": Entry(source: "Bill Payment", language: "en", french: "Paiement de factures"),
        "sponsorSection": Entry(source: "SPONSOR", language: "en", french: "PARRAINAGE"),
        "sponsoredWallets": Entry(source: "Sponsored Wallets", language: "en", french: "Portefeuilles parrainés"),
        "sponsoringWallets": Entry(source: "Sponsoring Wallets", language: "en", french: "Mes parrains"),
        "savingsSection": Entry(source: "SAVINGS", language: "en", french: "ÉPARGNE"),
        "savingsWallet": Entry(source: "Savings wallet", language: "en", french: "Portefeuille d’épargne"),
        "savingsStatement": Entry(source: "Savings Wallet Statement", language: "en", french: "Relevé du portefeuille d’épargne"),
        "transactionsSection": Entry(source: "TRANSACTIONS", language: "en", french: "TRANSACTIONS"),
        "walletManagement": Entry(source: "WALLET MANAGEMENT", language: "en", french: "GESTION DU PORTEFEUILLE"),
        "deactivateWallet": Entry(source: "Deactivate Wallet", language: "en", french: "Désactiver le portefeuille"),
        "pendingTransactions": Entry(source: "Pending Transactions", language: "en", french: "Transactions en attente"),
        "helpSection": Entry(source: "HELP", language: "en", french: "ASSISTANCE"),
        "sendFeedback": Entry(source: "Send Feedback", language: "en", french: "Envoyer un commentaire"),
        "fileComplaint": Entry(source: "File a Complaint", language: "en", french: "Déposer une réclamation"),
        "contactUs": Entry(source: "Contact Us", language: "en", french: "Nous contacter"),
        "terms": Entry(source: "Terms and Conditions", language: "en", french: "Conditions générales"),
        "faq": Entry(source: "FAQ", language: "en", french: "FAQ"),
        "logout": Entry(source: "Logout", language: "en", french: "Déconnexion"),
        "fillAllFields": Entry(source: "Please fill in all fields", language: "en", french: "Veuillez remplir tous les champs"),
        "sessionExpired": Entry(source: "Session Expired", language: "en", french: "Session expirée"),
        "loginAgain": Entry(source: "Session expired. Please login again.", language: "en", french: "Session expirée. Veuillez vous reconnecter."),
        "loginWithPin": Entry(source: "Session expired. Please login with your PIN.", language: "en", french: "Session expirée. Veuillez vous connecter avec votre code PIN."),
        "updateRequired": Entry(source: "Update Required", language: "en", french: "Mise à jour requise"),
        "update": Entry(source: "Update", language: "en", french: "Mettre à jour"),
        "quit": Entry(source: "Quit", language: "en", french: "Quitter"),
        "forgotPinTitle": Entry(source: "Forgot PIN", language: "en", french: "Code PIN oublié"),
        "forgotPinHelp": Entry(source: "Please contact customer support with your identity document for security verification.", language: "en", french: "Merci de contacter le service client muni de votre pièce d'identité pour des questions de sécurité"),
        "traitementEnCours": Entry(source: "Processing...", language: "en", french: "Traitement en cours..."),
        "saveBeneficiary": Entry(source: "Save beneficiary?", language: "en", french: "Enregistrer le bénéficiaire ?"),
        "save": Entry(source: "Save", language: "en", french: "Enregistrer"),
        "notNow": Entry(source: "Not now", language: "en"),
        "wouldYouLikeToSaveValueToYourBeneficiaries": Entry(source: "Would you like to save __ARG_0__ to your beneficiaries for future transfers?", language: "en", french: "Souhaitez-vous enregistrer __ARG_0__ parmi vos bénéficiaires pour de futurs transferts ?"),
        "accountDetails": Entry(source: "Account Details", language: "en"),
        "enterAccountNumber": Entry(source: "Enter account number", language: "en"),
        "verify": Entry(source: "Verify", language: "en"),
        "saved": Entry(source: "Saved", language: "en", french: "Enregistrés"),
        "beneficiaryName": Entry(source: "Beneficiary Name", language: "en", french: "Nom du bénéficiaire"),
        "amount": Entry(source: "Amount", language: "en"),
        "amount2": Entry(source: "Amount *", language: "en"),
        "impossibleDeCalculer": Entry(source: "Impossible de calculer", language: "fr"),
        "reasonOptional": Entry(source: "Reason (optional)", language: "en"),
        "enterAReason": Entry(source: "Enter a reason", language: "en"),
        "submit": Entry(source: "Submit", language: "en"),
        "numeroDeCompteInvalide": Entry(source: "Numéro de compte invalide", language: "fr"),
        "erreurValue": Entry(source: "Error: __ARG_0__", language: "en", french: "Erreur: __ARG_0__"),
        "erreurReseauValue": Entry(source: "Network error: __ARG_0__", language: "en", french: "Erreur réseau: __ARG_0__"),
        "enterAnAccountNumber": Entry(source: "Enter an account number", language: "en"),
        "compteVerifieAvecSucces": Entry(source: "Compte vérifié avec succès", language: "fr"),
        "compteVerifie": Entry(source: "Compte vérifié", language: "fr"),
        "informationDuCompteNonDisponible": Entry(source: "Information du compte non disponible", language: "fr"),
        "compteNonTrouve": Entry(source: "Compte non trouvé", language: "fr"),
        "donneesManquantesDansLaRequete": Entry(source: "Données manquantes dans la requête", language: "en"),
        "echecDeLaVerificationCodeValue": Entry(source: "Échec de la vérification. Code: __ARG_0__", language: "en"),
        "pleaseSelectASponsorWallet": Entry(source: "Please select a sponsor wallet", language: "en"),
        "veuillezSaisirUnNumeroDeCompteValideEtLe": Entry(source: "Veuillez saisir un numéro de compte valide et le vérifier", language: "fr"),
        "leMontantEstRequis": Entry(source: "Amount is required", language: "en", french: "Le montant est requis"),
        "veuillezDAbordVerifierLeCompte": Entry(source: "Veuillez d'abord vérifier le compte", language: "fr"),
        "veuillezSelectionnerUnCompteValide": Entry(source: "Veuillez sélectionner un compte valide", language: "fr"),
        "veuillezVerifierLeNumeroDeCompteEtSaisirUn": Entry(source: "Veuillez vérifier le numéro de compte et saisir un montant valide.", language: "fr"),
        "veuillezSaisirVotreCodePin": Entry(source: "Veuillez saisir votre code PIN", language: "fr"),
        "transfertEchoueValue": Entry(source: "Transfert échoué: __ARG_0__", language: "fr"),
        "unableToSaveBeneficiary": Entry(source: "Unable to save beneficiary", language: "en"),
        "theAccountDetailsAreUnavailablePleaseTryAgain": Entry(source: "The account details are unavailable. Please try again.", language: "en"),
        "pleaseTryAgainLater": Entry(source: "Please try again later.", language: "en"),
        "pleaseCheckYourConnectionAndTryAgain": Entry(source: "Please check your connection and try again.", language: "en"),
        "succes": Entry(source: "Success", language: "en", french: "Succès"),
        "walletToWallet": Entry(source: "Wallet to Wallet", language: "en"),
        "saveRecipient": Entry(source: "Save recipient?", language: "en", french: "Enregistrer le destinataire ?"),
        "wouldYouLikeToSaveValueForFutureTransfers": Entry(source: "Would you like to save __ARG_0__ for future transfers?", language: "en", french: "Souhaitez-vous enregistrer __ARG_0__ pour de futurs transferts ?"),
        "recipientDetails": Entry(source: "Recipient Details", language: "en"),
        "recipientIdentifier": Entry(source: "Recipient identifier", language: "en"),
        "walletNumber": Entry(source: "Wallet Number", language: "en", french: "Numéro de portefeuille"),
        "phoneOrCustomerId": Entry(source: "Phone or Customer ID", language: "en", french: "Téléphone ou identifiant client"),
        "recipientNumber": Entry(source: "Recipient number", language: "en"),
        "contacts": Entry(source: "Contacts", language: "en", french: "Contacts"),
        "recipientName": Entry(source: "Recipient Name", language: "en"),
        "verifyAgain": Entry(source: "Verify Again", language: "en", french: "Vérifier à nouveau"),
        "enterReason": Entry(source: "Enter reason", language: "en"),
        "chooseSavedRecipient": Entry(source: "Choose saved recipient", language: "en"),
        "choosePhoneContact": Entry(source: "Choose phone contact", language: "en"),
        "unableToVerifyThisRecipient": Entry(source: "Unable to verify this recipient.", language: "en", french: "Impossible de vérifier ce destinataire."),
        "unableToVerifyTheRecipientPleaseTryAgain": Entry(source: "Unable to verify the recipient. Please try again.", language: "en"),
        "enterTheRecipientPhoneNumberCustomerIdOrWallet": Entry(source: "Enter the recipient number.", language: "en", french: "Saisissez le numéro du destinataire."),
        "pleaseVerifyTheRecipientFirst": Entry(source: "Please verify the recipient first.", language: "en"),
        "pleaseChooseAnotherRecipient": Entry(source: "Please choose another recipient.", language: "en"),
        "enterAValidAmountWithUpToTwoDecimal": Entry(source: "Enter a valid amount with up to two decimal places.", language: "en"),
        "selectASponsorFirst": Entry(source: "Select a sponsor first.", language: "en"),
        "unableToCalculateFees": Entry(source: "Unable to calculate fees.", language: "en"),
        "invalidFeeQuotePleaseTryAgain": Entry(source: "Invalid fee quote. Please try again.", language: "en"),
        "unableToCalculateFeesPleaseTryAgain": Entry(source: "Unable to calculate fees. Please try again.", language: "en"),
        "transferDetailsChangedPleaseSubmitAgain": Entry(source: "Transfer details changed. Please submit again.", language: "en"),
        "enterYourPin": Entry(source: "Enter your PIN.", language: "en"),
        "transferFailed": Entry(source: "Transfer failed.", language: "en"),
        "transferCouldNotBeConfirmedCheckTransactionHistoryBefore": Entry(source: "Transfer could not be confirmed. Check transaction history before trying again.", language: "en"),
        "recipientDetailsAreUnavailablePleaseTryAgain": Entry(source: "Recipient details are unavailable. Please try again.", language: "en"),
        "unableToSaveRecipient": Entry(source: "Unable to save recipient", language: "en"),
        "transferSuccessful": Entry(source: "Transfer successful", language: "en"),
        "yourTransferIsComplete": Entry(source: "Your transfer is complete.", language: "en"),
        "transactionInformation": Entry(source: "Transaction Information", language: "en"),
        "idTransaction": Entry(source: "ID Transaction:", language: "en"),
        "amountDetails": Entry(source: "Amount Details", language: "en"),
        "amountSent": Entry(source: "Amount sent:", language: "en"),
        "withdrawalFee": Entry(source: "Withdrawal fee:", language: "en"),
        "transferFee": Entry(source: "Transfer fee:", language: "en"),
        "free": Entry(source: "Free", language: "en"),
        "totalDebited": Entry(source: "Total debited:", language: "en"),
        "sender": Entry(source: "Sender", language: "en"),
        "recipient": Entry(source: "Recipient", language: "en"),
        "shareReceipt": Entry(source: "Share receipt", language: "en"),
        "close": Entry(source: "Close", language: "en"),
        "transferReceipt": Entry(source: "Transfer Receipt", language: "en"),
        "recuDeTransfert": Entry(source: "REÇU DE TRANSFERT", language: "fr"),
        "statusTransferSuccessful": Entry(source: "Status: Transfer successful", language: "en"),
        "idTransactionValue": Entry(source: "ID Transaction: __ARG_0__", language: "en"),
        "dateValue": Entry(source: "Date: __ARG_0__", language: "en"),
        "amountDetails2": Entry(source: "AMOUNT DETAILS", language: "en"),
        "amountSentValue": Entry(source: "Amount sent: __ARG_0__", language: "en"),
        "withdrawalFeeValue": Entry(source: "Withdrawal fee: __ARG_0__", language: "en"),
        "transferFeeValue": Entry(source: "Transfer fee: __ARG_0__", language: "en"),
        "totalDebitedValue": Entry(source: "Total debited: __ARG_0__", language: "en"),
        "nameValue": Entry(source: "Name: __ARG_0__", language: "en"),
        "phoneValue": Entry(source: "Phone: __ARG_0__", language: "en"),
        "reasonValue": Entry(source: "Reason: __ARG_0__", language: "en"),
        "thisReceiptWasGeneratedAutomaticallyOnValue": Entry(source: "This receipt was generated automatically on __ARG_0__", language: "en"),
        "loadingTransactions": Entry(source: "Loading transactions...", language: "en"),
        "somethingWentWrong": Entry(source: "Something went wrong.", language: "en"),
        "startDate": Entry(source: "Start date", language: "en"),
        "endDate": Entry(source: "End date", language: "en"),
        "filterByDate": Entry(source: "Filter by Date", language: "en"),
        "startDate2": Entry(source: "Start Date", language: "en"),
        "endDate2": Entry(source: "End Date", language: "en"),
        "reset": Entry(source: "Reset", language: "en", french: "Réinitialiser"),
        "filter": Entry(source: "Filter", language: "en", french: "Filtrer"),
        "last30Days": Entry(source: "Last 30 Days", language: "en"),
        "pdf": Entry(source: "PDF", language: "en"),
        "excel": Entry(source: "Excel", language: "en"),
        "csv": Entry(source: "CSV", language: "en"),
        "exportTransactions": Entry(source: "Export transactions", language: "en"),
        "unableToCreateTheExportFilePleaseTryAgain": Entry(source: "Unable to create the export file. Please try again.", language: "en"),
        "dateRangeValueValue": Entry(source: "Date range: __ARG_0__ - __ARG_1__", language: "en"),
        "noTransactionsFound": Entry(source: "No transactions found", language: "en"),
        "thereAreNoTransactionsForTheSelectedDateRange": Entry(source: "There are no transactions for the selected date range.", language: "en"),
        "refresh": Entry(source: "Refresh", language: "en"),
        "pageValueOfValue": Entry(source: "Page __ARG_0__ of __ARG_1__", language: "en"),
        "walletNumberNotFoundPleaseSignInAgain": Entry(source: "Wallet number not found. Please sign in again.", language: "en"),
        "unableToLoadTransactionsValue": Entry(source: "Unable to load transactions. __ARG_0__", language: "en"),
        "errorValue": Entry(source: "Error: __ARG_0__", language: "en"),
        "connectionErrorValue": Entry(source: "Connection error: __ARG_0__", language: "en"),
        "pleaseSelectAStartAndEndDate": Entry(source: "Please select a start and end date.", language: "en"),
        "theStartDateMustBeOnOrBeforeThe": Entry(source: "The start date must be on or before the end date.", language: "en"),
        "cancel": Entry(source: "Cancel", language: "en", french: "Annuler"),
        "done": Entry(source: "Done", language: "en", french: "Terminé"),
        "transactionDetails": Entry(source: "Transaction Details", language: "en"),
        "transactionInformation2": Entry(source: "TRANSACTION INFORMATION", language: "en"),
        "reference": Entry(source: "Reference", language: "en", french: "Référence"),
        "nA": Entry(source: "N/A", language: "en"),
        "type": Entry(source: "Type", language: "en"),
        "details": Entry(source: "Details", language: "en"),
        "noAdditionalDetails": Entry(source: "No additional details", language: "en"),
        "openingBalance": Entry(source: "Opening balance", language: "en"),
        "closingBalance": Entry(source: "Closing balance", language: "en"),
        "moneySent": Entry(source: "Money sent", language: "en"),
        "moneyReceived": Entry(source: "Money received", language: "en"),
        "unknown": Entry(source: "Unknown", language: "en", french: "Inconnu"),
        "refValue": Entry(source: "Ref. __ARG_0__", language: "en"),
        "transactionReceipt": Entry(source: "Transaction receipt", language: "en"),
        "transactionReceipt2": Entry(source: "Transaction Receipt", language: "en"),
        "referenceValue": Entry(source: "Reference: __ARG_0__", language: "en"),
        "typeValue": Entry(source: "Type: __ARG_0__", language: "en"),
        "amountValue": Entry(source: "Amount: __ARG_0__", language: "en"),
        "statusValue": Entry(source: "Status: __ARG_0__", language: "en"),
        "detailsValue": Entry(source: "Details: __ARG_0__", language: "en"),
        "openingBalanceValue": Entry(source: "Opening balance: __ARG_0__", language: "en"),
        "closingBalanceValue": Entry(source: "Closing balance: __ARG_0__", language: "en"),
        "conditionsGenerales": Entry(source: "Conditions Générales", language: "fr"),
        "conditionsGeneralesDUtilisation": Entry(source: "Conditions Générales d'Utilisation", language: "fr"),
        "definitions": Entry(source: "Définitions", language: "fr"),
        "objet": Entry(source: "Objet", language: "fr"),
        "fonctionnalitesDuService": Entry(source: "Fonctionnalités du service", language: "fr"),
        "iHaveReadAndAcceptTheTermsAndConditions": Entry(source: "I have read and accept the terms and conditions", language: "en"),
        "refuse": Entry(source: "Refuse", language: "en"),
        "accept": Entry(source: "Accept", language: "en"),
        "pourLesBesoinsDuPresentContratIlConvientD": Entry(source: "Pour les besoins du présent contrat, il convient d'entendre par :", language: "fr"),
        "banque": Entry(source: "Banque", language: "fr"),
        "laDiamaBankSa": Entry(source: "La DIAMA BANK SA.", language: "fr"),
        "contrat": Entry(source: "Contrat", language: "fr"),
        "designeLePresentContratDAdhesionAuServiceDiamacash": Entry(source: "Désigne le présent contrat d'adhésion au service GambiaPay, ses Conditions Générales de fonctionnement, ses Conditions Particulières ainsi que tout document annexe et avenant, qui constitue un tout indivisible.", language: "fr"),
        "applicationMobile": Entry(source: "Application mobile", language: "fr"),
        "uneApplicationMobileEstUnLogicielApplicatifDeveloppePour": Entry(source: "Une application mobile est un logiciel applicatif développé pour un appareil électronique mobile, tel qu'un assistant personnel, un téléphone portable, un smartphone…", language: "fr"),
        "wallet": Entry(source: "Wallet", language: "fr"),
        "constitueUnMoyenDePaiementPermettantASonDetenteur": Entry(source: "Constitue un moyen de paiement permettant à son détenteur de stocker de façon sécurisée dans un portefeuille numérique, de la monnaie électronique en vue d'effectuer des paiements, d'émettre ou de recevoir des transferts d'argent ainsi que de faire du cash in et du cash out.", language: "fr"),
        "etablissement": Entry(source: "Etablissement", language: "fr"),
        "designeToutEtablissementBancaireOuLesEtablissementsDePaiement": Entry(source: "Désigne tout établissement bancaire ou les établissements de paiement.", language: "fr"),
        "cashIn": Entry(source: "Cash-In", language: "fr"),
        "ilSAgitDUneOperationDeDepotD": Entry(source: "Il s'agit d'une opération de dépôt d'espèce au niveau du Wallet.", language: "fr"),
        "cashOut": Entry(source: "Cash-Out", language: "fr"),
        "ilSAgitDUneOperationDeRetraitD": Entry(source: "Il s'agit d'une opération de retrait d'espèce à partir du Wallet, auprès d'un distributeur agréé par la DIAMA BANK SA.", language: "fr"),
        "compteDeRattachement": Entry(source: "Compte de rattachement", language: "fr"),
        "designeLeCompteOuvertDansLesLivresDeLa": Entry(source: "Désigne le compte ouvert dans les livres de la Banque tel que précisé dans le Bulletin d'Adhésion et sur lequel est rattaché le Wallet.", language: "fr"),
        "detenteurDuWallet": Entry(source: "Détenteur du Wallet", language: "fr"),
        "peutEtreLeTitulaireDuCompteOuTouteAutre": Entry(source: "Peut-être le titulaire du compte ou toute autre personne nommément désignée dans le présent contrat.", language: "fr"),
        "designeLApplicationDePaiementMobilePourLesClients": Entry(source: "Désigne l'application de paiement mobile pour les clients à titre privé.", language: "fr"),
        "dabGab": Entry(source: "DAB/GAB", language: "fr"),
        "appareilsDeDistributionAutomatiqueDeBilletsDeBanque": Entry(source: "Appareils de distribution automatique de billets de Banque.", language: "fr"),
        "tpe": Entry(source: "TPE", language: "fr"),
        "terminalDePaiementElectronique": Entry(source: "Terminal de Paiement Electronique.", language: "fr"),
        "leWalletDiamacashEstUnMoyenDePaiementElectronique": Entry(source: "Le Wallet GambiaPay est un moyen de paiement électronique sécurisé, pouvant être lié au compte bancaire du client ouvert dans les livres de la DIAMA BANK SA, qui permet à son titulaire d'effectuer en temps réel différents services de paiement et de transfert d'argent et ce, via l'application mobile GambiaPay.", language: "fr"),
        "cetteApplicationEstTelechargeableAPartirDeGooglePlay": Entry(source: "Cette application est téléchargeable à partir de Google Play et Apple Store.", language: "fr"),
        "lesFonctionnalitesDisponiblesAuNiveauDeLApplicationDiamacash": Entry(source: "Les fonctionnalités disponibles au niveau de l'application GambiaPay sont :", language: "fr"),
        "laSouscription": Entry(source: "La souscription", language: "fr"),
        "leClientPeutInitierDirectementSonInscriptionSurL": Entry(source: "Le client peut initier directement son inscription sur l'application GambiaPay en renseignant les formulaires associés ou se rendre soit chez un agent agréé, soit en agence pour se faire assister pour son inscription.", language: "fr"),
        "laConnexion": Entry(source: "La connexion", language: "fr"),
        "leClientSeConnecteASonCompteDiamacashA": Entry(source: "Le client se connecte à son compte GambiaPay à l'aide de son numéro de téléphone et de son code secret. Lors de la toute première connexion, il lui sera demandé de saisir un code de confirmation qu'il recevra par sms pour des raisons de sécurité.", language: "fr"),
        "laLiaisonDeSonCompteBancaire": Entry(source: "La liaison de son compte bancaire", language: "fr"),
        "leClientQuiAUnCompteBancaireOuvertDans": Entry(source: "Le client qui a un compte bancaire ouvert dans les livres de la DIAMA BANK SA peut se rendre en agence pour demander la liaison de son compte et ainsi effectuer les opérations de transfert gratuitement entre son compte GambiaPay et son compte bancaire.", language: "fr"),
        "leDeplafonnementDuWallet": Entry(source: "Le déplafonnement du wallet", language: "fr"),
        "parDefautLeCompteDiamacashDuClientEstLimite": Entry(source: "Par défaut, le compte GambiaPay du client est limité à un solde maximum de 5.000.000 GNF lors de l'ouverture de son compte à distance. Il peut cependant se rendre en agence ou chez un distributeur agréé pour signer la convention de contrat et demander le déplafonnement de son compte GambiaPay.", language: "fr"),
        "leChargementDuWalletCashIn": Entry(source: "Le Chargement du Wallet (Cash-In)", language: "fr"),
        "leDetenteurDuWalletPeutBeneficierDeDeuxCanaux": Entry(source: "Le détenteur du Wallet peut bénéficier de deux canaux de chargement : Chargement au niveau des distributeurs en faisant un versement espèces, ou Chargement via son compte bancaire DIAMA BANK SA lié à son wallet.", language: "fr"),
        "retraitDArgentCashOut": Entry(source: "Retrait d'argent (Cash-Out)", language: "fr"),
        "leClientPeutSeRendreChezNImporteQuels": Entry(source: "Le client peut se rendre chez n'importe quels distributeurs pour effectuer un retrait sur son compte GambiaPay.", language: "fr"),
        "transfertVersUnAutreCompteDiamacash": Entry(source: "Transfert vers un autre compte GambiaPay", language: "fr"),
        "leClientPeutAToutMomentEffectuerDesTransferts": Entry(source: "Le client peut à tout moment effectuer des transferts d'argent à un autre wallet client dans la limite de son solde et de ces autorisations.", language: "fr"),
        "transfertVersMaBanque": Entry(source: "Transfert vers ma banque", language: "fr"),
        "leClientPeutAToutMomentEffectuerDesTransferts2": Entry(source: "Le client peut à tout moment effectuer des transferts d'argent vers son compte bancaire DIAMA BANK SA qui a été au préalable lié à son wallet.", language: "fr"),
        "transfertDeMaBanque": Entry(source: "Transfert de ma banque", language: "fr"),
        "leClientPeutAToutMomentEffectuerDesTransferts3": Entry(source: "Le client peut à tout moment effectuer des transferts d'argent depuis son compte bancaire DIAMA BANK SA qui a été au préalable lié à son wallet.", language: "fr"),
        "leClientPeutAToutMomentEffectuerDesTransferts4": Entry(source: "Le client peut à tout moment effectuer des transferts d'argent à une personne n'ayant pas de compte GambiaPay.", language: "fr"),
        "leClientPeutAToutMomentEffectuerLeParrainage": Entry(source: "Le client peut à tout moment effectuer le parrainage d'un autre compte GambiaPay.", language: "fr"),
        "virementPermanent": Entry(source: "Virement permanent", language: "fr"),
        "leClientPeutAToutMomentInitierDesVirements": Entry(source: "Le client peut à tout moment initier des virements permanents vers un autre compte GambiaPay.", language: "fr"),
        "paiementChezLeCommercant": Entry(source: "Paiement chez le commerçant", language: "fr"),
        "leClientPeutPayerSesAchatsAPartirDe": Entry(source: "Le Client peut payer ses achats à partir de son Wallet GambiaPay, auprès des commerçants accepteurs détenant un Wallet GambiaPay PRO.", language: "fr"),
        "conditionsDInscriptionAuService": Entry(source: "Conditions d'inscription au service", language: "fr"),
        "leServiceEstReserveALaClienteleDesParticuliers": Entry(source: "Le Service est réservé à la clientèle des particuliers, personnes physiques majeures titulaires disposant :", language: "fr"),
        "dUnSmartphoneCompatibleAvecPlayStoreOuApple": Entry(source: "D'un smartphone compatible avec Play Store ou Apple Store", language: "fr"),
        "dUnNumeroMobileGuineenEnLeurNom": Entry(source: "D'un numéro mobile guinéen en leur nom", language: "fr"),
        "lUtilisationDeDiamacashSeFaitEnGuineeComme": Entry(source: "L'utilisation de GambiaPay se fait en Guinée comme à l'étranger.", language: "fr"),
        "accesAuService": Entry(source: "Accès au service", language: "fr"),
        "lAccesAuServiceEstSubordonneAuRespectPar": Entry(source: "L'accès au service est subordonné au respect par l'Utilisateur des dispositions de ce contrat.", language: "fr"),
        "moyensTechniques": Entry(source: "Moyens techniques :", language: "fr"),
        "lAccesAuServiceSeFaitViaLUtilisation": Entry(source: "L'accès au Service se fait via l'utilisation d'Internet au moyen d'un terminal mobile. L'Utilisateur s'assure de disposer à minima :", language: "fr"),
        "dUnSmartphoneDeSaMiseEnServiceEt": Entry(source: "D'un smartphone, de sa mise en service et de sa maintenance", language: "fr"),
        "dUnAccesAInternetSurSonTerminalMobile": Entry(source: "D'un accès à Internet sur son terminal mobile", language: "fr"),
        "deLaCompatibiliteDuMaterielEtDesLogicielsDestines": Entry(source: "De la compatibilité du matériel et des logiciels destinés à utiliser le Service", language: "fr"),
        "codesEtSecurite": Entry(source: "Codes et sécurité", language: "fr"),
        "leCodePersonnelDefiniLorsDeLInscriptionA": Entry(source: "Le code personnel défini lors de l'inscription à GambiaPay est strictement confidentiel. Le Client s'engage à le tenir secret et s'interdit de le communiquer à quiconque.", language: "fr"),
        "leClientEstEntierementResponsableDeLaConservationEt": Entry(source: "Le Client est entièrement responsable de la conservation et de l'utilisation de ses codes et, le cas échéant, des conséquences de leur divulgation et/ou de leur utilisation par des tiers.", language: "fr"),
        "ilAppartientNotammentAuClientDeSAssurerQue": Entry(source: "Il appartient notamment au client de s'assurer que la conservation et la saisie de ses codes personnels soient effectuées dans des conditions parfaites de sécurité et de confidentialité.", language: "fr"),
        "pourDesRaisonsDeSecuriteLAccesAuService": Entry(source: "Pour des raisons de sécurité, l'accès au Service pourra être bloqué temporairement au Client après composition à trois reprises d'un mot de passe erroné.", language: "fr"),
        "laBanqueRecommandeDeModifierLeMotDePasse": Entry(source: "La Banque recommande de modifier le mot de passe de l'application GambiaPay chaque 3 mois.", language: "fr"),
        "evolutionsDuService": Entry(source: "Évolutions du service", language: "fr"),
        "enFonctionNotammentDesEvolutionsTechnologiquesLaBanqueApportera": Entry(source: "En fonction notamment des évolutions technologiques, la Banque apportera aux services de GambiaPay les adaptations qui lui sembleront souhaitables. Elle en informera le client par tout moyen.", language: "fr"),
        "assistance": Entry(source: "Assistance", language: "fr"),
        "laBanqueMetADispositionDeLUtilisateurUn": Entry(source: "La Banque met à disposition de l'utilisateur un service d'assistance via son Centre de relations clients (CRC).", language: "fr"),
        "secretProfessionnel": Entry(source: "Secret professionnel", language: "fr"),
        "laDiamaBankSaEstTenueAuSecretProfessionnel": Entry(source: "La DIAMA BANK SA est tenue au secret professionnel conformément à la loi bancaire de la République de Guinée. Obligation légale est faite à son personnel de ne pas révéler les informations confidentielles dont il peut avoir connaissance. Cependant lorsque la loi le prévoit, le secret professionnel ne peut être opposé aux personnes, autorités ou organismes visés par cette dernière.", language: "fr"),
        "responsabilite": Entry(source: "Responsabilité", language: "fr"),
        "laBanque": Entry(source: "LA BANQUE", language: "fr"),
        "laDiamaBankSaSEngageAFournirLe": Entry(source: "La DIAMA BANK SA s'engage à fournir le service selon les modalités définies au présent Contrat.", language: "fr"),
        "laBanqueDeclineTouteResponsabiliteEnCasDeDysfonctionnement": Entry(source: "La Banque décline toute responsabilité en cas de dysfonctionnement dû à un défaut de compatibilité de l'équipement personnel du client ou de la configuration de son matériel.", language: "fr"),
        "laBanqueNEstPasResponsableDesDysfonctionnementsImputables": Entry(source: "La Banque n'est pas responsable des dysfonctionnements imputables aux fournisseurs d'accès et opérateurs de téléphonie mobile choisis par l'Utilisateur.", language: "fr"),
        "leClient": Entry(source: "LE CLIENT", language: "fr"),
        "leClientDoitPrendreTouteMesurePourConserverA": Entry(source: "Le Client doit prendre toute mesure pour conserver à tout moment en sa possession son smartphone et préserver la confidentialité de ses codes.", language: "fr"),
        "leClientDoitUtiliserLeServiceConformementAuxFinalites": Entry(source: "Le Client doit utiliser le service conformément aux finalités spécifiées dans le présent Contrat. Il assume les conséquences de l'utilisation du Service tant qu'il n'a pas fait une demande d'opposition (ou de blocage).", language: "fr"),
        "leClientSEngageAMettreAJourLes": Entry(source: "Le Client s'engage à mettre à jour les informations communiquées lors de l'inscription, en cas de changement de celles-ci.", language: "fr"),
        "leClientEstResponsableDesOperationsEffectueesViaSon": Entry(source: "Le Client est responsable des opérations effectuées via son Wallet GambiaPay. La banque décline toute responsabilité liée à l'exécution d'une transaction par erreur à un autre bénéficiaire différent que celui souhaité ou un montant autre que celui voulu lors de l'action.", language: "fr"),
        "interruptionDuService": Entry(source: "Interruption du service", language: "fr"),
        "laBanquePeutBloquerLAccesTotalAuxServices": Entry(source: "La Banque peut bloquer l'accès total aux services GambiaPay pour des raisons de sécurité ou de présomption d'opération non autorisée ou frauduleuse. Cette décision de blocage sera notifiée dans tous les cas au Client.", language: "fr"),
        "leServicePourraEtrePonctuellementInterrompuPourDeCourtes": Entry(source: "Le Service pourra être ponctuellement interrompu pour de courtes périodes pour des raisons d'ordre technique, notamment pour effectuer des opérations de maintenance.", language: "fr"),
        "oppositionOuBlocageParLeClient": Entry(source: "Opposition ou blocage par le client", language: "fr"),
        "enCasDeVolDeDetournementOuDeToute": Entry(source: "En cas de vol, de détournement ou de toute utilisation frauduleuse de ses codes d'accès ou de son smartphone, le Client doit en informer sans tarder la Banque aux fins de blocage de l'accès au Service.", language: "fr"),
        "dansTousLesCasLeClientDoitImmediatement": Entry(source: "Dans tous les cas, le client doit immédiatement :", language: "fr"),
        "alerterLaBanque": Entry(source: "Alerter la banque", language: "fr"),
        "ouAppelerLeCentreDeRelationsClientsCrcDe": Entry(source: "Ou appeler le centre de relations clients (CRC) de la banque par téléphone", language: "fr"),
        "tarificationDuService": Entry(source: "Tarification du service", language: "fr"),
        "lesServicesCiApresSontOffertsGratuitementPourLe": Entry(source: "Les services ci-après sont offerts gratuitement pour le détenteur du Wallet GambiaPay :", language: "fr"),
        "laSouscriptionAuWalletDiamacash": Entry(source: "La souscription au Wallet GambiaPay", language: "fr"),
        "leChargementDuWalletDiamacash": Entry(source: "Le chargement du Wallet GambiaPay", language: "fr"),
        "lePaiementChezLeCommercantOuAutresPrestataires": Entry(source: "Le paiement chez le commerçant ou autres prestataires", language: "fr"),
        "laDesinscription": Entry(source: "La désinscription", language: "fr"),
        "leClientConserveASaChargeLesCoutsDe": Entry(source: "Le Client conserve à sa charge les coûts de connexion facturés par son fournisseur d'accès Internet lors de l'utilisation du Service.", language: "fr"),
        "dureeDuContratResiliation": Entry(source: "Durée du contrat - Résiliation", language: "fr"),
        "lePresentContratEstConcluPourUneDureeIndeterminee": Entry(source: "Le présent Contrat est conclu pour une durée indéterminée.", language: "fr"),
        "ilPeutEtreResilieAToutMomentParLe": Entry(source: "Il peut être résilié à tout moment par le Client dans son compte GambiaPay ou par la Banque.", language: "fr"),
        "laResiliationParLeClientPrendEffetTrente30": Entry(source: "La résiliation par le Client prend effet trente (30) jours après la date de réception de sa demande de résiliation sous réserve de la bonne exécution des opérations de paiement effectuées au moyen du Service et encore en cours.", language: "fr"),
        "laResiliationParLaBanquePrendEffetQuinzeJours": Entry(source: "La résiliation par La Banque prend effet quinze jours (15) après la date d'envoi de sa notification au Client.", language: "fr"),
        "modificationDuContrat": Entry(source: "Modification du contrat", language: "fr"),
        "laBanqueSeReserveLeDroitDApporterDes": Entry(source: "La Banque se réserve le droit d'apporter des modifications au présent Contrat, qui seront communiquées au Client par l'envoi d'un message via les canaux de communication de la banque, 30 jours avant la date de leur entrée en vigueur.", language: "fr"),
        "lAbsenceDeContestationNotifieeALaBanqueAvant": Entry(source: "L'absence de contestation notifiée à La Banque avant l'expiration du délai précité vaut acceptation de ces modifications.", language: "fr"),
        "arretDuService": Entry(source: "Arrêt du service", language: "fr"),
        "enCasDArretDeLaFournitureDuService": Entry(source: "En cas d'arrêt de la fourniture du Service, le Client sera informé avec un préavis de trois (3) mois des dates et conditions d'arrêt de la fourniture du Service.", language: "fr"),
        "loiApplicableJuridictionLitiges": Entry(source: "Loi applicable - Juridiction - Litiges", language: "fr"),
        "leContratEstRegiEtInterpreteSelonLeDroit": Entry(source: "Le contrat est régi et interprété selon le droit Guinéen. Les parties déclarent se soumettre aux lois et règlements en vigueur en République de Guinée.", language: "fr"),
        "toutDifferendYRelatifQuantASonInterpretationOu": Entry(source: "Tout différend y relatif quant à son interprétation ou son exécution, et qui n'aura pas été résolu à l'amiable sera porté devant les tribunaux compétents de Conakry.", language: "fr"),
        "sourceOfFunds": Entry(source: "Source of Funds", language: "en"),
        "sourceDesFonds": Entry(source: "Source des Fonds", language: "fr"),
        "monPortefeuille": Entry(source: "Mon Portefeuille", language: "fr"),
        "sponsor": Entry(source: "Sponsor", language: "en"),
        "selectionnerUnSponsor": Entry(source: "Sélectionner un Sponsor", language: "fr"),
        "selectASponsor": Entry(source: "Select a Sponsor", language: "en"),
        "unnamedSponsor": Entry(source: "Unnamed Sponsor", language: "en"),
        "sponsorSansNom": Entry(source: "Sponsor sans nom", language: "fr"),
        "availableBalance2": Entry(source: "Available balance", language: "en"),
        "dailyLimitGmd": Entry(source: "Daily limit (GMD)", language: "en"),
        "limiteQuotidienneGmd": Entry(source: "Limite quotidienne (GMD)", language: "fr"),
        "unableToLoadSponsorWallets": Entry(source: "Unable to load sponsor wallets", language: "en"),
        "erreurLorsDeLaRecuperationDesPortefeuillesSponsors": Entry(source: "Erreur lors de la récupération des portefeuilles sponsors", language: "fr"),
        "networkErrorValue": Entry(source: "Network error: __ARG_0__", language: "en"),
        "pleaseWait": Entry(source: "Please wait...", language: "en"),
        "veuillezPatienter": Entry(source: "Veuillez patienter...", language: "fr"),
        "transferToAccountSuccessful": Entry(source: "Transfer to account successful", language: "en"),
        "idValue": Entry(source: "ID: __ARG_0__", language: "en"),
        "date": Entry(source: "Date", language: "en"),
        "phone": Entry(source: "Phone", language: "en"),
        "accountNo": Entry(source: "Account No", language: "en"),
        "bank": Entry(source: "Bank", language: "en"),
        "transferToAccount": Entry(source: "Transfer to account", language: "en"),
        "withdrawalFee2": Entry(source: "Withdrawal fee", language: "en"),
        "totalDebited2": Entry(source: "Total debited", language: "en"),
        "recuDeTransfertVersCompte": Entry(source: "Reçu de Transfert vers Compte", language: "fr"),
        "recuDeTransfertVersCompte2": Entry(source: "REÇU DE TRANSFERT VERS COMPTE", language: "fr"),
        "statutTransfertVersCompteReussi": Entry(source: "Statut: Transfert vers compte réussi", language: "fr"),
        "montantValue": Entry(source: "Montant: __ARG_0__", language: "fr"),
        "fraisValue": Entry(source: "Frais: __ARG_0__", language: "fr"),
        "totalDebiteValue": Entry(source: "Total débité: __ARG_0__", language: "fr"),
        "nomValue": Entry(source: "Nom: __ARG_0__", language: "fr"),
        "portefeuilleValue": Entry(source: "Portefeuille: __ARG_0__", language: "fr"),
        "telephoneValue": Entry(source: "Téléphone: __ARG_0__", language: "fr"),
        "compteDestinataire": Entry(source: "COMPTE DESTINATAIRE", language: "fr"),
        "nomDuCompteValue": Entry(source: "Nom du compte: __ARG_0__", language: "fr"),
        "numeroDeCompteValue": Entry(source: "Numéro de compte: __ARG_0__", language: "fr"),
        "banqueValue": Entry(source: "Banque: __ARG_0__", language: "fr"),
        "detailsValue2": Entry(source: "Détails: __ARG_0__", language: "fr"),
        "ceRecuAEteGenereAutomatiquementLeValue": Entry(source: "Ce reçu a été généré automatiquement le __ARG_0__", language: "fr"),
        "confirmTransfer": Entry(source: "Confirm transfer", language: "en"),
        "reviewTheDetailsAndEnterYourPin": Entry(source: "Review the details and enter your PIN", language: "en"),
        "transferAmount": Entry(source: "Transfer amount", language: "en"),
        "applicableFees": Entry(source: "Applicable fees", language: "en"),
        "transferFee2": Entry(source: "Transfer fee", language: "en"),
        "totalToDebit": Entry(source: "Total to debit", language: "en"),
        "name": Entry(source: "Name", language: "en", french: "Nom"),
        "sourceOfFunds2": Entry(source: "Source of funds", language: "en"),
        "sponsorWallet": Entry(source: "Sponsor wallet", language: "en"),
        "myWallet": Entry(source: "My wallet", language: "en"),
        "reason": Entry(source: "Reason", language: "en"),
        "enterPin": Entry(source: "Enter PIN", language: "en"),
        "confirm": Entry(source: "Confirm", language: "en"),
        "pinMustContainExactly4Digits": Entry(source: "PIN must contain exactly 4 digits", language: "en"),
        "confirmationDuTransfert": Entry(source: "Confirmation du transfert", language: "fr"),
        "verifiezLesDetailsEtSaisissezVotreCodePin": Entry(source: "Vérifiez les détails et saisissez votre code PIN", language: "fr"),
        "montant": Entry(source: "MONTANT", language: "fr"),
        "fraisDEnvoi": Entry(source: "Frais d'envoi", language: "fr"),
        "gratuit": Entry(source: "Gratuit", language: "fr"),
        "totalADebiter": Entry(source: "Total à débiter", language: "fr"),
        "informationsDuBeneficiaire": Entry(source: "INFORMATIONS DU BÉNÉFICIAIRE", language: "fr"),
        "numeroDeCompte": Entry(source: "Numéro de compte", language: "fr"),
        "description": Entry(source: "DESCRIPTION", language: "fr"),
        "authentification": Entry(source: "AUTHENTIFICATION", language: "fr"),
        "annuler": Entry(source: "Cancel", language: "en", french: "Annuler"),
        "transferer": Entry(source: "Transférer", language: "fr"),
        "lePinDoitContenirExactement4Chiffres": Entry(source: "Le PIN doit contenir exactement 4 chiffres", language: "fr"),
        "translatingApp": Entry(source: "Preparing language…", language: "en"),
        "translationFailed": Entry(source: "Unable to prepare this language. Your previous language is still selected. Please try again.", language: "en"),
        "automaticLanguages": Entry(source: "Automatically translated languages", language: "en"),
        "automaticLanguageHelp": Entry(source: "Choose any language supported by Apple Translation on this device. A language download may be required.", language: "en"),
        "requiresIOS18": Entry(source: "More languages require iOS 18 or later.", language: "en"),
        "retry": Entry(source: "Retry", language: "en"),
        "cancelLanguage": Entry(source: "Cancel", language: "en"),
        "languageUnavailable": Entry(source: "This language is not currently supported on this device.", language: "en"),
        "automaticTermsNotice": Entry(source: "This text is automatically translated.", language: "en"),
        "showOriginalTerms": Entry(source: "Show original French text", language: "en"),
        "showTranslatedTerms": Entry(source: "Show translated text", language: "en"),
        "processing": Entry(source: "Processing...", language: "en"),
        "dateLabel": Entry(source: "Date:", language: "en"),
        "nameLabel": Entry(source: "Name:", language: "en"),
        "phoneLabel": Entry(source: "Phone:", language: "en"),
        "reasonLabel": Entry(source: "Reason:", language: "en"),
        "senderHeading": Entry(source: "SENDER", language: "en"),
        "recipientHeading": Entry(source: "RECIPIENT", language: "en"),
        "account": Entry(source: "Account", language: "en"),
        "fee": Entry(source: "Fee", language: "en"),
        "share": Entry(source: "SHARE", language: "en"),
        "closeHeading": Entry(source: "CLOSE", language: "en"),
        "errorHeading": Entry(source: "Error!", language: "en"),
        "beneficiary": Entry(source: "Bénéficiaire", language: "fr"),
        "sponsorship": Entry(source: "Parrainage", language: "fr"),
        "unknownError": Entry(source: "Erreur inconnue", language: "fr"),
        "pleaseTryAgain": Entry(source: "Please try again.", language: "en", french: "Veuillez réessayer."),
        "balance": Entry(source: "Balance", language: "en"),
        "status": Entry(source: "Status", language: "en", french: "Statut"),
        "dateUnavailable": Entry(source: "Date unavailable", language: "en", french: "Date indisponible"),
        "transactionGeneric": Entry(source: "Transaction", language: "en"),
        "balanceValue": Entry(source: "Balance: __ARG_0__", language: "en"),
        "transfertVersPortefeuilleReussi": Entry(source: "Transfert vers portefeuille réussi", language: "fr"),
        "montant2": Entry(source: "Montant:", language: "fr"),
        "fraisDEnvoi2": Entry(source: "Frais d'envoi:", language: "fr"),
        "frais": Entry(source: "Frais:", language: "fr"),
        "totalDebite": Entry(source: "Total débité:", language: "fr"),
        "compteSource": Entry(source: "COMPTE SOURCE", language: "fr"),
        "titulaire": Entry(source: "Titulaire:", language: "fr"),
        "numeroDeCompte2": Entry(source: "Numéro de compte:", language: "fr"),
        "banque2": Entry(source: "Banque:", language: "fr"),
        "portefeuilleDestinataire": Entry(source: "PORTEFEUILLE DESTINATAIRE", language: "fr"),
        "nom": Entry(source: "Nom:", language: "fr"),
        "portefeuille": Entry(source: "Portefeuille:", language: "fr"),
        "telephone": Entry(source: "Téléphone:", language: "fr"),
        "details2": Entry(source: "Détails:", language: "fr"),
        "transfertVersPortefeuille": Entry(source: "Transfert vers portefeuille", language: "fr"),
        "partagerLeRecu": Entry(source: "Partager le reçu", language: "fr"),
        "fermer": Entry(source: "Fermer", language: "en"),
        "recuDeTransfert2": Entry(source: "Reçu de transfert", language: "fr"),
        "recuDeTransfertVersPortefeuille": Entry(source: "Reçu de Transfert vers Portefeuille", language: "fr"),
        "recuDeTransfertVersPortefeuille2": Entry(source: "REÇU DE TRANSFERT VERS PORTEFEUILLE", language: "fr"),
        "statutTransfertVersPortefeuilleReussi": Entry(source: "Statut: Transfert vers portefeuille réussi", language: "fr"),
        "titulaireValue": Entry(source: "Titulaire: __ARG_0__", language: "fr"),
        "detailsDuPaiementValue": Entry(source: "Détails du paiement: __ARG_0__", language: "fr"),
        "jeanDupont": Entry(source: "Jean Dupont", language: "fr"),
        "banqueCentrale": Entry(source: "Banque Centrale", language: "fr"),
        "marieMartin": Entry(source: "Marie Martin", language: "fr"),
        "testTransfer": Entry(source: "Test transfer", language: "fr"),
        "transfertDeCompteVersPortefeuille": Entry(source: "Transfert de Compte vers Portefeuille", language: "fr"),
        "compteSource2": Entry(source: "Compte Source", language: "fr"),
        "selectionnerUnCompte": Entry(source: "Sélectionner un compte", language: "fr"),
        "enregistres": Entry(source: "Enregistrés", language: "fr"),
        "titulaireDuCompte": Entry(source: "Titulaire du compte", language: "fr"),
        "verificationEnCours": Entry(source: "Vérification en cours...", language: "fr"),
        "montant3": Entry(source: "Amount", language: "en", french: "Montant"),
        "entrerLeMontantGmd": Entry(source: "Entrer le montant (GMD)", language: "fr"),
        "referenceOptionnel": Entry(source: "Référence (optionnel)", language: "fr"),
        "entrerUneReference": Entry(source: "Entrer une référence", language: "fr"),
        "soumettre": Entry(source: "Soumettre", language: "en"),
        "noLinkedBankAccountsWereReturnedLinkABankAccount": Entry(source: "No linked bank accounts were returned. Link a bank account before transferring to your wallet.", language: "en"),
        "veuillezSelectionnerUnCompte": Entry(source: "Veuillez sélectionner un compte", language: "fr"),
        "enterAValidAmountGreaterThanZero": Entry(source: "Enter a valid amount greater than zero.", language: "en"),
        "confirmerLeTransfert": Entry(source: "Confirmer le Transfert", language: "fr"),
        "fraisApplicables": Entry(source: "Frais applicables", language: "fr"),
        "fraisDeRetrait": Entry(source: "Frais de retrait", language: "fr"),
        "fraisDeTransfert": Entry(source: "Frais de transfert", language: "fr"),
        "totalACrediter": Entry(source: "Total à créditer", language: "fr"),
        "compteSource3": Entry(source: "Compte source", language: "fr"),
        "compte": Entry(source: "Compte", language: "en"),
        "titulaire2": Entry(source: "Titulaire", language: "en"),
        "reference2": Entry(source: "Référence", language: "fr"),
        "entrerLeCodePin": Entry(source: "Enter PIN", language: "en", french: "Entrer le code PIN"),
        "confirmer": Entry(source: "Confirm", language: "en", french: "Confirmer"),
        "expediteur": Entry(source: "EXPÉDITEUR", language: "fr"),
        "loadingBeneficiaries": Entry(source: "Loading beneficiaries...", language: "en", french: "Chargement des bénéficiaires..."),
        "couldntLoadBeneficiaries": Entry(source: "Couldn’t load beneficiaries", language: "en", french: "Impossible de charger les bénéficiaires"),
        "tryAgain": Entry(source: "Try Again", language: "en", french: "Réessayer"),
        "noBeneficiariesYet": Entry(source: "No beneficiaries yet", language: "en", french: "Aucun bénéficiaire pour le moment"),
        "yourSavedWalletAndBankBeneficiariesWillAppearHere": Entry(source: "Your saved wallet and bank beneficiaries will appear here.", language: "en", french: "Vos bénéficiaires de portefeuille et de compte bancaire enregistrés apparaîtront ici."),
        "removeBeneficiary": Entry(source: "Remove beneficiary?", language: "en", french: "Supprimer ce bénéficiaire ?"),
        "remove": Entry(source: "Remove", language: "en", french: "Supprimer"),
        "thisBeneficiaryWillBeRemovedFromYourSavedList": Entry(source: "This beneficiary will be removed from your saved list.", language: "en", french: "Ce bénéficiaire sera supprimé de votre liste de bénéficiaires enregistrés."),
        "couldntRemoveBeneficiary": Entry(source: "Couldn’t remove beneficiary", language: "en", french: "Impossible de supprimer le bénéficiaire"),
        "addedValue": Entry(source: "Added: __ARG_0__", language: "en", french: "Ajouté le : __ARG_0__"),
        "removeBeneficiary2": Entry(source: "Remove beneficiary", language: "en", french: "Supprimer le bénéficiaire"),
        "pleaseSignInAgainToLoadYourBeneficiaries": Entry(source: "Please sign in again to load your beneficiaries.", language: "en", french: "Veuillez vous reconnecter pour charger vos bénéficiaires."),
        "unableToLoadBeneficiaries": Entry(source: "Unable to load beneficiaries.", language: "en", french: "Impossible de charger les bénéficiaires."),
        "unableToLoadBeneficiariesPleaseTryAgain": Entry(source: "Unable to load beneficiaries. Please try again.", language: "en", french: "Impossible de charger les bénéficiaires. Veuillez réessayer."),
        "beneficiaryDetailsAreIncomplete": Entry(source: "Beneficiary details are incomplete.", language: "en", french: "Les informations du bénéficiaire sont incomplètes."),
        "pleaseSignInAgainToManageBeneficiaries": Entry(source: "Please sign in again to manage beneficiaries.", language: "en", french: "Veuillez vous reconnecter pour gérer vos bénéficiaires."),
        "unableToRemoveBeneficiary": Entry(source: "Unable to remove beneficiary.", language: "en", french: "Impossible de supprimer le bénéficiaire."),
        "unableToRemoveBeneficiaryPleaseTryAgain": Entry(source: "Unable to remove beneficiary. Please try again.", language: "en", french: "Impossible de supprimer le bénéficiaire. Veuillez réessayer."),
        "billPayments": Entry(source: "Bill Payments", language: "en"),
        "directionDeLaSecuriteDouaniere": Entry(source: "Direction de la Sécurité Douanière", language: "fr"),
        "biometricSettings": Entry(source: "Biometric Settings", language: "en"),
        "activerValue": Entry(source: "Activer __ARG_0__", language: "fr"),
        "connexionRapideEtSecurisee": Entry(source: "Connexion rapide et sécurisée", language: "fr"),
        "commentCaMarche": Entry(source: "Comment ça marche", language: "fr"),
        "aLaProchaineConnexionVousVerrezLeBoutonDAuthentification": Entry(source: "À la prochaine connexion, vous verrez le bouton d'authentification biométrique", language: "fr"),
        "appuyezSurLeBoutonEtUtilisezVotreValue": Entry(source: "Appuyez sur le bouton et utilisez votre __ARG_0__", language: "fr"),
        "accedezInstantanementAVotrePortefeuille": Entry(source: "Accédez instantanément à votre portefeuille", language: "fr"),
        "laConnexionBiometriqueEstActiveePourUneConnexionRapideEt": Entry(source: "La connexion biométrique est activée pour une connexion rapide et sécurisée", language: "fr"),
        "activezLaConnexionBiometriquePourUneAuthentificationPlusRapide": Entry(source: "Activez la connexion biométrique pour une authentification plus rapide", language: "fr"),
        "confirmerPourActiverValue": Entry(source: "Confirmer pour activer __ARG_0__", language: "fr"),
        "valueActiveAvecSucces": Entry(source: "__ARG_0__ activé avec succès", language: "fr"),
        "impossibleDActiverValue": Entry(source: "Impossible d'activer __ARG_0__", language: "fr"),
        "valueDesactive": Entry(source: "__ARG_0__ désactivé", language: "fr"),
        "entrezVotrePinPourConfirmer": Entry(source: "Entrez votre PIN pour confirmer", language: "fr"),
        "changeYourPin": Entry(source: "Change your PIN", language: "en"),
        "walletInformation": Entry(source: "Wallet information", language: "en"),
        "verifyCurrentPin": Entry(source: "Verify current PIN", language: "en"),
        "enterYourCurrentPin": Entry(source: "Enter your current PIN", language: "en"),
        "pinVerified": Entry(source: "PIN verified", language: "en"),
        "verifyPin": Entry(source: "Verify PIN", language: "en"),
        "newPin": Entry(source: "New PIN", language: "en"),
        "enterYourNewPin": Entry(source: "Enter your new PIN", language: "en"),
        "confirmYourNewPin": Entry(source: "Confirm your new PIN", language: "en"),
        "confirmPinChange": Entry(source: "Confirm PIN change", language: "en"),
        "areYouSureYouWantToChangeYourPinYou": Entry(source: "Are you sure you want to change your PIN?\n\nYou will need to use the new PIN for future transactions.", language: "en"),
        "pinIsRequired": Entry(source: "PIN is required.", language: "en"),
        "pinMustContainAtLeast4Digits": Entry(source: "PIN must contain at least 4 digits.", language: "en"),
        "pleaseConfirmYourNewPin": Entry(source: "Please confirm your new PIN.", language: "en"),
        "thePinsDoNotMatch": Entry(source: "The PINs do not match.", language: "en"),
        "pinVerificationFailedCodeValue": Entry(source: "PIN verification failed. Code: __ARG_0__", language: "en"),
        "verificationSuccessful": Entry(source: "Verification successful", language: "en"),
        "yourCurrentPinHasBeenVerifiedYouCanNowSet": Entry(source: "Your current PIN has been verified. You can now set a new PIN.", language: "en"),
        "verifyYourCurrentPinFirst": Entry(source: "Verify your current PIN first.", language: "en"),
        "unableToChangePinPleaseTryAgain": Entry(source: "Unable to change PIN. Please try again.", language: "en"),
        "pinChanged": Entry(source: "PIN changed", language: "en"),
        "yourPinWasChangedSuccessfullyUseYourNewPinFor": Entry(source: "Your PIN was changed successfully. Use your new PIN for future transactions.", language: "en"),
        "loadingLimits": Entry(source: "Loading limits...", language: "en"),
        "noLimitsConfigured": Entry(source: "No limits configured", language: "en"),
        "refreshWalletLimits": Entry(source: "Refresh wallet limits", language: "en"),
        "limitsByTransaction": Entry(source: "Limits by transaction", language: "en"),
        "globalDailyLimit": Entry(source: "Global Daily Limit", language: "en"),
        "allYourTransactionsShareThisCommonDailyLimit": Entry(source: "All your transactions share this common daily limit.", language: "en"),
        "notAvailable": Entry(source: "Not available", language: "en"),
        "period": Entry(source: "Period", language: "en"),
        "transactionValue": Entry(source: "Transaction __ARG_0__", language: "fr"),
        "processingCode": Entry(source: "Processing code", language: "en"),
        "dailyUsage": Entry(source: "Daily usage", language: "fr"),
        "dailyLimitUsage": Entry(source: "Daily limit usage", language: "en"),
        "dailyLimit": Entry(source: "Daily limit", language: "en"),
        "usedToday": Entry(source: "Used today", language: "en"),
        "remainingToday": Entry(source: "Remaining today", language: "en"),
        "transactionsToday": Entry(source: "Transactions today", language: "en"),
        "canTransact": Entry(source: "Can transact", language: "en"),
        "alertLevel": Entry(source: "Alert level", language: "en"),
        "hideDetails": Entry(source: "Hide details", language: "en"),
        "viewDetails": Entry(source: "View details", language: "en"),
        "minimumPerTransaction": Entry(source: "Minimum per transaction", language: "en"),
        "maximumPerTransaction": Entry(source: "Maximum per transaction", language: "en"),
        "periodType": Entry(source: "Period type", language: "en"),
        "periodLimit": Entry(source: "Period limit", language: "en"),
        "usedThisPeriod": Entry(source: "Used this period", language: "en"),
        "remainingThisPeriod": Entry(source: "Remaining this period", language: "en"),
        "periodStarts": Entry(source: "Period starts", language: "en"),
        "periodEnds": Entry(source: "Period ends", language: "en"),
        "notProvided": Entry(source: "Not provided", language: "en", french: "Non renseigné"),
        "yourWalletDetailsAreMissingPleaseSignInAgain": Entry(source: "Your wallet details are missing. Please sign in again.", language: "en", french: "Les informations de votre portefeuille sont manquantes. Veuillez vous reconnecter."),
        "unableToLoadWalletLimitsPleaseTryAgain": Entry(source: "Unable to load wallet limits. Please try again.", language: "en"),
        "unableToLoadWalletLimitsPleaseCheckYourConnectionAnd": Entry(source: "Unable to load wallet limits. Please check your connection and try again.", language: "en"),
        "scannerQrCode": Entry(source: "Scanner QR Code", language: "en"),
        "placezLeCodeQrDansLeCadre": Entry(source: "Placez le code QR dans le cadre", language: "fr"),
        "leScanSeFeraAutomatiquement": Entry(source: "Le scan se fera automatiquement", language: "fr"),
        "dsdBills": Entry(source: "DSD Bills", language: "en"),
        "primoArrivant": Entry(source: "Primo Arrivant", language: "fr"),
        "paiementPourPrimoArrivant": Entry(source: "Paiement pour primo arrivant", language: "fr"),
        "facturesDsd": Entry(source: "Factures DSD", language: "fr"),
        "aucuneOperationEnAttente": Entry(source: "Aucune opération en attente", language: "fr"),
        "lesPaiementsDsdEnAttenteApparaitrontIci": Entry(source: "Les paiements DSD en attente apparaîtront ici", language: "fr"),
        "erreurLorsDuChargementDesPaiements": Entry(source: "Erreur lors du chargement des paiements", language: "fr"),
        "paiementValideAvecSucces": Entry(source: "Paiement validé avec succès", language: "fr"),
        "erreurLorsDeLaValidation": Entry(source: "Erreur lors de la validation", language: "fr"),
        "paiementRejeteAvecSucces": Entry(source: "Paiement rejeté avec succès", language: "fr"),
        "erreurLorsDuRejet": Entry(source: "Erreur lors du rejet", language: "fr"),
        "chassis": Entry(source: "Chassis", language: "en"),
        "montantAPayer": Entry(source: "Montant à payer", language: "fr"),
        "dateDeCreation": Entry(source: "Date de création", language: "fr"),
        "rejeter": Entry(source: "Rejeter", language: "en"),
        "approuver": Entry(source: "Approuver", language: "en"),
        "categorieA": Entry(source: "CATÉGORIE A", language: "fr"),
        "categorieB": Entry(source: "CATÉGORIE B", language: "fr"),
        "categorieC": Entry(source: "CATÉGORIE C", language: "fr"),
        "categorieD": Entry(source: "CATÉGORIE D", language: "fr"),
        "orderFoodFastLocalDelivery": Entry(source: "Order Food. Fast local delivery", language: "en"),
        "vu": Entry(source: "Vu", language: "en"),
        "sponsoriserUnPortefeuille": Entry(source: "Sponsoriser un portefeuille", language: "fr"),
        "mesLimites": Entry(source: "Mes limites", language: "fr"),
        "neManquezPasCetteOpportunite": Entry(source: "Ne manquez pas cette opportunité", language: "fr"),
        "aucuneImageDisponible": Entry(source: "Aucune image disponible", language: "fr"),
        "whatIsGambiapay": Entry(source: "What is GambiaPay?", language: "en"),
        "gambiapayIsYourSecureDigitalWalletForManagingPaymentsTransfers": Entry(source: "GambiaPay is your secure digital wallet for managing payments, transfers, and top-ups.", language: "en"),
        "howDoIRegisterForGambiapay": Entry(source: "How do I register for GambiaPay?", language: "en"),
        "downloadTheGambiapayAppFromTheAppleAppStoreOr": Entry(source: "Download the GambiaPay app from the Apple App Store or Google Play, open it, tap Sign Up, and follow the instructions.", language: "en"),
        "howDoILogInToGambiapay": Entry(source: "How do I log in to GambiaPay?", language: "en"),
        "openTheGambiapayAppEnterYourPhoneNumberAndPin": Entry(source: "Open the GambiaPay app, enter your phone number and PIN, then tap Log In.", language: "en"),
        "iForgotMyPinCodeWhatShouldIDo": Entry(source: "I forgot my PIN code. What should I do?", language: "en"),
        "contactCustomerSupportWithAValidFormOfIdentificationTo": Entry(source: "Contact customer support with a valid form of identification to answer the security questions and begin resetting your PIN.", language: "en"),
        "howDoICheckMyGambiapayWalletBalance": Entry(source: "How do I check my GambiaPay wallet balance?", language: "en"),
        "yourBalanceAppearsWhenYouLogInIfItIs": Entry(source: "Your balance appears when you log in. If it is hidden by asterisks (*), tap the eye icon to show it.", language: "en"),
        "whyDoesMyBalanceShowAsAsterisks": Entry(source: "Why does my balance show as asterisks (*)?", language: "en"),
        "yourBalanceIsHiddenForSecurityTapTheEyeIcon": Entry(source: "Your balance is hidden for security. Tap the eye icon to show it.", language: "en"),
        "howDoICheckMyTransactionHistory": Entry(source: "How do I check my transaction history?", language: "en"),
        "afterLoggingInTapSeeMoreBelowYourBalanceTo": Entry(source: "After logging in, tap See More below your balance to view your transactions from the last 30 days.", language: "en"),
        "howDoISendMoney": Entry(source: "How do I send money?", language: "en"),
        "tapInternalTransferThenFollowTheseSteps1ChooseThe": Entry(source: "Tap Internal Transfer, then follow these steps:\n1. Choose the funding source\n2. Enter the recipient's 9-digit phone number\n3. Verify the recipient\n4. Enter the amount\n5. Select Add Fees if needed\n6. Add an optional comment\n7. Review the transfer\n8. Enter your PIN\n9. Confirm the transfer.", language: "en"),
        "howDoILinkMyGambiapayWalletToMyBank": Entry(source: "How do I link my GambiaPay wallet to my bank account?", language: "en"),
        "visitABranchOfYourBankWithValidIdentificationTo": Entry(source: "Visit a branch of your bank with valid identification to request a wallet link.", language: "en"),
        "howDoIAddMoneyToMyGambiapayWalletFrom": Entry(source: "How do I add money to my GambiaPay wallet from my bank account?", language: "en"),
        "tapTopUpMyWalletThenSelectYourAccountEnter": Entry(source: "Tap Top Up My Wallet, then select your account, enter the amount, add an optional reference, review the transfer, enter your PIN, and confirm.", language: "en"),
        "howDoITransferMoneyFromMyGambiapayWalletTo": Entry(source: "How do I transfer money from my GambiaPay wallet to my bank account?", language: "en"),
        "tapToMyBankSelectYourAccountEnterTheAmount": Entry(source: "Tap To My Bank, select your account, enter the amount, add an optional reference, review the transfer, enter your PIN, and confirm.", language: "en"),
        "howOftenIsMyBalanceUpdated": Entry(source: "How often is my balance updated?", language: "en"),
        "yourBalanceUpdatesInRealTimeWheneverYouOpenOr": Entry(source: "Your balance updates in real time whenever you open or manually refresh the app.", language: "en"),
        "whatTypesOfTransfersCanIMake": Entry(source: "What types of transfers can I make?", language: "en"),
        "walletToWalletWalletToBankAccountBankAccountTo": Entry(source: "• Wallet to wallet\n• Wallet to bank account\n• Bank account to wallet\n• Mobile money through partner services", language: "en"),
        "areThereLimitsOnHowMuchICanTransfer": Entry(source: "Are there limits on how much I can transfer?", language: "en"),
        "yesLimitsDependOnYourAccountTypeAndVerificationLevel": Entry(source: "Yes. Limits depend on your account type and verification level. Contact support for details.", language: "en"),
        "howLongDoTransfersTake": Entry(source: "How long do transfers take?", language: "en"),
        "mostWalletToWalletTransfersAreInstant": Entry(source: "Most wallet-to-wallet transfers are instant.", language: "en"),
        "canIBuyPhoneCreditInTheApp": Entry(source: "Can I buy phone credit in the app?", language: "en"),
        "yesYouCanBuyPhoneCreditForYourselfOrSomeone": Entry(source: "Yes. You can buy phone credit for yourself or someone else in the app.", language: "en"),
        "canIBuyDataBundles": Entry(source: "Can I buy data bundles?", language: "en"),
        "theAppLetsYouBuyInternetBundlesForSeveralMobile": Entry(source: "The app lets you buy internet bundles for several mobile networks.", language: "en"),
        "canIPayBillsWithGambiapay": Entry(source: "Can I pay bills with GambiaPay?", language: "en"),
        "yesYouCanUseTheAppToPayUtilityAnd": Entry(source: "Yes. You can use the app to pay utility and other bills.", language: "en"),
        "whatIsACashVoucher": Entry(source: "What is a cash voucher?", language: "en"),
        "cashVouchersLetYouCreateACodeThatSomeoneElse": Entry(source: "Cash vouchers let you create a code that someone else can redeem for money.", language: "en"),
        "whatAreStandingInstructions": Entry(source: "What are standing instructions?", language: "en"),
        "theyLetYouScheduleRecurringAutomaticTransfersSuchAsMonthly": Entry(source: "They let you schedule recurring automatic transfers, such as monthly payments.", language: "en"),
        "whatAreSponsoredWallets": Entry(source: "What are sponsored wallets?", language: "en"),
        "theyLetUsersSponsorAnotherUserOrBeSponsoredTo": Entry(source: "They let users sponsor another user or be sponsored to share funds.", language: "en"),
        "whatIsASavingsWallet": Entry(source: "What is a savings wallet?", language: "en"),
        "itHelpsYouSetMoneyAsideSeparatelyFromYourMain": Entry(source: "It helps you set money aside separately from your main balance.", language: "en"),
        "howDoIViewRecentTransactions": Entry(source: "How do I view recent transactions?", language: "en"),
        "openMiniStatementFromTheMenuToSeeYourRecent": Entry(source: "Open Mini Statement from the menu to see your recent transactions.", language: "en"),
        "isMyMoneySafeInTheApp": Entry(source: "Is my money safe in the app?", language: "en"),
        "yesGambiapayUsesEncryptionAndSecurityProtocolsToHelpProtect": Entry(source: "Yes. GambiaPay uses encryption and security protocols to help protect your account.", language: "en"),
        "canIChangeMyPin": Entry(source: "Can I change my PIN?", language: "en"),
        "yesOpenTheMenuAndSelectChangePin": Entry(source: "Yes. Open the menu and select Change PIN.", language: "en"),
        "whatShouldIDoIfSomeoneAccessesMyAccountWithout": Entry(source: "What should I do if someone accesses my account without permission?", language: "en"),
        "changeYourPinImmediatelyReviewYourTransactionsAndContactSupport": Entry(source: "Change your PIN immediately, review your transactions, and contact support.", language: "en"),
        "howDoIDeactivateMyWallet": Entry(source: "How do I deactivate my wallet?", language: "en"),
        "selectDeactivateWalletFromTheMenuThisActionMayBe": Entry(source: "Select Deactivate Wallet from the menu. This action may be irreversible.", language: "en"),
        "howDoIContactCustomerSupport": Entry(source: "How do I contact customer support?", language: "en"),
        "call0612008699UseContactUsInThe": Entry(source: "• Call 0612 00 86 99\n• Use Contact Us in the app\n• Send feedback from the app menu.", language: "en"),
        "howDoIReportAProblem": Entry(source: "How do I report a problem?", language: "en"),
        "selectReportAProblemFromTheNavigationMenu": Entry(source: "Select Report a Problem from the navigation menu.", language: "en"),
        "canISendFeedbackAboutTheApp": Entry(source: "Can I send feedback about the app?", language: "en"),
        "yesSelectSendFeedbackFromTheMenu": Entry(source: "Yes. Select Send Feedback from the menu.", language: "en"),
        "theAppWonTLoadMyBalanceWhatShouldI": Entry(source: "The app won't load my balance. What should I do?", language: "en"),
        "copy1CheckYourInternetConnection2RestartTheApp3": Entry(source: "1. Check your internet connection\n2. Restart the app\n3. Tap the eye icon to refresh\n4. Contact support if the problem continues.", language: "en"),
        "iMHavingProblemsWithTransfersWhatCouldBeWrong": Entry(source: "I'm having problems with transfers. What could be wrong?", language: "en"),
        "checkYourBalanceInternetConnectionRecipientSNumberAndTransfer": Entry(source: "Check your balance, internet connection, recipient's number, and transfer limits.", language: "en"),
        "howDoIUpdateTheApp": Entry(source: "How do I update the app?", language: "en"),
        "checkTheAppStoreOrGooglePlayForTheLatest": Entry(source: "Check the App Store or Google Play for the latest version.", language: "en"),
        "theAppCrashesFrequentlyWhatShouldIDo": Entry(source: "The app crashes frequently. What should I do?", language: "en"),
        "copy1RestartYourDevice2ClearTheAppCache3": Entry(source: "1. Restart your device\n2. Clear the app cache\n3. Update the app\n4. Contact support if the problem continues.", language: "en"),
        "howDoILogOutOfTheApp": Entry(source: "How do I log out of the app?", language: "en"),
        "openTheMenuAndSelectLogOut": Entry(source: "Open the menu and select Log Out.", language: "en"),
        "canIUseTheAppOnMultipleDevices": Entry(source: "Can I use the app on multiple devices?", language: "en"),
        "yesButYouWillNeedToVerifyWithAOne": Entry(source: "Yes, but you will need to verify with a one-time password when logging in on a new device.", language: "en"),
        "whatHappensIfIUninstallTheApp": Entry(source: "What happens if I uninstall the app?", language: "en"),
        "yourFundsRemainSafeReinstallTheAppToAccessYour": Entry(source: "Your funds remain safe. Reinstall the app to access your wallet again.", language: "en"),
        "areThereFeesForUsingTheApp": Entry(source: "Are there fees for using the app?", language: "en"),
        "someTransactionsMayHaveFeesContactCustomerSupportForDetails": Entry(source: "Some transactions may have fees. Contact customer support for details.", language: "en"),
        "frequentlyAskedQuestions": Entry(source: "Frequently Asked Questions", language: "en"),
        "needHelp": Entry(source: "Need help?", language: "en"),
        "feedback": Entry(source: "Feedback", language: "en"),
        "giveYourOpinion": Entry(source: "Give your opinion", language: "en"),
        "questionsAnswers": Entry(source: "Questions & Answers", language: "en"),
        "noResultsFound": Entry(source: "No results found", language: "en"),
        "tryAnotherSearch": Entry(source: "Try another search", language: "en"),
        "needAdditionalHelp": Entry(source: "Need additional help?", language: "en"),
        "ourTeamIsAvailable247ToHelpYou": Entry(source: "Our team is available 24/7 to help you", language: "en"),
        "transactionEchouee": Entry(source: "Transaction échouée", language: "fr"),
        "debitNonAutorise": Entry(source: "Débit non autorisé", language: "fr"),
        "problemeDeSecurite": Entry(source: "Problème de sécurité", language: "fr"),
        "serviceClient": Entry(source: "Service client", language: "en"),
        "applicationDefaillante": Entry(source: "Application défaillante", language: "fr"),
        "fraisIncorrects": Entry(source: "Frais incorrects", language: "fr"),
        "problemeDeCompte": Entry(source: "Problème de compte", language: "fr"),
        "autre": Entry(source: "Autre", language: "fr"),
        "urgentPerteFinanciere": Entry(source: "🔴 Urgent - Perte financière", language: "fr"),
        "eleveServiceIndisponible": Entry(source: "🟠 Élevé - Service indisponible", language: "fr"),
        "moyenProblemeFonctionnel": Entry(source: "🟡 Moyen - Problème fonctionnel", language: "fr"),
        "faibleAmelioration": Entry(source: "🟢 Faible - Amélioration", language: "fr"),
        "smsNumeroEnregistre": Entry(source: "SMS (Numéro enregistré)", language: "fr"),
        "emailAlternatif": Entry(source: "Email (alternatif)", language: "fr"),
        "nePasMeContacter": Entry(source: "Ne pas me contacter", language: "fr"),
        "deposerUnePlainte": Entry(source: "Déposer une Plainte", language: "fr"),
        "signalerUnProbleme": Entry(source: "Signaler un problème", language: "fr"),
        "veuillezFournirAutantDeDetailsQuePossiblePourNousAider": Entry(source: "Veuillez fournir autant de détails que possible pour nous aider à résoudre votre problème rapidement.", language: "fr"),
        "typeDePlainte": Entry(source: "Type de Plainte", language: "fr"),
        "priorite": Entry(source: "Priorité", language: "fr"),
        "titre": Entry(source: "Titre", language: "en"),
        "entrerLeTitre": Entry(source: "Entrer le titre", language: "fr"),
        "description2": Entry(source: "Description", language: "en", french: "Description"),
        "valueValueCaracteres": Entry(source: "__ARG_0__/__ARG_1__ caractères", language: "fr"),
        "dateDeLIncident": Entry(source: "Date de l'incident", language: "fr"),
        "jjMmAaaa": Entry(source: "JJ/MM/AAAA", language: "fr"),
        "referenceTransactionOptionnel": Entry(source: "Référence Transaction (optionnel)", language: "fr"),
        "entrerLaReference": Entry(source: "Entrer la référence", language: "fr"),
        "methodeDeContact": Entry(source: "Méthode de Contact", language: "fr"),
        "emailAlternatif2": Entry(source: "Email Alternatif", language: "fr"),
        "entrerVotreEmail": Entry(source: "Entrer votre email", language: "fr"),
        "veuillezEntrerUnTitre": Entry(source: "Veuillez entrer un titre", language: "fr"),
        "leTitreDoitContenirAuMoins5Caracteres": Entry(source: "Le titre doit contenir au moins 5 caractères", language: "fr"),
        "veuillezDecrireVotrePlainte": Entry(source: "Veuillez décrire votre plainte", language: "fr"),
        "laDescriptionDoitContenirAuMoins20Caracteres": Entry(source: "La description doit contenir au moins 20 caractères", language: "fr"),
        "veuillezEntrerLaDateDeLIncident": Entry(source: "Veuillez entrer la date de l'incident", language: "fr"),
        "formatDEmailInvalide": Entry(source: "Format d'email invalide", language: "fr"),
        "copy2448Heures": Entry(source: "24-48 heures", language: "fr"),
        "copy23JoursOuvrables": Entry(source: "2-3 jours ouvrables", language: "fr"),
        "copy57JoursOuvrables": Entry(source: "5-7 jours ouvrables", language: "fr"),
        "copy714JoursOuvrables": Entry(source: "7-14 jours ouvrables", language: "fr"),
        "donneesInvalidesVeuillezVerifierVosInformations": Entry(source: "Données invalides. Veuillez vérifier vos informations.", language: "fr"),
        "vousAvezDeposeTropDePlaintesRecemmentVeuillezAttendre": Entry(source: "Vous avez déposé trop de plaintes récemment. Veuillez attendre.", language: "fr"),
        "erreurDuServeurVeuillezReessayerPlusTard": Entry(source: "Erreur du serveur. Veuillez réessayer plus tard.", language: "fr"),
        "confirmerLeDepotDePlainte": Entry(source: "Confirmer le dépôt de plainte", language: "fr"),
        "type2": Entry(source: "Type:", language: "en"),
        "priorite2": Entry(source: "Priorité:", language: "fr"),
        "titre2": Entry(source: "Titre:", language: "fr"),
        "resolutionEstimee": Entry(source: "Résolution estimée:", language: "fr"),
        "etesVousSurDeVouloirDeposerCettePlainte": Entry(source: "Êtes-vous sûr de vouloir déposer cette plainte?", language: "fr"),
        "deposer": Entry(source: "Déposer", language: "fr"),
        "plainteDeposee": Entry(source: "Plainte déposée", language: "fr"),
        "tempsDeResolutionEstime": Entry(source: "Temps de résolution estimé:", language: "fr"),
        "vousRecevrezUneConfirmationEtDesMisesAJourSelon": Entry(source: "Vous recevrez une confirmation et des mises à jour selon votre méthode de contact préférée.", language: "fr"),
        "foodQuality": Entry(source: "Food quality", language: "en"),
        "missingItem": Entry(source: "Missing item", language: "en"),
        "lateDelivery": Entry(source: "Late delivery", language: "en"),
        "incorrectOrder": Entry(source: "Incorrect order", language: "en"),
        "restaurantService": Entry(source: "Restaurant service", language: "en"),
        "other": Entry(source: "Other", language: "en"),
        "foodComplaints": Entry(source: "Food Complaints", language: "en"),
        "loadingComplaints": Entry(source: "Loading complaints…", language: "en"),
        "foodComplaints2": Entry(source: "Food complaints", language: "en"),
        "complaintSubmitted": Entry(source: "Complaint submitted", language: "en"),
        "noFoodComplaintsYet": Entry(source: "No food complaints yet", language: "en"),
        "ifSomethingWentWrongWithAFoodOrderTellUs": Entry(source: "If something went wrong with a food order, tell us and we’ll follow up.", language: "en"),
        "fileAFoodServiceComplaint": Entry(source: "File a food service complaint", language: "en"),
        "placeAFoodOrderFirstToFileAComplaintAbout": Entry(source: "Place a food order first to file a complaint about it.", language: "en"),
        "foodService": Entry(source: "Food service", language: "en"),
        "orderValue": Entry(source: "Order __ARG_0__", language: "en"),
        "response": Entry(source: "Response", language: "en"),
        "order": Entry(source: "Order", language: "en"),
        "selectAnOrder": Entry(source: "Select an order", language: "en"),
        "whatWentWrong": Entry(source: "What went wrong?", language: "en"),
        "complaintType": Entry(source: "Complaint type", language: "en"),
        "describeTheIssue": Entry(source: "Describe the issue", language: "en"),
        "newComplaint": Entry(source: "New complaint", language: "en"),
        "couldNotLoadFoodComplaints": Entry(source: "Could not load food complaints.", language: "en"),
        "yourComplaintHasBeenSubmitted": Entry(source: "Your complaint has been submitted.", language: "en"),
        "couldNotSubmitYourComplaint": Entry(source: "Could not submit your complaint.", language: "en"),
        "premierAcces": Entry(source: "Premier accès", language: "fr"),
        "pinExpire": Entry(source: "PIN expiré", language: "fr"),
        "changementObligatoire": Entry(source: "Changement Obligatoire", language: "fr"),
        "bienvenueVousDevezCreerVotreCodePinPourVotrePremier": Entry(source: "Bienvenue. Vous devez créer votre code PIN pour votre premier accès.", language: "fr"),
        "votreCodePinAExpireVousDevezLeModifierPour": Entry(source: "Votre code PIN a expiré. Vous devez le modifier pour continuer à utiliser l'application.", language: "fr"),
        "modifierVotreCodePin": Entry(source: "Modifier votre code PIN", language: "fr"),
        "codePinActuel": Entry(source: "Code PIN actuel", language: "fr"),
        "nouveauCodePin": Entry(source: "Nouveau code PIN", language: "fr"),
        "cePinNEstPasSecuriseVeuillezEnChoisirUn": Entry(source: "Ce PIN n'est pas sécurisé, veuillez en choisir un autre", language: "fr"),
        "confirmerLeNouveauPin": Entry(source: "Confirmer le nouveau PIN", language: "fr"),
        "changerLePin": Entry(source: "Changer le PIN", language: "fr"),
        "confirmationDeChangementDePin": Entry(source: "Confirmation de changement de PIN", language: "fr"),
        "confirmezVousLeChangementDeVotreCodePinCetteAction": Entry(source: "Confirmez-vous le changement de votre code PIN?\n\nCette action est irréversible et vous devrez utiliser le nouveau code PIN pour vos futures transactions.", language: "fr"),
        "leCodePinActuelEstRequis": Entry(source: "Le code PIN actuel est requis", language: "fr"),
        "leCodePinDoitContenirAuMoins4Chiffres": Entry(source: "Le code PIN doit contenir au moins 4 chiffres", language: "fr"),
        "leNouveauCodePinEstRequis": Entry(source: "Le nouveau code PIN est requis", language: "fr"),
        "leNouveauPinDoitEtreDifferentDeLAncien": Entry(source: "Le nouveau PIN doit être différent de l'ancien", language: "fr"),
        "ceCodePinNEstPasSecuriseEx00001111": Entry(source: "Ce code PIN n'est pas sécurisé (ex: 0000, 1111, 1234). Veuillez en choisir un autre.", language: "fr"),
        "laConfirmationDuCodePinEstRequise": Entry(source: "La confirmation du code PIN est requise", language: "fr"),
        "lesCodesPinNeCorrespondentPas": Entry(source: "Les codes PIN ne correspondent pas", language: "fr"),
        "codePinModifie": Entry(source: "Code PIN modifié", language: "fr"),
        "votreCodePinAEteModifieAvecSuccesUtilisezCe": Entry(source: "Votre code PIN a été modifié avec succès. Utilisez ce nouveau code PIN pour vos prochaines transactions.", language: "fr"),
        "erreurLorsDuChangementDePin": Entry(source: "Erreur lors du changement de PIN", language: "fr"),
        "codePinActuelIncorrect": Entry(source: "Code PIN actuel incorrect", language: "fr"),
        "conseilsDeSecurite": Entry(source: "Conseils de sécurité", language: "fr"),
        "choisissezUnCodePinUniqueEtDifficileADeviner": Entry(source: "Choisissez un code PIN unique et difficile à deviner", language: "fr"),
        "nePartagezJamaisVotreCodePinAvecPersonne": Entry(source: "Ne partagez jamais votre code PIN avec personne", language: "fr"),
        "votreCodePinExpireTousLes90JoursPourVotre": Entry(source: "Votre code PIN expire tous les 90 jours pour votre sécurité", language: "fr"),
        "evitezLesCodesSimplesComme1234Ou0000": Entry(source: "Évitez les codes simples comme 1234 ou 0000", language: "fr"),
        "nDeTelephone": Entry(source: "N° de téléphone", language: "fr"),
        "votreReponse": Entry(source: "Votre réponse", language: "fr"),
        "nouveauPin": Entry(source: "Nouveau PIN", language: "fr"),
        "confirmerPin": Entry(source: "Confirmer PIN", language: "fr"),
        "entrerOtp": Entry(source: "Entrer OTP", language: "en"),
        "retourALaConnexion": Entry(source: "Retour à la connexion", language: "fr"),
        "entrerVotreNumeroDeTelephone": Entry(source: "Entrer votre numéro de téléphone", language: "fr"),
        "questionSecrete": Entry(source: "Question secrète", language: "fr"),
        "reinitialiserPin": Entry(source: "Réinitialiser PIN", language: "fr"),
        "verifierOtp": Entry(source: "Vérifier OTP", language: "fr"),
        "saisissezVotreNumeroDeTelephoneEnregistre": Entry(source: "Saisissez votre numéro de téléphone enregistré", language: "fr"),
        "repondezAVotreQuestionDeSecuritePourVerifierVotreIdentite": Entry(source: "Répondez à votre question de sécurité pour vérifier votre identité", language: "fr"),
        "saisissezVotreNouveauCodePinA4Chiffres": Entry(source: "Saisissez votre nouveau code PIN à 4 chiffres", language: "fr"),
        "entrezLeCodeA6ChiffresEnvoyeAValue": Entry(source: "Entrez le code à 6 chiffres envoyé à __ARG_0__", language: "fr"),
        "chargementDeLaQuestion": Entry(source: "Chargement de la question...", language: "fr"),
        "questionNonDisponible": Entry(source: "Question non disponible", language: "fr"),
        "questionIdValue": Entry(source: "Question ID: __ARG_0__", language: "fr"),
        "veuillezEntrerVotreNumeroDeTelephone": Entry(source: "Veuillez entrer votre numéro de téléphone", language: "fr"),
        "veuillezRepondreAVotreQuestion": Entry(source: "Veuillez répondre à votre question", language: "fr"),
        "veuillezEntrerVotreReponse": Entry(source: "Veuillez entrer votre réponse", language: "fr"),
        "verificationReussie": Entry(source: "Vérification réussie", language: "fr"),
        "veuillezRemplirTousLesChampsPin": Entry(source: "Veuillez remplir tous les champs PIN", language: "fr"),
        "lePinDoitContenir4Chiffres": Entry(source: "Le PIN doit contenir 4 chiffres", language: "fr"),
        "lesPinsNeCorrespondentPas": Entry(source: "Les PINs ne correspondent pas", language: "fr"),
        "otpEnvoye": Entry(source: "OTP envoyé", language: "fr"),
        "pinReinitialiseAvecSucces": Entry(source: "PIN réinitialisé avec succès!", language: "fr"),
        "veuillezEntrerUnOtpA6ChiffresValide": Entry(source: "Veuillez entrer un OTP à 6 chiffres valide", language: "fr"),
        "tokenNonTrouveVeuillezRecommencer": Entry(source: "Token non trouvé. Veuillez recommencer", language: "fr"),
        "uneErreurSEstProduite": Entry(source: "Une erreur s'est produite", language: "fr"),
        "tropDeTentativesVeuillezReessayerPlusTard": Entry(source: "Trop de tentatives. Veuillez réessayer plus tard", language: "fr"),
        "votreCompteEstBloqueVeuillezContacterLeSupportClient": Entry(source: "Votre compte est bloqué. Veuillez contacter le support client", language: "fr"),
        "otpInvalideVeuillezVerifierEtReessayer": Entry(source: "OTP invalide. Veuillez vérifier et réessayer", language: "fr"),
        "reponseIncorrecteVeuillezReessayer": Entry(source: "Réponse incorrecte. Veuillez réessayer", language: "fr"),
        "linkedBankAccounts": Entry(source: "Linked Bank Accounts", language: "en"),
        "chargementEnCours": Entry(source: "Chargement en cours...", language: "fr"),
        "comptesBancairesLies": Entry(source: "Comptes bancaires liés", language: "fr"),
        "aucunCompteBancaireLieTrouve": Entry(source: "Aucun compte bancaire lié trouvé", language: "fr"),
        "erreurLorsDeLaRecuperationDesComptes": Entry(source: "Erreur lors de la récupération des comptes", language: "fr"),
        "erreurDeConnexionValue": Entry(source: "Erreur de connexion: __ARG_0__", language: "fr"),
        "soldeMisAJourValueValue": Entry(source: "Solde mis à jour: __ARG_0__ __ARG_1__", language: "fr"),
        "impossibleDeRecupererLeSolde": Entry(source: "Impossible de récupérer le solde", language: "fr"),
        "echecDeLaConnexion": Entry(source: "Échec de la connexion", language: "fr"),
        "solde": Entry(source: "Solde", language: "en"),
        "verificationDuCodePin": Entry(source: "Vérification du code PIN", language: "fr"),
        "entrezVotreCodePinPourContinuer": Entry(source: "Entrez votre code PIN pour continuer", language: "fr"),
        "verifier": Entry(source: "Vérifier", language: "fr"),
        "loanProvider": Entry(source: "Loan Provider", language: "en", french: "Organisme de prêt"),
        "selectLoanProvider": Entry(source: "Select Loan Provider", language: "en", french: "Choisir un organisme de prêt"),
        "loanAmount": Entry(source: "Loan Amount", language: "en", french: "Montant du prêt"),
        "enterAmountGmd": Entry(source: "Enter amount (GMD)", language: "en", french: "Saisir le montant (GMD)"),
        "purposeOfLoan": Entry(source: "Purpose of Loan", language: "en", french: "Objet du prêt"),
        "selectPurpose": Entry(source: "Select Purpose", language: "en", french: "Choisir un objet"),
        "repaymentPeriod": Entry(source: "Repayment Period", language: "en", french: "Durée de remboursement"),
        "selectRepaymentPeriod": Entry(source: "Select repayment period", language: "en", french: "Choisir une durée de remboursement"),
        "valueMonths": Entry(source: "__ARG_0__ months", language: "en", french: "__ARG_0__ mois"),
        "remarksOptional": Entry(source: "Remarks (optional)", language: "en", french: "Remarques (facultatif)"),
        "addANote": Entry(source: "Add a note", language: "en", french: "Ajouter une note"),
        "iAcceptTheLoanTermsConditions": Entry(source: "I accept the **Loan Terms & Conditions**", language: "en", french: "J’accepte les **conditions générales du prêt**"),
        "submitRequest": Entry(source: "SUBMIT REQUEST", language: "en", french: "ENVOYER LA DEMANDE"),
        "requestSubmitted": Entry(source: "Request submitted", language: "en", french: "Demande envoyée"),
        "loanRequest": Entry(source: "Loan request", language: "en", french: "Demande de prêt"),
        "chooseALoanProviderAndPurpose": Entry(source: "Choose a loan provider and purpose.", language: "en", french: "Choisissez un organisme de prêt et un objet."),
        "enterAValidLoanAmount": Entry(source: "Enter a valid loan amount.", language: "en", french: "Saisissez un montant de prêt valide."),
        "pleaseAcceptTheLoanTermsToContinue": Entry(source: "Please accept the loan terms to continue.", language: "en", french: "Veuillez accepter les conditions du prêt pour continuer."),
        "yourLoanRequestHasBeenReceived": Entry(source: "Your loan request has been received.", language: "en", french: "Votre demande de prêt a été reçue."),
        "all": Entry(source: "All", language: "en", french: "Tous"),
        "filterLoanRequests": Entry(source: "Filter Loan Requests", language: "en", french: "Filtrer les demandes de prêt"),
        "filterByStatusOrProvider": Entry(source: "Filter by status or provider", language: "en", french: "Filtrer par statut ou par organisme"),
        "provider": Entry(source: "Provider", language: "en", french: "Organisme"),
        "noLoanRequests": Entry(source: "No loan requests", language: "en", french: "Aucune demande de prêt"),
        "yourSubmittedLoanRequestsWillAppearHere": Entry(source: "Your submitted loan requests will appear here.", language: "en", french: "Les demandes de prêt que vous avez envoyées apparaîtront ici."),
        "loanRequests": Entry(source: "Loan requests", language: "en", french: "Demandes de prêt"),
        "loanProvider2": Entry(source: "Loan provider", language: "en", french: "Organisme de prêt"),
        "loanRequestDetails": Entry(source: "Loan Request Details", language: "en", french: "Détails de la demande de prêt"),
        "requestedAmount": Entry(source: "Requested Amount", language: "en", french: "Montant demandé"),
        "purpose": Entry(source: "Purpose", language: "en", french: "Objet"),
        "valueMonths2": Entry(source: "__ARG_0__ Months", language: "en", french: "__ARG_0__ mois"),
        "requestDate": Entry(source: "Request Date", language: "en", french: "Date de la demande"),
        "approvalDate": Entry(source: "Approval Date", language: "en", french: "Date d’approbation"),
        "remarks": Entry(source: "Remarks", language: "en", french: "Remarques"),
        "currentStatus": Entry(source: "Current Status", language: "en", french: "Statut actuel"),
        "yourRequestStatusWillUpdateAsItProgresses": Entry(source: "Your request status will update as it progresses.", language: "en", french: "Le statut de votre demande sera mis à jour au fur et à mesure de son traitement."),
        "cancelRequest": Entry(source: "Cancel request", language: "en", french: "Annuler la demande"),
        "loanDetails": Entry(source: "Loan Details", language: "en", french: "Détails du prêt"),
        "cancelThisLoanRequest": Entry(source: "Cancel this loan request?", language: "en", french: "Annuler cette demande de prêt ?"),
        "yourRequestHasBeenCancelled": Entry(source: "Your request has been cancelled.", language: "en", french: "Votre demande a été annulée."),
        "youMustHaveAnActiveGambiapayWalletAndProvideAccurate": Entry(source: "You must have an active GambiaPay wallet and provide accurate information. Each lender may apply additional eligibility checks before approving a request.", language: "en", french: "Vous devez disposer d’un portefeuille GambiaPay actif et fournir des informations exactes. Chaque prêteur peut appliquer des critères d’éligibilité supplémentaires avant d’approuver une demande."),
        "loanConditions": Entry(source: "Loan Conditions", language: "en", french: "Conditions du prêt"),
        "loanAmountsFeesInterestAndFinalApprovalAreDeterminedBy": Entry(source: "Loan amounts, fees, interest, and final approval are determined by the selected loan provider. Review the provider's offer carefully before accepting it.", language: "en", french: "Le montant du prêt, les frais, les intérêts et l’approbation finale sont déterminés par l’organisme de prêt choisi. Consultez attentivement son offre avant de l’accepter."),
        "repaymentDatesAndMethodsAreSetByTheLoanProvider": Entry(source: "Repayment dates and methods are set by the loan provider. Keep sufficient funds available and contact the provider if you need help.", language: "en", french: "Les dates et les modalités de remboursement sont fixées par l’organisme de prêt. Assurez-vous de disposer de fonds suffisants et contactez l’organisme si vous avez besoin d’aide."),
        "privacyPolicy": Entry(source: "Privacy Policy", language: "en", french: "Politique de confidentialité"),
        "informationEnteredForALoanRequestIsSharedWithThe": Entry(source: "Information entered for a loan request is shared with the selected provider to assess and process your application.", language: "en", french: "Les informations saisies pour une demande de prêt sont partagées avec l’organisme choisi afin d’évaluer et de traiter votre demande."),
        "howDoIApplyForALoan": Entry(source: "How do I apply for a loan?", language: "en", french: "Comment demander un prêt ?"),
        "chooseAProviderEnterTheAmountAndPurposeSelectA": Entry(source: "Choose a provider, enter the amount and purpose, select a repayment period, review the terms, then submit your request.", language: "en", french: "Choisissez un organisme, saisissez le montant et l’objet du prêt, sélectionnez une durée de remboursement, consultez les conditions, puis envoyez votre demande."),
        "howLongDoesApprovalTake": Entry(source: "How long does approval take?", language: "en", french: "Quel est le délai d’approbation ?"),
        "theSelectedProviderReviewsEachApplicationProcessingTimesVaryCheck": Entry(source: "The selected provider reviews each application. Processing times vary; check My Loan Requests for status updates.", language: "en", french: "L’organisme choisi examine chaque demande. Les délais de traitement varient ; consultez Mes demandes de prêt pour suivre leur statut."),
        "canICancelMyLoanRequest": Entry(source: "Can I cancel my loan request?", language: "en", french: "Puis-je annuler ma demande de prêt ?"),
        "youCanCancelARequestWhileItsStatusIsPending": Entry(source: "You can cancel a request while its status is pending or under review from the request details screen.", language: "en", french: "Vous pouvez annuler une demande depuis l’écran de ses détails tant que son statut est en attente ou en cours d’examen."),
        "howDoIRepayMyLoan": Entry(source: "How do I repay my loan?", language: "en", french: "Comment rembourser mon prêt ?"),
        "repaymentIsHandledByTheLoanProviderFollowTheRepayment": Entry(source: "Repayment is handled by the loan provider. Follow the repayment instructions and schedule they provide.", language: "en", french: "Le remboursement est géré par l’organisme de prêt. Suivez les instructions et le calendrier de remboursement qu’il vous communique."),
        "whatHappensIfIMissAPayment": Entry(source: "What happens if I miss a payment?", language: "en", french: "Que se passe-t-il si je manque une échéance ?"),
        "contactYourLoanProviderPromptlyFeesOrOtherConsequencesDepend": Entry(source: "Contact your loan provider promptly. Fees or other consequences depend on the provider's agreement.", language: "en", french: "Contactez rapidement votre organisme de prêt. Les frais et les autres conséquences éventuelles dépendent des conditions de cet organisme."),
        "canIRepayMyLoanEarly": Entry(source: "Can I repay my loan early?", language: "en", french: "Puis-je rembourser mon prêt par anticipation ?"),
        "earlyRepaymentRulesDependOnYourProviderContactThemTo": Entry(source: "Early repayment rules depend on your provider. Contact them to confirm any conditions or fees.", language: "en", french: "Les règles de remboursement anticipé dépendent de votre organisme de prêt. Contactez-le pour confirmer les conditions et les frais éventuels."),
        "loanHelp2": Entry(source: "Loan Help", language: "en", french: "Aide sur les prêts"),
        "loanTermsConditions": Entry(source: "Loan Terms & Conditions", language: "en", french: "Conditions générales des prêts"),
        "gambiapayLoanServices": Entry(source: "GambiaPay · Loan services", language: "en", french: "GambiaPay · Services de prêt"),
        "searchTermsAndFaqs": Entry(source: "Search terms and FAQs", language: "en", french: "Rechercher dans les conditions et la FAQ"),
        "acceptContinue": Entry(source: "Accept & Continue", language: "en", french: "Accepter et continuer"),
        "loanFaqs": Entry(source: "Loan FAQs", language: "en", french: "Questions fréquentes sur les prêts"),
        "versionValue": Entry(source: "Version __ARG_0__", language: "fr"),
        "biometricCredentialsNotFoundPleaseLoginWithYourPin": Entry(source: "Biometric credentials not found. Please login with your PIN.", language: "en"),
        "biometricUnavailable": Entry(source: "Biometric Unavailable", language: "en"),
        "authenticationFailed": Entry(source: "Authentication Failed", language: "en"),
        "tropDeTentativesVeuillezReessayerDansQuelquesMinutes": Entry(source: "Trop de tentatives. Veuillez réessayer dans quelques minutes.", language: "fr"),
        "limiteAtteinte": Entry(source: "Limite Atteinte", language: "fr"),
        "uneNouvelleVersionDeLApplicationEstDisponibleVeuillezMettre": Entry(source: "Une nouvelle version de l'application est disponible. Veuillez mettre à jour pour continuer.", language: "fr"),
        "votreCompteEstBloqueVeuillezContacterLeServiceClient": Entry(source: "Votre compte est bloqué. Veuillez contacter le service client.", language: "fr"),
        "compteBloque": Entry(source: "Compte Bloqué", language: "fr"),
        "codePinExpire": Entry(source: "Code PIN Expiré", language: "fr"),
        "votreCodePinAExpireVousDevezLeModifierPour2": Entry(source: "Votre code PIN a expiré. Vous devez le modifier pour continuer.", language: "fr"),
        "numeroDeTelephoneOuPinIncorrect": Entry(source: "Numéro de téléphone ou PIN incorrect.", language: "fr"),
        "erreurDeConnexion": Entry(source: "Erreur de Connexion", language: "fr"),
        "compteIntrouvableVeuillezVerifierVotreNumeroDeTelephone": Entry(source: "Compte introuvable. Veuillez vérifier votre numéro de téléphone.", language: "fr"),
        "compteIntrouvable": Entry(source: "Compte Introuvable", language: "fr"),
        "uneErreurEstSurvenue": Entry(source: "Une erreur est survenue", language: "fr"),
        "erreurReseau": Entry(source: "Erreur Réseau", language: "fr"),
        "loginFailed": Entry(source: "Login failed", language: "en"),
        "loginFailed2": Entry(source: "Login Failed", language: "en"),
        "loginErrorNoAuthenticationTokenReceived": Entry(source: "Login error: No authentication token received", language: "en"),
        "loginError": Entry(source: "Login Error", language: "en"),
        "loginErrorCouldNotSaveAuthenticationData": Entry(source: "Login error: Could not save authentication data", language: "en"),
        "activerValue2": Entry(source: "Activer __ARG_0__?", language: "fr"),
        "voulezVousUtiliserValuePourUnAccesPlusRapideEt": Entry(source: "Voulez-vous utiliser __ARG_0__ pour un accès plus rapide et plus sécurisé à votre portefeuille?", language: "fr"),
        "activer": Entry(source: "Activer", language: "en"),
        "pasMaintenant": Entry(source: "Pas maintenant", language: "fr"),
        "miniStatement": Entry(source: "Mini Statement", language: "en"),
        "dateDeDebut": Entry(source: "Start date", language: "en", french: "Date de début"),
        "dateDeFin": Entry(source: "End date", language: "en", french: "Date de fin"),
        "miniReleve": Entry(source: "Mini Relevé", language: "fr"),
        "de": Entry(source: "De", language: "en"),
        "a": Entry(source: "À", language: "fr"),
        "telechargerLeReleve": Entry(source: "Télécharger le relevé", language: "fr"),
        "laRechercheAfficheLes5DernieresTransactions": Entry(source: "La recherche affiche les 5 dernières transactions", language: "fr"),
        "aucuneTransaction": Entry(source: "Aucune transaction", language: "fr"),
        "ilNYAPasDeTransactionsPourLaPeriode": Entry(source: "Il n'y a pas de transactions pour la période sélectionnée", language: "fr"),
        "echecDeLaRecuperationDesTransactions": Entry(source: "Échec de la récupération des transactions", language: "fr"),
        "erreurDeConnexionVerifiezVotreInternet": Entry(source: "Erreur de connexion. Vérifiez votre internet.", language: "fr"),
        "releveTelechargeAvecSucces": Entry(source: "Relevé téléchargé avec succès", language: "fr"),
        "echecDuTelechargementDuReleve": Entry(source: "Échec du téléchargement du relevé", language: "fr"),
        "ref": Entry(source: "Réf:", language: "fr"),
        "solde2": Entry(source: "Solde:", language: "fr"),
        "wouldYouLikeToSaveValueForFutureMobileMoney": Entry(source: "Would you like to save __ARG_0__ for future Mobile Money transfers?", language: "en", french: "Souhaitez-vous enregistrer __ARG_0__ pour de futurs transferts Mobile Money ?"),
        "confirmMobileMoney": Entry(source: "Confirm Mobile Money", language: "en"),
        "providerDetails": Entry(source: "Provider Details", language: "en"),
        "loadingProviders": Entry(source: "Loading providers...", language: "en"),
        "selectProvider": Entry(source: "Select provider", language: "en"),
        "beneficiaryDetails": Entry(source: "Beneficiary Details", language: "en"),
        "phoneNumber2": Entry(source: "Phone number", language: "en", french: "Numéro de téléphone"),
        "beneficiaryName2": Entry(source: "Beneficiary name", language: "en"),
        "saveRecipient2": Entry(source: "Save recipient", language: "en", french: "Enregistrer le destinataire"),
        "paymentReference": Entry(source: "Payment Reference", language: "en"),
        "enterPaymentReference": Entry(source: "Enter payment reference", language: "en"),
        "noProvidersAreAvailable": Entry(source: "No providers are available.", language: "en"),
        "unableToLoadProviders": Entry(source: "Unable to load providers.", language: "en"),
        "pleaseSelectAProvider": Entry(source: "Please select a provider.", language: "en"),
        "beneficiaryPhoneNumberIsRequired": Entry(source: "Beneficiary phone number is required.", language: "en"),
        "enterAValidAmount": Entry(source: "Enter a valid amount.", language: "en"),
        "yourWalletDetailsAreUnavailablePleaseSignInAgain": Entry(source: "Your wallet details are unavailable. Please sign in again.", language: "en"),
        "theReceiverWasFoundButVerificationCouldNotBeCompleted": Entry(source: "The receiver was found, but verification could not be completed. Please try again.", language: "en"),
        "receiverPhoneNumberWasNotFoundForTheSelectedProvider": Entry(source: "Receiver phone number was not found for the selected provider.", language: "en"),
        "unableToVerifyTheReceiverPhoneNumber": Entry(source: "Unable to verify the receiver phone number.", language: "en"),
        "mobileMoneyTransferFailed": Entry(source: "Mobile Money transfer failed.", language: "en"),
        "mobileMoneyTransferCouldNotBeConfirmedCheckTransactionHistory": Entry(source: "Mobile Money transfer could not be confirmed. Check transaction history before trying again.", language: "en"),
        "enterABeneficiaryPhoneNumberBeforeSaving": Entry(source: "Enter a beneficiary phone number before saving.", language: "en"),
        "recipientSaved": Entry(source: "Recipient saved", language: "en"),
        "theRecipientHasBeenSaved": Entry(source: "The recipient has been saved.", language: "en"),
        "unableToSaveTheBeneficiary": Entry(source: "Unable to save the beneficiary.", language: "en"),
        "votrePortefeuilleDigitalSecurise": Entry(source: "Votre portefeuille digital sécurisé", language: "fr"),
        "transfert": Entry(source: "TRANSFERT", language: "fr"),
        "transfererDeLArgent": Entry(source: "Transférer de l'argent", language: "fr"),
        "walletVersMaBanque": Entry(source: "Wallet vers ma Banque", language: "fr"),
        "banqueVersMonWallet": Entry(source: "Banque vers mon Wallet", language: "fr"),
        "virementsPermanents": Entry(source: "Virements Permanents", language: "fr"),
        "afficherMesParrains": Entry(source: "Afficher mes parrains", language: "fr"),
        "demandeDeMiniReleve": Entry(source: "Demande de mini-relevé", language: "fr"),
        "desactiverMonCompte": Entry(source: "Désactiver mon compte", language: "fr"),
        "transactionAValider": Entry(source: "Transaction à valider", language: "fr"),
        "comptesBancaires": Entry(source: "Comptes Bancaires", language: "fr"),
        "parametre": Entry(source: "PARAMETRE", language: "en"),
        "changerLeCodePin": Entry(source: "Changer le code PIN", language: "fr"),
        "connexionBiometrique": Entry(source: "Connexion biométrique", language: "fr"),
        "ecrireUnCommentaire": Entry(source: "Écrire un commentaire", language: "fr"),
        "declarerUnIncident": Entry(source: "Déclarer un incident", language: "fr"),
        "wouldYouLikeToSaveValueForFutureVoucherTransfers": Entry(source: "Would you like to save __ARG_0__ for future voucher transfers?", language: "en", french: "Souhaitez-vous enregistrer __ARG_0__ pour de futurs transferts par bon ?"),
        "miseADisposition": Entry(source: "Mise à Disposition", language: "fr"),
        "recipientName2": Entry(source: "Recipient name", language: "en"),
        "idNumber": Entry(source: "ID Number", language: "en"),
        "ajouterLesFraisDeRetrait": Entry(source: "Ajouter les frais de retrait", language: "fr"),
        "feeValue": Entry(source: "Fee: __ARG_0__", language: "en"),
        "aucunFraisApplicable": Entry(source: "Aucun frais applicable", language: "fr"),
        "enterAnAmountToSeeTheFee": Entry(source: "Enter an amount to see the fee", language: "en"),
        "veuillezSelectionnerUnPortefeuilleSponsor": Entry(source: "Veuillez sélectionner un portefeuille sponsor", language: "fr"),
        "amountExceedsTheSponsorSDailyLimit": Entry(source: "Amount exceeds the sponsor's daily limit", language: "en"),
        "recipientPhoneNumberIsRequired": Entry(source: "Recipient phone number is required", language: "en"),
        "enterAValidAmount2": Entry(source: "Enter a valid amount", language: "en"),
        "impossibleDeCalculerLesFraisValue": Entry(source: "Impossible de calculer les frais: __ARG_0__", language: "fr"),
        "erreurReseauLorsDuCalculDesFrais": Entry(source: "Erreur réseau lors du calcul des frais", language: "fr"),
        "voucherTransferFailedValue": Entry(source: "Voucher transfer failed: __ARG_0__", language: "en"),
        "recipientDetailsAreUnavailableSoTheVoucherRecipientCouldNot": Entry(source: "Recipient details are unavailable, so the voucher recipient could not be saved.", language: "en"),
        "theVoucherRecipientHasBeenSaved": Entry(source: "The voucher recipient has been saved.", language: "en"),
        "unableToSaveTheVoucherRecipient": Entry(source: "Unable to save the voucher recipient.", language: "en"),
        "transferConfirmation": Entry(source: "Transfer Confirmation", language: "en"),
        "loadingProfile": Entry(source: "Loading profile...", language: "en", french: "Chargement du profil..."),
        "profileUnavailable": Entry(source: "Profile unavailable", language: "en", french: "Profil indisponible"),
        "personalInformation": Entry(source: "Personal Information", language: "en", french: "Informations personnelles"),
        "customerName": Entry(source: "Customer name", language: "en", french: "Nom du client"),
        "firstName": Entry(source: "First name", language: "en", french: "Prénom"),
        "familyName": Entry(source: "Family name", language: "en", french: "Nom de famille"),
        "email": Entry(source: "Email", language: "en", french: "Adresse e-mail"),
        "address": Entry(source: "Address", language: "en", french: "Adresse"),
        "walletInformation2": Entry(source: "Wallet Information", language: "en", french: "Informations du portefeuille"),
        "walletNumber2": Entry(source: "Wallet number", language: "en", french: "Numéro de portefeuille"),
        "walletType": Entry(source: "Wallet type", language: "en", french: "Type de portefeuille"),
        "walletStatus": Entry(source: "Wallet status", language: "en", french: "Statut du portefeuille"),
        "kycLevel": Entry(source: "KYC level", language: "en", french: "Niveau de vérification d’identité"),
        "registrationDate": Entry(source: "Registration date", language: "en", french: "Date d’inscription"),
        "bankCode": Entry(source: "Bank code", language: "en", french: "Code banque"),
        "identification": Entry(source: "Identification", language: "en", french: "Identification"),
        "nationalId": Entry(source: "National ID", language: "en", french: "Pièce d’identité nationale"),
        "documentCode": Entry(source: "Document code", language: "en", french: "Code du document"),
        "nextOfKin": Entry(source: "Next of Kin", language: "en", french: "Proche à contacter"),
        "refreshProfile": Entry(source: "Refresh profile", language: "en", french: "Actualiser le profil"),
        "unableToLoadYourProfilePleaseTryAgain": Entry(source: "Unable to load your profile. Please try again.", language: "en", french: "Impossible de charger votre profil. Veuillez réessayer."),
        "unableToLoadYourProfilePleaseCheckYourConnectionAnd": Entry(source: "Unable to load your profile. Please check your connection and try again.", language: "en", french: "Impossible de charger votre profil. Vérifiez votre connexion, puis réessayez."),
        "myQrCode": Entry(source: "My QR Code", language: "en"),
        "generationDuCodeQr": Entry(source: "Génération du code QR...", language: "fr"),
        "aucunCodeQrDisponible": Entry(source: "Aucun code QR disponible", language: "fr"),
        "enregistrer": Entry(source: "Enregistrer", language: "en"),
        "partager": Entry(source: "Partager", language: "en"),
        "commentCaMarche2": Entry(source: "Comment ça marche?", language: "fr"),
        "copy1MontrezOuEnvoyezCeCodeQrALaPersonne": Entry(source: "1. Montrez ou envoyez ce code QR à la personne qui souhaite vous transférer\n\n2. Elle scanne le code avec son application\n\n3. Elle entre le montant et confirme\n\n4. Vous recevez instantanément l'argent!", language: "fr"),
        "numeroDeTelephoneNonTrouve": Entry(source: "Numéro de téléphone non trouvé", language: "fr"),
        "donneesQrManquantes": Entry(source: "Données QR manquantes", language: "fr"),
        "donneesQrVides": Entry(source: "Données QR vides", language: "fr"),
        "erreurGenerationImageQr": Entry(source: "Erreur génération image QR", language: "fr"),
        "aucunCodeQrAEnregistrer": Entry(source: "Aucun code QR à enregistrer", language: "fr"),
        "codeQrEnregistreDansLaGalerie": Entry(source: "Code QR enregistré dans la galerie!", language: "fr"),
        "foodHistory2": Entry(source: "Food History", language: "en"),
        "findingRestaurants": Entry(source: "Finding restaurants…", language: "en"),
        "orderFood2": Entry(source: "Order food", language: "en"),
        "orderPlaced": Entry(source: "Order placed", language: "en"),
        "restaurantsNearYou": Entry(source: "Restaurants near you", language: "en"),
        "myOrders": Entry(source: "My orders", language: "en"),
        "noRestaurantsAreAvailableRightNow": Entry(source: "No restaurants are available right now.", language: "en"),
        "restaurant": Entry(source: "Restaurant", language: "en"),
        "openNow": Entry(source: "Open now", language: "en"),
        "checkAvailability": Entry(source: "Check availability", language: "en"),
        "loadingMenu": Entry(source: "Loading menu…", language: "en"),
        "valueItems": Entry(source: "__ARG_0__ items", language: "en"),
        "thisRestaurantHasNoMenuItemsAvailable": Entry(source: "This restaurant has no menu items available.", language: "en"),
        "menuItem": Entry(source: "Menu item", language: "en"),
        "deliverTo": Entry(source: "Deliver to", language: "en"),
        "chooseDeliveryAddress": Entry(source: "Choose delivery address", language: "en"),
        "addAddress": Entry(source: "Add address", language: "en"),
        "deliveryAddress": Entry(source: "Delivery address", language: "en"),
        "addNewAddress": Entry(source: "Add new address", language: "en"),
        "placingOrder": Entry(source: "Placing order…", language: "en"),
        "placeOrderGmdValue": Entry(source: "Place order · GMD __ARG_0__", language: "en"),
        "labelHomeWork": Entry(source: "Label (Home, Work…)", language: "en"),
        "streetAddress": Entry(source: "Street address", language: "en"),
        "apartmentSuiteOptional": Entry(source: "Apartment, suite (optional)", language: "en"),
        "city": Entry(source: "City", language: "en"),
        "yourOrdersWillAppearHere": Entry(source: "Your orders will appear here.", language: "en"),
        "getHelp": Entry(source: "Get help", language: "en"),
        "tellUsWhatHappened": Entry(source: "Tell us what happened", language: "en"),
        "contactSupport": Entry(source: "Contact support", language: "en"),
        "send": Entry(source: "Send", language: "en"),
        "couldNotLoadRestaurants": Entry(source: "Could not load restaurants.", language: "en"),
        "couldNotLoadTheMenu": Entry(source: "Could not load the menu.", language: "en"),
        "couldNotCancelThisOrder": Entry(source: "Could not cancel this order.", language: "en"),
        "yourMessageHasBeenSent": Entry(source: "Your message has been sent.", language: "en"),
        "couldNotSendYourMessage": Entry(source: "Could not send your message.", language: "en"),
        "yourOrderHasBeenReceived": Entry(source: "Your order has been received.", language: "en"),
        "couldNotPlaceYourOrder": Entry(source: "Could not place your order.", language: "en"),
        "couldNotSaveThisAddress": Entry(source: "Could not save this address.", language: "en"),
        "verifiezVotreAppareil": Entry(source: "Vérifiez votre appareil", language: "fr"),
        "entrezLeCodeOtpEnvoyeAValue": Entry(source: "Entrez le code OTP envoyé à __ARG_0__", language: "fr"),
        "otpVerificationFailed": Entry(source: "OTP verification failed", language: "en"),
        "loadingTransactions2": Entry(source: "Loading transactions…", language: "en"),
        "waitingForYourApproval": Entry(source: "Waiting for your approval", language: "en"),
        "noPendingTransactions": Entry(source: "No pending transactions", language: "en"),
        "youreAllCaughtUp": Entry(source: "You’re all caught up.", language: "en"),
        "couldNotLoadPendingTransactions": Entry(source: "Could not load pending transactions.", language: "en"),
        "transactionValueSuccessfully": Entry(source: "Transaction __ARG_0__ successfully.", language: "en"),
        "couldNotUpdateTransactionValue": Entry(source: "Could not update transaction: __ARG_0__", language: "en"),
        "fees": Entry(source: "Fees", language: "en"),
        "tax": Entry(source: "Tax", language: "en"),
        "reject": Entry(source: "Reject", language: "en"),
        "approve": Entry(source: "Approve", language: "en"),
        "codePinRequis": Entry(source: "Code PIN requis", language: "fr"),
        "entrezVotreCodePinPourValueLaTransaction": Entry(source: "Entrez votre code PIN pour __ARG_0__ la transaction", language: "fr"),
        "reference3": Entry(source: "Référence:", language: "fr"),
        "entrezVotreCodePin": Entry(source: "Entrez votre code PIN", language: "fr"),
        "leCodePinEstObligatoire": Entry(source: "Le code PIN est obligatoire", language: "fr"),
        "codeQrInvalide": Entry(source: "Code QR invalide", language: "en"),
        "qrInvalideOuExpire": Entry(source: "QR invalide ou expiré", language: "fr"),
        "erreurDeValidation": Entry(source: "Erreur de validation", language: "fr"),
        "qrExpireOuInvalide": Entry(source: "QR expiré ou invalide", language: "fr"),
        "impossibleDeCalculerLesFrais": Entry(source: "Impossible de calculer les frais", language: "fr"),
        "erreurLorsDuCalculDesFraisValue": Entry(source: "Erreur lors du calcul des frais: __ARG_0__", language: "fr"),
        "paymentToValue": Entry(source: "Payment to __ARG_0__", language: "en"),
        "paiementEchoueValue": Entry(source: "Paiement échoué: __ARG_0__", language: "fr"),
        "erreurReseau2": Entry(source: "Erreur réseau", language: "fr"),
        "merchantPayment": Entry(source: "Merchant Payment", language: "en"),
        "chooseScanMethod": Entry(source: "Choose Scan Method", language: "en"),
        "camera": Entry(source: "Camera", language: "en"),
        "scanNow": Entry(source: "Scan now", language: "en"),
        "gallery": Entry(source: "Gallery", language: "en"),
        "fromPhotos": Entry(source: "From photos", language: "en"),
        "quickTip": Entry(source: "Quick Tip", language: "en"),
        "scanTheQrCodeDisplayedAtTheMerchantLocationTo": Entry(source: "Scan the QR code displayed at the merchant location to complete your payment", language: "en"),
        "paiementQrCodeEmv": Entry(source: "Paiement QR Code EMV", language: "fr"),
        "permissionCameraRequise": Entry(source: "Permission caméra requise", language: "fr"),
        "activezLaCameraDansLesReglages": Entry(source: "Activez la caméra dans les réglages", language: "fr"),
        "aucunQrDetecte": Entry(source: "Aucun QR détecté", language: "fr"),
        "choosePhotoSource": Entry(source: "Choose photo source", language: "en"),
        "chooseHowToAddThePhoto": Entry(source: "Choose how to add the photo", language: "en"),
        "camera2": Entry(source: "📷 Camera", language: "en"),
        "photoLibrary": Entry(source: "📁 Photo Library", language: "en"),
        "stepValueOfValue": Entry(source: "Step __ARG_0__ of __ARG_1__", language: "en"),
        "enterYourPersonalInformation": Entry(source: "Enter your personal information", language: "en"),
        "basicInformation": Entry(source: "Basic Information", language: "en"),
        "firstName2": Entry(source: "First Name*", language: "en"),
        "lastName": Entry(source: "Last Name*", language: "en"),
        "phoneNumber3": Entry(source: "Phone Number*", language: "en"),
        "email2": Entry(source: "Email*", language: "en"),
        "dateOfBirth": Entry(source: "Date of Birth*", language: "en"),
        "gender": Entry(source: "Gender*", language: "en"),
        "male": Entry(source: "Male", language: "en"),
        "female": Entry(source: "Female", language: "en"),
        "selectYourGender": Entry(source: "Select your gender", language: "en"),
        "nationalId2": Entry(source: "National ID*", language: "en"),
        "chooseABranch": Entry(source: "Choose a branch", language: "en"),
        "residentialAddress": Entry(source: "Residential Address*", language: "en"),
        "security": Entry(source: "Security", language: "en"),
        "secretQuestion": Entry(source: "Secret Question*", language: "fr"),
        "selectAQuestion": Entry(source: "Select a question", language: "en"),
        "yourAnswer": Entry(source: "Your Answer*", language: "en"),
        "nextOfKin2": Entry(source: "Next Of Kin", language: "en"),
        "nextOfKinName": Entry(source: "Next Of Kin Name*", language: "en"),
        "nextOfKinPhone": Entry(source: "Next Of Kin Phone*", language: "en"),
        "createYourPinCode": Entry(source: "Create Your PIN Code", language: "en"),
        "thisPinCodeWillSecureYourAccountAndConfirmYour": Entry(source: "This PIN code will secure your account and confirm your transactions.", language: "en"),
        "enterYour4DigitPinCode": Entry(source: "Enter your 4-digit PIN code", language: "en"),
        "confirmYourPinCode": Entry(source: "Confirm your PIN code", language: "en"),
        "chooseALessPredictablePin": Entry(source: "Choose a less predictable PIN", language: "en"),
        "pinLooksSecure": Entry(source: "PIN looks secure", language: "en"),
        "pinsMustMatch": Entry(source: "PINs must match", language: "en"),
        "scanYourIdentificationDocuments": Entry(source: "Scan your identification documents", language: "en"),
        "toValidateYourAccountScanTheRequestedDocumentsMakeSure": Entry(source: "To validate your account, scan the requested documents. Make sure each image is clear and readable.", language: "en"),
        "personalPhoto": Entry(source: "Personal Photo", language: "en"),
        "takeAWellLitPhotoOfYourFaceWithoutGlasses": Entry(source: "Take a well-lit photo of your face without glasses or a hat, against a plain background.", language: "en"),
        "takeAPhoto": Entry(source: "Take a Photo", language: "en"),
        "retakePhoto": Entry(source: "Retake Photo", language: "en"),
        "frontOfIdCard": Entry(source: "Front of ID Card", language: "en"),
        "makeSureAllInformationIsClearlyVisibleAndThePhoto": Entry(source: "Make sure all information is clearly visible and the photo is not reflective.", language: "en"),
        "takeFrontPhoto": Entry(source: "Take Front Photo", language: "en"),
        "retakeFront": Entry(source: "Retake Front", language: "en"),
        "backOfIdCard": Entry(source: "Back of ID Card", language: "en"),
        "makeSureAllInformationIsClearlyVisibleAndTheDocument": Entry(source: "Make sure all information is clearly visible and the document is complete.", language: "en"),
        "takeBackPhoto": Entry(source: "Take Back Photo", language: "en"),
        "retakeBack": Entry(source: "Retake Back", language: "en"),
        "documentsCapturedValue3": Entry(source: "Documents captured: __ARG_0__/3", language: "en"),
        "allDocumentsAreCapturedYouCanContinue": Entry(source: "All documents are captured. You can continue.", language: "en"),
        "pleaseReviewAndAcceptTheTermsToContinue": Entry(source: "Please review and accept the terms to continue.", language: "en"),
        "definitions2": Entry(source: "Definitions", language: "en"),
        "object": Entry(source: "Object", language: "en"),
        "serviceFeatures": Entry(source: "Service Features", language: "en"),
        "iAgreeToTheProcessingOfMyPersonalDataUnder": Entry(source: "I agree to the processing of my personal data under the privacy policy", language: "en"),
        "verifyYourPhoneNumber": Entry(source: "Verify your phone number", language: "en"),
        "enterTheVerificationCodeSentToValue": Entry(source: "Enter the verification code sent to __ARG_0__", language: "en"),
        "verificationCode": Entry(source: "Verification Code", language: "en"),
        "enterTheVerificationCode": Entry(source: "Enter the verification code", language: "en"),
        "enterThe6DigitVerificationCode": Entry(source: "Enter the 6-digit verification code.", language: "en"),
        "didnTReceiveTheCodePleaseContactSupport": Entry(source: "Didn't receive the code? Please contact support.", language: "en"),
        "yourPhone": Entry(source: "your phone", language: "en"),
        "enterYourFirstName": Entry(source: "Enter your first name.", language: "en"),
        "enterYourLastName": Entry(source: "Enter your last name.", language: "en"),
        "enterExactly10DigitsIncludingTheCountryCode": Entry(source: "Enter exactly 10 digits, including the country code.", language: "en"),
        "enterYourEmailAddress": Entry(source: "Enter your email address.", language: "en"),
        "selectYourDateOfBirth": Entry(source: "Select your date of birth.", language: "en"),
        "selectMaleOrFemale": Entry(source: "Select Male or Female.", language: "en"),
        "chooseYourNationality": Entry(source: "Choose your nationality.", language: "en"),
        "enterTheNumberShownOnYourId": Entry(source: "Enter the number shown on your ID.", language: "en"),
        "chooseABranch2": Entry(source: "Choose a branch.", language: "en"),
        "enterYourResidentialAddress": Entry(source: "Enter your residential address.", language: "en"),
        "selectASecurityQuestion": Entry(source: "Select a security question.", language: "en"),
        "enterAnAnswerToYourSecurityQuestion": Entry(source: "Enter an answer to your security question.", language: "en"),
        "enterYourNextOfKinSName": Entry(source: "Enter your next of kin's name.", language: "en"),
        "couldNotIdentifyThisDevicePleaseRestartTheAppAnd": Entry(source: "Could not identify this device. Please restart the app and try again.", language: "en"),
        "yourPinMustContainExactly4Digits": Entry(source: "Your PIN must contain exactly 4 digits.", language: "en"),
        "chooseALessPredictablePinSuchAsOneWithoutRepeated": Entry(source: "Choose a less predictable PIN, such as one without repeated or sequential digits.", language: "en"),
        "confirmYour4DigitPin": Entry(source: "Confirm your 4-digit PIN.", language: "en"),
        "felicitations": Entry(source: "Félicitations!", language: "fr"),
        "votreCompteAEteCreeAvecSucces": Entry(source: "Votre compte a été créé avec succès.", language: "fr"),
        "goToLogin": Entry(source: "Go to Login", language: "en"),
        "sierraLeonean": Entry(source: "Sierra Leonean", language: "en"),
        "quelEstLeNomDeVotreAnimalDeCompagnie": Entry(source: "Quel est le nom de votre animal de compagnie ?", language: "fr"),
        "dansQuelleVilleEtesVousNeE": Entry(source: "Dans quelle ville êtes-vous né(e) ?", language: "fr"),
        "quelEstLeNomDeJeuneFilleDeVotreMere": Entry(source: "Quel est le nom de jeune fille de votre mère ?", language: "fr"),
        "quelEtaitLeNomDeVotrePremiereEcole": Entry(source: "Quel était le nom de votre première école ?", language: "fr"),
        "quelEstVotreLivrePrefere": Entry(source: "Quel est votre livre préféré ?", language: "fr"),
        "veuillezCapturerTousLesDocumentsRequis": Entry(source: "Veuillez capturer tous les documents requis", language: "fr"),
        "veuillezAccepterLesConditionsPourContinuer": Entry(source: "Veuillez accepter les conditions pour continuer", language: "fr"),
        "erreurLorsDeLaConversionDeLImage": Entry(source: "Erreur lors de la conversion de l'image", language: "fr"),
        "registrationSucceededButNoVerificationCodeWasReturnedPleaseContact": Entry(source: "Registration succeeded but no verification code was returned. Please contact support.", language: "en"),
        "registrationFailedInvalidData": Entry(source: "Registration failed: Invalid data", language: "en"),
        "sessionExpiredPleaseRestartRegistration": Entry(source: "Session expired, please restart registration", language: "en"),
        "registrationFailed": Entry(source: "Registration failed", language: "en"),
        "incorrectOtpPleaseTryAgain": Entry(source: "Incorrect OTP, please try again", language: "en"),
        "nationality": Entry(source: "Nationality*", language: "en"),
        "chooseANationality": Entry(source: "Choose a nationality", language: "en"),
        "rechercherUneNationalite": Entry(source: "Rechercher une nationalité...", language: "fr"),
        "aucuneNationaliteTrouvee": Entry(source: "Aucune nationalité trouvée", language: "fr"),
        "savedRecipients": Entry(source: "Saved recipients", language: "en"),
        "loadingSavedRecipients": Entry(source: "Loading saved recipients...", language: "en"),
        "noSavedRecipients": Entry(source: "No saved recipients", language: "en"),
        "noMatchingRecipients": Entry(source: "No matching recipients", language: "en"),
        "savedRecipient": Entry(source: "Saved recipient", language: "en"),
        "pleaseSignInAgainToLoadSavedRecipients": Entry(source: "Please sign in again to load saved recipients.", language: "en"),
        "unableToLoadSavedRecipients": Entry(source: "Unable to load saved recipients.", language: "en"),
        "unableToLoadSavedRecipientsPleaseTryAgain": Entry(source: "Unable to load saved recipients. Please try again.", language: "en"),
        "selectASavedVoucherRecipient": Entry(source: "Select a saved voucher recipient", language: "en"),
        "selectASavedMobileMoneyRecipient": Entry(source: "Select a saved mobile money recipient", language: "en"),
        "selectARecentRecipient": Entry(source: "Select a recent recipient", language: "en"),
        "savedVoucherRecipientsWillAppearHere": Entry(source: "Saved voucher recipients will appear here.", language: "en"),
        "savedMobileMoneyRecipientsWillAppearHere": Entry(source: "Saved mobile money recipients will appear here.", language: "en"),
        "savedBankAccountsWillAppearHere": Entry(source: "Saved bank accounts will appear here.", language: "en"),
        "noSavedAccounts": Entry(source: "No saved accounts", language: "en"),
        "linkedBankAccountsWillAppearHere": Entry(source: "Linked bank accounts will appear here.", language: "en"),
        "noMatchingAccounts": Entry(source: "No matching accounts", language: "en"),
        "noSavedWalletRecipients": Entry(source: "No saved wallet recipients", language: "en"),
        "nameOrRecipientNumber": Entry(source: "Name or recipient number", language: "en"),
        "savedRecipients2": Entry(source: "Saved Recipients", language: "en"),
        "toSavings": Entry(source: "To Savings", language: "en", french: "Vers l'épargne"),
        "fromSavings": Entry(source: "From Savings", language: "en"),
        "savingsWalletBalance": Entry(source: "Savings wallet balance", language: "en"),
        "currentBalance": Entry(source: "Current Balance", language: "en"),
        "interestAcquired": Entry(source: "Interest Acquired", language: "en"),
        "fundTransfer": Entry(source: "Fund Transfer", language: "en"),
        "enterAmount": Entry(source: "Enter Amount", language: "en"),
        "transferReason": Entry(source: "Transfer reason", language: "en"),
        "transfer": Entry(source: "Transfer", language: "en"),
        "noRecentSavingsTransactions": Entry(source: "No recent savings transactions", language: "en"),
        "refValue2": Entry(source: "Ref: __ARG_0__", language: "fr"),
        "verifyYourTransactionDetails": Entry(source: "Verify your transaction details", language: "en"),
        "amount3": Entry(source: "AMOUNT", language: "en"),
        "recipientInformation": Entry(source: "RECIPIENT INFORMATION", language: "en"),
        "mainWallet": Entry(source: "Main wallet", language: "en"),
        "authentication": Entry(source: "AUTHENTICATION", language: "en"),
        "pinCode": Entry(source: "PIN Code", language: "en"),
        "enterYourPinToContinue": Entry(source: "Enter your PIN to continue.", language: "en"),
        "pinVerificationFailedPleaseTryAgain": Entry(source: "PIN verification failed. Please try again.", language: "en"),
        "transferCompletedSuccessfully": Entry(source: "Transfer completed successfully.", language: "en"),
        "transferCouldNotBeCompletedPleaseTryAgain": Entry(source: "Transfer could not be completed. Please try again.", language: "en"),
        "pdfPortableDocument": Entry(source: "PDF (Portable Document)", language: "fr"),
        "excelSpreadsheet": Entry(source: "Excel (Spreadsheet)", language: "en"),
        "csvCommaSeparatedValues": Entry(source: "CSV (Comma Separated Values)", language: "en"),
        "statementOptions": Entry(source: "Statement Options", language: "en"),
        "selectPeriod": Entry(source: "Select Period", language: "en"),
        "selectFormat": Entry(source: "Select Format", language: "en"),
        "generateStatement": Entry(source: "Generate Statement", language: "en"),
        "theSavingsAccountStatementWillBeGeneratedAndSentTo": Entry(source: "The savings account statement will be generated and sent to the email address associated with your account. Please check your inbox after clicking the ‘Generate Statement’ button.", language: "en"),
        "savingsStatement2": Entry(source: "Savings statement", language: "en"),
        "yourStatementHasBeenRequestedCheckYourEmail": Entry(source: "Your statement has been requested. Check your email.", language: "en"),
        "unableToGenerateTheStatement": Entry(source: "Unable to generate the statement.", language: "en"),
        "interfaceUtilisateur": Entry(source: "Interface utilisateur", language: "fr"),
        "fonctionnalites": Entry(source: "Fonctionnalités", language: "fr"),
        "securite": Entry(source: "Security", language: "en", french: "Sécurité"),
        "suggestionDAmelioration": Entry(source: "Suggestion d'amélioration", language: "fr"),
        "felicitations2": Entry(source: "Félicitations", language: "fr"),
        "commentairesSuggestions": Entry(source: "Commentaires & Suggestions", language: "fr"),
        "envoiEnCours": Entry(source: "Envoi en cours...", language: "fr"),
        "commentaireEnvoye": Entry(source: "Commentaire envoyé", language: "fr"),
        "votreCommentaireAEteEnvoyeAvecSuccesMerciPourVotre": Entry(source: "Votre commentaire a été envoyé avec succès! Merci pour votre retour.", language: "fr"),
        "nousValorisonsVosRetours": Entry(source: "Nous valorisons vos retours", language: "fr"),
        "partagezVosCommentairesSuggestionsOuFelicitationsPourNousAiderA": Entry(source: "Partagez vos commentaires, suggestions ou félicitations pour nous aider à améliorer nos services.", language: "fr"),
        "categorie": Entry(source: "Catégorie", language: "fr"),
        "sujet": Entry(source: "Sujet", language: "en"),
        "entrerLeSujet": Entry(source: "Entrer le sujet", language: "fr"),
        "commentaire": Entry(source: "Commentaire", language: "en"),
        "emailOptionnel": Entry(source: "Email (optionnel)", language: "fr"),
        "envoyer": Entry(source: "Envoyer", language: "en"),
        "veuillezEntrerUnSujet": Entry(source: "Veuillez entrer un sujet", language: "fr"),
        "veuillezEntrerVotreCommentaire": Entry(source: "Veuillez entrer votre commentaire", language: "fr"),
        "leCommentaireDoitContenirAuMoins10Caracteres": Entry(source: "Le commentaire doit contenir au moins 10 caractères", language: "fr"),
        "confirmerLEnvoi": Entry(source: "Confirmer l'envoi", language: "fr"),
        "categorie2": Entry(source: "Catégorie:", language: "fr"),
        "sujet2": Entry(source: "Sujet:", language: "fr"),
        "etesVousSurDeVouloirEnvoyerCeCommentaire": Entry(source: "Êtes-vous sûr de vouloir envoyer ce commentaire?", language: "fr"),
        "sponsorAWallet": Entry(source: "Sponsor a Wallet", language: "en"),
        "processing2": Entry(source: "Processing…", language: "en"),
        "authentication2": Entry(source: "Authentication", language: "en"),
        "numeroDeTelephone": Entry(source: "Numéro de Téléphone", language: "fr"),
        "recipientNumber2": Entry(source: "Recipient Number", language: "en"),
        "dailyLimit2": Entry(source: "Daily Limit", language: "en"),
        "monthlyLimit": Entry(source: "Monthly Limit", language: "en"),
        "dateAdjusted": Entry(source: "Date adjusted", language: "en"),
        "theEndDateWasMovedAfterTheStartDate": Entry(source: "The end date was moved after the start date.", language: "en"),
        "theVerifiedNumberDoesNotMatchTheNumberEntered": Entry(source: "The verified number does not match the number entered.", language: "en"),
        "recipientInformationIsUnavailable": Entry(source: "Recipient information is unavailable.", language: "en"),
        "walletNotFound": Entry(source: "Wallet not found.", language: "en"),
        "requiredRequestDetailsAreMissing": Entry(source: "Required request details are missing.", language: "en"),
        "incorrectPin": Entry(source: "Incorrect PIN.", language: "en"),
        "pinIsBlocked": Entry(source: "PIN is blocked.", language: "en"),
        "userIsNotAuthorized": Entry(source: "User is not authorized.", language: "en"),
        "verificationFailedCodeValue": Entry(source: "Verification failed. Code: __ARG_0__", language: "en"),
        "recipientPhoneNumberIsRequired2": Entry(source: "Recipient phone number is required.", language: "en"),
        "dailyLimitIsRequired": Entry(source: "Daily limit is required.", language: "en"),
        "monthlyLimitIsRequired": Entry(source: "Monthly limit is required.", language: "en"),
        "enterValidLimitAmounts": Entry(source: "Enter valid limit amounts.", language: "en"),
        "monthlyLimitMustBeAtLeastTheDailyLimit": Entry(source: "Monthly limit must be at least the daily limit.", language: "en"),
        "walletSponsoredSuccessfully": Entry(source: "Wallet sponsored successfully.", language: "en"),
        "couldNotSponsorThisWallet": Entry(source: "Could not sponsor this wallet.", language: "en"),
        "success": Entry(source: "Success", language: "en"),
        "unlinkWallet": Entry(source: "Unlink Wallet", language: "en"),
        "unlink": Entry(source: "Unlink", language: "en"),
        "areYouSureYouWantToUnlinkTheWalletFor": Entry(source: "Are you sure you want to unlink the wallet for __ARG_0__?\n\nThis action cannot be undone.", language: "en"),
        "sponsorAWallet2": Entry(source: "Sponsor a wallet", language: "en"),
        "enterYourPinToConfirm": Entry(source: "Enter your PIN to confirm", language: "en"),
        "loadingWallets": Entry(source: "Loading wallets…", language: "en"),
        "noSponsoredWallets": Entry(source: "No sponsored wallets", language: "en"),
        "youHaveNotSponsoredAnyWalletsYet": Entry(source: "You have not sponsored any wallets yet.", language: "en"),
        "unableToLoadWallets": Entry(source: "Unable to load wallets", language: "en"),
        "notSpecified": Entry(source: "Not specified", language: "en"),
        "walletUnlinkedSuccessfully": Entry(source: "Wallet unlinked successfully", language: "en"),
        "failedToUnlinkWallet": Entry(source: "Failed to unlink wallet", language: "en"),
        "sponsoredWallet": Entry(source: "Sponsored wallet", language: "en"),
        "walletOptions": Entry(source: "Wallet options", language: "en"),
        "monthlyLimit2": Entry(source: "Monthly limit", language: "en"),
        "validity": Entry(source: "Validity", language: "en"),
        "options": Entry(source: "Options", language: "en"),
        "noLimit": Entry(source: "No limit", language: "en"),
        "valueToValue": Entry(source: "__ARG_0__ to __ARG_1__", language: "en"),
        "fromValue": Entry(source: "From __ARG_0__", language: "en"),
        "startDateNotSpecified": Entry(source: "Start date not specified", language: "en"),
        "toValue": Entry(source: " to __ARG_0__", language: "en"),
        "noEndDate": Entry(source: " - No end date", language: "en"),
        "pleaseEnterYourPin": Entry(source: "Please enter your PIN", language: "en"),
        "noSponsoringWalletsFound": Entry(source: "No sponsoring wallets found.", language: "en"),
        "walletsSponsoringYou": Entry(source: "Wallets sponsoring you", language: "en"),
        "walletInformationIsUnavailable": Entry(source: "Wallet information is unavailable.", language: "en"),
        "checkYourInternetConnection": Entry(source: "Check your internet connection.", language: "en"),
        "miseAJourDeLaLimitePourValue": Entry(source: "Mise à jour de la limite pour __ARG_0__", language: "fr"),
        "fonctionnaliteDeDissociationAImplementer": Entry(source: "Fonctionnalité de dissociation à implémenter", language: "fr"),
        "validUntilValue": Entry(source: "Valid until: __ARG_0__", language: "en"),
        "daily": Entry(source: "Daily", language: "en"),
        "monthly": Entry(source: "Monthly", language: "en"),
        "portefeuilleVersPortefeuille": Entry(source: "Portefeuille vers Portefeuille", language: "fr"),
        "createStandingInstruction": Entry(source: "Create Standing Instruction", language: "en", french: "Créer un virement permanent"),
        "creerUnVirementPermanent": Entry(source: "Créer un Virement Permanent", language: "fr"),
        "typeDeTransaction": Entry(source: "Transaction Type", language: "en", french: "Type de Transaction"),
        "detailsDuDestinataire": Entry(source: "Recipient Details", language: "en", french: "Détails du Destinataire"),
        "codeBanque": Entry(source: "Code banque", language: "fr"),
        "entrerLeMontantGnf": Entry(source: "Entrer le montant (GNF)", language: "fr"),
        "entrerUneDescription": Entry(source: "Enter a description", language: "en", french: "Entrer une description"),
        "planification": Entry(source: "Schedule", language: "en", french: "Planification"),
        "creer": Entry(source: "Créer", language: "fr"),
        "nDeCompte": Entry(source: "N° de compte", language: "fr"),
        "nDeTelephoneMobile": Entry(source: "N° de téléphone mobile", language: "fr"),
        "nDeCompteDEpargne": Entry(source: "Savings account number", language: "en", french: "N° de compte d'épargne"),
        "verificationNonDisponiblePourCeType": Entry(source: "Vérification non disponible pour ce type", language: "fr"),
        "leCodeBanqueEstRequis": Entry(source: "Le code banque est requis", language: "fr"),
        "verificationDeCompteNonImplementee": Entry(source: "Vérification de compte non implémentée", language: "fr"),
        "verificationMobileMoneyNonImplementee": Entry(source: "Vérification mobile money non implémentée", language: "fr"),
        "laDestinationEstRequise": Entry(source: "Destination is required", language: "en", french: "La destination est requise"),
        "veuillezDAbordVerifierLeDestinataire": Entry(source: "Please verify the recipient first", language: "en", french: "Veuillez d'abord vérifier le destinataire"),
        "laDateDeDebutDoitEtreAvantLaDateDe": Entry(source: "The start date must be before the end date", language: "en", french: "La date de début doit être avant la date de fin"),
        "laDateDeFinNePeutPasEtreDansLe": Entry(source: "The end date cannot be in the past", language: "en", french: "La date de fin ne peut pas être dans le passé"),
        "virementPermanentCreeAvecSucces": Entry(source: "Standing instruction created successfully", language: "en", french: "Virement permanent créé avec succès"),
        "veuillezEntrerVotrePin": Entry(source: "Please enter your PIN", language: "en", french: "Veuillez entrer votre PIN"),
        "termine": Entry(source: "Done", language: "en", french: "Terminé"),
        "vousNAvezAucunVirementPermanent": Entry(source: "You have no standing instructions", language: "en", french: "Vous n'avez aucun virement permanent"),
        "creerUnVirement": Entry(source: "Create a standing instruction", language: "en", french: "Créer un virement"),
        "numeroDeTelephoneNonDisponible": Entry(source: "Phone number unavailable", language: "en", french: "Numéro de téléphone non disponible"),
        "virementPermanentSupprimeAvecSucces": Entry(source: "Standing instruction deleted successfully", language: "en", french: "Virement permanent supprimé avec succès"),
        "frequence": Entry(source: "Frequency:", language: "en", french: "Fréquence:"),
        "prochaineDate": Entry(source: "Prochaine date:", language: "fr"),
        "description3": Entry(source: "Description:", language: "en"),
        "modifier": Entry(source: "Edit", language: "en", french: "Modifier"),
        "supprimer": Entry(source: "Delete", language: "en", french: "Supprimer"),
        "confirmerLaSuppression": Entry(source: "Confirm deletion", language: "en", french: "Confirmer la suppression"),
        "entrezVotreCodePinPourSupprimerCeVirementPermanent": Entry(source: "Enter your PIN to delete this standing instruction", language: "en", french: "Entrez votre code PIN pour supprimer ce virement permanent"),
        "editStandingInstruction": Entry(source: "Edit Standing Instruction", language: "en", french: "Modifier le virement permanent"),
        "modifierLeVirement": Entry(source: "Edit Standing Instruction", language: "en", french: "Modifier le Virement"),
        "detailsDuBeneficiaire": Entry(source: "Beneficiary Details", language: "en", french: "Détails du Bénéficiaire"),
        "detailsDePaiement": Entry(source: "Payment Details", language: "en", french: "Détails de Paiement"),
        "entrerLeMontant": Entry(source: "Enter amount", language: "en", french: "Entrer le montant"),
        "devise": Entry(source: "Currency", language: "en", french: "Devise"),
        "dateDeFinOptionnel": Entry(source: "End date (optional)", language: "en", french: "Date de fin (optionnel)"),
        "entrerVotrePin": Entry(source: "Enter your PIN", language: "en", french: "Entrer votre PIN"),
        "laDescriptionEstRequise": Entry(source: "Description is required", language: "en", french: "La description est requise"),
        "leCodePinEstRequis": Entry(source: "PIN is required", language: "en", french: "Le code PIN est requis"),
        "instructionMiseAJourAvecSucces": Entry(source: "Standing instruction updated successfully", language: "en", french: "Instruction mise à jour avec succès"),
        "updateSponsoredWallet": Entry(source: "Update Sponsored Wallet", language: "en"),
        "mettreAJourLesLimites": Entry(source: "Mettre à jour les limites", language: "fr"),
        "beneficiaireValue": Entry(source: "Bénéficiaire: __ARG_0__", language: "fr"),
        "limiteJournaliere": Entry(source: "Limite journalière", language: "fr"),
        "limiteMensuelle": Entry(source: "Limite mensuelle", language: "fr"),
        "periode": Entry(source: "Période", language: "fr"),
        "confirmerLaMiseAJour": Entry(source: "Confirmer la mise à jour", language: "fr"),
        "confirmerLaMiseAJourDesLimitesPourValue": Entry(source: "Confirmer la mise à jour des limites pour __ARG_0__?", language: "fr"),
        "limiteJournaliere2": Entry(source: "Limite journalière:", language: "fr"),
        "limiteMensuelle2": Entry(source: "Limite mensuelle:", language: "fr"),
        "periode2": Entry(source: "Période:", language: "fr"),
        "dateAjustee": Entry(source: "Date ajustée", language: "fr"),
        "laDateDeFinAEteAjusteePourEtrePosterieure": Entry(source: "La date de fin a été ajustée pour être postérieure à la date de début", language: "fr"),
        "laLimiteJournaliereEstRequise": Entry(source: "La limite journalière est requise", language: "fr"),
        "laLimiteMensuelleEstRequise": Entry(source: "La limite mensuelle est requise", language: "fr"),
        "montantsInvalides": Entry(source: "Montants invalides", language: "fr"),
        "laLimiteMensuelleDoitEtreSuperieureOuEgaleALa": Entry(source: "La limite mensuelle doit être supérieure ou égale à la limite journalière", language: "fr"),
        "laDateDeFinDoitEtreApresLaDateDe": Entry(source: "La date de fin doit être après la date de début", language: "fr"),
        "miseAJourReussie": Entry(source: "Mise à jour réussie", language: "fr"),
        "echecDeLaMiseAJour": Entry(source: "Update failed", language: "en", french: "Échec de la mise à jour"),
        "moneyVoucherSentSuccessfully": Entry(source: "Money voucher sent successfully", language: "en"),
        "availabilityFee": Entry(source: "Availability fee", language: "en"),
        "voucherFee": Entry(source: "Voucher fee", language: "en"),
        "notVerified": Entry(source: "Not verified", language: "en"),
        "moneyVoucher2": Entry(source: "Money voucher", language: "en"),
        "recuDeMiseADisposition": Entry(source: "Reçu de Mise à Disposition", language: "fr"),
        "recuDeMiseADisposition2": Entry(source: "REÇU DE MISE À DISPOSITION", language: "fr"),
        "statutMiseADispositionGeneree": Entry(source: "Statut: Mise à disposition générée", language: "fr"),
        "codeVoucherValue": Entry(source: "Code Voucher: __ARG_0__", language: "en"),
        "emetteur": Entry(source: "ÉMETTEUR", language: "fr"),
        "destinataire": Entry(source: "DESTINATAIRE", language: "en"),
        "nonVerifie": Entry(source: "Non vérifié", language: "fr"),
        "instructions": Entry(source: "INSTRUCTIONS:", language: "en"),
        "leDestinatairePeutRetirerCesFondsAvecLeCode": Entry(source: "Le destinataire peut retirer ces fonds avec le code", language: "fr"),
        "voucherDansNImporteQuelPointDeService": Entry(source: "voucher dans n'importe quel point de service.", language: "fr"),
        "recuDeMiseADispositionStatutMiseADispositionGeneree": Entry(source: "REÇU DE MISE À DISPOSITION\n\nStatut: Mise à disposition générée\nCode Voucher: __ARG_0__\nID Transaction: __ARG_1__\nDate: __ARG_2__\n\nMontant: __ARG_3__\nFrais: __ARG_4__\nTotal débité: __ARG_5__\n\nÉMETTEUR\nNom: __ARG_6__\nTéléphone: __ARG_7__\n\nDESTINATAIRE\nNom: __ARG_8__\nTéléphone: __ARG_9__\n\nDétails: __ARG_10__\n\nINSTRUCTIONS:\nLe destinataire peut retirer ces fonds avec le code voucher dans n'importe quel point de service.\n\nCe reçu a été généré automatiquement.", language: "fr"),
        "selectionnerUneRaison": Entry(source: "Sélectionner une raison", language: "fr"),
        "jeNUtilisePlusLeService": Entry(source: "Je n'utilise plus le service", language: "fr"),
        "problemesDeSecurite": Entry(source: "Problèmes de sécurité", language: "fr"),
        "interfaceDifficileAUtiliser": Entry(source: "Interface difficile à utiliser", language: "fr"),
        "fraisTropEleves": Entry(source: "Frais trop élevés", language: "fr"),
        "serviceClientInsatisfaisant": Entry(source: "Service client insatisfaisant", language: "fr"),
        "changementDeSituationFinanciere": Entry(source: "Changement de situation financière", language: "fr"),
        "autreRaison": Entry(source: "Autre raison", language: "fr"),
        "desactivationDuPortefeuille": Entry(source: "Désactivation du Portefeuille", language: "fr"),
        "fermezDefinitivementVotrePortefeuilleEtTransferezVotreSolde": Entry(source: "Fermez définitivement votre portefeuille et transférez votre solde", language: "fr"),
        "raisonDeLaDesactivation": Entry(source: "Raison de la Désactivation", language: "fr"),
        "selectionnezLaRaisonPrincipale": Entry(source: "Sélectionnez la raison principale", language: "fr"),
        "detailsSupplementairesMax50Caracteres": Entry(source: "Détails supplémentaires (max 50 caractères)", language: "fr"),
        "methodeDeTransfertDuSolde": Entry(source: "Méthode de Transfert du Solde", language: "fr"),
        "choisissezCommentRecevoirVotreSoldeRestant": Entry(source: "Choisissez comment recevoir votre solde restant", language: "fr"),
        "compteBancaire": Entry(source: "Compte bancaire", language: "fr"),
        "autrePortefeuilleMobile": Entry(source: "Autre portefeuille mobile", language: "fr"),
        "retraitEnAgence": Entry(source: "Retrait en agence", language: "fr"),
        "numeroDeTelephoneDuDestinataire": Entry(source: "Numéro de téléphone du destinataire", language: "fr"),
        "nomDuTitulaire": Entry(source: "Nom du titulaire", language: "fr"),
        "compteBancaireLie": Entry(source: "Compte bancaire lié", language: "fr"),
        "chargementDesComptes": Entry(source: "Chargement des comptes...", language: "fr"),
        "nomDuTitulaireDuCompte": Entry(source: "Nom du titulaire du compte", language: "fr"),
        "agenceDeRetrait": Entry(source: "Agence de retrait", language: "fr"),
        "chargementDesAgences": Entry(source: "Chargement des agences...", language: "fr"),
        "selectionnerUneAgence": Entry(source: "Sélectionner une agence", language: "fr"),
        "vousPourrezRetirerVotreSoldeDirectementEnAgenceAvecUne": Entry(source: "💡 Vous pourrez retirer votre solde directement en agence avec une pièce d'identité", language: "fr"),
        "confirmationDeSecurite": Entry(source: "Confirmation de Sécurité", language: "fr"),
        "entrezVotreCodePinPourConfirmerLaDesactivationDefinitiveDe": Entry(source: "Entrez votre code PIN pour confirmer la désactivation définitive de votre portefeuille", language: "fr"),
        "informationsImportantes": Entry(source: "Informations Importantes", language: "fr"),
        "leSoldeRestantSeraTransfereVersLeDestinataireChoisi": Entry(source: "• Le solde restant sera transféré vers le destinataire choisi", language: "fr"),
        "votrePortefeuilleSeraDefinitivementFerme": Entry(source: "• Votre portefeuille sera définitivement fermé", language: "fr"),
        "cetteActionNePeutPasEtreAnnulee": Entry(source: "• Cette action ne peut pas être annulée", language: "fr"),
        "vousDevrezCreerUnNouveauComptePourUtiliserNosServices": Entry(source: "• Vous devrez créer un nouveau compte pour utiliser nos services", language: "fr"),
        "unCodeOtpSeraEnvoyePourConfirmationFinale": Entry(source: "• Un code OTP sera envoyé pour confirmation finale", language: "fr"),
        "desactiverLePortefeuille": Entry(source: "Désactiver le Portefeuille", language: "fr"),
        "leNumeroVerifieNeCorrespondPasAuNumeroSaisi": Entry(source: "Le numéro vérifié ne correspond pas au numéro saisi", language: "fr"),
        "informationDuDestinataireNonDisponible": Entry(source: "Information du destinataire non disponible", language: "fr"),
        "portefeuilleNonTrouve": Entry(source: "Portefeuille non trouvé", language: "fr"),
        "codePinIncorrect": Entry(source: "Code PIN incorrect", language: "en"),
        "codePinBloque": Entry(source: "Code PIN bloqué", language: "fr"),
        "utilisateurNonAutorise": Entry(source: "Utilisateur non autorisé", language: "fr"),
        "aucuneAgenceTrouvee": Entry(source: "Aucune agence trouvée", language: "fr"),
        "veuillezSelectionnerUneRaisonDeDesactivation": Entry(source: "Veuillez sélectionner une raison de désactivation", language: "fr"),
        "veuillezPreciserLaRaisonDeDesactivation": Entry(source: "Veuillez préciser la raison de désactivation", language: "fr"),
        "veuillezSelectionnerUneMethodeDeTransfert": Entry(source: "Veuillez sélectionner une méthode de transfert", language: "fr"),
        "veuillezSaisirLeNumeroDuDestinataire": Entry(source: "Veuillez saisir le numéro du destinataire", language: "fr"),
        "veuillezSelectionnerUneAgence": Entry(source: "Veuillez sélectionner une agence", language: "fr"),
        "branchCashOutValue": Entry(source: "Branch Cash Out - __ARG_0__", language: "en"),
        "erreurLorsDeLaDesactivationDuPortefeuille": Entry(source: "Erreur lors de la désactivation du portefeuille", language: "fr"),
        "veuillezSaisirLeCodeOtp": Entry(source: "Veuillez saisir le code OTP", language: "fr"),
        "leCodeOtpDoitContenirExactement6Chiffres": Entry(source: "Le code OTP doit contenir exactement 6 chiffres", language: "fr"),
        "codeOtpInvalideVeuillezReessayer": Entry(source: "Code OTP invalide. Veuillez réessayer.", language: "fr"),
        "confirmationDeDesactivation": Entry(source: "Confirmation de Désactivation", language: "fr"),
        "etesVousSurDeVouloirDesactiverDefinitivementVotrePortefeuilleCette": Entry(source: "Êtes-vous sûr de vouloir désactiver définitivement votre portefeuille ?\n\nCette action est irréversible et votre compte sera fermé.", language: "fr"),
        "ouiDesactiver": Entry(source: "Oui, Désactiver", language: "fr"),
        "verificationOtp": Entry(source: "Vérification OTP", language: "fr"),
        "unCodeDeVerificationAEteEnvoyeAVotreNumero": Entry(source: "Un code de vérification a été envoyé à votre numéro. Veuillez saisir le code pour confirmer la désactivation.", language: "fr"),
        "codeOtp": Entry(source: "Code OTP", language: "en"),
        "demandeEnvoyee": Entry(source: "Demande Envoyée", language: "fr"),
        "votreDemandeDeDesactivationAEteTransmiseAvecSuccesLe": Entry(source: "Votre demande de désactivation a été transmise avec succès.\n\nLe solde restant sera transféré selon vos instructions.\n\nMerci d'avoir utilisé nos services.", language: "fr"),
        "entrezUnMontantPourVoirLesFrais": Entry(source: "Entrez un montant pour voir les frais", language: "fr"),
        "paiementQrCode": Entry(source: "Paiement QR Code", language: "fr"),
        "paiementA": Entry(source: "Paiement à", language: "fr"),
        "calculEnCours": Entry(source: "Calcul en cours...", language: "fr"),
        "fraisDePaiementQr": Entry(source: "Frais de paiement QR", language: "fr"),
        "fraisValueGmd": Entry(source: "Frais: __ARG_0__ GMD", language: "fr"),
        "montantDesFraisManquant": Entry(source: "Montant des frais manquant", language: "fr"),
        "erreurDeCalcul": Entry(source: "Erreur de calcul", language: "fr"),
        "biometric": Entry(source: "Biometric", language: "en"),
        "biometricAuthenticationIsNotAvailableOnThisDevice": Entry(source: "Biometric authentication is not available on this device", language: "en"),
        "noBiometricDataEnrolledPleaseSetUpFaceIdTouch": Entry(source: "No biometric data enrolled. Please set up Face ID, Touch ID, or Optic ID in Settings", language: "en"),
        "authenticationFailedPleaseTryAgain": Entry(source: "Authentication failed. Please try again", language: "en"),
        "authenticationCancelled": Entry(source: "Authentication cancelled", language: "en"),
        "userChoseToUsePin": Entry(source: "User chose to use PIN", language: "en"),
        "authenticationCancelledBySystem": Entry(source: "Authentication cancelled by system", language: "en"),
        "devicePasscodeNotSetPleaseSetUpAPasscodeFirst": Entry(source: "Device passcode not set. Please set up a passcode first", language: "en"),
        "biometricAuthenticationIsLockedDueToTooManyFailedAttempts": Entry(source: "Biometric authentication is locked due to too many failed attempts", language: "en"),
        "valueIsAvailable": Entry(source: "__ARG_0__ is available", language: "en"),
        "biometricAuthenticationIsNotAvailable": Entry(source: "Biometric authentication is not available", language: "en"),
        "authenticateToAccessYourWallet": Entry(source: "Authenticate to access your wallet", language: "en"),
        "usePin": Entry(source: "Use PIN", language: "en"),
        "unknownError2": Entry(source: "Unknown error", language: "en"),
        "valider": Entry(source: "Valider", language: "en"),
        "confirmerLaValidation": Entry(source: "Confirmer la validation", language: "fr"),
        "voulezVousVraimentValiderCePaiementDsd": Entry(source: "Voulez-vous vraiment valider ce paiement DSD?", language: "fr"),
        "continuer": Entry(source: "Continuer", language: "en"),
        "confirmerLeRejet": Entry(source: "Confirmer le rejet", language: "fr"),
        "voulezVousVraimentRejeterCePaiementDsdCetteActionEst": Entry(source: "Voulez-vous vraiment rejeter ce paiement DSD? Cette action est irréversible.", language: "fr"),
        "paiementCodeQrEmv": Entry(source: "Paiement Code QR EMV", language: "fr"),
        "ceCodeQrAExpire": Entry(source: "Ce code QR a expiré", language: "fr"),
        "fraisDeRetrait2": Entry(source: "Frais de retrait:", language: "fr"),
        "totalADebiter2": Entry(source: "Total à débiter:", language: "fr"),
        "destinataire2": Entry(source: "Destinataire", language: "en"),
        "nom2": Entry(source: "Nom", language: "en"),
        "portefeuille2": Entry(source: "Portefeuille", language: "fr"),
        "diamabankSa": Entry(source: "DIAMABANK SA", language: "fr"),
        "expireLe": Entry(source: "Expire le", language: "fr"),
        "payer": Entry(source: "Payer", language: "en"),
        "leCodePinDoitContenir4Chiffres": Entry(source: "Le code PIN doit contenir 4 chiffres", language: "fr"),
        "echecDeLaValidationCodeValue": Entry(source: "Échec de la validation. Code: __ARG_0__", language: "fr"),
        "paiementReussi": Entry(source: "Paiement réussi", language: "fr"),
        "montant4": Entry(source: "Montant :", language: "fr"),
        "emetteur2": Entry(source: "Émetteur:", language: "fr"),
        "destinataire3": Entry(source: "Destinataire:", language: "fr"),
        "idDestinataire": Entry(source: "ID Destinataire:", language: "fr"),
        "recuDePaiementQr": Entry(source: "Reçu de paiement QR", language: "fr"),
        "recuDePaiementQrEmv": Entry(source: "Reçu de Paiement QR EMV", language: "fr"),
        "recuDePaiementQrEmv2": Entry(source: "REÇU DE PAIEMENT QR EMV", language: "fr"),
        "statutPaiementReussi": Entry(source: "Statut: Paiement réussi", language: "fr"),
        "fraisDEnvoiValue": Entry(source: "Frais d'envoi: __ARG_0__", language: "fr"),
        "fraisDeRetraitValue": Entry(source: "Frais de retrait: __ARG_0__", language: "fr"),
        "marchand": Entry(source: "MARCHAND", language: "en"),
        "idMarchandValue": Entry(source: "ID Marchand: __ARG_0__", language: "en"),
        "ceRecuAEteGenereAutomatiquement": Entry(source: "Ce reçu a été généré automatiquement.", language: "fr"),
        "fraisDEnvoiValue2": Entry(source: "Frais d'envoi: __ARG_0__\n", language: "fr"),
        "fraisDeRetraitValue2": Entry(source: "Frais de retrait: __ARG_0__\n", language: "fr"),
        "nomValueTypeValuePortefeuilleValue": Entry(source: "Nom: __ARG_0__\nType: __ARG_1__\nPortefeuille: __ARG_2__", language: "fr"),
        "idMarchandValue2": Entry(source: "\nID Marchand: __ARG_0__", language: "en"),
        "banqueValue2": Entry(source: "\nBanque: __ARG_0__", language: "fr"),
        "recuDePaiementQrEmvStatutPaiementReussiIdTransaction": Entry(source: "REÇU DE PAIEMENT QR EMV\n\nStatut: Paiement réussi\nID Transaction: __ARG_0__\nDate: __ARG_1__\n\nMontant: __ARG_2__\n__ARG_3__Total débité: __ARG_4__\n\nÉMETTEUR\nNom: __ARG_5__\nTéléphone: __ARG_6__\n\nMARCHAND\n__ARG_7__\n\n__ARG_8__\nCe reçu a été généré automatiquement.", language: "fr"),
        "confirmerLaMiseADisposition": Entry(source: "Confirmer la Mise à Disposition", language: "fr"),
        "mobileMoneyFee": Entry(source: "Mobile Money fee", language: "en"),
        "fraisDeMiseADisposition": Entry(source: "Frais de mise à disposition", language: "fr"),
        "totalToDebit2": Entry(source: "Total to Debit", language: "en"),
        "recipientInformation2": Entry(source: "Recipient Information", language: "en"),
        "sourceDesFonds2": Entry(source: "Source des fonds", language: "fr"),
        "portefeuilleSponsor": Entry(source: "Portefeuille Sponsor", language: "fr"),
        "pending": Entry(source: "Pending", language: "en", french: "En attente"),
        "underReview": Entry(source: "Under review", language: "en", french: "En cours d’examen"),
        "approved": Entry(source: "Approved", language: "en", french: "Approuvé"),
        "rejected": Entry(source: "Rejected", language: "en", french: "Refusé"),
        "cancelled": Entry(source: "Cancelled", language: "en", french: "Annulé"),
        "failed": Entry(source: "Failed", language: "en", french: "Échoué"),
        "expired": Entry(source: "Expired", language: "en", french: "Expiré"),
        "ordered": Entry(source: "Ordered", language: "en"),
        "accepted": Entry(source: "Accepted", language: "en", french: "Accepté"),
        "preparing": Entry(source: "Preparing", language: "en"),
        "ready": Entry(source: "Ready", language: "en"),
        "outForDelivery": Entry(source: "Out for delivery", language: "en"),
        "delivered": Entry(source: "Delivered", language: "en"),
        "completed": Entry(source: "Completed", language: "en"),
        "weekly": Entry(source: "Weekly", language: "en"),
        "yearly": Entry(source: "Yearly", language: "en"),
        "quotidien": Entry(source: "Daily", language: "en", french: "Quotidien"),
        "hebdomadaire": Entry(source: "Weekly", language: "en", french: "Hebdomadaire"),
        "mensuel": Entry(source: "Monthly", language: "en", french: "Mensuel"),
        "annuel": Entry(source: "Yearly", language: "en", french: "Annuel"),
        "detailsValue3": Entry(source: "Détails: __ARG_0__\n", language: "fr"),
        "calcul": Entry(source: "Calcul...", language: "fr"),
        "impossibleDeChargerLesComptes": Entry(source: "Impossible de charger les comptes", language: "en"),
        "chargement": Entry(source: "Loading...", language: "en", french: "Chargement..."),
        "echecDeLaSuppression": Entry(source: "Deletion failed", language: "en", french: "Échec de la suppression"),
        "confirmation": Entry(source: "Confirmation", language: "en"),
        "verificationEchouee": Entry(source: "Vérification échouée", language: "fr"),
        "echecDeLaCreation": Entry(source: "Creation failed", language: "en", french: "Échec de la création"),
        "search": Entry(source: "Search...", language: "en", french: "Rechercher..."),
        "valueValue": Entry(source: "__ARG_0__  •  __ARG_1__", language: "en"),
        "valueValue2": Entry(source: "__ARG_0__ · __ARG_1__", language: "en"),
        "miseADispositionDeFonds": Entry(source: "Mise à disposition de fonds", language: "fr"),
        "registration": Entry(source: "Registration", language: "en"),
        "loading": Entry(source: "Loading...", language: "en"),
        "submitted": Entry(source: "Submitted", language: "en"),
        "inProgress": Entry(source: "In progress", language: "en"),
        "resolved": Entry(source: "Resolved", language: "en"),
        "closed": Entry(source: "Closed", language: "en"),
        "confirmed": Entry(source: "Confirmed", language: "en"),
        "appareilNonSecurise": Entry(source: "⚠️ Appareil Non Sécurisé", language: "fr"),
        "votreAppareilSembleEtreJailbreakePourVotreSecuriteDiamacash": Entry(source: "Votre appareil semble être jailbreaké. Pour votre sécurité, GambiaPay ne peut pas fonctionner sur des appareils compromis.\n\nVeuillez utiliser un appareil iOS sécurisé.", language: "fr"),
        "enterTheNumberShownOnYourNationalId": Entry(source: "Enter the number shown on your National ID.", language: "en"),
        "walletDetailsAreMissingPleaseSignInAgain": Entry(source: "Wallet details are missing. Please sign in again.", language: "en"),
        "invalidUrl": Entry(source: "Invalid URL", language: "en"),
        "invalidResponse": Entry(source: "Invalid response", language: "en"),
        "donneesInvalides": Entry(source: "Données invalides", language: "fr"),
        "nonAutorise": Entry(source: "Non autorisé", language: "fr"),
        "erreurDuServeur": Entry(source: "Erreur du serveur", language: "fr"),
        "tropDePlaintesRecentes": Entry(source: "Trop de plaintes récentes", language: "fr"),
        "noDataReceived": Entry(source: "No data received", language: "en"),
        "invalidResponseFormat": Entry(source: "Invalid response format", language: "en"),
        "sessionExpired2": Entry(source: "Session expired", language: "en"),
        "serverError": Entry(source: "Server error", language: "en"),
        "accessDenied": Entry(source: "Access denied", language: "en"),
        "clientError": Entry(source: "Client error", language: "en"),
        "transfertDArgent": Entry(source: "Transfert d'argent", language: "fr"),
        "retraitBancaire": Entry(source: "Retrait bancaire", language: "fr"),
        "rechargeTelephonique": Entry(source: "Recharge téléphonique", language: "fr"),
        "paiementMarchand": Entry(source: "Paiement marchand", language: "fr"),
        "retraitDEspeces": Entry(source: "Retrait d'espèces", language: "fr"),
        "paiementDeFacture": Entry(source: "Paiement de facture", language: "fr"),
        "agent": Entry(source: "Agent", language: "en"),
        "transfertRecuDeValue": Entry(source: "Transfert reçu de __ARG_0__", language: "fr"),
        "valueViaValue": Entry(source: "__ARG_0__ via __ARG_1__", language: "en"),
        "depotDEspeces": Entry(source: "Dépôt d'espèces", language: "fr"),
        "achatDeCredit": Entry(source: "Achat de crédit", language: "fr"),
        "creditEvalue": Entry(source: "Crédit eValue", language: "fr"),
        "debitEvalue": Entry(source: "Débit eValue", language: "fr"),
        "transfertEvalue": Entry(source: "Transfert eValue", language: "fr"),
        "retraitGuichet": Entry(source: "Retrait guichet", language: "fr"),
        "depotGuichet": Entry(source: "Dépôt guichet", language: "fr"),
        "creditQrGip": Entry(source: "Crédit QR GIP", language: "fr"),
        "debitQrGip": Entry(source: "Débit QR GIP", language: "fr"),
        "transfertEntrePortefeuilles": Entry(source: "Transfert entre portefeuilles", language: "fr"),
        "transfertBonDArgent": Entry(source: "Transfert bon d'argent", language: "fr"),
        "depotAgent": Entry(source: "Dépôt agent", language: "fr"),
        "retraitAgent": Entry(source: "Retrait agent", language: "fr"),
        "especesBonAgent": Entry(source: "Espèces bon agent", language: "fr"),
        "creditGip": Entry(source: "Crédit GIP", language: "fr"),
        "debitGip": Entry(source: "Débit GIP", language: "fr"),
        "demandeDePaiement": Entry(source: "Demande de paiement", language: "fr"),
        "paiementFactureCompte": Entry(source: "Paiement facture compte", language: "fr"),
        "paiementFacturePortefeuille": Entry(source: "Paiement facture portefeuille", language: "fr"),
        "consultationPortefeuille": Entry(source: "Consultation portefeuille", language: "fr"),
        "transactionEpargne": Entry(source: "Transaction épargne", language: "fr"),
        "interetsQuotidiensEpargne": Entry(source: "Intérêts quotidiens épargne", language: "fr"),
        "annulationInteretsEpargne": Entry(source: "Annulation intérêts épargne", language: "fr"),
        "interetsEpargne": Entry(source: "Intérêts épargne", language: "fr"),
        "creditDInterets": Entry(source: "Crédit d'intérêts", language: "fr"),
        "transactionDInterets": Entry(source: "Transaction d'intérêts", language: "fr"),
        "transactionSponsorisee": Entry(source: "Transaction sponsorisée", language: "fr"),
        "commissionAgent": Entry(source: "Commission agent", language: "fr"),
        "portefeuilleDormant": Entry(source: "Portefeuille dormant", language: "fr"),
        "epargneDormante": Entry(source: "Épargne dormante", language: "fr"),
        "transfertDepuisPortefeuille": Entry(source: "Transfert depuis portefeuille", language: "fr"),
        "walletTransfer": Entry(source: "Wallet Transfer", language: "en", french: "Transfert vers un portefeuille"),
        "sponsoredWallet2": Entry(source: "Sponsored Wallet", language: "en", french: "Portefeuille parrainé"),
        "bankTransfer": Entry(source: "Bank Transfer", language: "en", french: "Virement bancaire"),
        "otherTypeValue": Entry(source: "Other Type (__ARG_0__)", language: "en", french: "Autre type (__ARG_0__)"),
        "information": Entry(source: "Information", language: "en", french: "Information"),
        "info": Entry(source: "Info", language: "en"),
        "menu": Entry(source: "Menu", language: "en"),
        "active": Entry(source: "Active", language: "en", french: "Actif"),
        "past": Entry(source: "Past", language: "en"),
        "eligibility": Entry(source: "Eligibility", language: "en", french: "Éligibilité"),
        "repayment": Entry(source: "Repayment", language: "en", french: "Remboursement"),
        "performance": Entry(source: "Performance", language: "en"),
        "sending": Entry(source: "Sending…", language: "en"),
        "promo": Entry(source: "Promo", language: "en"),
        "promotion": Entry(source: "Promotion", language: "en"),
        "desactive": Entry(source: "Désactivé", language: "fr"),
        "branch": Entry(source: "Branch", language: "en"),
        "loading2": Entry(source: "LOADING...", language: "en"),
        "accept2": Entry(source: "ACCEPT", language: "en"),
        "verify2": Entry(source: "VERIFY", language: "en"),
        "next": Entry(source: "NEXT", language: "en"),
        "ghanaian": Entry(source: "Ghanaian", language: "en"),
        "nigerian": Entry(source: "Nigerian", language: "en"),
        "ivorian": Entry(source: "Ivorian", language: "en"),
        "senegalese": Entry(source: "Senegalese", language: "en"),
        "malian": Entry(source: "Malian", language: "en"),
        "burkinabe": Entry(source: "Burkinabé", language: "en"),
        "togolese": Entry(source: "Togolese", language: "en"),
        "beninese": Entry(source: "Beninese", language: "en"),
        "guinean": Entry(source: "Guinean", language: "en"),
        "liberian": Entry(source: "Liberian", language: "en"),
        "gambian": Entry(source: "Gambian", language: "en"),
        "client": Entry(source: "CLIENT", language: "fr"),
        "agent2": Entry(source: "AGENT", language: "fr"),
        "inconnu": Entry(source: "INCONNU", language: "fr"),
        "telephone2": Entry(source: "Téléphone", language: "fr"),
        "verifying": Entry(source: "Verifying...", language: "en"),
        "submitting": Entry(source: "Submitting...", language: "en"),
        "saving": Entry(source: "Saving...", language: "en"),
        "profileInactive": Entry(source: "Inactive", language: "en", french: "Inactif"),
        "profileBlocked": Entry(source: "Blocked", language: "en", french: "Bloqué"),
        "profileClosed": Entry(source: "Closed", language: "en", french: "Fermé"),
        "profilePersonal": Entry(source: "Personal", language: "en", french: "Personnel"),
        "profileBusiness": Entry(source: "Business", language: "en", french: "Professionnel"),
        "profileSavings": Entry(source: "Savings", language: "en", french: "Épargne"),
        "loanPurposeEducation": Entry(source: "Education", language: "en", french: "Études"),
        "loanPurposeMedical": Entry(source: "Medical", language: "en", french: "Soins médicaux"),
        "loanPurposeAgriculture": Entry(source: "Agriculture", language: "en", french: "Agriculture"),
        "loanPurposeEmergency": Entry(source: "Emergency", language: "en", french: "Urgence"),
        "loanPurposeHomeImprovement": Entry(source: "Home improvement", language: "en", french: "Amélioration du logement"),
        "loanPurposeOther": Entry(source: "Other", language: "en", french: "Autre"),
        "receiptGenerationFailed": Entry(source: "Unable to generate the receipt. Please try again.", language: "en", french: "Impossible de générer le reçu. Veuillez réessayer."),
        "refreshTranslations": Entry(source: "Refresh translations", language: "en", french: "Actualiser les traductions"),
    ]

    static var receiptGenerationFailed: String { value("receiptGenerationFailed") }

    static func original(_ key: String) -> String { catalog[key]?.source ?? key }

    /// Apply sentence case after localization, only to visible button labels.
    static func buttonTitle(_ title: String) -> String {
        guard let firstLetter = title.firstIndex(where: { $0.isLetter }) else { return title }
        return String(title[..<firstLetter])
            + String(title[firstLetter]).uppercased()
            + title[title.index(after: firstLetter)...].lowercased()
    }

    static func value(_ key: String, arguments: [String] = [], original: Bool = false) -> String {
        let template = original ? self.original(key) : AppLanguageStore.shared.text(for: key)
        return format(template, arguments: arguments)
    }

    static func format(_ template: String, arguments: [String]) -> String {
        // One pass prevents recipient-supplied text from being interpreted as a placeholder.
        let pattern = "__ARG_([0-9]+)__"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return template }
        var output = template
        for match in regex.matches(in: template, range: NSRange(template.startIndex..., in: template)).reversed() {
            guard let numberRange = Range(match.range(at: 1), in: template),
                  let index = Int(template[numberRange]), arguments.indices.contains(index),
                  let range = Range(match.range, in: output) else { continue }
            output.replaceSubrange(range, with: arguments[index])
        }
        return output
    }

    static var language: String { value("language") }
    static var welcomeBack: String { value("welcomeBack") }
    static var deactivationIntro: String { value("deactivationIntro") }
    static var deactivationReasonTitle: String { value("deactivationReasonTitle") }
    static var deactivationSelectReason: String { value("deactivationSelectReason") }
    static var deactivationTransferTitle: String { value("deactivationTransferTitle") }
    static var deactivationTransferHelp: String { value("deactivationTransferHelp") }
    static var deactivationLinkedAccount: String { value("deactivationLinkedAccount") }
    static var deactivationCashOut: String { value("deactivationCashOut") }
    static var rechargeProviderDetails: String { value("rechargeProviderDetails") }
    static var rechargeRecipientDetails: String { value("rechargeRecipientDetails") }
    static var rechargeRecipientNumber: String { value("rechargeRecipientNumber") }
    static var rechargeSaved: String { value("rechargeSaved") }
    static var rechargeContacts: String { value("rechargeContacts") }
    static var rechargeProducts: String { value("rechargeProducts") }
    static var rechargeEnterAmount: String { value("rechargeEnterAmount") }
    static var rechargeSaveNumber: String { value("rechargeSaveNumber") }
    static var rechargeNoSaved: String { value("rechargeNoSaved") }
    static var rechargeChooseSaved: String { value("rechargeChooseSaved") }
    static var rechargeInvalidPhone: String { value("rechargeInvalidPhone") }
    static var rechargeInvalidAmount: String { value("rechargeInvalidAmount") }
    static var rechargeNotConnected: String { value("rechargeNotConnected") }
    static var rechargeWaterAccount: String { value("rechargeWaterAccount") }
    static var rechargeMeterNumber: String { value("rechargeMeterNumber") }
    static var rechargeEnquire: String { value("rechargeEnquire") }
    static var rechargePay: String { value("rechargePay") }
    static var rechargeAccountRequired: String { value("rechargeAccountRequired") }
    static var rechargeMeterRequired: String { value("rechargeMeterRequired") }
    static var rechargeMoreBillers: String { value("rechargeMoreBillers") }
    static var rechargeBillProviders: String { value("rechargeBillProviders") }
    static var rechargePayBills: String { value("rechargePayBills") }
    static var walletTagline: String { value("walletTagline") }
    static var phoneNumber: String { value("phoneNumber") }
    static var pin: String { value("pin") }
    static var loggingIn: String { value("loggingIn") }
    static var login: String { value("login") }
    static var forgotPin: String { value("forgotPin") }
    static var noAccount: String { value("noAccount") }
    static var signUp: String { value("signUp") }
    static var ok: String { value("ok") }
    static var error: String { value("error") }
    static var hello: String { value("hello") }
    static var availableBalance: String { value("availableBalance") }
    static var transactionHistory: String { value("transactionHistory") }
    static var quickAccess: String { value("quickAccess") }
    static var transferToWallet: String { value("transferToWallet") }
    static var walletToAccount: String { value("walletToAccount") }
    static var accountToWallet: String { value("accountToWallet") }
    static var bills: String { value("bills") }
    static var qrPayment: String { value("qrPayment") }
    static var promotions: String { value("promotions") }
    static var noPromotions: String { value("noPromotions") }
    static var home: String { value("home") }
    static var sponsors: String { value("sponsors") }
    static var limits: String { value("limits") }
    static var settings: String { value("settings") }
    static var orderFood: String { value("orderFood") }
    static var fastDelivery: String { value("fastDelivery") }
    static var securitySettings: String { value("securitySettings") }
    static var securityQuestion: String { value("securityQuestion") }
    static var securityQuestionHelp: String { value("securityQuestionHelp") }
    static var requirePin: String { value("requirePin") }
    static var pinBypassHelp: String { value("pinBypassHelp") }
    static var transactionsWithoutPin: String { value("transactionsWithoutPin") }
    static var pinAlwaysRequired: String { value("pinAlwaysRequired") }
    static var fiveTransactionsLeft: String { value("fiveTransactionsLeft") }
    static var changePin: String { value("changePin") }
    static var changeSecurityQuestion: String { value("changeSecurityQuestion") }
    static var biometricAuthentication: String { value("biometricAuthentication") }
    static var biometricHelp: String { value("biometricHelp") }
    static var importantInformation: String { value("importantInformation") }
    static var pinResetRule: String { value("pinResetRule") }
    static var keepPinSecure: String { value("keepPinSecure") }
    static var counterReset: String { value("counterReset") }
    static var disableBypass: String { value("disableBypass") }
    static var profileSection: String { value("profileSection") }
    static var myProfile: String { value("myProfile") }
    static var beneficiaries: String { value("beneficiaries") }
    static var loansSection: String { value("loansSection") }
    static var requestLoan: String { value("requestLoan") }
    static var myLoans: String { value("myLoans") }
    static var loanHelp: String { value("loanHelp") }
    static var transfersSection: String { value("transfersSection") }
    static var moneyVoucher: String { value("moneyVoucher") }
    static var mobileMoney: String { value("mobileMoney") }
    static var qrTransfer: String { value("qrTransfer") }
    static var crowdFunding: String { value("crowdFunding") }
    static var standingInstructions: String { value("standingInstructions") }
    static var foodSection: String { value("foodSection") }
    static var foodHistory: String { value("foodHistory") }
    static var complaints: String { value("complaints") }
    static var rechargesSection: String { value("rechargesSection") }
    static var phoneCredit: String { value("phoneCredit") }
    static var buyData: String { value("buyData") }
    static var billPayment: String { value("billPayment") }
    static var sponsorSection: String { value("sponsorSection") }
    static var sponsoredWallets: String { value("sponsoredWallets") }
    static var sponsoringWallets: String { value("sponsoringWallets") }
    static var savingsSection: String { value("savingsSection") }
    static var savingsWallet: String { value("savingsWallet") }
    static var savingsStatement: String { value("savingsStatement") }
    static var transactionsSection: String { value("transactionsSection") }
    static var walletManagement: String { value("walletManagement") }
    static var deactivateWallet: String { value("deactivateWallet") }
    static var pendingTransactions: String { value("pendingTransactions") }
    static var helpSection: String { value("helpSection") }
    static var sendFeedback: String { value("sendFeedback") }
    static var fileComplaint: String { value("fileComplaint") }
    static var contactUs: String { value("contactUs") }
    static var terms: String { value("terms") }
    static var faq: String { value("faq") }
    static var logout: String { value("logout") }
    static var fillAllFields: String { value("fillAllFields") }
    static var sessionExpired: String { value("sessionExpired") }
    static var loginAgain: String { value("loginAgain") }
    static var loginWithPin: String { value("loginWithPin") }
    static var updateRequired: String { value("updateRequired") }
    static var update: String { value("update") }
    static var quit: String { value("quit") }
    static var forgotPinTitle: String { value("forgotPinTitle") }
    static var forgotPinHelp: String { value("forgotPinHelp") }
    static var traitementEnCours: String { value("traitementEnCours") }
    static var saveBeneficiary: String { value("saveBeneficiary") }
    static var save: String { value("save") }
    static var notNow: String { value("notNow") }
    static func wouldYouLikeToSaveValueToYourBeneficiaries(_ value0: String) -> String { value("wouldYouLikeToSaveValueToYourBeneficiaries", arguments: [value0]) }
    static var accountDetails: String { value("accountDetails") }
    static var enterAccountNumber: String { value("enterAccountNumber") }
    static var verify: String { value("verify") }
    static var saved: String { value("saved") }
    static var beneficiaryName: String { value("beneficiaryName") }
    static var amount: String { value("amount") }
    static var amount2: String { value("amount2") }
    static var impossibleDeCalculer: String { value("impossibleDeCalculer") }
    static var reasonOptional: String { value("reasonOptional") }
    static var enterAReason: String { value("enterAReason") }
    static var submit: String { value("submit") }
    static var numeroDeCompteInvalide: String { value("numeroDeCompteInvalide") }
    static func erreurValue(_ value0: String) -> String { value("erreurValue", arguments: [value0]) }
    static func erreurReseauValue(_ value0: String) -> String { value("erreurReseauValue", arguments: [value0]) }
    static var enterAnAccountNumber: String { value("enterAnAccountNumber") }
    static var compteVerifieAvecSucces: String { value("compteVerifieAvecSucces") }
    static var compteVerifie: String { value("compteVerifie") }
    static var informationDuCompteNonDisponible: String { value("informationDuCompteNonDisponible") }
    static var compteNonTrouve: String { value("compteNonTrouve") }
    static var donneesManquantesDansLaRequete: String { value("donneesManquantesDansLaRequete") }
    static func echecDeLaVerificationCodeValue(_ value0: String) -> String { value("echecDeLaVerificationCodeValue", arguments: [value0]) }
    static var pleaseSelectASponsorWallet: String { value("pleaseSelectASponsorWallet") }
    static var veuillezSaisirUnNumeroDeCompteValideEtLe: String { value("veuillezSaisirUnNumeroDeCompteValideEtLe") }
    static var leMontantEstRequis: String { value("leMontantEstRequis") }
    static var veuillezDAbordVerifierLeCompte: String { value("veuillezDAbordVerifierLeCompte") }
    static var veuillezSelectionnerUnCompteValide: String { value("veuillezSelectionnerUnCompteValide") }
    static var veuillezVerifierLeNumeroDeCompteEtSaisirUn: String { value("veuillezVerifierLeNumeroDeCompteEtSaisirUn") }
    static var veuillezSaisirVotreCodePin: String { value("veuillezSaisirVotreCodePin") }
    static func transfertEchoueValue(_ value0: String) -> String { value("transfertEchoueValue", arguments: [value0]) }
    static var unableToSaveBeneficiary: String { value("unableToSaveBeneficiary") }
    static var theAccountDetailsAreUnavailablePleaseTryAgain: String { value("theAccountDetailsAreUnavailablePleaseTryAgain") }
    static var pleaseTryAgainLater: String { value("pleaseTryAgainLater") }
    static var pleaseCheckYourConnectionAndTryAgain: String { value("pleaseCheckYourConnectionAndTryAgain") }
    static var succes: String { value("succes") }
    static var walletToWallet: String { value("walletToWallet") }
    static var saveRecipient: String { value("saveRecipient") }
    static func wouldYouLikeToSaveValueForFutureTransfers(_ value0: String) -> String { value("wouldYouLikeToSaveValueForFutureTransfers", arguments: [value0]) }
    static var recipientDetails: String { value("recipientDetails") }
    static var recipientIdentifier: String { value("recipientIdentifier") }
    static var walletNumber: String { value("walletNumber") }
    static var phoneOrCustomerId: String { value("phoneOrCustomerId") }
    static var recipientNumber: String { value("recipientNumber") }
    static var contacts: String { value("contacts") }
    static var recipientName: String { value("recipientName") }
    static var verifyAgain: String { value("verifyAgain") }
    static var enterReason: String { value("enterReason") }
    static var chooseSavedRecipient: String { value("chooseSavedRecipient") }
    static var choosePhoneContact: String { value("choosePhoneContact") }
    static var unableToVerifyThisRecipient: String { value("unableToVerifyThisRecipient") }
    static var unableToVerifyTheRecipientPleaseTryAgain: String { value("unableToVerifyTheRecipientPleaseTryAgain") }
    static var enterTheRecipientPhoneNumberCustomerIdOrWallet: String { value("enterTheRecipientPhoneNumberCustomerIdOrWallet") }
    static var pleaseVerifyTheRecipientFirst: String { value("pleaseVerifyTheRecipientFirst") }
    static var pleaseChooseAnotherRecipient: String { value("pleaseChooseAnotherRecipient") }
    static var enterAValidAmountWithUpToTwoDecimal: String { value("enterAValidAmountWithUpToTwoDecimal") }
    static var selectASponsorFirst: String { value("selectASponsorFirst") }
    static var unableToCalculateFees: String { value("unableToCalculateFees") }
    static var invalidFeeQuotePleaseTryAgain: String { value("invalidFeeQuotePleaseTryAgain") }
    static var unableToCalculateFeesPleaseTryAgain: String { value("unableToCalculateFeesPleaseTryAgain") }
    static var transferDetailsChangedPleaseSubmitAgain: String { value("transferDetailsChangedPleaseSubmitAgain") }
    static var enterYourPin: String { value("enterYourPin") }
    static var transferFailed: String { value("transferFailed") }
    static var transferCouldNotBeConfirmedCheckTransactionHistoryBefore: String { value("transferCouldNotBeConfirmedCheckTransactionHistoryBefore") }
    static var recipientDetailsAreUnavailablePleaseTryAgain: String { value("recipientDetailsAreUnavailablePleaseTryAgain") }
    static var unableToSaveRecipient: String { value("unableToSaveRecipient") }
    static var transferSuccessful: String { value("transferSuccessful") }
    static var yourTransferIsComplete: String { value("yourTransferIsComplete") }
    static var transactionInformation: String { value("transactionInformation") }
    static var idTransaction: String { value("idTransaction") }
    static var amountDetails: String { value("amountDetails") }
    static var amountSent: String { value("amountSent") }
    static var withdrawalFee: String { value("withdrawalFee") }
    static var transferFee: String { value("transferFee") }
    static var free: String { value("free") }
    static var totalDebited: String { value("totalDebited") }
    static var sender: String { value("sender") }
    static var recipient: String { value("recipient") }
    static var shareReceipt: String { value("shareReceipt") }
    static var close: String { value("close") }
    static var transferReceipt: String { value("transferReceipt") }
    static var recuDeTransfert: String { value("recuDeTransfert") }
    static var statusTransferSuccessful: String { value("statusTransferSuccessful") }
    static func idTransactionValue(_ value0: String) -> String { value("idTransactionValue", arguments: [value0]) }
    static func dateValue(_ value0: String) -> String { value("dateValue", arguments: [value0]) }
    static var amountDetails2: String { value("amountDetails2") }
    static func amountSentValue(_ value0: String) -> String { value("amountSentValue", arguments: [value0]) }
    static func withdrawalFeeValue(_ value0: String) -> String { value("withdrawalFeeValue", arguments: [value0]) }
    static func transferFeeValue(_ value0: String) -> String { value("transferFeeValue", arguments: [value0]) }
    static func totalDebitedValue(_ value0: String) -> String { value("totalDebitedValue", arguments: [value0]) }
    static func nameValue(_ value0: String) -> String { value("nameValue", arguments: [value0]) }
    static func phoneValue(_ value0: String) -> String { value("phoneValue", arguments: [value0]) }
    static func reasonValue(_ value0: String) -> String { value("reasonValue", arguments: [value0]) }
    static func thisReceiptWasGeneratedAutomaticallyOnValue(_ value0: String) -> String { value("thisReceiptWasGeneratedAutomaticallyOnValue", arguments: [value0]) }
    static var loadingTransactions: String { value("loadingTransactions") }
    static var somethingWentWrong: String { value("somethingWentWrong") }
    static var startDate: String { value("startDate") }
    static var endDate: String { value("endDate") }
    static var filterByDate: String { value("filterByDate") }
    static var startDate2: String { value("startDate2") }
    static var endDate2: String { value("endDate2") }
    static var reset: String { value("reset") }
    static var filter: String { value("filter") }
    static var last30Days: String { value("last30Days") }
    static var pdf: String { value("pdf") }
    static var excel: String { value("excel") }
    static var csv: String { value("csv") }
    static var exportTransactions: String { value("exportTransactions") }
    static var unableToCreateTheExportFilePleaseTryAgain: String { value("unableToCreateTheExportFilePleaseTryAgain") }
    static func dateRangeValueValue(_ value0: String, _ value1: String) -> String { value("dateRangeValueValue", arguments: [value0, value1]) }
    static var noTransactionsFound: String { value("noTransactionsFound") }
    static var thereAreNoTransactionsForTheSelectedDateRange: String { value("thereAreNoTransactionsForTheSelectedDateRange") }
    static var refresh: String { value("refresh") }
    static func pageValueOfValue(_ value0: String, _ value1: String) -> String { value("pageValueOfValue", arguments: [value0, value1]) }
    static var walletNumberNotFoundPleaseSignInAgain: String { value("walletNumberNotFoundPleaseSignInAgain") }
    static func unableToLoadTransactionsValue(_ value0: String) -> String { value("unableToLoadTransactionsValue", arguments: [value0]) }
    static func errorValue(_ value0: String) -> String { value("errorValue", arguments: [value0]) }
    static func connectionErrorValue(_ value0: String) -> String { value("connectionErrorValue", arguments: [value0]) }
    static var pleaseSelectAStartAndEndDate: String { value("pleaseSelectAStartAndEndDate") }
    static var theStartDateMustBeOnOrBeforeThe: String { value("theStartDateMustBeOnOrBeforeThe") }
    static var cancel: String { value("cancel") }
    static var done: String { value("done") }
    static var transactionDetails: String { value("transactionDetails") }
    static var transactionInformation2: String { value("transactionInformation2") }
    static var reference: String { value("reference") }
    static var nA: String { value("nA") }
    static var type: String { value("type") }
    static var details: String { value("details") }
    static var noAdditionalDetails: String { value("noAdditionalDetails") }
    static var openingBalance: String { value("openingBalance") }
    static var closingBalance: String { value("closingBalance") }
    static var moneySent: String { value("moneySent") }
    static var moneyReceived: String { value("moneyReceived") }
    static var unknown: String { value("unknown") }
    static func refValue(_ value0: String) -> String { value("refValue", arguments: [value0]) }
    static var transactionReceipt: String { value("transactionReceipt") }
    static var transactionReceipt2: String { value("transactionReceipt2") }
    static func referenceValue(_ value0: String) -> String { value("referenceValue", arguments: [value0]) }
    static func typeValue(_ value0: String) -> String { value("typeValue", arguments: [value0]) }
    static func amountValue(_ value0: String) -> String { value("amountValue", arguments: [value0]) }
    static func statusValue(_ value0: String) -> String { value("statusValue", arguments: [value0]) }
    static func detailsValue(_ value0: String) -> String { value("detailsValue", arguments: [value0]) }
    static func openingBalanceValue(_ value0: String) -> String { value("openingBalanceValue", arguments: [value0]) }
    static func closingBalanceValue(_ value0: String) -> String { value("closingBalanceValue", arguments: [value0]) }
    static var conditionsGenerales: String { value("conditionsGenerales") }
    static var conditionsGeneralesDUtilisation: String { value("conditionsGeneralesDUtilisation") }
    static var definitions: String { value("definitions") }
    static var objet: String { value("objet") }
    static var fonctionnalitesDuService: String { value("fonctionnalitesDuService") }
    static var iHaveReadAndAcceptTheTermsAndConditions: String { value("iHaveReadAndAcceptTheTermsAndConditions") }
    static var refuse: String { value("refuse") }
    static var accept: String { value("accept") }
    static var pourLesBesoinsDuPresentContratIlConvientD: String { value("pourLesBesoinsDuPresentContratIlConvientD") }
    static var banque: String { value("banque") }
    static var laDiamaBankSa: String { value("laDiamaBankSa") }
    static var contrat: String { value("contrat") }
    static var designeLePresentContratDAdhesionAuServiceDiamacash: String { value("designeLePresentContratDAdhesionAuServiceDiamacash") }
    static var applicationMobile: String { value("applicationMobile") }
    static var uneApplicationMobileEstUnLogicielApplicatifDeveloppePour: String { value("uneApplicationMobileEstUnLogicielApplicatifDeveloppePour") }
    static var wallet: String { value("wallet") }
    static var constitueUnMoyenDePaiementPermettantASonDetenteur: String { value("constitueUnMoyenDePaiementPermettantASonDetenteur") }
    static var etablissement: String { value("etablissement") }
    static var designeToutEtablissementBancaireOuLesEtablissementsDePaiement: String { value("designeToutEtablissementBancaireOuLesEtablissementsDePaiement") }
    static var cashIn: String { value("cashIn") }
    static var ilSAgitDUneOperationDeDepotD: String { value("ilSAgitDUneOperationDeDepotD") }
    static var cashOut: String { value("cashOut") }
    static var ilSAgitDUneOperationDeRetraitD: String { value("ilSAgitDUneOperationDeRetraitD") }
    static var compteDeRattachement: String { value("compteDeRattachement") }
    static var designeLeCompteOuvertDansLesLivresDeLa: String { value("designeLeCompteOuvertDansLesLivresDeLa") }
    static var detenteurDuWallet: String { value("detenteurDuWallet") }
    static var peutEtreLeTitulaireDuCompteOuTouteAutre: String { value("peutEtreLeTitulaireDuCompteOuTouteAutre") }
    static var designeLApplicationDePaiementMobilePourLesClients: String { value("designeLApplicationDePaiementMobilePourLesClients") }
    static var dabGab: String { value("dabGab") }
    static var appareilsDeDistributionAutomatiqueDeBilletsDeBanque: String { value("appareilsDeDistributionAutomatiqueDeBilletsDeBanque") }
    static var tpe: String { value("tpe") }
    static var terminalDePaiementElectronique: String { value("terminalDePaiementElectronique") }
    static var leWalletDiamacashEstUnMoyenDePaiementElectronique: String { value("leWalletDiamacashEstUnMoyenDePaiementElectronique") }
    static var cetteApplicationEstTelechargeableAPartirDeGooglePlay: String { value("cetteApplicationEstTelechargeableAPartirDeGooglePlay") }
    static var lesFonctionnalitesDisponiblesAuNiveauDeLApplicationDiamacash: String { value("lesFonctionnalitesDisponiblesAuNiveauDeLApplicationDiamacash") }
    static var laSouscription: String { value("laSouscription") }
    static var leClientPeutInitierDirectementSonInscriptionSurL: String { value("leClientPeutInitierDirectementSonInscriptionSurL") }
    static var laConnexion: String { value("laConnexion") }
    static var leClientSeConnecteASonCompteDiamacashA: String { value("leClientSeConnecteASonCompteDiamacashA") }
    static var laLiaisonDeSonCompteBancaire: String { value("laLiaisonDeSonCompteBancaire") }
    static var leClientQuiAUnCompteBancaireOuvertDans: String { value("leClientQuiAUnCompteBancaireOuvertDans") }
    static var leDeplafonnementDuWallet: String { value("leDeplafonnementDuWallet") }
    static var parDefautLeCompteDiamacashDuClientEstLimite: String { value("parDefautLeCompteDiamacashDuClientEstLimite") }
    static var leChargementDuWalletCashIn: String { value("leChargementDuWalletCashIn") }
    static var leDetenteurDuWalletPeutBeneficierDeDeuxCanaux: String { value("leDetenteurDuWalletPeutBeneficierDeDeuxCanaux") }
    static var retraitDArgentCashOut: String { value("retraitDArgentCashOut") }
    static var leClientPeutSeRendreChezNImporteQuels: String { value("leClientPeutSeRendreChezNImporteQuels") }
    static var transfertVersUnAutreCompteDiamacash: String { value("transfertVersUnAutreCompteDiamacash") }
    static var leClientPeutAToutMomentEffectuerDesTransferts: String { value("leClientPeutAToutMomentEffectuerDesTransferts") }
    static var transfertVersMaBanque: String { value("transfertVersMaBanque") }
    static var leClientPeutAToutMomentEffectuerDesTransferts2: String { value("leClientPeutAToutMomentEffectuerDesTransferts2") }
    static var transfertDeMaBanque: String { value("transfertDeMaBanque") }
    static var leClientPeutAToutMomentEffectuerDesTransferts3: String { value("leClientPeutAToutMomentEffectuerDesTransferts3") }
    static var leClientPeutAToutMomentEffectuerDesTransferts4: String { value("leClientPeutAToutMomentEffectuerDesTransferts4") }
    static var leClientPeutAToutMomentEffectuerLeParrainage: String { value("leClientPeutAToutMomentEffectuerLeParrainage") }
    static var virementPermanent: String { value("virementPermanent") }
    static var leClientPeutAToutMomentInitierDesVirements: String { value("leClientPeutAToutMomentInitierDesVirements") }
    static var paiementChezLeCommercant: String { value("paiementChezLeCommercant") }
    static var leClientPeutPayerSesAchatsAPartirDe: String { value("leClientPeutPayerSesAchatsAPartirDe") }
    static var conditionsDInscriptionAuService: String { value("conditionsDInscriptionAuService") }
    static var leServiceEstReserveALaClienteleDesParticuliers: String { value("leServiceEstReserveALaClienteleDesParticuliers") }
    static var dUnSmartphoneCompatibleAvecPlayStoreOuApple: String { value("dUnSmartphoneCompatibleAvecPlayStoreOuApple") }
    static var dUnNumeroMobileGuineenEnLeurNom: String { value("dUnNumeroMobileGuineenEnLeurNom") }
    static var lUtilisationDeDiamacashSeFaitEnGuineeComme: String { value("lUtilisationDeDiamacashSeFaitEnGuineeComme") }
    static var accesAuService: String { value("accesAuService") }
    static var lAccesAuServiceEstSubordonneAuRespectPar: String { value("lAccesAuServiceEstSubordonneAuRespectPar") }
    static var moyensTechniques: String { value("moyensTechniques") }
    static var lAccesAuServiceSeFaitViaLUtilisation: String { value("lAccesAuServiceSeFaitViaLUtilisation") }
    static var dUnSmartphoneDeSaMiseEnServiceEt: String { value("dUnSmartphoneDeSaMiseEnServiceEt") }
    static var dUnAccesAInternetSurSonTerminalMobile: String { value("dUnAccesAInternetSurSonTerminalMobile") }
    static var deLaCompatibiliteDuMaterielEtDesLogicielsDestines: String { value("deLaCompatibiliteDuMaterielEtDesLogicielsDestines") }
    static var codesEtSecurite: String { value("codesEtSecurite") }
    static var leCodePersonnelDefiniLorsDeLInscriptionA: String { value("leCodePersonnelDefiniLorsDeLInscriptionA") }
    static var leClientEstEntierementResponsableDeLaConservationEt: String { value("leClientEstEntierementResponsableDeLaConservationEt") }
    static var ilAppartientNotammentAuClientDeSAssurerQue: String { value("ilAppartientNotammentAuClientDeSAssurerQue") }
    static var pourDesRaisonsDeSecuriteLAccesAuService: String { value("pourDesRaisonsDeSecuriteLAccesAuService") }
    static var laBanqueRecommandeDeModifierLeMotDePasse: String { value("laBanqueRecommandeDeModifierLeMotDePasse") }
    static var evolutionsDuService: String { value("evolutionsDuService") }
    static var enFonctionNotammentDesEvolutionsTechnologiquesLaBanqueApportera: String { value("enFonctionNotammentDesEvolutionsTechnologiquesLaBanqueApportera") }
    static var assistance: String { value("assistance") }
    static var laBanqueMetADispositionDeLUtilisateurUn: String { value("laBanqueMetADispositionDeLUtilisateurUn") }
    static var secretProfessionnel: String { value("secretProfessionnel") }
    static var laDiamaBankSaEstTenueAuSecretProfessionnel: String { value("laDiamaBankSaEstTenueAuSecretProfessionnel") }
    static var responsabilite: String { value("responsabilite") }
    static var laBanque: String { value("laBanque") }
    static var laDiamaBankSaSEngageAFournirLe: String { value("laDiamaBankSaSEngageAFournirLe") }
    static var laBanqueDeclineTouteResponsabiliteEnCasDeDysfonctionnement: String { value("laBanqueDeclineTouteResponsabiliteEnCasDeDysfonctionnement") }
    static var laBanqueNEstPasResponsableDesDysfonctionnementsImputables: String { value("laBanqueNEstPasResponsableDesDysfonctionnementsImputables") }
    static var leClient: String { value("leClient") }
    static var leClientDoitPrendreTouteMesurePourConserverA: String { value("leClientDoitPrendreTouteMesurePourConserverA") }
    static var leClientDoitUtiliserLeServiceConformementAuxFinalites: String { value("leClientDoitUtiliserLeServiceConformementAuxFinalites") }
    static var leClientSEngageAMettreAJourLes: String { value("leClientSEngageAMettreAJourLes") }
    static var leClientEstResponsableDesOperationsEffectueesViaSon: String { value("leClientEstResponsableDesOperationsEffectueesViaSon") }
    static var interruptionDuService: String { value("interruptionDuService") }
    static var laBanquePeutBloquerLAccesTotalAuxServices: String { value("laBanquePeutBloquerLAccesTotalAuxServices") }
    static var leServicePourraEtrePonctuellementInterrompuPourDeCourtes: String { value("leServicePourraEtrePonctuellementInterrompuPourDeCourtes") }
    static var oppositionOuBlocageParLeClient: String { value("oppositionOuBlocageParLeClient") }
    static var enCasDeVolDeDetournementOuDeToute: String { value("enCasDeVolDeDetournementOuDeToute") }
    static var dansTousLesCasLeClientDoitImmediatement: String { value("dansTousLesCasLeClientDoitImmediatement") }
    static var alerterLaBanque: String { value("alerterLaBanque") }
    static var ouAppelerLeCentreDeRelationsClientsCrcDe: String { value("ouAppelerLeCentreDeRelationsClientsCrcDe") }
    static var tarificationDuService: String { value("tarificationDuService") }
    static var lesServicesCiApresSontOffertsGratuitementPourLe: String { value("lesServicesCiApresSontOffertsGratuitementPourLe") }
    static var laSouscriptionAuWalletDiamacash: String { value("laSouscriptionAuWalletDiamacash") }
    static var leChargementDuWalletDiamacash: String { value("leChargementDuWalletDiamacash") }
    static var lePaiementChezLeCommercantOuAutresPrestataires: String { value("lePaiementChezLeCommercantOuAutresPrestataires") }
    static var laDesinscription: String { value("laDesinscription") }
    static var leClientConserveASaChargeLesCoutsDe: String { value("leClientConserveASaChargeLesCoutsDe") }
    static var dureeDuContratResiliation: String { value("dureeDuContratResiliation") }
    static var lePresentContratEstConcluPourUneDureeIndeterminee: String { value("lePresentContratEstConcluPourUneDureeIndeterminee") }
    static var ilPeutEtreResilieAToutMomentParLe: String { value("ilPeutEtreResilieAToutMomentParLe") }
    static var laResiliationParLeClientPrendEffetTrente30: String { value("laResiliationParLeClientPrendEffetTrente30") }
    static var laResiliationParLaBanquePrendEffetQuinzeJours: String { value("laResiliationParLaBanquePrendEffetQuinzeJours") }
    static var modificationDuContrat: String { value("modificationDuContrat") }
    static var laBanqueSeReserveLeDroitDApporterDes: String { value("laBanqueSeReserveLeDroitDApporterDes") }
    static var lAbsenceDeContestationNotifieeALaBanqueAvant: String { value("lAbsenceDeContestationNotifieeALaBanqueAvant") }
    static var arretDuService: String { value("arretDuService") }
    static var enCasDArretDeLaFournitureDuService: String { value("enCasDArretDeLaFournitureDuService") }
    static var loiApplicableJuridictionLitiges: String { value("loiApplicableJuridictionLitiges") }
    static var leContratEstRegiEtInterpreteSelonLeDroit: String { value("leContratEstRegiEtInterpreteSelonLeDroit") }
    static var toutDifferendYRelatifQuantASonInterpretationOu: String { value("toutDifferendYRelatifQuantASonInterpretationOu") }
    static var sourceOfFunds: String { value("sourceOfFunds") }
    static var sourceDesFonds: String { value("sourceDesFonds") }
    static var monPortefeuille: String { value("monPortefeuille") }
    static var sponsor: String { value("sponsor") }
    static var selectionnerUnSponsor: String { value("selectionnerUnSponsor") }
    static var selectASponsor: String { value("selectASponsor") }
    static var unnamedSponsor: String { value("unnamedSponsor") }
    static var sponsorSansNom: String { value("sponsorSansNom") }
    static var availableBalance2: String { value("availableBalance2") }
    static var dailyLimitGmd: String { value("dailyLimitGmd") }
    static var limiteQuotidienneGmd: String { value("limiteQuotidienneGmd") }
    static var unableToLoadSponsorWallets: String { value("unableToLoadSponsorWallets") }
    static var erreurLorsDeLaRecuperationDesPortefeuillesSponsors: String { value("erreurLorsDeLaRecuperationDesPortefeuillesSponsors") }
    static func networkErrorValue(_ value0: String) -> String { value("networkErrorValue", arguments: [value0]) }
    static var pleaseWait: String { value("pleaseWait") }
    static var veuillezPatienter: String { value("veuillezPatienter") }
    static var transferToAccountSuccessful: String { value("transferToAccountSuccessful") }
    static func idValue(_ value0: String) -> String { value("idValue", arguments: [value0]) }
    static var date: String { value("date") }
    static var phone: String { value("phone") }
    static var accountNo: String { value("accountNo") }
    static var bank: String { value("bank") }
    static var transferToAccount: String { value("transferToAccount") }
    static var withdrawalFee2: String { value("withdrawalFee2") }
    static var totalDebited2: String { value("totalDebited2") }
    static var recuDeTransfertVersCompte: String { value("recuDeTransfertVersCompte") }
    static var recuDeTransfertVersCompte2: String { value("recuDeTransfertVersCompte2") }
    static var statutTransfertVersCompteReussi: String { value("statutTransfertVersCompteReussi") }
    static func montantValue(_ value0: String) -> String { value("montantValue", arguments: [value0]) }
    static func fraisValue(_ value0: String) -> String { value("fraisValue", arguments: [value0]) }
    static func totalDebiteValue(_ value0: String) -> String { value("totalDebiteValue", arguments: [value0]) }
    static func nomValue(_ value0: String) -> String { value("nomValue", arguments: [value0]) }
    static func portefeuilleValue(_ value0: String) -> String { value("portefeuilleValue", arguments: [value0]) }
    static func telephoneValue(_ value0: String) -> String { value("telephoneValue", arguments: [value0]) }
    static var compteDestinataire: String { value("compteDestinataire") }
    static func nomDuCompteValue(_ value0: String) -> String { value("nomDuCompteValue", arguments: [value0]) }
    static func numeroDeCompteValue(_ value0: String) -> String { value("numeroDeCompteValue", arguments: [value0]) }
    static func banqueValue(_ value0: String) -> String { value("banqueValue", arguments: [value0]) }
    static func detailsValue2(_ value0: String) -> String { value("detailsValue2", arguments: [value0]) }
    static func ceRecuAEteGenereAutomatiquementLeValue(_ value0: String) -> String { value("ceRecuAEteGenereAutomatiquementLeValue", arguments: [value0]) }
    static var confirmTransfer: String { value("confirmTransfer") }
    static var reviewTheDetailsAndEnterYourPin: String { value("reviewTheDetailsAndEnterYourPin") }
    static var transferAmount: String { value("transferAmount") }
    static var applicableFees: String { value("applicableFees") }
    static var transferFee2: String { value("transferFee2") }
    static var totalToDebit: String { value("totalToDebit") }
    static var name: String { value("name") }
    static var sourceOfFunds2: String { value("sourceOfFunds2") }
    static var sponsorWallet: String { value("sponsorWallet") }
    static var myWallet: String { value("myWallet") }
    static var reason: String { value("reason") }
    static var enterPin: String { value("enterPin") }
    static var confirm: String { value("confirm") }
    static var pinMustContainExactly4Digits: String { value("pinMustContainExactly4Digits") }
    static var confirmationDuTransfert: String { value("confirmationDuTransfert") }
    static var verifiezLesDetailsEtSaisissezVotreCodePin: String { value("verifiezLesDetailsEtSaisissezVotreCodePin") }
    static var montant: String { value("montant") }
    static var fraisDEnvoi: String { value("fraisDEnvoi") }
    static var gratuit: String { value("gratuit") }
    static var totalADebiter: String { value("totalADebiter") }
    static var informationsDuBeneficiaire: String { value("informationsDuBeneficiaire") }
    static var numeroDeCompte: String { value("numeroDeCompte") }
    static var description: String { value("description") }
    static var authentification: String { value("authentification") }
    static var annuler: String { value("annuler") }
    static var transferer: String { value("transferer") }
    static var lePinDoitContenirExactement4Chiffres: String { value("lePinDoitContenirExactement4Chiffres") }
    static var translatingApp: String { value("translatingApp") }
    static var translationFailed: String { value("translationFailed") }
    static var automaticLanguages: String { value("automaticLanguages") }
    static var automaticLanguageHelp: String { value("automaticLanguageHelp") }
    static var requiresIOS18: String { value("requiresIOS18") }
    static var retry: String { value("retry") }
    static var cancelLanguage: String { value("cancelLanguage") }
    static var languageUnavailable: String { value("languageUnavailable") }
    static var automaticTermsNotice: String { value("automaticTermsNotice") }
    static var showOriginalTerms: String { value("showOriginalTerms") }
    static var showTranslatedTerms: String { value("showTranslatedTerms") }
    static let brand = "GambiaPay"
    static var processing: String { value("processing") }
    static var dateLabel: String { value("dateLabel") }
    static var nameLabel: String { value("nameLabel") }
    static var phoneLabel: String { value("phoneLabel") }
    static var reasonLabel: String { value("reasonLabel") }
    static var senderHeading: String { value("senderHeading") }
    static var recipientHeading: String { value("recipientHeading") }
    static var account: String { value("account") }
    static var fee: String { value("fee") }
    static var share: String { value("share") }
    static var closeHeading: String { value("closeHeading") }
    static var errorHeading: String { value("errorHeading") }
    static var beneficiary: String { value("beneficiary") }
    static var sponsorship: String { value("sponsorship") }
    static var unknownError: String { value("unknownError") }
    static var pleaseTryAgain: String { value("pleaseTryAgain") }
    static var balance: String { value("balance") }
    static var status: String { value("status") }

    static var dateUnavailable: String { value("dateUnavailable") }
    static var transactionGeneric: String { value("transactionGeneric") }
    static func balanceValue(_ amount: String) -> String { value("balanceValue", arguments: [amount]) }

    static var transfertVersPortefeuilleReussi: String { value("transfertVersPortefeuilleReussi") }
    static var montant2: String { value("montant2") }
    static var fraisDEnvoi2: String { value("fraisDEnvoi2") }
    static var frais: String { value("frais") }
    static var totalDebite: String { value("totalDebite") }
    static var compteSource: String { value("compteSource") }
    static var titulaire: String { value("titulaire") }
    static var numeroDeCompte2: String { value("numeroDeCompte2") }
    static var banque2: String { value("banque2") }
    static var portefeuilleDestinataire: String { value("portefeuilleDestinataire") }
    static var nom: String { value("nom") }
    static var portefeuille: String { value("portefeuille") }
    static var telephone: String { value("telephone") }
    static var details2: String { value("details2") }
    static var transfertVersPortefeuille: String { value("transfertVersPortefeuille") }
    static var partagerLeRecu: String { value("partagerLeRecu") }
    static var fermer: String { value("fermer") }
    static var recuDeTransfert2: String { value("recuDeTransfert2") }
    static var recuDeTransfertVersPortefeuille: String { value("recuDeTransfertVersPortefeuille") }
    static var recuDeTransfertVersPortefeuille2: String { value("recuDeTransfertVersPortefeuille2") }
    static var statutTransfertVersPortefeuilleReussi: String { value("statutTransfertVersPortefeuilleReussi") }
    static func titulaireValue(_ value0: String) -> String { value("titulaireValue", arguments: [value0]) }
    static func detailsDuPaiementValue(_ value0: String) -> String { value("detailsDuPaiementValue", arguments: [value0]) }
    static var jeanDupont: String { value("jeanDupont") }
    static var banqueCentrale: String { value("banqueCentrale") }
    static var marieMartin: String { value("marieMartin") }
    static var testTransfer: String { value("testTransfer") }
    static var transfertDeCompteVersPortefeuille: String { value("transfertDeCompteVersPortefeuille") }
    static var compteSource2: String { value("compteSource2") }
    static var selectionnerUnCompte: String { value("selectionnerUnCompte") }
    static var enregistres: String { value("enregistres") }
    static var titulaireDuCompte: String { value("titulaireDuCompte") }
    static var verificationEnCours: String { value("verificationEnCours") }
    static var montant3: String { value("montant3") }
    static var entrerLeMontantGmd: String { value("entrerLeMontantGmd") }
    static var referenceOptionnel: String { value("referenceOptionnel") }
    static var entrerUneReference: String { value("entrerUneReference") }
    static var soumettre: String { value("soumettre") }
    static var noLinkedBankAccountsWereReturnedLinkABankAccount: String { value("noLinkedBankAccountsWereReturnedLinkABankAccount") }
    static var veuillezSelectionnerUnCompte: String { value("veuillezSelectionnerUnCompte") }
    static var enterAValidAmountGreaterThanZero: String { value("enterAValidAmountGreaterThanZero") }
    static var confirmerLeTransfert: String { value("confirmerLeTransfert") }
    static var fraisApplicables: String { value("fraisApplicables") }
    static var fraisDeRetrait: String { value("fraisDeRetrait") }
    static var fraisDeTransfert: String { value("fraisDeTransfert") }
    static var totalACrediter: String { value("totalACrediter") }
    static var compteSource3: String { value("compteSource3") }
    static var compte: String { value("compte") }
    static var titulaire2: String { value("titulaire2") }
    static var reference2: String { value("reference2") }
    static var entrerLeCodePin: String { value("entrerLeCodePin") }
    static var confirmer: String { value("confirmer") }
    static var expediteur: String { value("expediteur") }
    static var loadingBeneficiaries: String { value("loadingBeneficiaries") }
    static var couldntLoadBeneficiaries: String { value("couldntLoadBeneficiaries") }
    static var tryAgain: String { value("tryAgain") }
    static var noBeneficiariesYet: String { value("noBeneficiariesYet") }
    static var yourSavedWalletAndBankBeneficiariesWillAppearHere: String { value("yourSavedWalletAndBankBeneficiariesWillAppearHere") }
    static var removeBeneficiary: String { value("removeBeneficiary") }
    static var remove: String { value("remove") }
    static var thisBeneficiaryWillBeRemovedFromYourSavedList: String { value("thisBeneficiaryWillBeRemovedFromYourSavedList") }
    static var couldntRemoveBeneficiary: String { value("couldntRemoveBeneficiary") }
    static func addedValue(_ value0: String) -> String { value("addedValue", arguments: [value0]) }
    static var removeBeneficiary2: String { value("removeBeneficiary2") }
    static var pleaseSignInAgainToLoadYourBeneficiaries: String { value("pleaseSignInAgainToLoadYourBeneficiaries") }
    static var unableToLoadBeneficiaries: String { value("unableToLoadBeneficiaries") }
    static var unableToLoadBeneficiariesPleaseTryAgain: String { value("unableToLoadBeneficiariesPleaseTryAgain") }
    static var beneficiaryDetailsAreIncomplete: String { value("beneficiaryDetailsAreIncomplete") }
    static var pleaseSignInAgainToManageBeneficiaries: String { value("pleaseSignInAgainToManageBeneficiaries") }
    static var unableToRemoveBeneficiary: String { value("unableToRemoveBeneficiary") }
    static var unableToRemoveBeneficiaryPleaseTryAgain: String { value("unableToRemoveBeneficiaryPleaseTryAgain") }
    static var billPayments: String { value("billPayments") }
    static var directionDeLaSecuriteDouaniere: String { value("directionDeLaSecuriteDouaniere") }
    static var biometricSettings: String { value("biometricSettings") }
    static func activerValue(_ value0: String) -> String { value("activerValue", arguments: [value0]) }
    static var connexionRapideEtSecurisee: String { value("connexionRapideEtSecurisee") }
    static var commentCaMarche: String { value("commentCaMarche") }
    static var aLaProchaineConnexionVousVerrezLeBoutonDAuthentification: String { value("aLaProchaineConnexionVousVerrezLeBoutonDAuthentification") }
    static func appuyezSurLeBoutonEtUtilisezVotreValue(_ value0: String) -> String { value("appuyezSurLeBoutonEtUtilisezVotreValue", arguments: [value0]) }
    static var accedezInstantanementAVotrePortefeuille: String { value("accedezInstantanementAVotrePortefeuille") }
    static var laConnexionBiometriqueEstActiveePourUneConnexionRapideEt: String { value("laConnexionBiometriqueEstActiveePourUneConnexionRapideEt") }
    static var activezLaConnexionBiometriquePourUneAuthentificationPlusRapide: String { value("activezLaConnexionBiometriquePourUneAuthentificationPlusRapide") }
    static func confirmerPourActiverValue(_ value0: String) -> String { value("confirmerPourActiverValue", arguments: [value0]) }
    static func valueActiveAvecSucces(_ value0: String) -> String { value("valueActiveAvecSucces", arguments: [value0]) }
    static func impossibleDActiverValue(_ value0: String) -> String { value("impossibleDActiverValue", arguments: [value0]) }
    static func valueDesactive(_ value0: String) -> String { value("valueDesactive", arguments: [value0]) }
    static var entrezVotrePinPourConfirmer: String { value("entrezVotrePinPourConfirmer") }
    static var changeYourPin: String { value("changeYourPin") }
    static var walletInformation: String { value("walletInformation") }
    static var verifyCurrentPin: String { value("verifyCurrentPin") }
    static var enterYourCurrentPin: String { value("enterYourCurrentPin") }
    static var pinVerified: String { value("pinVerified") }
    static var verifyPin: String { value("verifyPin") }
    static var newPin: String { value("newPin") }
    static var enterYourNewPin: String { value("enterYourNewPin") }
    static var confirmYourNewPin: String { value("confirmYourNewPin") }
    static var confirmPinChange: String { value("confirmPinChange") }
    static var areYouSureYouWantToChangeYourPinYou: String { value("areYouSureYouWantToChangeYourPinYou") }
    static var pinIsRequired: String { value("pinIsRequired") }
    static var pinMustContainAtLeast4Digits: String { value("pinMustContainAtLeast4Digits") }
    static var pleaseConfirmYourNewPin: String { value("pleaseConfirmYourNewPin") }
    static var thePinsDoNotMatch: String { value("thePinsDoNotMatch") }
    static func pinVerificationFailedCodeValue(_ value0: String) -> String { value("pinVerificationFailedCodeValue", arguments: [value0]) }
    static var verificationSuccessful: String { value("verificationSuccessful") }
    static var yourCurrentPinHasBeenVerifiedYouCanNowSet: String { value("yourCurrentPinHasBeenVerifiedYouCanNowSet") }
    static var verifyYourCurrentPinFirst: String { value("verifyYourCurrentPinFirst") }
    static var unableToChangePinPleaseTryAgain: String { value("unableToChangePinPleaseTryAgain") }
    static var pinChanged: String { value("pinChanged") }
    static var yourPinWasChangedSuccessfullyUseYourNewPinFor: String { value("yourPinWasChangedSuccessfullyUseYourNewPinFor") }
    static var loadingLimits: String { value("loadingLimits") }
    static var noLimitsConfigured: String { value("noLimitsConfigured") }
    static var refreshWalletLimits: String { value("refreshWalletLimits") }
    static var limitsByTransaction: String { value("limitsByTransaction") }
    static var globalDailyLimit: String { value("globalDailyLimit") }
    static var allYourTransactionsShareThisCommonDailyLimit: String { value("allYourTransactionsShareThisCommonDailyLimit") }
    static var notAvailable: String { value("notAvailable") }
    static var period: String { value("period") }
    static func transactionValue(_ value0: String) -> String { value("transactionValue", arguments: [value0]) }
    static var processingCode: String { value("processingCode") }
    static var dailyUsage: String { value("dailyUsage") }
    static var dailyLimitUsage: String { value("dailyLimitUsage") }
    static var dailyLimit: String { value("dailyLimit") }
    static var usedToday: String { value("usedToday") }
    static var remainingToday: String { value("remainingToday") }
    static var transactionsToday: String { value("transactionsToday") }
    static var canTransact: String { value("canTransact") }
    static var alertLevel: String { value("alertLevel") }
    static var hideDetails: String { value("hideDetails") }
    static var viewDetails: String { value("viewDetails") }
    static var minimumPerTransaction: String { value("minimumPerTransaction") }
    static var maximumPerTransaction: String { value("maximumPerTransaction") }
    static var periodType: String { value("periodType") }
    static var periodLimit: String { value("periodLimit") }
    static var usedThisPeriod: String { value("usedThisPeriod") }
    static var remainingThisPeriod: String { value("remainingThisPeriod") }
    static var periodStarts: String { value("periodStarts") }
    static var periodEnds: String { value("periodEnds") }
    static var notProvided: String { value("notProvided") }
    static var yourWalletDetailsAreMissingPleaseSignInAgain: String { value("yourWalletDetailsAreMissingPleaseSignInAgain") }
    static var unableToLoadWalletLimitsPleaseTryAgain: String { value("unableToLoadWalletLimitsPleaseTryAgain") }
    static var unableToLoadWalletLimitsPleaseCheckYourConnectionAnd: String { value("unableToLoadWalletLimitsPleaseCheckYourConnectionAnd") }
    static var scannerQrCode: String { value("scannerQrCode") }
    static var placezLeCodeQrDansLeCadre: String { value("placezLeCodeQrDansLeCadre") }
    static var leScanSeFeraAutomatiquement: String { value("leScanSeFeraAutomatiquement") }
    static var dsdBills: String { value("dsdBills") }
    static var primoArrivant: String { value("primoArrivant") }
    static var paiementPourPrimoArrivant: String { value("paiementPourPrimoArrivant") }
    static var facturesDsd: String { value("facturesDsd") }
    static var aucuneOperationEnAttente: String { value("aucuneOperationEnAttente") }
    static var lesPaiementsDsdEnAttenteApparaitrontIci: String { value("lesPaiementsDsdEnAttenteApparaitrontIci") }
    static var erreurLorsDuChargementDesPaiements: String { value("erreurLorsDuChargementDesPaiements") }
    static var paiementValideAvecSucces: String { value("paiementValideAvecSucces") }
    static var erreurLorsDeLaValidation: String { value("erreurLorsDeLaValidation") }
    static var paiementRejeteAvecSucces: String { value("paiementRejeteAvecSucces") }
    static var erreurLorsDuRejet: String { value("erreurLorsDuRejet") }
    static var chassis: String { value("chassis") }
    static var montantAPayer: String { value("montantAPayer") }
    static var dateDeCreation: String { value("dateDeCreation") }
    static var rejeter: String { value("rejeter") }
    static var approuver: String { value("approuver") }
    static var categorieA: String { value("categorieA") }
    static var categorieB: String { value("categorieB") }
    static var categorieC: String { value("categorieC") }
    static var categorieD: String { value("categorieD") }
    static var orderFoodFastLocalDelivery: String { value("orderFoodFastLocalDelivery") }
    static var vu: String { value("vu") }
    static var sponsoriserUnPortefeuille: String { value("sponsoriserUnPortefeuille") }
    static var mesLimites: String { value("mesLimites") }
    static var neManquezPasCetteOpportunite: String { value("neManquezPasCetteOpportunite") }
    static var aucuneImageDisponible: String { value("aucuneImageDisponible") }
    static var whatIsGambiapay: String { value("whatIsGambiapay") }
    static var gambiapayIsYourSecureDigitalWalletForManagingPaymentsTransfers: String { value("gambiapayIsYourSecureDigitalWalletForManagingPaymentsTransfers") }
    static var howDoIRegisterForGambiapay: String { value("howDoIRegisterForGambiapay") }
    static var downloadTheGambiapayAppFromTheAppleAppStoreOr: String { value("downloadTheGambiapayAppFromTheAppleAppStoreOr") }
    static var howDoILogInToGambiapay: String { value("howDoILogInToGambiapay") }
    static var openTheGambiapayAppEnterYourPhoneNumberAndPin: String { value("openTheGambiapayAppEnterYourPhoneNumberAndPin") }
    static var iForgotMyPinCodeWhatShouldIDo: String { value("iForgotMyPinCodeWhatShouldIDo") }
    static var contactCustomerSupportWithAValidFormOfIdentificationTo: String { value("contactCustomerSupportWithAValidFormOfIdentificationTo") }
    static var howDoICheckMyGambiapayWalletBalance: String { value("howDoICheckMyGambiapayWalletBalance") }
    static var yourBalanceAppearsWhenYouLogInIfItIs: String { value("yourBalanceAppearsWhenYouLogInIfItIs") }
    static var whyDoesMyBalanceShowAsAsterisks: String { value("whyDoesMyBalanceShowAsAsterisks") }
    static var yourBalanceIsHiddenForSecurityTapTheEyeIcon: String { value("yourBalanceIsHiddenForSecurityTapTheEyeIcon") }
    static var howDoICheckMyTransactionHistory: String { value("howDoICheckMyTransactionHistory") }
    static var afterLoggingInTapSeeMoreBelowYourBalanceTo: String { value("afterLoggingInTapSeeMoreBelowYourBalanceTo") }
    static var howDoISendMoney: String { value("howDoISendMoney") }
    static var tapInternalTransferThenFollowTheseSteps1ChooseThe: String { value("tapInternalTransferThenFollowTheseSteps1ChooseThe") }
    static var howDoILinkMyGambiapayWalletToMyBank: String { value("howDoILinkMyGambiapayWalletToMyBank") }
    static var visitABranchOfYourBankWithValidIdentificationTo: String { value("visitABranchOfYourBankWithValidIdentificationTo") }
    static var howDoIAddMoneyToMyGambiapayWalletFrom: String { value("howDoIAddMoneyToMyGambiapayWalletFrom") }
    static var tapTopUpMyWalletThenSelectYourAccountEnter: String { value("tapTopUpMyWalletThenSelectYourAccountEnter") }
    static var howDoITransferMoneyFromMyGambiapayWalletTo: String { value("howDoITransferMoneyFromMyGambiapayWalletTo") }
    static var tapToMyBankSelectYourAccountEnterTheAmount: String { value("tapToMyBankSelectYourAccountEnterTheAmount") }
    static var howOftenIsMyBalanceUpdated: String { value("howOftenIsMyBalanceUpdated") }
    static var yourBalanceUpdatesInRealTimeWheneverYouOpenOr: String { value("yourBalanceUpdatesInRealTimeWheneverYouOpenOr") }
    static var whatTypesOfTransfersCanIMake: String { value("whatTypesOfTransfersCanIMake") }
    static var walletToWalletWalletToBankAccountBankAccountTo: String { value("walletToWalletWalletToBankAccountBankAccountTo") }
    static var areThereLimitsOnHowMuchICanTransfer: String { value("areThereLimitsOnHowMuchICanTransfer") }
    static var yesLimitsDependOnYourAccountTypeAndVerificationLevel: String { value("yesLimitsDependOnYourAccountTypeAndVerificationLevel") }
    static var howLongDoTransfersTake: String { value("howLongDoTransfersTake") }
    static var mostWalletToWalletTransfersAreInstant: String { value("mostWalletToWalletTransfersAreInstant") }
    static var canIBuyPhoneCreditInTheApp: String { value("canIBuyPhoneCreditInTheApp") }
    static var yesYouCanBuyPhoneCreditForYourselfOrSomeone: String { value("yesYouCanBuyPhoneCreditForYourselfOrSomeone") }
    static var canIBuyDataBundles: String { value("canIBuyDataBundles") }
    static var theAppLetsYouBuyInternetBundlesForSeveralMobile: String { value("theAppLetsYouBuyInternetBundlesForSeveralMobile") }
    static var canIPayBillsWithGambiapay: String { value("canIPayBillsWithGambiapay") }
    static var yesYouCanUseTheAppToPayUtilityAnd: String { value("yesYouCanUseTheAppToPayUtilityAnd") }
    static var whatIsACashVoucher: String { value("whatIsACashVoucher") }
    static var cashVouchersLetYouCreateACodeThatSomeoneElse: String { value("cashVouchersLetYouCreateACodeThatSomeoneElse") }
    static var whatAreStandingInstructions: String { value("whatAreStandingInstructions") }
    static var theyLetYouScheduleRecurringAutomaticTransfersSuchAsMonthly: String { value("theyLetYouScheduleRecurringAutomaticTransfersSuchAsMonthly") }
    static var whatAreSponsoredWallets: String { value("whatAreSponsoredWallets") }
    static var theyLetUsersSponsorAnotherUserOrBeSponsoredTo: String { value("theyLetUsersSponsorAnotherUserOrBeSponsoredTo") }
    static var whatIsASavingsWallet: String { value("whatIsASavingsWallet") }
    static var itHelpsYouSetMoneyAsideSeparatelyFromYourMain: String { value("itHelpsYouSetMoneyAsideSeparatelyFromYourMain") }
    static var howDoIViewRecentTransactions: String { value("howDoIViewRecentTransactions") }
    static var openMiniStatementFromTheMenuToSeeYourRecent: String { value("openMiniStatementFromTheMenuToSeeYourRecent") }
    static var isMyMoneySafeInTheApp: String { value("isMyMoneySafeInTheApp") }
    static var yesGambiapayUsesEncryptionAndSecurityProtocolsToHelpProtect: String { value("yesGambiapayUsesEncryptionAndSecurityProtocolsToHelpProtect") }
    static var canIChangeMyPin: String { value("canIChangeMyPin") }
    static var yesOpenTheMenuAndSelectChangePin: String { value("yesOpenTheMenuAndSelectChangePin") }
    static var whatShouldIDoIfSomeoneAccessesMyAccountWithout: String { value("whatShouldIDoIfSomeoneAccessesMyAccountWithout") }
    static var changeYourPinImmediatelyReviewYourTransactionsAndContactSupport: String { value("changeYourPinImmediatelyReviewYourTransactionsAndContactSupport") }
    static var howDoIDeactivateMyWallet: String { value("howDoIDeactivateMyWallet") }
    static var selectDeactivateWalletFromTheMenuThisActionMayBe: String { value("selectDeactivateWalletFromTheMenuThisActionMayBe") }
    static var howDoIContactCustomerSupport: String { value("howDoIContactCustomerSupport") }
    static var call0612008699UseContactUsInThe: String { value("call0612008699UseContactUsInThe") }
    static var howDoIReportAProblem: String { value("howDoIReportAProblem") }
    static var selectReportAProblemFromTheNavigationMenu: String { value("selectReportAProblemFromTheNavigationMenu") }
    static var canISendFeedbackAboutTheApp: String { value("canISendFeedbackAboutTheApp") }
    static var yesSelectSendFeedbackFromTheMenu: String { value("yesSelectSendFeedbackFromTheMenu") }
    static var theAppWonTLoadMyBalanceWhatShouldI: String { value("theAppWonTLoadMyBalanceWhatShouldI") }
    static var copy1CheckYourInternetConnection2RestartTheApp3: String { value("copy1CheckYourInternetConnection2RestartTheApp3") }
    static var iMHavingProblemsWithTransfersWhatCouldBeWrong: String { value("iMHavingProblemsWithTransfersWhatCouldBeWrong") }
    static var checkYourBalanceInternetConnectionRecipientSNumberAndTransfer: String { value("checkYourBalanceInternetConnectionRecipientSNumberAndTransfer") }
    static var howDoIUpdateTheApp: String { value("howDoIUpdateTheApp") }
    static var checkTheAppStoreOrGooglePlayForTheLatest: String { value("checkTheAppStoreOrGooglePlayForTheLatest") }
    static var theAppCrashesFrequentlyWhatShouldIDo: String { value("theAppCrashesFrequentlyWhatShouldIDo") }
    static var copy1RestartYourDevice2ClearTheAppCache3: String { value("copy1RestartYourDevice2ClearTheAppCache3") }
    static var howDoILogOutOfTheApp: String { value("howDoILogOutOfTheApp") }
    static var openTheMenuAndSelectLogOut: String { value("openTheMenuAndSelectLogOut") }
    static var canIUseTheAppOnMultipleDevices: String { value("canIUseTheAppOnMultipleDevices") }
    static var yesButYouWillNeedToVerifyWithAOne: String { value("yesButYouWillNeedToVerifyWithAOne") }
    static var whatHappensIfIUninstallTheApp: String { value("whatHappensIfIUninstallTheApp") }
    static var yourFundsRemainSafeReinstallTheAppToAccessYour: String { value("yourFundsRemainSafeReinstallTheAppToAccessYour") }
    static var areThereFeesForUsingTheApp: String { value("areThereFeesForUsingTheApp") }
    static var someTransactionsMayHaveFeesContactCustomerSupportForDetails: String { value("someTransactionsMayHaveFeesContactCustomerSupportForDetails") }
    static var frequentlyAskedQuestions: String { value("frequentlyAskedQuestions") }
    static var needHelp: String { value("needHelp") }
    static var feedback: String { value("feedback") }
    static var giveYourOpinion: String { value("giveYourOpinion") }
    static var questionsAnswers: String { value("questionsAnswers") }
    static var noResultsFound: String { value("noResultsFound") }
    static var tryAnotherSearch: String { value("tryAnotherSearch") }
    static var needAdditionalHelp: String { value("needAdditionalHelp") }
    static var ourTeamIsAvailable247ToHelpYou: String { value("ourTeamIsAvailable247ToHelpYou") }
    static var transactionEchouee: String { value("transactionEchouee") }
    static var debitNonAutorise: String { value("debitNonAutorise") }
    static var problemeDeSecurite: String { value("problemeDeSecurite") }
    static var serviceClient: String { value("serviceClient") }
    static var applicationDefaillante: String { value("applicationDefaillante") }
    static var fraisIncorrects: String { value("fraisIncorrects") }
    static var problemeDeCompte: String { value("problemeDeCompte") }
    static var autre: String { value("autre") }
    static var urgentPerteFinanciere: String { value("urgentPerteFinanciere") }
    static var eleveServiceIndisponible: String { value("eleveServiceIndisponible") }
    static var moyenProblemeFonctionnel: String { value("moyenProblemeFonctionnel") }
    static var faibleAmelioration: String { value("faibleAmelioration") }
    static var smsNumeroEnregistre: String { value("smsNumeroEnregistre") }
    static var emailAlternatif: String { value("emailAlternatif") }
    static var nePasMeContacter: String { value("nePasMeContacter") }
    static var deposerUnePlainte: String { value("deposerUnePlainte") }
    static var signalerUnProbleme: String { value("signalerUnProbleme") }
    static var veuillezFournirAutantDeDetailsQuePossiblePourNousAider: String { value("veuillezFournirAutantDeDetailsQuePossiblePourNousAider") }
    static var typeDePlainte: String { value("typeDePlainte") }
    static var priorite: String { value("priorite") }
    static var titre: String { value("titre") }
    static var entrerLeTitre: String { value("entrerLeTitre") }
    static var description2: String { value("description2") }
    static func valueValueCaracteres(_ value0: String, _ value1: String) -> String { value("valueValueCaracteres", arguments: [value0, value1]) }
    static var dateDeLIncident: String { value("dateDeLIncident") }
    static var jjMmAaaa: String { value("jjMmAaaa") }
    static var referenceTransactionOptionnel: String { value("referenceTransactionOptionnel") }
    static var entrerLaReference: String { value("entrerLaReference") }
    static var methodeDeContact: String { value("methodeDeContact") }
    static var emailAlternatif2: String { value("emailAlternatif2") }
    static var entrerVotreEmail: String { value("entrerVotreEmail") }
    static var veuillezEntrerUnTitre: String { value("veuillezEntrerUnTitre") }
    static var leTitreDoitContenirAuMoins5Caracteres: String { value("leTitreDoitContenirAuMoins5Caracteres") }
    static var veuillezDecrireVotrePlainte: String { value("veuillezDecrireVotrePlainte") }
    static var laDescriptionDoitContenirAuMoins20Caracteres: String { value("laDescriptionDoitContenirAuMoins20Caracteres") }
    static var veuillezEntrerLaDateDeLIncident: String { value("veuillezEntrerLaDateDeLIncident") }
    static var formatDEmailInvalide: String { value("formatDEmailInvalide") }
    static var copy2448Heures: String { value("copy2448Heures") }
    static var copy23JoursOuvrables: String { value("copy23JoursOuvrables") }
    static var copy57JoursOuvrables: String { value("copy57JoursOuvrables") }
    static var copy714JoursOuvrables: String { value("copy714JoursOuvrables") }
    static var donneesInvalidesVeuillezVerifierVosInformations: String { value("donneesInvalidesVeuillezVerifierVosInformations") }
    static var vousAvezDeposeTropDePlaintesRecemmentVeuillezAttendre: String { value("vousAvezDeposeTropDePlaintesRecemmentVeuillezAttendre") }
    static var erreurDuServeurVeuillezReessayerPlusTard: String { value("erreurDuServeurVeuillezReessayerPlusTard") }
    static var confirmerLeDepotDePlainte: String { value("confirmerLeDepotDePlainte") }
    static var type2: String { value("type2") }
    static var priorite2: String { value("priorite2") }
    static var titre2: String { value("titre2") }
    static var resolutionEstimee: String { value("resolutionEstimee") }
    static var etesVousSurDeVouloirDeposerCettePlainte: String { value("etesVousSurDeVouloirDeposerCettePlainte") }
    static var deposer: String { value("deposer") }
    static var plainteDeposee: String { value("plainteDeposee") }
    static var tempsDeResolutionEstime: String { value("tempsDeResolutionEstime") }
    static var vousRecevrezUneConfirmationEtDesMisesAJourSelon: String { value("vousRecevrezUneConfirmationEtDesMisesAJourSelon") }
    static var foodQuality: String { value("foodQuality") }
    static var missingItem: String { value("missingItem") }
    static var lateDelivery: String { value("lateDelivery") }
    static var incorrectOrder: String { value("incorrectOrder") }
    static var restaurantService: String { value("restaurantService") }
    static var other: String { value("other") }
    static var foodComplaints: String { value("foodComplaints") }
    static var loadingComplaints: String { value("loadingComplaints") }
    static var foodComplaints2: String { value("foodComplaints2") }
    static var complaintSubmitted: String { value("complaintSubmitted") }
    static var noFoodComplaintsYet: String { value("noFoodComplaintsYet") }
    static var ifSomethingWentWrongWithAFoodOrderTellUs: String { value("ifSomethingWentWrongWithAFoodOrderTellUs") }
    static var fileAFoodServiceComplaint: String { value("fileAFoodServiceComplaint") }
    static var placeAFoodOrderFirstToFileAComplaintAbout: String { value("placeAFoodOrderFirstToFileAComplaintAbout") }
    static var foodService: String { value("foodService") }
    static func orderValue(_ value0: String) -> String { value("orderValue", arguments: [value0]) }
    static var response: String { value("response") }
    static var order: String { value("order") }
    static var selectAnOrder: String { value("selectAnOrder") }
    static var whatWentWrong: String { value("whatWentWrong") }
    static var complaintType: String { value("complaintType") }
    static var describeTheIssue: String { value("describeTheIssue") }
    static var newComplaint: String { value("newComplaint") }
    static var couldNotLoadFoodComplaints: String { value("couldNotLoadFoodComplaints") }
    static var yourComplaintHasBeenSubmitted: String { value("yourComplaintHasBeenSubmitted") }
    static var couldNotSubmitYourComplaint: String { value("couldNotSubmitYourComplaint") }
    static var premierAcces: String { value("premierAcces") }
    static var pinExpire: String { value("pinExpire") }
    static var changementObligatoire: String { value("changementObligatoire") }
    static var bienvenueVousDevezCreerVotreCodePinPourVotrePremier: String { value("bienvenueVousDevezCreerVotreCodePinPourVotrePremier") }
    static var votreCodePinAExpireVousDevezLeModifierPour: String { value("votreCodePinAExpireVousDevezLeModifierPour") }
    static var modifierVotreCodePin: String { value("modifierVotreCodePin") }
    static var codePinActuel: String { value("codePinActuel") }
    static var nouveauCodePin: String { value("nouveauCodePin") }
    static var cePinNEstPasSecuriseVeuillezEnChoisirUn: String { value("cePinNEstPasSecuriseVeuillezEnChoisirUn") }
    static var confirmerLeNouveauPin: String { value("confirmerLeNouveauPin") }
    static var changerLePin: String { value("changerLePin") }
    static var confirmationDeChangementDePin: String { value("confirmationDeChangementDePin") }
    static var confirmezVousLeChangementDeVotreCodePinCetteAction: String { value("confirmezVousLeChangementDeVotreCodePinCetteAction") }
    static var leCodePinActuelEstRequis: String { value("leCodePinActuelEstRequis") }
    static var leCodePinDoitContenirAuMoins4Chiffres: String { value("leCodePinDoitContenirAuMoins4Chiffres") }
    static var leNouveauCodePinEstRequis: String { value("leNouveauCodePinEstRequis") }
    static var leNouveauPinDoitEtreDifferentDeLAncien: String { value("leNouveauPinDoitEtreDifferentDeLAncien") }
    static var ceCodePinNEstPasSecuriseEx00001111: String { value("ceCodePinNEstPasSecuriseEx00001111") }
    static var laConfirmationDuCodePinEstRequise: String { value("laConfirmationDuCodePinEstRequise") }
    static var lesCodesPinNeCorrespondentPas: String { value("lesCodesPinNeCorrespondentPas") }
    static var codePinModifie: String { value("codePinModifie") }
    static var votreCodePinAEteModifieAvecSuccesUtilisezCe: String { value("votreCodePinAEteModifieAvecSuccesUtilisezCe") }
    static var erreurLorsDuChangementDePin: String { value("erreurLorsDuChangementDePin") }
    static var codePinActuelIncorrect: String { value("codePinActuelIncorrect") }
    static var conseilsDeSecurite: String { value("conseilsDeSecurite") }
    static var choisissezUnCodePinUniqueEtDifficileADeviner: String { value("choisissezUnCodePinUniqueEtDifficileADeviner") }
    static var nePartagezJamaisVotreCodePinAvecPersonne: String { value("nePartagezJamaisVotreCodePinAvecPersonne") }
    static var votreCodePinExpireTousLes90JoursPourVotre: String { value("votreCodePinExpireTousLes90JoursPourVotre") }
    static var evitezLesCodesSimplesComme1234Ou0000: String { value("evitezLesCodesSimplesComme1234Ou0000") }
    static var nDeTelephone: String { value("nDeTelephone") }
    static var votreReponse: String { value("votreReponse") }
    static var nouveauPin: String { value("nouveauPin") }
    static var confirmerPin: String { value("confirmerPin") }
    static var entrerOtp: String { value("entrerOtp") }
    static var retourALaConnexion: String { value("retourALaConnexion") }
    static var entrerVotreNumeroDeTelephone: String { value("entrerVotreNumeroDeTelephone") }
    static var questionSecrete: String { value("questionSecrete") }
    static var reinitialiserPin: String { value("reinitialiserPin") }
    static var verifierOtp: String { value("verifierOtp") }
    static var saisissezVotreNumeroDeTelephoneEnregistre: String { value("saisissezVotreNumeroDeTelephoneEnregistre") }
    static var repondezAVotreQuestionDeSecuritePourVerifierVotreIdentite: String { value("repondezAVotreQuestionDeSecuritePourVerifierVotreIdentite") }
    static var saisissezVotreNouveauCodePinA4Chiffres: String { value("saisissezVotreNouveauCodePinA4Chiffres") }
    static func entrezLeCodeA6ChiffresEnvoyeAValue(_ value0: String) -> String { value("entrezLeCodeA6ChiffresEnvoyeAValue", arguments: [value0]) }
    static var chargementDeLaQuestion: String { value("chargementDeLaQuestion") }
    static var questionNonDisponible: String { value("questionNonDisponible") }
    static func questionIdValue(_ value0: String) -> String { value("questionIdValue", arguments: [value0]) }
    static var veuillezEntrerVotreNumeroDeTelephone: String { value("veuillezEntrerVotreNumeroDeTelephone") }
    static var veuillezRepondreAVotreQuestion: String { value("veuillezRepondreAVotreQuestion") }
    static var veuillezEntrerVotreReponse: String { value("veuillezEntrerVotreReponse") }
    static var verificationReussie: String { value("verificationReussie") }
    static var veuillezRemplirTousLesChampsPin: String { value("veuillezRemplirTousLesChampsPin") }
    static var lePinDoitContenir4Chiffres: String { value("lePinDoitContenir4Chiffres") }
    static var lesPinsNeCorrespondentPas: String { value("lesPinsNeCorrespondentPas") }
    static var otpEnvoye: String { value("otpEnvoye") }
    static var pinReinitialiseAvecSucces: String { value("pinReinitialiseAvecSucces") }
    static var veuillezEntrerUnOtpA6ChiffresValide: String { value("veuillezEntrerUnOtpA6ChiffresValide") }
    static var tokenNonTrouveVeuillezRecommencer: String { value("tokenNonTrouveVeuillezRecommencer") }
    static var uneErreurSEstProduite: String { value("uneErreurSEstProduite") }
    static var tropDeTentativesVeuillezReessayerPlusTard: String { value("tropDeTentativesVeuillezReessayerPlusTard") }
    static var votreCompteEstBloqueVeuillezContacterLeSupportClient: String { value("votreCompteEstBloqueVeuillezContacterLeSupportClient") }
    static var otpInvalideVeuillezVerifierEtReessayer: String { value("otpInvalideVeuillezVerifierEtReessayer") }
    static var reponseIncorrecteVeuillezReessayer: String { value("reponseIncorrecteVeuillezReessayer") }
    static var linkedBankAccounts: String { value("linkedBankAccounts") }
    static var chargementEnCours: String { value("chargementEnCours") }
    static var comptesBancairesLies: String { value("comptesBancairesLies") }
    static var aucunCompteBancaireLieTrouve: String { value("aucunCompteBancaireLieTrouve") }
    static var erreurLorsDeLaRecuperationDesComptes: String { value("erreurLorsDeLaRecuperationDesComptes") }
    static func erreurDeConnexionValue(_ value0: String) -> String { value("erreurDeConnexionValue", arguments: [value0]) }
    static func soldeMisAJourValueValue(_ value0: String, _ value1: String) -> String { value("soldeMisAJourValueValue", arguments: [value0, value1]) }
    static var impossibleDeRecupererLeSolde: String { value("impossibleDeRecupererLeSolde") }
    static var echecDeLaConnexion: String { value("echecDeLaConnexion") }
    static var solde: String { value("solde") }
    static var verificationDuCodePin: String { value("verificationDuCodePin") }
    static var entrezVotreCodePinPourContinuer: String { value("entrezVotreCodePinPourContinuer") }
    static var verifier: String { value("verifier") }
    static var loanProvider: String { value("loanProvider") }
    static var selectLoanProvider: String { value("selectLoanProvider") }
    static var loanAmount: String { value("loanAmount") }
    static var enterAmountGmd: String { value("enterAmountGmd") }
    static var purposeOfLoan: String { value("purposeOfLoan") }
    static var selectPurpose: String { value("selectPurpose") }
    static var repaymentPeriod: String { value("repaymentPeriod") }
    static var selectRepaymentPeriod: String { value("selectRepaymentPeriod") }
    static func valueMonths(_ value0: String) -> String { value("valueMonths", arguments: [value0]) }
    static var remarksOptional: String { value("remarksOptional") }
    static var addANote: String { value("addANote") }
    static var iAcceptTheLoanTermsConditions: String { value("iAcceptTheLoanTermsConditions") }
    static var submitRequest: String { value("submitRequest") }
    static var requestSubmitted: String { value("requestSubmitted") }
    static var loanRequest: String { value("loanRequest") }
    static var chooseALoanProviderAndPurpose: String { value("chooseALoanProviderAndPurpose") }
    static var enterAValidLoanAmount: String { value("enterAValidLoanAmount") }
    static var pleaseAcceptTheLoanTermsToContinue: String { value("pleaseAcceptTheLoanTermsToContinue") }
    static var yourLoanRequestHasBeenReceived: String { value("yourLoanRequestHasBeenReceived") }
    static var all: String { value("all") }
    static var filterLoanRequests: String { value("filterLoanRequests") }
    static var filterByStatusOrProvider: String { value("filterByStatusOrProvider") }
    static var provider: String { value("provider") }
    static var noLoanRequests: String { value("noLoanRequests") }
    static var yourSubmittedLoanRequestsWillAppearHere: String { value("yourSubmittedLoanRequestsWillAppearHere") }
    static var loanRequests: String { value("loanRequests") }
    static var loanProvider2: String { value("loanProvider2") }
    static var loanRequestDetails: String { value("loanRequestDetails") }
    static var requestedAmount: String { value("requestedAmount") }
    static var purpose: String { value("purpose") }
    static func valueMonths2(_ value0: String) -> String { value("valueMonths2", arguments: [value0]) }
    static var requestDate: String { value("requestDate") }
    static var approvalDate: String { value("approvalDate") }
    static var remarks: String { value("remarks") }
    static var currentStatus: String { value("currentStatus") }
    static var yourRequestStatusWillUpdateAsItProgresses: String { value("yourRequestStatusWillUpdateAsItProgresses") }
    static var cancelRequest: String { value("cancelRequest") }
    static var loanDetails: String { value("loanDetails") }
    static var cancelThisLoanRequest: String { value("cancelThisLoanRequest") }
    static var yourRequestHasBeenCancelled: String { value("yourRequestHasBeenCancelled") }
    static var youMustHaveAnActiveGambiapayWalletAndProvideAccurate: String { value("youMustHaveAnActiveGambiapayWalletAndProvideAccurate") }
    static var loanConditions: String { value("loanConditions") }
    static var loanAmountsFeesInterestAndFinalApprovalAreDeterminedBy: String { value("loanAmountsFeesInterestAndFinalApprovalAreDeterminedBy") }
    static var repaymentDatesAndMethodsAreSetByTheLoanProvider: String { value("repaymentDatesAndMethodsAreSetByTheLoanProvider") }
    static var privacyPolicy: String { value("privacyPolicy") }
    static var informationEnteredForALoanRequestIsSharedWithThe: String { value("informationEnteredForALoanRequestIsSharedWithThe") }
    static var howDoIApplyForALoan: String { value("howDoIApplyForALoan") }
    static var chooseAProviderEnterTheAmountAndPurposeSelectA: String { value("chooseAProviderEnterTheAmountAndPurposeSelectA") }
    static var howLongDoesApprovalTake: String { value("howLongDoesApprovalTake") }
    static var theSelectedProviderReviewsEachApplicationProcessingTimesVaryCheck: String { value("theSelectedProviderReviewsEachApplicationProcessingTimesVaryCheck") }
    static var canICancelMyLoanRequest: String { value("canICancelMyLoanRequest") }
    static var youCanCancelARequestWhileItsStatusIsPending: String { value("youCanCancelARequestWhileItsStatusIsPending") }
    static var howDoIRepayMyLoan: String { value("howDoIRepayMyLoan") }
    static var repaymentIsHandledByTheLoanProviderFollowTheRepayment: String { value("repaymentIsHandledByTheLoanProviderFollowTheRepayment") }
    static var whatHappensIfIMissAPayment: String { value("whatHappensIfIMissAPayment") }
    static var contactYourLoanProviderPromptlyFeesOrOtherConsequencesDepend: String { value("contactYourLoanProviderPromptlyFeesOrOtherConsequencesDepend") }
    static var canIRepayMyLoanEarly: String { value("canIRepayMyLoanEarly") }
    static var earlyRepaymentRulesDependOnYourProviderContactThemTo: String { value("earlyRepaymentRulesDependOnYourProviderContactThemTo") }
    static var loanHelp2: String { value("loanHelp2") }
    static var loanTermsConditions: String { value("loanTermsConditions") }
    static var gambiapayLoanServices: String { value("gambiapayLoanServices") }
    static var searchTermsAndFaqs: String { value("searchTermsAndFaqs") }
    static var acceptContinue: String { value("acceptContinue") }
    static var loanFaqs: String { value("loanFaqs") }
    static func versionValue(_ value0: String) -> String { value("versionValue", arguments: [value0]) }
    static var biometricCredentialsNotFoundPleaseLoginWithYourPin: String { value("biometricCredentialsNotFoundPleaseLoginWithYourPin") }
    static var biometricUnavailable: String { value("biometricUnavailable") }
    static var authenticationFailed: String { value("authenticationFailed") }
    static var tropDeTentativesVeuillezReessayerDansQuelquesMinutes: String { value("tropDeTentativesVeuillezReessayerDansQuelquesMinutes") }
    static var limiteAtteinte: String { value("limiteAtteinte") }
    static var uneNouvelleVersionDeLApplicationEstDisponibleVeuillezMettre: String { value("uneNouvelleVersionDeLApplicationEstDisponibleVeuillezMettre") }
    static var votreCompteEstBloqueVeuillezContacterLeServiceClient: String { value("votreCompteEstBloqueVeuillezContacterLeServiceClient") }
    static var compteBloque: String { value("compteBloque") }
    static var codePinExpire: String { value("codePinExpire") }
    static var votreCodePinAExpireVousDevezLeModifierPour2: String { value("votreCodePinAExpireVousDevezLeModifierPour2") }
    static var numeroDeTelephoneOuPinIncorrect: String { value("numeroDeTelephoneOuPinIncorrect") }
    static var erreurDeConnexion: String { value("erreurDeConnexion") }
    static var compteIntrouvableVeuillezVerifierVotreNumeroDeTelephone: String { value("compteIntrouvableVeuillezVerifierVotreNumeroDeTelephone") }
    static var compteIntrouvable: String { value("compteIntrouvable") }
    static var uneErreurEstSurvenue: String { value("uneErreurEstSurvenue") }
    static var erreurReseau: String { value("erreurReseau") }
    static var loginFailed: String { value("loginFailed") }
    static var loginFailed2: String { value("loginFailed2") }
    static var loginErrorNoAuthenticationTokenReceived: String { value("loginErrorNoAuthenticationTokenReceived") }
    static var loginError: String { value("loginError") }
    static var loginErrorCouldNotSaveAuthenticationData: String { value("loginErrorCouldNotSaveAuthenticationData") }
    static func activerValue2(_ value0: String) -> String { value("activerValue2", arguments: [value0]) }
    static func voulezVousUtiliserValuePourUnAccesPlusRapideEt(_ value0: String) -> String { value("voulezVousUtiliserValuePourUnAccesPlusRapideEt", arguments: [value0]) }
    static var activer: String { value("activer") }
    static var pasMaintenant: String { value("pasMaintenant") }
    static var miniStatement: String { value("miniStatement") }
    static var dateDeDebut: String { value("dateDeDebut") }
    static var dateDeFin: String { value("dateDeFin") }
    static var miniReleve: String { value("miniReleve") }
    static var de: String { value("de") }
    static var a: String { value("a") }
    static var telechargerLeReleve: String { value("telechargerLeReleve") }
    static var laRechercheAfficheLes5DernieresTransactions: String { value("laRechercheAfficheLes5DernieresTransactions") }
    static var aucuneTransaction: String { value("aucuneTransaction") }
    static var ilNYAPasDeTransactionsPourLaPeriode: String { value("ilNYAPasDeTransactionsPourLaPeriode") }
    static var echecDeLaRecuperationDesTransactions: String { value("echecDeLaRecuperationDesTransactions") }
    static var erreurDeConnexionVerifiezVotreInternet: String { value("erreurDeConnexionVerifiezVotreInternet") }
    static var releveTelechargeAvecSucces: String { value("releveTelechargeAvecSucces") }
    static var echecDuTelechargementDuReleve: String { value("echecDuTelechargementDuReleve") }
    static var ref: String { value("ref") }
    static var solde2: String { value("solde2") }
    static func wouldYouLikeToSaveValueForFutureMobileMoney(_ value0: String) -> String { value("wouldYouLikeToSaveValueForFutureMobileMoney", arguments: [value0]) }
    static var confirmMobileMoney: String { value("confirmMobileMoney") }
    static var providerDetails: String { value("providerDetails") }
    static var loadingProviders: String { value("loadingProviders") }
    static var selectProvider: String { value("selectProvider") }
    static var beneficiaryDetails: String { value("beneficiaryDetails") }
    static var phoneNumber2: String { value("phoneNumber2") }
    static var beneficiaryName2: String { value("beneficiaryName2") }
    static var saveRecipient2: String { value("saveRecipient2") }
    static var paymentReference: String { value("paymentReference") }
    static var enterPaymentReference: String { value("enterPaymentReference") }
    static var noProvidersAreAvailable: String { value("noProvidersAreAvailable") }
    static var unableToLoadProviders: String { value("unableToLoadProviders") }
    static var pleaseSelectAProvider: String { value("pleaseSelectAProvider") }
    static var beneficiaryPhoneNumberIsRequired: String { value("beneficiaryPhoneNumberIsRequired") }
    static var enterAValidAmount: String { value("enterAValidAmount") }
    static var yourWalletDetailsAreUnavailablePleaseSignInAgain: String { value("yourWalletDetailsAreUnavailablePleaseSignInAgain") }
    static var theReceiverWasFoundButVerificationCouldNotBeCompleted: String { value("theReceiverWasFoundButVerificationCouldNotBeCompleted") }
    static var receiverPhoneNumberWasNotFoundForTheSelectedProvider: String { value("receiverPhoneNumberWasNotFoundForTheSelectedProvider") }
    static var unableToVerifyTheReceiverPhoneNumber: String { value("unableToVerifyTheReceiverPhoneNumber") }
    static var mobileMoneyTransferFailed: String { value("mobileMoneyTransferFailed") }
    static var mobileMoneyTransferCouldNotBeConfirmedCheckTransactionHistory: String { value("mobileMoneyTransferCouldNotBeConfirmedCheckTransactionHistory") }
    static var enterABeneficiaryPhoneNumberBeforeSaving: String { value("enterABeneficiaryPhoneNumberBeforeSaving") }
    static var recipientSaved: String { value("recipientSaved") }
    static var theRecipientHasBeenSaved: String { value("theRecipientHasBeenSaved") }
    static var unableToSaveTheBeneficiary: String { value("unableToSaveTheBeneficiary") }
    static var votrePortefeuilleDigitalSecurise: String { value("votrePortefeuilleDigitalSecurise") }
    static var transfert: String { value("transfert") }
    static var transfererDeLArgent: String { value("transfererDeLArgent") }
    static var walletVersMaBanque: String { value("walletVersMaBanque") }
    static var banqueVersMonWallet: String { value("banqueVersMonWallet") }
    static var virementsPermanents: String { value("virementsPermanents") }
    static var afficherMesParrains: String { value("afficherMesParrains") }
    static var demandeDeMiniReleve: String { value("demandeDeMiniReleve") }
    static var desactiverMonCompte: String { value("desactiverMonCompte") }
    static var transactionAValider: String { value("transactionAValider") }
    static var comptesBancaires: String { value("comptesBancaires") }
    static var parametre: String { value("parametre") }
    static var changerLeCodePin: String { value("changerLeCodePin") }
    static var connexionBiometrique: String { value("connexionBiometrique") }
    static var ecrireUnCommentaire: String { value("ecrireUnCommentaire") }
    static var declarerUnIncident: String { value("declarerUnIncident") }
    static func wouldYouLikeToSaveValueForFutureVoucherTransfers(_ value0: String) -> String { value("wouldYouLikeToSaveValueForFutureVoucherTransfers", arguments: [value0]) }
    static var miseADisposition: String { value("miseADisposition") }
    static var recipientName2: String { value("recipientName2") }
    static var idNumber: String { value("idNumber") }
    static var ajouterLesFraisDeRetrait: String { value("ajouterLesFraisDeRetrait") }
    static func feeValue(_ value0: String) -> String { value("feeValue", arguments: [value0]) }
    static var aucunFraisApplicable: String { value("aucunFraisApplicable") }
    static var enterAnAmountToSeeTheFee: String { value("enterAnAmountToSeeTheFee") }
    static var veuillezSelectionnerUnPortefeuilleSponsor: String { value("veuillezSelectionnerUnPortefeuilleSponsor") }
    static var amountExceedsTheSponsorSDailyLimit: String { value("amountExceedsTheSponsorSDailyLimit") }
    static var recipientPhoneNumberIsRequired: String { value("recipientPhoneNumberIsRequired") }
    static var enterAValidAmount2: String { value("enterAValidAmount2") }
    static func impossibleDeCalculerLesFraisValue(_ value0: String) -> String { value("impossibleDeCalculerLesFraisValue", arguments: [value0]) }
    static var erreurReseauLorsDuCalculDesFrais: String { value("erreurReseauLorsDuCalculDesFrais") }
    static func voucherTransferFailedValue(_ value0: String) -> String { value("voucherTransferFailedValue", arguments: [value0]) }
    static var recipientDetailsAreUnavailableSoTheVoucherRecipientCouldNot: String { value("recipientDetailsAreUnavailableSoTheVoucherRecipientCouldNot") }
    static var theVoucherRecipientHasBeenSaved: String { value("theVoucherRecipientHasBeenSaved") }
    static var unableToSaveTheVoucherRecipient: String { value("unableToSaveTheVoucherRecipient") }
    static var transferConfirmation: String { value("transferConfirmation") }
    static var loadingProfile: String { value("loadingProfile") }
    static var profileUnavailable: String { value("profileUnavailable") }
    static var personalInformation: String { value("personalInformation") }
    static var customerName: String { value("customerName") }
    static var firstName: String { value("firstName") }
    static var familyName: String { value("familyName") }
    static var email: String { value("email") }
    static var address: String { value("address") }
    static var walletInformation2: String { value("walletInformation2") }
    static var walletNumber2: String { value("walletNumber2") }
    static var walletType: String { value("walletType") }
    static var walletStatus: String { value("walletStatus") }
    static var kycLevel: String { value("kycLevel") }
    static var registrationDate: String { value("registrationDate") }
    static var bankCode: String { value("bankCode") }
    static var identification: String { value("identification") }
    static var nationalId: String { value("nationalId") }
    static var documentCode: String { value("documentCode") }
    static var nextOfKin: String { value("nextOfKin") }
    static var refreshProfile: String { value("refreshProfile") }
    static var unableToLoadYourProfilePleaseTryAgain: String { value("unableToLoadYourProfilePleaseTryAgain") }
    static var unableToLoadYourProfilePleaseCheckYourConnectionAnd: String { value("unableToLoadYourProfilePleaseCheckYourConnectionAnd") }
    static var myQrCode: String { value("myQrCode") }
    static var generationDuCodeQr: String { value("generationDuCodeQr") }
    static var aucunCodeQrDisponible: String { value("aucunCodeQrDisponible") }
    static var enregistrer: String { value("enregistrer") }
    static var partager: String { value("partager") }
    static var commentCaMarche2: String { value("commentCaMarche2") }
    static var copy1MontrezOuEnvoyezCeCodeQrALaPersonne: String { value("copy1MontrezOuEnvoyezCeCodeQrALaPersonne") }
    static var numeroDeTelephoneNonTrouve: String { value("numeroDeTelephoneNonTrouve") }
    static var donneesQrManquantes: String { value("donneesQrManquantes") }
    static var donneesQrVides: String { value("donneesQrVides") }
    static var erreurGenerationImageQr: String { value("erreurGenerationImageQr") }
    static var aucunCodeQrAEnregistrer: String { value("aucunCodeQrAEnregistrer") }
    static var codeQrEnregistreDansLaGalerie: String { value("codeQrEnregistreDansLaGalerie") }
    static var foodHistory2: String { value("foodHistory2") }
    static var findingRestaurants: String { value("findingRestaurants") }
    static var orderFood2: String { value("orderFood2") }
    static var orderPlaced: String { value("orderPlaced") }
    static var restaurantsNearYou: String { value("restaurantsNearYou") }
    static var myOrders: String { value("myOrders") }
    static var noRestaurantsAreAvailableRightNow: String { value("noRestaurantsAreAvailableRightNow") }
    static var restaurant: String { value("restaurant") }
    static var openNow: String { value("openNow") }
    static var checkAvailability: String { value("checkAvailability") }
    static var loadingMenu: String { value("loadingMenu") }
    static func valueItems(_ value0: String) -> String { value("valueItems", arguments: [value0]) }
    static var thisRestaurantHasNoMenuItemsAvailable: String { value("thisRestaurantHasNoMenuItemsAvailable") }
    static var menuItem: String { value("menuItem") }
    static var deliverTo: String { value("deliverTo") }
    static var chooseDeliveryAddress: String { value("chooseDeliveryAddress") }
    static var addAddress: String { value("addAddress") }
    static var deliveryAddress: String { value("deliveryAddress") }
    static var addNewAddress: String { value("addNewAddress") }
    static var placingOrder: String { value("placingOrder") }
    static func placeOrderGmdValue(_ value0: String) -> String { value("placeOrderGmdValue", arguments: [value0]) }
    static var labelHomeWork: String { value("labelHomeWork") }
    static var streetAddress: String { value("streetAddress") }
    static var apartmentSuiteOptional: String { value("apartmentSuiteOptional") }
    static var city: String { value("city") }
    static var yourOrdersWillAppearHere: String { value("yourOrdersWillAppearHere") }
    static var getHelp: String { value("getHelp") }
    static var tellUsWhatHappened: String { value("tellUsWhatHappened") }
    static var contactSupport: String { value("contactSupport") }
    static var send: String { value("send") }
    static var couldNotLoadRestaurants: String { value("couldNotLoadRestaurants") }
    static var couldNotLoadTheMenu: String { value("couldNotLoadTheMenu") }
    static var couldNotCancelThisOrder: String { value("couldNotCancelThisOrder") }
    static var yourMessageHasBeenSent: String { value("yourMessageHasBeenSent") }
    static var couldNotSendYourMessage: String { value("couldNotSendYourMessage") }
    static var yourOrderHasBeenReceived: String { value("yourOrderHasBeenReceived") }
    static var couldNotPlaceYourOrder: String { value("couldNotPlaceYourOrder") }
    static var couldNotSaveThisAddress: String { value("couldNotSaveThisAddress") }
    static var verifiezVotreAppareil: String { value("verifiezVotreAppareil") }
    static func entrezLeCodeOtpEnvoyeAValue(_ value0: String) -> String { value("entrezLeCodeOtpEnvoyeAValue", arguments: [value0]) }
    static var otpVerificationFailed: String { value("otpVerificationFailed") }
    static var loadingTransactions2: String { value("loadingTransactions2") }
    static var waitingForYourApproval: String { value("waitingForYourApproval") }
    static var noPendingTransactions: String { value("noPendingTransactions") }
    static var youreAllCaughtUp: String { value("youreAllCaughtUp") }
    static var couldNotLoadPendingTransactions: String { value("couldNotLoadPendingTransactions") }
    static func transactionValueSuccessfully(_ value0: String) -> String { value("transactionValueSuccessfully", arguments: [value0]) }
    static func couldNotUpdateTransactionValue(_ value0: String) -> String { value("couldNotUpdateTransactionValue", arguments: [value0]) }
    static var fees: String { value("fees") }
    static var tax: String { value("tax") }
    static var reject: String { value("reject") }
    static var approve: String { value("approve") }
    static var codePinRequis: String { value("codePinRequis") }
    static func entrezVotreCodePinPourValueLaTransaction(_ value0: String) -> String { value("entrezVotreCodePinPourValueLaTransaction", arguments: [value0]) }
    static var reference3: String { value("reference3") }
    static var entrezVotreCodePin: String { value("entrezVotreCodePin") }
    static var leCodePinEstObligatoire: String { value("leCodePinEstObligatoire") }
    static var codeQrInvalide: String { value("codeQrInvalide") }
    static var qrInvalideOuExpire: String { value("qrInvalideOuExpire") }
    static var erreurDeValidation: String { value("erreurDeValidation") }
    static var qrExpireOuInvalide: String { value("qrExpireOuInvalide") }
    static var impossibleDeCalculerLesFrais: String { value("impossibleDeCalculerLesFrais") }
    static func erreurLorsDuCalculDesFraisValue(_ value0: String) -> String { value("erreurLorsDuCalculDesFraisValue", arguments: [value0]) }
    static func paymentToValue(_ value0: String) -> String { value("paymentToValue", arguments: [value0]) }
    static func paiementEchoueValue(_ value0: String) -> String { value("paiementEchoueValue", arguments: [value0]) }
    static var erreurReseau2: String { value("erreurReseau2") }
    static var merchantPayment: String { value("merchantPayment") }
    static var chooseScanMethod: String { value("chooseScanMethod") }
    static var camera: String { value("camera") }
    static var scanNow: String { value("scanNow") }
    static var gallery: String { value("gallery") }
    static var fromPhotos: String { value("fromPhotos") }
    static var quickTip: String { value("quickTip") }
    static var scanTheQrCodeDisplayedAtTheMerchantLocationTo: String { value("scanTheQrCodeDisplayedAtTheMerchantLocationTo") }
    static var paiementQrCodeEmv: String { value("paiementQrCodeEmv") }
    static var permissionCameraRequise: String { value("permissionCameraRequise") }
    static var activezLaCameraDansLesReglages: String { value("activezLaCameraDansLesReglages") }
    static var aucunQrDetecte: String { value("aucunQrDetecte") }
    static var choosePhotoSource: String { value("choosePhotoSource") }
    static var chooseHowToAddThePhoto: String { value("chooseHowToAddThePhoto") }
    static var camera2: String { value("camera2") }
    static var photoLibrary: String { value("photoLibrary") }
    static func stepValueOfValue(_ value0: String, _ value1: String) -> String { value("stepValueOfValue", arguments: [value0, value1]) }
    static var enterYourPersonalInformation: String { value("enterYourPersonalInformation") }
    static var basicInformation: String { value("basicInformation") }
    static var firstName2: String { value("firstName2") }
    static var lastName: String { value("lastName") }
    static var phoneNumber3: String { value("phoneNumber3") }
    static var email2: String { value("email2") }
    static var dateOfBirth: String { value("dateOfBirth") }
    static var gender: String { value("gender") }
    static var male: String { value("male") }
    static var female: String { value("female") }
    static var selectYourGender: String { value("selectYourGender") }
    static var nationalId2: String { value("nationalId2") }
    static var chooseABranch: String { value("chooseABranch") }
    static var residentialAddress: String { value("residentialAddress") }
    static var security: String { value("security") }
    static var secretQuestion: String { value("secretQuestion") }
    static var selectAQuestion: String { value("selectAQuestion") }
    static var yourAnswer: String { value("yourAnswer") }
    static var nextOfKin2: String { value("nextOfKin2") }
    static var nextOfKinName: String { value("nextOfKinName") }
    static var nextOfKinPhone: String { value("nextOfKinPhone") }
    static var createYourPinCode: String { value("createYourPinCode") }
    static var thisPinCodeWillSecureYourAccountAndConfirmYour: String { value("thisPinCodeWillSecureYourAccountAndConfirmYour") }
    static var enterYour4DigitPinCode: String { value("enterYour4DigitPinCode") }
    static var confirmYourPinCode: String { value("confirmYourPinCode") }
    static var chooseALessPredictablePin: String { value("chooseALessPredictablePin") }
    static var pinLooksSecure: String { value("pinLooksSecure") }
    static var pinsMustMatch: String { value("pinsMustMatch") }
    static var scanYourIdentificationDocuments: String { value("scanYourIdentificationDocuments") }
    static var toValidateYourAccountScanTheRequestedDocumentsMakeSure: String { value("toValidateYourAccountScanTheRequestedDocumentsMakeSure") }
    static var personalPhoto: String { value("personalPhoto") }
    static var takeAWellLitPhotoOfYourFaceWithoutGlasses: String { value("takeAWellLitPhotoOfYourFaceWithoutGlasses") }
    static var takeAPhoto: String { value("takeAPhoto") }
    static var retakePhoto: String { value("retakePhoto") }
    static var frontOfIdCard: String { value("frontOfIdCard") }
    static var makeSureAllInformationIsClearlyVisibleAndThePhoto: String { value("makeSureAllInformationIsClearlyVisibleAndThePhoto") }
    static var takeFrontPhoto: String { value("takeFrontPhoto") }
    static var retakeFront: String { value("retakeFront") }
    static var backOfIdCard: String { value("backOfIdCard") }
    static var makeSureAllInformationIsClearlyVisibleAndTheDocument: String { value("makeSureAllInformationIsClearlyVisibleAndTheDocument") }
    static var takeBackPhoto: String { value("takeBackPhoto") }
    static var retakeBack: String { value("retakeBack") }
    static func documentsCapturedValue3(_ value0: String) -> String { value("documentsCapturedValue3", arguments: [value0]) }
    static var allDocumentsAreCapturedYouCanContinue: String { value("allDocumentsAreCapturedYouCanContinue") }
    static var pleaseReviewAndAcceptTheTermsToContinue: String { value("pleaseReviewAndAcceptTheTermsToContinue") }
    static var definitions2: String { value("definitions2") }
    static var object: String { value("object") }
    static var serviceFeatures: String { value("serviceFeatures") }
    static var iAgreeToTheProcessingOfMyPersonalDataUnder: String { value("iAgreeToTheProcessingOfMyPersonalDataUnder") }
    static var verifyYourPhoneNumber: String { value("verifyYourPhoneNumber") }
    static func enterTheVerificationCodeSentToValue(_ value0: String) -> String { value("enterTheVerificationCodeSentToValue", arguments: [value0]) }
    static var verificationCode: String { value("verificationCode") }
    static var enterTheVerificationCode: String { value("enterTheVerificationCode") }
    static var enterThe6DigitVerificationCode: String { value("enterThe6DigitVerificationCode") }
    static var didnTReceiveTheCodePleaseContactSupport: String { value("didnTReceiveTheCodePleaseContactSupport") }
    static var yourPhone: String { value("yourPhone") }
    static var enterYourFirstName: String { value("enterYourFirstName") }
    static var enterYourLastName: String { value("enterYourLastName") }
    static var enterExactly10DigitsIncludingTheCountryCode: String { value("enterExactly10DigitsIncludingTheCountryCode") }
    static var enterYourEmailAddress: String { value("enterYourEmailAddress") }
    static var selectYourDateOfBirth: String { value("selectYourDateOfBirth") }
    static var selectMaleOrFemale: String { value("selectMaleOrFemale") }
    static var chooseYourNationality: String { value("chooseYourNationality") }
    static var enterTheNumberShownOnYourId: String { value("enterTheNumberShownOnYourId") }
    static var chooseABranch2: String { value("chooseABranch2") }
    static var enterYourResidentialAddress: String { value("enterYourResidentialAddress") }
    static var selectASecurityQuestion: String { value("selectASecurityQuestion") }
    static var enterAnAnswerToYourSecurityQuestion: String { value("enterAnAnswerToYourSecurityQuestion") }
    static var enterYourNextOfKinSName: String { value("enterYourNextOfKinSName") }
    static var couldNotIdentifyThisDevicePleaseRestartTheAppAnd: String { value("couldNotIdentifyThisDevicePleaseRestartTheAppAnd") }
    static var yourPinMustContainExactly4Digits: String { value("yourPinMustContainExactly4Digits") }
    static var chooseALessPredictablePinSuchAsOneWithoutRepeated: String { value("chooseALessPredictablePinSuchAsOneWithoutRepeated") }
    static var confirmYour4DigitPin: String { value("confirmYour4DigitPin") }
    static var felicitations: String { value("felicitations") }
    static var votreCompteAEteCreeAvecSucces: String { value("votreCompteAEteCreeAvecSucces") }
    static var goToLogin: String { value("goToLogin") }
    static var sierraLeonean: String { value("sierraLeonean") }
    static var quelEstLeNomDeVotreAnimalDeCompagnie: String { value("quelEstLeNomDeVotreAnimalDeCompagnie") }
    static var dansQuelleVilleEtesVousNeE: String { value("dansQuelleVilleEtesVousNeE") }
    static var quelEstLeNomDeJeuneFilleDeVotreMere: String { value("quelEstLeNomDeJeuneFilleDeVotreMere") }
    static var quelEtaitLeNomDeVotrePremiereEcole: String { value("quelEtaitLeNomDeVotrePremiereEcole") }
    static var quelEstVotreLivrePrefere: String { value("quelEstVotreLivrePrefere") }
    static var veuillezCapturerTousLesDocumentsRequis: String { value("veuillezCapturerTousLesDocumentsRequis") }
    static var veuillezAccepterLesConditionsPourContinuer: String { value("veuillezAccepterLesConditionsPourContinuer") }
    static var erreurLorsDeLaConversionDeLImage: String { value("erreurLorsDeLaConversionDeLImage") }
    static var registrationSucceededButNoVerificationCodeWasReturnedPleaseContact: String { value("registrationSucceededButNoVerificationCodeWasReturnedPleaseContact") }
    static var registrationFailedInvalidData: String { value("registrationFailedInvalidData") }
    static var sessionExpiredPleaseRestartRegistration: String { value("sessionExpiredPleaseRestartRegistration") }
    static var registrationFailed: String { value("registrationFailed") }
    static var incorrectOtpPleaseTryAgain: String { value("incorrectOtpPleaseTryAgain") }
    static var nationality: String { value("nationality") }
    static var chooseANationality: String { value("chooseANationality") }
    static var rechercherUneNationalite: String { value("rechercherUneNationalite") }
    static var aucuneNationaliteTrouvee: String { value("aucuneNationaliteTrouvee") }
    static var savedRecipients: String { value("savedRecipients") }
    static var loadingSavedRecipients: String { value("loadingSavedRecipients") }
    static var noSavedRecipients: String { value("noSavedRecipients") }
    static var noMatchingRecipients: String { value("noMatchingRecipients") }
    static var savedRecipient: String { value("savedRecipient") }
    static var pleaseSignInAgainToLoadSavedRecipients: String { value("pleaseSignInAgainToLoadSavedRecipients") }
    static var unableToLoadSavedRecipients: String { value("unableToLoadSavedRecipients") }
    static var unableToLoadSavedRecipientsPleaseTryAgain: String { value("unableToLoadSavedRecipientsPleaseTryAgain") }
    static var selectASavedVoucherRecipient: String { value("selectASavedVoucherRecipient") }
    static var selectASavedMobileMoneyRecipient: String { value("selectASavedMobileMoneyRecipient") }
    static var selectARecentRecipient: String { value("selectARecentRecipient") }
    static var savedVoucherRecipientsWillAppearHere: String { value("savedVoucherRecipientsWillAppearHere") }
    static var savedMobileMoneyRecipientsWillAppearHere: String { value("savedMobileMoneyRecipientsWillAppearHere") }
    static var savedBankAccountsWillAppearHere: String { value("savedBankAccountsWillAppearHere") }
    static var noSavedAccounts: String { value("noSavedAccounts") }
    static var linkedBankAccountsWillAppearHere: String { value("linkedBankAccountsWillAppearHere") }
    static var noMatchingAccounts: String { value("noMatchingAccounts") }
    static var noSavedWalletRecipients: String { value("noSavedWalletRecipients") }
    static var nameOrRecipientNumber: String { value("nameOrRecipientNumber") }
    static var savedRecipients2: String { value("savedRecipients2") }
    static var toSavings: String { value("toSavings") }
    static var fromSavings: String { value("fromSavings") }
    static var savingsWalletBalance: String { value("savingsWalletBalance") }
    static var currentBalance: String { value("currentBalance") }
    static var interestAcquired: String { value("interestAcquired") }
    static var fundTransfer: String { value("fundTransfer") }
    static var enterAmount: String { value("enterAmount") }
    static var transferReason: String { value("transferReason") }
    static var transfer: String { value("transfer") }
    static var noRecentSavingsTransactions: String { value("noRecentSavingsTransactions") }
    static func refValue2(_ value0: String) -> String { value("refValue2", arguments: [value0]) }
    static var verifyYourTransactionDetails: String { value("verifyYourTransactionDetails") }
    static var amount3: String { value("amount3") }
    static var recipientInformation: String { value("recipientInformation") }
    static var mainWallet: String { value("mainWallet") }
    static var authentication: String { value("authentication") }
    static var pinCode: String { value("pinCode") }
    static var enterYourPinToContinue: String { value("enterYourPinToContinue") }
    static var pinVerificationFailedPleaseTryAgain: String { value("pinVerificationFailedPleaseTryAgain") }
    static var transferCompletedSuccessfully: String { value("transferCompletedSuccessfully") }
    static var transferCouldNotBeCompletedPleaseTryAgain: String { value("transferCouldNotBeCompletedPleaseTryAgain") }
    static var pdfPortableDocument: String { value("pdfPortableDocument") }
    static var excelSpreadsheet: String { value("excelSpreadsheet") }
    static var csvCommaSeparatedValues: String { value("csvCommaSeparatedValues") }
    static var statementOptions: String { value("statementOptions") }
    static var selectPeriod: String { value("selectPeriod") }
    static var selectFormat: String { value("selectFormat") }
    static var generateStatement: String { value("generateStatement") }
    static var theSavingsAccountStatementWillBeGeneratedAndSentTo: String { value("theSavingsAccountStatementWillBeGeneratedAndSentTo") }
    static var savingsStatement2: String { value("savingsStatement2") }
    static var yourStatementHasBeenRequestedCheckYourEmail: String { value("yourStatementHasBeenRequestedCheckYourEmail") }
    static var unableToGenerateTheStatement: String { value("unableToGenerateTheStatement") }
    static var interfaceUtilisateur: String { value("interfaceUtilisateur") }
    static var fonctionnalites: String { value("fonctionnalites") }
    static var securite: String { value("securite") }
    static var suggestionDAmelioration: String { value("suggestionDAmelioration") }
    static var felicitations2: String { value("felicitations2") }
    static var commentairesSuggestions: String { value("commentairesSuggestions") }
    static var envoiEnCours: String { value("envoiEnCours") }
    static var commentaireEnvoye: String { value("commentaireEnvoye") }
    static var votreCommentaireAEteEnvoyeAvecSuccesMerciPourVotre: String { value("votreCommentaireAEteEnvoyeAvecSuccesMerciPourVotre") }
    static var nousValorisonsVosRetours: String { value("nousValorisonsVosRetours") }
    static var partagezVosCommentairesSuggestionsOuFelicitationsPourNousAiderA: String { value("partagezVosCommentairesSuggestionsOuFelicitationsPourNousAiderA") }
    static var categorie: String { value("categorie") }
    static var sujet: String { value("sujet") }
    static var entrerLeSujet: String { value("entrerLeSujet") }
    static var commentaire: String { value("commentaire") }
    static var emailOptionnel: String { value("emailOptionnel") }
    static var envoyer: String { value("envoyer") }
    static var veuillezEntrerUnSujet: String { value("veuillezEntrerUnSujet") }
    static var veuillezEntrerVotreCommentaire: String { value("veuillezEntrerVotreCommentaire") }
    static var leCommentaireDoitContenirAuMoins10Caracteres: String { value("leCommentaireDoitContenirAuMoins10Caracteres") }
    static var confirmerLEnvoi: String { value("confirmerLEnvoi") }
    static var categorie2: String { value("categorie2") }
    static var sujet2: String { value("sujet2") }
    static var etesVousSurDeVouloirEnvoyerCeCommentaire: String { value("etesVousSurDeVouloirEnvoyerCeCommentaire") }
    static var sponsorAWallet: String { value("sponsorAWallet") }
    static var processing2: String { value("processing2") }
    static var authentication2: String { value("authentication2") }
    static var numeroDeTelephone: String { value("numeroDeTelephone") }
    static var recipientNumber2: String { value("recipientNumber2") }
    static var dailyLimit2: String { value("dailyLimit2") }
    static var monthlyLimit: String { value("monthlyLimit") }
    static var dateAdjusted: String { value("dateAdjusted") }
    static var theEndDateWasMovedAfterTheStartDate: String { value("theEndDateWasMovedAfterTheStartDate") }
    static var theVerifiedNumberDoesNotMatchTheNumberEntered: String { value("theVerifiedNumberDoesNotMatchTheNumberEntered") }
    static var recipientInformationIsUnavailable: String { value("recipientInformationIsUnavailable") }
    static var walletNotFound: String { value("walletNotFound") }
    static var requiredRequestDetailsAreMissing: String { value("requiredRequestDetailsAreMissing") }
    static var incorrectPin: String { value("incorrectPin") }
    static var pinIsBlocked: String { value("pinIsBlocked") }
    static var userIsNotAuthorized: String { value("userIsNotAuthorized") }
    static func verificationFailedCodeValue(_ value0: String) -> String { value("verificationFailedCodeValue", arguments: [value0]) }
    static var recipientPhoneNumberIsRequired2: String { value("recipientPhoneNumberIsRequired2") }
    static var dailyLimitIsRequired: String { value("dailyLimitIsRequired") }
    static var monthlyLimitIsRequired: String { value("monthlyLimitIsRequired") }
    static var enterValidLimitAmounts: String { value("enterValidLimitAmounts") }
    static var monthlyLimitMustBeAtLeastTheDailyLimit: String { value("monthlyLimitMustBeAtLeastTheDailyLimit") }
    static var walletSponsoredSuccessfully: String { value("walletSponsoredSuccessfully") }
    static var couldNotSponsorThisWallet: String { value("couldNotSponsorThisWallet") }
    static var success: String { value("success") }
    static var unlinkWallet: String { value("unlinkWallet") }
    static var unlink: String { value("unlink") }
    static func areYouSureYouWantToUnlinkTheWalletFor(_ value0: String) -> String { value("areYouSureYouWantToUnlinkTheWalletFor", arguments: [value0]) }
    static var sponsorAWallet2: String { value("sponsorAWallet2") }
    static var enterYourPinToConfirm: String { value("enterYourPinToConfirm") }
    static var loadingWallets: String { value("loadingWallets") }
    static var noSponsoredWallets: String { value("noSponsoredWallets") }
    static var youHaveNotSponsoredAnyWalletsYet: String { value("youHaveNotSponsoredAnyWalletsYet") }
    static var unableToLoadWallets: String { value("unableToLoadWallets") }
    static var notSpecified: String { value("notSpecified") }
    static var walletUnlinkedSuccessfully: String { value("walletUnlinkedSuccessfully") }
    static var failedToUnlinkWallet: String { value("failedToUnlinkWallet") }
    static var sponsoredWallet: String { value("sponsoredWallet") }
    static var walletOptions: String { value("walletOptions") }
    static var monthlyLimit2: String { value("monthlyLimit2") }
    static var validity: String { value("validity") }
    static var options: String { value("options") }
    static var noLimit: String { value("noLimit") }
    static func valueToValue(_ value0: String, _ value1: String) -> String { value("valueToValue", arguments: [value0, value1]) }
    static func fromValue(_ value0: String) -> String { value("fromValue", arguments: [value0]) }
    static var startDateNotSpecified: String { value("startDateNotSpecified") }
    static func toValue(_ value0: String) -> String { value("toValue", arguments: [value0]) }
    static var noEndDate: String { value("noEndDate") }
    static var pleaseEnterYourPin: String { value("pleaseEnterYourPin") }
    static var noSponsoringWalletsFound: String { value("noSponsoringWalletsFound") }
    static var walletsSponsoringYou: String { value("walletsSponsoringYou") }
    static var walletInformationIsUnavailable: String { value("walletInformationIsUnavailable") }
    static var checkYourInternetConnection: String { value("checkYourInternetConnection") }
    static func miseAJourDeLaLimitePourValue(_ value0: String) -> String { value("miseAJourDeLaLimitePourValue", arguments: [value0]) }
    static var fonctionnaliteDeDissociationAImplementer: String { value("fonctionnaliteDeDissociationAImplementer") }
    static func validUntilValue(_ value0: String) -> String { value("validUntilValue", arguments: [value0]) }
    static var daily: String { value("daily") }
    static var monthly: String { value("monthly") }
    static var portefeuilleVersPortefeuille: String { value("portefeuilleVersPortefeuille") }
    static var createStandingInstruction: String { value("createStandingInstruction") }
    static var creerUnVirementPermanent: String { value("creerUnVirementPermanent") }
    static var typeDeTransaction: String { value("typeDeTransaction") }
    static var detailsDuDestinataire: String { value("detailsDuDestinataire") }
    static var codeBanque: String { value("codeBanque") }
    static var entrerLeMontantGnf: String { value("entrerLeMontantGnf") }
    static var entrerUneDescription: String { value("entrerUneDescription") }
    static var planification: String { value("planification") }
    static var creer: String { value("creer") }
    static var nDeCompte: String { value("nDeCompte") }
    static var nDeTelephoneMobile: String { value("nDeTelephoneMobile") }
    static var nDeCompteDEpargne: String { value("nDeCompteDEpargne") }
    static var verificationNonDisponiblePourCeType: String { value("verificationNonDisponiblePourCeType") }
    static var leCodeBanqueEstRequis: String { value("leCodeBanqueEstRequis") }
    static var verificationDeCompteNonImplementee: String { value("verificationDeCompteNonImplementee") }
    static var verificationMobileMoneyNonImplementee: String { value("verificationMobileMoneyNonImplementee") }
    static var laDestinationEstRequise: String { value("laDestinationEstRequise") }
    static var veuillezDAbordVerifierLeDestinataire: String { value("veuillezDAbordVerifierLeDestinataire") }
    static var laDateDeDebutDoitEtreAvantLaDateDe: String { value("laDateDeDebutDoitEtreAvantLaDateDe") }
    static var laDateDeFinNePeutPasEtreDansLe: String { value("laDateDeFinNePeutPasEtreDansLe") }
    static var virementPermanentCreeAvecSucces: String { value("virementPermanentCreeAvecSucces") }
    static var veuillezEntrerVotrePin: String { value("veuillezEntrerVotrePin") }
    static var termine: String { value("termine") }
    static var vousNAvezAucunVirementPermanent: String { value("vousNAvezAucunVirementPermanent") }
    static var creerUnVirement: String { value("creerUnVirement") }
    static var numeroDeTelephoneNonDisponible: String { value("numeroDeTelephoneNonDisponible") }
    static var virementPermanentSupprimeAvecSucces: String { value("virementPermanentSupprimeAvecSucces") }
    static var frequence: String { value("frequence") }
    static var prochaineDate: String { value("prochaineDate") }
    static var description3: String { value("description3") }
    static var modifier: String { value("modifier") }
    static var supprimer: String { value("supprimer") }
    static var confirmerLaSuppression: String { value("confirmerLaSuppression") }
    static var entrezVotreCodePinPourSupprimerCeVirementPermanent: String { value("entrezVotreCodePinPourSupprimerCeVirementPermanent") }
    static var editStandingInstruction: String { value("editStandingInstruction") }
    static var modifierLeVirement: String { value("modifierLeVirement") }
    static var detailsDuBeneficiaire: String { value("detailsDuBeneficiaire") }
    static var detailsDePaiement: String { value("detailsDePaiement") }
    static var entrerLeMontant: String { value("entrerLeMontant") }
    static var devise: String { value("devise") }
    static var dateDeFinOptionnel: String { value("dateDeFinOptionnel") }
    static var entrerVotrePin: String { value("entrerVotrePin") }
    static var laDescriptionEstRequise: String { value("laDescriptionEstRequise") }
    static var leCodePinEstRequis: String { value("leCodePinEstRequis") }
    static var instructionMiseAJourAvecSucces: String { value("instructionMiseAJourAvecSucces") }
    static var updateSponsoredWallet: String { value("updateSponsoredWallet") }
    static var mettreAJourLesLimites: String { value("mettreAJourLesLimites") }
    static func beneficiaireValue(_ value0: String) -> String { value("beneficiaireValue", arguments: [value0]) }
    static var limiteJournaliere: String { value("limiteJournaliere") }
    static var limiteMensuelle: String { value("limiteMensuelle") }
    static var periode: String { value("periode") }
    static var confirmerLaMiseAJour: String { value("confirmerLaMiseAJour") }
    static func confirmerLaMiseAJourDesLimitesPourValue(_ value0: String) -> String { value("confirmerLaMiseAJourDesLimitesPourValue", arguments: [value0]) }
    static var limiteJournaliere2: String { value("limiteJournaliere2") }
    static var limiteMensuelle2: String { value("limiteMensuelle2") }
    static var periode2: String { value("periode2") }
    static var dateAjustee: String { value("dateAjustee") }
    static var laDateDeFinAEteAjusteePourEtrePosterieure: String { value("laDateDeFinAEteAjusteePourEtrePosterieure") }
    static var laLimiteJournaliereEstRequise: String { value("laLimiteJournaliereEstRequise") }
    static var laLimiteMensuelleEstRequise: String { value("laLimiteMensuelleEstRequise") }
    static var montantsInvalides: String { value("montantsInvalides") }
    static var laLimiteMensuelleDoitEtreSuperieureOuEgaleALa: String { value("laLimiteMensuelleDoitEtreSuperieureOuEgaleALa") }
    static var laDateDeFinDoitEtreApresLaDateDe: String { value("laDateDeFinDoitEtreApresLaDateDe") }
    static var miseAJourReussie: String { value("miseAJourReussie") }
    static var echecDeLaMiseAJour: String { value("echecDeLaMiseAJour") }
    static var moneyVoucherSentSuccessfully: String { value("moneyVoucherSentSuccessfully") }
    static var availabilityFee: String { value("availabilityFee") }
    static var voucherFee: String { value("voucherFee") }
    static var notVerified: String { value("notVerified") }
    static var moneyVoucher2: String { value("moneyVoucher2") }
    static var recuDeMiseADisposition: String { value("recuDeMiseADisposition") }
    static var recuDeMiseADisposition2: String { value("recuDeMiseADisposition2") }
    static var statutMiseADispositionGeneree: String { value("statutMiseADispositionGeneree") }
    static func codeVoucherValue(_ value0: String) -> String { value("codeVoucherValue", arguments: [value0]) }
    static var emetteur: String { value("emetteur") }
    static var destinataire: String { value("destinataire") }
    static var nonVerifie: String { value("nonVerifie") }
    static var instructions: String { value("instructions") }
    static var leDestinatairePeutRetirerCesFondsAvecLeCode: String { value("leDestinatairePeutRetirerCesFondsAvecLeCode") }
    static var voucherDansNImporteQuelPointDeService: String { value("voucherDansNImporteQuelPointDeService") }
    static func recuDeMiseADispositionStatutMiseADispositionGeneree(_ value0: String, _ value1: String, _ value2: String, _ value3: String, _ value4: String, _ value5: String, _ value6: String, _ value7: String, _ value8: String, _ value9: String, _ value10: String) -> String { value("recuDeMiseADispositionStatutMiseADispositionGeneree", arguments: [value0, value1, value2, value3, value4, value5, value6, value7, value8, value9, value10]) }
    static var selectionnerUneRaison: String { value("selectionnerUneRaison") }
    static var jeNUtilisePlusLeService: String { value("jeNUtilisePlusLeService") }
    static var problemesDeSecurite: String { value("problemesDeSecurite") }
    static var interfaceDifficileAUtiliser: String { value("interfaceDifficileAUtiliser") }
    static var fraisTropEleves: String { value("fraisTropEleves") }
    static var serviceClientInsatisfaisant: String { value("serviceClientInsatisfaisant") }
    static var changementDeSituationFinanciere: String { value("changementDeSituationFinanciere") }
    static var autreRaison: String { value("autreRaison") }
    static var desactivationDuPortefeuille: String { value("desactivationDuPortefeuille") }
    static var fermezDefinitivementVotrePortefeuilleEtTransferezVotreSolde: String { value("fermezDefinitivementVotrePortefeuilleEtTransferezVotreSolde") }
    static var raisonDeLaDesactivation: String { value("raisonDeLaDesactivation") }
    static var selectionnezLaRaisonPrincipale: String { value("selectionnezLaRaisonPrincipale") }
    static var detailsSupplementairesMax50Caracteres: String { value("detailsSupplementairesMax50Caracteres") }
    static var methodeDeTransfertDuSolde: String { value("methodeDeTransfertDuSolde") }
    static var choisissezCommentRecevoirVotreSoldeRestant: String { value("choisissezCommentRecevoirVotreSoldeRestant") }
    static var compteBancaire: String { value("compteBancaire") }
    static var autrePortefeuilleMobile: String { value("autrePortefeuilleMobile") }
    static var retraitEnAgence: String { value("retraitEnAgence") }
    static var numeroDeTelephoneDuDestinataire: String { value("numeroDeTelephoneDuDestinataire") }
    static var nomDuTitulaire: String { value("nomDuTitulaire") }
    static var compteBancaireLie: String { value("compteBancaireLie") }
    static var chargementDesComptes: String { value("chargementDesComptes") }
    static var nomDuTitulaireDuCompte: String { value("nomDuTitulaireDuCompte") }
    static var agenceDeRetrait: String { value("agenceDeRetrait") }
    static var chargementDesAgences: String { value("chargementDesAgences") }
    static var selectionnerUneAgence: String { value("selectionnerUneAgence") }
    static var vousPourrezRetirerVotreSoldeDirectementEnAgenceAvecUne: String { value("vousPourrezRetirerVotreSoldeDirectementEnAgenceAvecUne") }
    static var confirmationDeSecurite: String { value("confirmationDeSecurite") }
    static var entrezVotreCodePinPourConfirmerLaDesactivationDefinitiveDe: String { value("entrezVotreCodePinPourConfirmerLaDesactivationDefinitiveDe") }
    static var informationsImportantes: String { value("informationsImportantes") }
    static var leSoldeRestantSeraTransfereVersLeDestinataireChoisi: String { value("leSoldeRestantSeraTransfereVersLeDestinataireChoisi") }
    static var votrePortefeuilleSeraDefinitivementFerme: String { value("votrePortefeuilleSeraDefinitivementFerme") }
    static var cetteActionNePeutPasEtreAnnulee: String { value("cetteActionNePeutPasEtreAnnulee") }
    static var vousDevrezCreerUnNouveauComptePourUtiliserNosServices: String { value("vousDevrezCreerUnNouveauComptePourUtiliserNosServices") }
    static var unCodeOtpSeraEnvoyePourConfirmationFinale: String { value("unCodeOtpSeraEnvoyePourConfirmationFinale") }
    static var desactiverLePortefeuille: String { value("desactiverLePortefeuille") }
    static var leNumeroVerifieNeCorrespondPasAuNumeroSaisi: String { value("leNumeroVerifieNeCorrespondPasAuNumeroSaisi") }
    static var informationDuDestinataireNonDisponible: String { value("informationDuDestinataireNonDisponible") }
    static var portefeuilleNonTrouve: String { value("portefeuilleNonTrouve") }
    static var codePinIncorrect: String { value("codePinIncorrect") }
    static var codePinBloque: String { value("codePinBloque") }
    static var utilisateurNonAutorise: String { value("utilisateurNonAutorise") }
    static var aucuneAgenceTrouvee: String { value("aucuneAgenceTrouvee") }
    static var veuillezSelectionnerUneRaisonDeDesactivation: String { value("veuillezSelectionnerUneRaisonDeDesactivation") }
    static var veuillezPreciserLaRaisonDeDesactivation: String { value("veuillezPreciserLaRaisonDeDesactivation") }
    static var veuillezSelectionnerUneMethodeDeTransfert: String { value("veuillezSelectionnerUneMethodeDeTransfert") }
    static var veuillezSaisirLeNumeroDuDestinataire: String { value("veuillezSaisirLeNumeroDuDestinataire") }
    static var veuillezSelectionnerUneAgence: String { value("veuillezSelectionnerUneAgence") }
    static func branchCashOutValue(_ value0: String) -> String { value("branchCashOutValue", arguments: [value0]) }
    static var erreurLorsDeLaDesactivationDuPortefeuille: String { value("erreurLorsDeLaDesactivationDuPortefeuille") }
    static var veuillezSaisirLeCodeOtp: String { value("veuillezSaisirLeCodeOtp") }
    static var leCodeOtpDoitContenirExactement6Chiffres: String { value("leCodeOtpDoitContenirExactement6Chiffres") }
    static var codeOtpInvalideVeuillezReessayer: String { value("codeOtpInvalideVeuillezReessayer") }
    static var confirmationDeDesactivation: String { value("confirmationDeDesactivation") }
    static var etesVousSurDeVouloirDesactiverDefinitivementVotrePortefeuilleCette: String { value("etesVousSurDeVouloirDesactiverDefinitivementVotrePortefeuilleCette") }
    static var ouiDesactiver: String { value("ouiDesactiver") }
    static var verificationOtp: String { value("verificationOtp") }
    static var unCodeDeVerificationAEteEnvoyeAVotreNumero: String { value("unCodeDeVerificationAEteEnvoyeAVotreNumero") }
    static var codeOtp: String { value("codeOtp") }
    static var demandeEnvoyee: String { value("demandeEnvoyee") }
    static var votreDemandeDeDesactivationAEteTransmiseAvecSuccesLe: String { value("votreDemandeDeDesactivationAEteTransmiseAvecSuccesLe") }
    static var entrezUnMontantPourVoirLesFrais: String { value("entrezUnMontantPourVoirLesFrais") }
    static var paiementQrCode: String { value("paiementQrCode") }
    static var paiementA: String { value("paiementA") }
    static var calculEnCours: String { value("calculEnCours") }
    static var fraisDePaiementQr: String { value("fraisDePaiementQr") }
    static func fraisValueGmd(_ value0: String) -> String { value("fraisValueGmd", arguments: [value0]) }
    static var montantDesFraisManquant: String { value("montantDesFraisManquant") }
    static var erreurDeCalcul: String { value("erreurDeCalcul") }
    static var biometric: String { value("biometric") }
    static var biometricAuthenticationIsNotAvailableOnThisDevice: String { value("biometricAuthenticationIsNotAvailableOnThisDevice") }
    static var noBiometricDataEnrolledPleaseSetUpFaceIdTouch: String { value("noBiometricDataEnrolledPleaseSetUpFaceIdTouch") }
    static var authenticationFailedPleaseTryAgain: String { value("authenticationFailedPleaseTryAgain") }
    static var authenticationCancelled: String { value("authenticationCancelled") }
    static var userChoseToUsePin: String { value("userChoseToUsePin") }
    static var authenticationCancelledBySystem: String { value("authenticationCancelledBySystem") }
    static var devicePasscodeNotSetPleaseSetUpAPasscodeFirst: String { value("devicePasscodeNotSetPleaseSetUpAPasscodeFirst") }
    static var biometricAuthenticationIsLockedDueToTooManyFailedAttempts: String { value("biometricAuthenticationIsLockedDueToTooManyFailedAttempts") }
    static func valueIsAvailable(_ value0: String) -> String { value("valueIsAvailable", arguments: [value0]) }
    static var biometricAuthenticationIsNotAvailable: String { value("biometricAuthenticationIsNotAvailable") }
    static var authenticateToAccessYourWallet: String { value("authenticateToAccessYourWallet") }
    static var usePin: String { value("usePin") }
    static var unknownError2: String { value("unknownError2") }
    static var valider: String { value("valider") }
    static var confirmerLaValidation: String { value("confirmerLaValidation") }
    static var voulezVousVraimentValiderCePaiementDsd: String { value("voulezVousVraimentValiderCePaiementDsd") }
    static var continuer: String { value("continuer") }
    static var confirmerLeRejet: String { value("confirmerLeRejet") }
    static var voulezVousVraimentRejeterCePaiementDsdCetteActionEst: String { value("voulezVousVraimentRejeterCePaiementDsdCetteActionEst") }
    static var paiementCodeQrEmv: String { value("paiementCodeQrEmv") }
    static var ceCodeQrAExpire: String { value("ceCodeQrAExpire") }
    static var fraisDeRetrait2: String { value("fraisDeRetrait2") }
    static var totalADebiter2: String { value("totalADebiter2") }
    static var destinataire2: String { value("destinataire2") }
    static var nom2: String { value("nom2") }
    static var portefeuille2: String { value("portefeuille2") }
    static var diamabankSa: String { value("diamabankSa") }
    static var expireLe: String { value("expireLe") }
    static var payer: String { value("payer") }
    static var leCodePinDoitContenir4Chiffres: String { value("leCodePinDoitContenir4Chiffres") }
    static func echecDeLaValidationCodeValue(_ value0: String) -> String { value("echecDeLaValidationCodeValue", arguments: [value0]) }
    static var paiementReussi: String { value("paiementReussi") }
    static var montant4: String { value("montant4") }
    static var emetteur2: String { value("emetteur2") }
    static var destinataire3: String { value("destinataire3") }
    static var idDestinataire: String { value("idDestinataire") }
    static var recuDePaiementQr: String { value("recuDePaiementQr") }
    static var recuDePaiementQrEmv: String { value("recuDePaiementQrEmv") }
    static var recuDePaiementQrEmv2: String { value("recuDePaiementQrEmv2") }
    static var statutPaiementReussi: String { value("statutPaiementReussi") }
    static func fraisDEnvoiValue(_ value0: String) -> String { value("fraisDEnvoiValue", arguments: [value0]) }
    static func fraisDeRetraitValue(_ value0: String) -> String { value("fraisDeRetraitValue", arguments: [value0]) }
    static var marchand: String { value("marchand") }
    static func idMarchandValue(_ value0: String) -> String { value("idMarchandValue", arguments: [value0]) }
    static var ceRecuAEteGenereAutomatiquement: String { value("ceRecuAEteGenereAutomatiquement") }
    static func fraisDEnvoiValue2(_ value0: String) -> String { value("fraisDEnvoiValue2", arguments: [value0]) }
    static func fraisDeRetraitValue2(_ value0: String) -> String { value("fraisDeRetraitValue2", arguments: [value0]) }
    static func nomValueTypeValuePortefeuilleValue(_ value0: String, _ value1: String, _ value2: String) -> String { value("nomValueTypeValuePortefeuilleValue", arguments: [value0, value1, value2]) }
    static func idMarchandValue2(_ value0: String) -> String { value("idMarchandValue2", arguments: [value0]) }
    static func banqueValue2(_ value0: String) -> String { value("banqueValue2", arguments: [value0]) }
    static func recuDePaiementQrEmvStatutPaiementReussiIdTransaction(_ value0: String, _ value1: String, _ value2: String, _ value3: String, _ value4: String, _ value5: String, _ value6: String, _ value7: String, _ value8: String) -> String { value("recuDePaiementQrEmvStatutPaiementReussiIdTransaction", arguments: [value0, value1, value2, value3, value4, value5, value6, value7, value8]) }
    static var confirmerLaMiseADisposition: String { value("confirmerLaMiseADisposition") }
    static var mobileMoneyFee: String { value("mobileMoneyFee") }
    static var fraisDeMiseADisposition: String { value("fraisDeMiseADisposition") }
    static var totalToDebit2: String { value("totalToDebit2") }
    static var recipientInformation2: String { value("recipientInformation2") }
    static var sourceDesFonds2: String { value("sourceDesFonds2") }
    static var portefeuilleSponsor: String { value("portefeuilleSponsor") }
    static var pending: String { value("pending") }
    static var underReview: String { value("underReview") }
    static var approved: String { value("approved") }
    static var rejected: String { value("rejected") }
    static var cancelled: String { value("cancelled") }
    static var failed: String { value("failed") }
    static var expired: String { value("expired") }
    static var ordered: String { value("ordered") }
    static var accepted: String { value("accepted") }
    static var preparing: String { value("preparing") }
    static var ready: String { value("ready") }
    static var outForDelivery: String { value("outForDelivery") }
    static var delivered: String { value("delivered") }
    static var completed: String { value("completed") }
    static var weekly: String { value("weekly") }
    static var yearly: String { value("yearly") }
    static var quotidien: String { value("quotidien") }
    static var hebdomadaire: String { value("hebdomadaire") }
    static var mensuel: String { value("mensuel") }
    static var annuel: String { value("annuel") }

    /// Display known local option labels while retaining their original API values and tags.
    private static let optionKeys: [String: String] = {
        var index: [String: String] = [:]
        for (key, entry) in catalog.sorted(by: { $0.key < $1.key }) {
            index[entry.source.lowercased()] = key
            if let french = entry.french { index[french.lowercased()] = key }
        }
        return index
    }()

    static func option(_ originalValue: String) -> String {
        let normalized = originalValue.replacingOccurrences(of: "_", with: " ").lowercased()
        guard let key = optionKeys[normalized] else { return originalValue }
        return value(key)
    }

    static func detailsValue3(_ value0: String) -> String { value("detailsValue3", arguments: [value0]) }
    static var calcul: String { value("calcul") }
    static var impossibleDeChargerLesComptes: String { value("impossibleDeChargerLesComptes") }
    static var chargement: String { value("chargement") }
    static var echecDeLaSuppression: String { value("echecDeLaSuppression") }
    static var confirmation: String { value("confirmation") }
    static var verificationEchouee: String { value("verificationEchouee") }
    static var echecDeLaCreation: String { value("echecDeLaCreation") }
    static var search: String { value("search") }
    static func valueValue(_ value0: String, _ value1: String) -> String { value("valueValue", arguments: [value0, value1]) }
    static func valueValue2(_ value0: String, _ value1: String) -> String { value("valueValue2", arguments: [value0, value1]) }
    static var miseADispositionDeFonds: String { value("miseADispositionDeFonds") }
    static var registration: String { value("registration") }
    static var loading: String { value("loading") }
    static var submitted: String { value("submitted") }
    static var inProgress: String { value("inProgress") }
    static var resolved: String { value("resolved") }
    static var closed: String { value("closed") }
    static var confirmed: String { value("confirmed") }

    static var appareilNonSecurise: String { value("appareilNonSecurise") }
    static var votreAppareilSembleEtreJailbreakePourVotreSecuriteDiamacash: String { value("votreAppareilSembleEtreJailbreakePourVotreSecuriteDiamacash") }
    static var enterTheNumberShownOnYourNationalId: String { value("enterTheNumberShownOnYourNationalId") }
    static var walletDetailsAreMissingPleaseSignInAgain: String { value("walletDetailsAreMissingPleaseSignInAgain") }
    static var invalidUrl: String { value("invalidUrl") }
    static var invalidResponse: String { value("invalidResponse") }
    static var donneesInvalides: String { value("donneesInvalides") }
    static var nonAutorise: String { value("nonAutorise") }
    static var erreurDuServeur: String { value("erreurDuServeur") }
    static var tropDePlaintesRecentes: String { value("tropDePlaintesRecentes") }
    static var noDataReceived: String { value("noDataReceived") }
    static var invalidResponseFormat: String { value("invalidResponseFormat") }
    static var sessionExpired2: String { value("sessionExpired2") }
    static var serverError: String { value("serverError") }
    static var accessDenied: String { value("accessDenied") }
    static var clientError: String { value("clientError") }

    static var transfertDArgent: String { value("transfertDArgent") }
    static var retraitBancaire: String { value("retraitBancaire") }
    static var rechargeTelephonique: String { value("rechargeTelephonique") }
    static var paiementMarchand: String { value("paiementMarchand") }
    static var retraitDEspeces: String { value("retraitDEspeces") }
    static var paiementDeFacture: String { value("paiementDeFacture") }
    static var agent: String { value("agent") }
    static func transfertRecuDeValue(_ value0: String) -> String { value("transfertRecuDeValue", arguments: [value0]) }
    static func valueViaValue(_ value0: String, _ value1: String) -> String { value("valueViaValue", arguments: [value0, value1]) }
    static var depotDEspeces: String { value("depotDEspeces") }
    static var achatDeCredit: String { value("achatDeCredit") }
    static var creditEvalue: String { value("creditEvalue") }
    static var debitEvalue: String { value("debitEvalue") }
    static var transfertEvalue: String { value("transfertEvalue") }
    static var retraitGuichet: String { value("retraitGuichet") }
    static var depotGuichet: String { value("depotGuichet") }
    static var creditQrGip: String { value("creditQrGip") }
    static var debitQrGip: String { value("debitQrGip") }
    static var transfertEntrePortefeuilles: String { value("transfertEntrePortefeuilles") }
    static var transfertBonDArgent: String { value("transfertBonDArgent") }
    static var depotAgent: String { value("depotAgent") }
    static var retraitAgent: String { value("retraitAgent") }
    static var especesBonAgent: String { value("especesBonAgent") }
    static var creditGip: String { value("creditGip") }
    static var debitGip: String { value("debitGip") }
    static var demandeDePaiement: String { value("demandeDePaiement") }
    static var paiementFactureCompte: String { value("paiementFactureCompte") }
    static var paiementFacturePortefeuille: String { value("paiementFacturePortefeuille") }
    static var consultationPortefeuille: String { value("consultationPortefeuille") }
    static var transactionEpargne: String { value("transactionEpargne") }
    static var interetsQuotidiensEpargne: String { value("interetsQuotidiensEpargne") }
    static var annulationInteretsEpargne: String { value("annulationInteretsEpargne") }
    static var interetsEpargne: String { value("interetsEpargne") }
    static var creditDInterets: String { value("creditDInterets") }
    static var transactionDInterets: String { value("transactionDInterets") }
    static var transactionSponsorisee: String { value("transactionSponsorisee") }
    static var commissionAgent: String { value("commissionAgent") }
    static var portefeuilleDormant: String { value("portefeuilleDormant") }
    static var epargneDormante: String { value("epargneDormante") }
    static var transfertDepuisPortefeuille: String { value("transfertDepuisPortefeuille") }
    static var walletTransfer: String { value("walletTransfer") }
    static var sponsoredWallet2: String { value("sponsoredWallet2") }
    static var bankTransfer: String { value("bankTransfer") }
    static func otherTypeValue(_ value0: String) -> String { value("otherTypeValue", arguments: [value0]) }

    static var information: String { value("information") }
    static var info: String { value("info") }
    static var menu: String { value("menu") }
    static var active: String { value("active") }
    static var past: String { value("past") }
    static var eligibility: String { value("eligibility") }
    static var repayment: String { value("repayment") }
    static var performance: String { value("performance") }
    static var sending: String { value("sending") }
    static var promo: String { value("promo") }
    static var promotion: String { value("promotion") }
    static var desactive: String { value("desactive") }
    static var branch: String { value("branch") }
    static var loading2: String { value("loading2") }
    static var accept2: String { value("accept2") }
    static var verify2: String { value("verify2") }
    static var next: String { value("next") }
    static var ghanaian: String { value("ghanaian") }
    static var nigerian: String { value("nigerian") }
    static var ivorian: String { value("ivorian") }
    static var senegalese: String { value("senegalese") }
    static var malian: String { value("malian") }
    static var burkinabe: String { value("burkinabe") }
    static var togolese: String { value("togolese") }
    static var beninese: String { value("beninese") }
    static var guinean: String { value("guinean") }
    static var liberian: String { value("liberian") }
    static var gambian: String { value("gambian") }
    static var client: String { value("client") }
    static var agent2: String { value("agent2") }
    static var inconnu: String { value("inconnu") }
    static var telephone2: String { value("telephone2") }

    static var verifying: String { value("verifying") }
    static var submitting: String { value("submitting") }
    static var saving: String { value("saving") }

    static var profileInactive: String { value("profileInactive") }
    static var profileBlocked: String { value("profileBlocked") }
    static var profileClosed: String { value("profileClosed") }
    static var profilePersonal: String { value("profilePersonal") }
    static var profileBusiness: String { value("profileBusiness") }
    static var profileSavings: String { value("profileSavings") }
    static var loanPurposeEducation: String { value("loanPurposeEducation") }
    static var loanPurposeMedical: String { value("loanPurposeMedical") }
    static var loanPurposeAgriculture: String { value("loanPurposeAgriculture") }
    static var loanPurposeEmergency: String { value("loanPurposeEmergency") }
    static var loanPurposeHomeImprovement: String { value("loanPurposeHomeImprovement") }
    static var loanPurposeOther: String { value("loanPurposeOther") }

    static func profileStatusValue(_ raw: String?) -> String? {
        guard let raw else { return nil }
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
        case "ACTIVE": return active
        case "INACTIVE": return profileInactive
        case "BLOCKED": return profileBlocked
        case "CLOSED": return profileClosed
        case "PENDING": return pending
        default: return raw
        }
    }

    static func profileTypeValue(_ raw: String?) -> String? {
        guard let raw else { return nil }
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
        case "C": return "Client"
        case "B": return "Business"
        case "PERSONAL": return profilePersonal
        case "BUSINESS": return profileBusiness
        case "SAVINGS": return profileSavings
        case "SPONSORED": return sponsoredWallet2
        default: return raw
        }
    }

    static func loanPurposeName(_ raw: String) -> String {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "_", with: " ").uppercased() {
        case "PERSONAL": return profilePersonal
        case "BUSINESS": return profileBusiness
        case "EDUCATION": return loanPurposeEducation
        case "MEDICAL": return loanPurposeMedical
        case "AGRICULTURE": return loanPurposeAgriculture
        case "EMERGENCY": return loanPurposeEmergency
        case "HOME IMPROVEMENT": return loanPurposeHomeImprovement
        case "OTHER": return loanPurposeOther
        default: return raw
        }
    }

    static var refreshTranslations: String { value("refreshTranslations") }

}
