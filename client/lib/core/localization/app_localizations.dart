import 'package:flutter/material.dart';

/// App localization delegate and localizations class
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Navigation
  String get home => locale.languageCode == 'fr' ? 'Accueil' : 'Home';
  String get stories => locale.languageCode == 'fr' ? 'Histoires' : 'Stories';
  String get about => locale.languageCode == 'fr' ? 'À propos' : 'About';
  String get profile => locale.languageCode == 'fr' ? 'Profil' : 'Profile';
  String get settings => locale.languageCode == 'fr' ? 'Paramètres' : 'Settings';
  String get login => locale.languageCode == 'fr' ? 'Connexion' : 'Login';
  String get register => locale.languageCode == 'fr' ? "S'inscrire" : 'Register';
  String get logout => locale.languageCode == 'fr' ? 'Déconnexion' : 'Logout';

  // Actions
  String get exploreStories => locale.languageCode == 'fr' ? 'Explorer les histoires' : 'Explore Stories';
  String get signIn => locale.languageCode == 'fr' ? 'Se connecter' : 'Sign In';
  String get signUp => locale.languageCode == 'fr' ? "S'inscrire" : 'Sign Up';
  String get createAccount => locale.languageCode == 'fr' ? 'Créer un compte' : 'Create Account';
  String get viewAll => locale.languageCode == 'fr' ? 'Voir tout' : 'View All';
  String get search => locale.languageCode == 'fr' ? 'Rechercher' : 'Search';
  String get cancel => locale.languageCode == 'fr' ? 'Annuler' : 'Cancel';
  String get save => locale.languageCode == 'fr' ? 'Enregistrer' : 'Save';
  String get delete => locale.languageCode == 'fr' ? 'Supprimer' : 'Delete';
  String get confirm => locale.languageCode == 'fr' ? 'Confirmer' : 'Confirm';

  // Story
  String get featuredStories => locale.languageCode == 'fr' ? 'Histoires en vedette' : 'Featured Stories';
  String get relatedStories => locale.languageCode == 'fr' ? 'Histoires similaires' : 'Related Stories';
  String get readMore => locale.languageCode == 'fr' ? 'Lire la suite' : 'Read More';
  String get listenToStory => locale.languageCode == 'fr' ? "Écouter l'histoire" : 'Listen to Story';
  String get watchVideo => locale.languageCode == 'fr' ? 'Regarder la vidéo' : 'Watch Video';
  String get views => locale.languageCode == 'fr' ? 'vues' : 'views';
  String get summary => locale.languageCode == 'fr' ? 'Résumé' : 'Summary';

  // Feedback
  String get flagCulturalInaccuracy => locale.languageCode == 'fr' ? 'Signaler une inexactitude culturelle' : 'Flag Cultural Inaccuracy';
  String get reportIssue => locale.languageCode == 'fr' ? 'Signaler un problème' : 'Report Issue';
  String get culturalInaccuracy => locale.languageCode == 'fr' ? 'Inexactitude culturelle' : 'Cultural Inaccuracy';
  String get inappropriateContent => locale.languageCode == 'fr' ? 'Contenu inapproprié' : 'Inappropriate Content';
  String get factualError => locale.languageCode == 'fr' ? 'Erreur factuelle' : 'Factual Error';
  String get offensiveLanguage => locale.languageCode == 'fr' ? 'Langage offensant' : 'Offensive Language';
  String get copyrightIssue => locale.languageCode == 'fr' ? 'Problème de droits d\'auteur' : 'Copyright Issue';
  String get additionalComments => locale.languageCode == 'fr' ? 'Commentaires supplémentaires' : 'Additional Comments';
  String get submitFeedback => locale.languageCode == 'fr' ? 'Soumettre' : 'Submit Feedback';

  // Account
  String get deleteAccount => locale.languageCode == 'fr' ? 'Supprimer le compte' : 'Delete Account';
  String get deleteAccountWarning => locale.languageCode == 'fr'
      ? 'Cette action est irréversible. Toutes vos données seront supprimées.'
      : 'This action is irreversible. All your data will be deleted.';
  String get language => locale.languageCode == 'fr' ? 'Langue' : 'Language';
  String get english => locale.languageCode == 'fr' ? 'Anglais' : 'English';
  String get french => locale.languageCode == 'fr' ? 'Français' : 'French';

  // Status
  String get offlineModeActive => locale.languageCode == 'fr' ? 'Mode hors ligne actif' : 'Offline Cache Mode Active';
  String get backOnline => locale.languageCode == 'fr' ? 'De retour en ligne' : 'Back Online';
  String get loading => locale.languageCode == 'fr' ? 'Chargement...' : 'Loading...';
  String get error => locale.languageCode == 'fr' ? 'Erreur' : 'Error';
  String get tryAgain => locale.languageCode == 'fr' ? 'Réessayer' : 'Try Again';

  // TTS
  String get listenWithTTS => locale.languageCode == 'fr' ? 'Écouter avec TTS' : 'Listen with TTS';
  String get playbackSpeed => locale.languageCode == 'fr' ? 'Vitesse de lecture' : 'Playback Speed';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
