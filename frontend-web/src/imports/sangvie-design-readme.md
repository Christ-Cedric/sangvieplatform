# 🩸 SangVie — Plateforme de Don de Sang
### Frontend Design README · Figma Documentation

> **Projet :** Système de Gestion des Dons de Sang  
> **Stack UI :** Figma (Mobile-first + Desktop Responsive)  
> **Langues :** Français 🇫🇷 / Anglais 🇬🇧  
> **Deadline :** 11 Mars 2025  
> **Équipe Frontend :** Nacoulma Betsaleel · Bassinga Keya · Zabre Tania

---

## 📐 Design System

### Palette de Couleurs

| Rôle | Couleur | Hex | Usage |
|------|---------|-----|-------|
| **Primary** | Rouge Sang | `#CC0000` | Boutons CTA, alertes urgence, accents |
| **Primary Light** | Rouge doux | `#E53333` | Hover states, badges |
| **Primary Dark** | Rouge foncé | `#990000` | Boutons actifs, emphase |
| **Background** | Blanc pur | `#FFFFFF` | Fond principal toutes les vues |
| **Surface** | Blanc cassé | `#F9F9F9` | Cards, modals, panels |
| **Text Primary** | Noir | `#111111` | Titres, texte principal |
| **Text Secondary** | Gris foncé | `#444444` | Sous-titres, labels |
| **Text Muted** | Gris | `#888888` | Placeholders, texte désactivé |
| **Border** | Gris clair | `#E0E0E0` | Séparateurs, contours de champs |
| **Danger / Urgence** | Rouge vif | `#FF0000` | Niveau urgence critique |
| **Success** | Vert sobre | `#1A7A3F` | Confirmations, statut actif |
| **Warning** | Orangé | `#D4720B` | Urgence modérée |

> ⚠️ Le rouge est utilisé **avec parcimonie** : uniquement sur les boutons principaux, les tags d'urgence et les éléments d'alerte. Le reste de l'interface reste blanc/noir pour un rendu épuré et médical.

---

### Typographie

| Rôle | Police | Taille | Poids |
|------|--------|--------|-------|
| **Display / Hero** | `DM Serif Display` | 32–48px | Regular |
| **Titres de section** | `DM Serif Display` | 20–28px | Regular |
| **Corps de texte** | `DM Sans` | 14–16px | Regular / Medium |
| **Labels & UI** | `DM Sans` | 12–13px | Medium |
| **Boutons** | `DM Sans` | 14–15px | SemiBold |
| **Micro texte** | `DM Sans` | 11px | Regular |

**Import Google Fonts :**
```
DM Serif Display: weights 400
DM Sans: weights 300, 400, 500, 600
```

---

### Spacing & Grid

| Token | Valeur | Usage |
|-------|--------|-------|
| `xs` | 4px | Micro-espacement |
| `sm` | 8px | Intérieur des composants |
| `md` | 16px | Espacement standard |
| `lg` | 24px | Entre sections |
| `xl` | 32px | Marges de page |
| `2xl` | 48px | Séparation de blocs |

**Grilles :**
- Mobile : 1 colonne, 16px margins, 16px gutter
- Tablet : 2 colonnes, 24px margins, 16px gutter
- Desktop : 12 colonnes, 80px margins, 24px gutter

**Border Radius :**
- Boutons : `8px`
- Cards : `12px`
- Modals : `16px`
- Badges / Tags : `999px` (pill)
- Input fields : `8px`

---

### Composants de Base (Atoms)

#### Boutons
```
[Primaire]   Fond #CC0000 · Texte blanc · hover #990000
[Secondaire] Fond blanc · Bordure #CC0000 · Texte #CC0000
[Ghost]      Fond transparent · Texte #444444
[Danger]     Fond #FF0000 · Texte blanc · Urgence critique
[Désactivé]  Fond #E0E0E0 · Texte #888888
```
Taille standard : `height: 48px` · padding : `12px 24px`

#### Champs de saisie
```
Height : 48px
Border : 1px solid #E0E0E0
Focus  : 1px solid #CC0000 + box-shadow léger rouge (15% opacité)
Error  : bordure #FF0000 + message rouge sous le champ
```

#### Badges & Tags
```
[Urgence Critique]  Fond #CC0000 · Texte blanc
[Urgence Modérée]   Fond #D4720B · Texte blanc
[Urgence Faible]    Fond #1A7A3F · Texte blanc
[Actif]             Fond #E8F5EE · Texte #1A7A3F
[Inactif]           Fond #F5F5F5 · Texte #888888
[Pending]           Fond #FFF4E5 · Texte #D4720B
```

#### Cards
```
Background : #FFFFFF
Border     : 1px solid #E0E0E0
Border-radius : 12px
Shadow     : 0 2px 12px rgba(0,0,0,0.06)
Padding    : 20px
```

#### Notifications
```
Icône bulle rouge · Compteur badge rouge sur cloche
Liste déroulante · fond blanc · ombre douce
```

---

## 📱 Responsive Breakpoints

| Breakpoint | Largeur | Description |
|-----------|---------|-------------|
| `mobile-sm` | 320px | Petits téléphones |
| `mobile` | 375px | iPhone standard (référence design) |
| `mobile-lg` | 430px | Grands téléphones |
| `tablet` | 768px | Tablettes portrait |
| `tablet-lg` | 1024px | Tablettes paysage / iPad |
| `desktop` | 1280px | Ordinateurs |
| `desktop-lg` | 1440px | Grand écran |

> 🔑 **Mobile-first** : Toutes les maquettes sont conçues d'abord en 375px puis adaptées vers le haut.

---

## 🗂️ Architecture des Écrans

### MODULE 1 — Authentification (Commun)

#### 1.1 Écran de Démarrage / Splash Screen
- Logo centré + slogan
- Animation légère de chargement (goutte de sang)
- Fond blanc, logo rouge et noir
- Durée : 2 secondes

#### 1.2 Page d'Accueil Publique
- Hero section : Illustration + titre + CTA "Devenir Donneur" + CTA "Hôpital – S'inscrire"
- Section explication rapide (3 icônes : Inscription · Notification · Don)
- Footer minimal : langue switcher FR / EN

#### 1.3 Connexion Donneur
```
Champs :
  - Téléphone (requis)
  - Mot de passe (requis)
Bouton : "Se connecter" [rouge]
Lien   : "Mot de passe oublié ?"
Lien   : "Créer un compte"
```

#### 1.4 Inscription Donneur
```
Étapes : Stepper 3 étapes (indicateur en haut)

Étape 1 — Identité
  - Nom et prénom (requis)
  - Téléphone (requis)
  - Email (optionnel)
  - Lieu de résidence (requis) — select Région

Étape 2 — Profil Sanguin
  - Groupe sanguin : sélecteur visuel (A+, A-, B+, B-, O+, O-, AB+, AB-)
  - (Cards cliquables avec indicateur rouge sur sélection)

Étape 3 — Sécurité
  - Mot de passe
  - Confirmation mot de passe
  - Bouton : "Créer mon compte" [rouge]
```

#### 1.5 Connexion Hôpital
```
Champs :
  - Email institutionnel
  - Mot de passe
Bouton : "Se connecter"
Lien   : "Inscrire mon hôpital"
Note   : "Compte en attente de validation admin"
```

#### 1.6 Inscription Hôpital
```
Champs :
  - Nom de l'hôpital
  - Adresse email institutionnelle
  - Numéro d'agrément
  - Contact (téléphone)
  - Région (select)
  - Mot de passe
  - Confirmation mot de passe

État après soumission :
  - Message "Votre demande est en cours d'examen"
  - Illustration attente + badge "En attente de validation"
```

---

### MODULE 2 — Espace Donneur (User)

#### 2.1 Page d'Accueil Donneur (Feed)
```
Header :
  - Logo + icône notif (badge rouge si nouvelles)
  - Avatar utilisateur

Statut Donneur :
  - Toggle switch "Actif / Inactif"
  - Fond vert si actif, gris si inactif
  - Texte explicatif sous le toggle

Feed d'actualité :
  - Liste de cards "Demandes d'urgence" des hôpitaux
  - Card demande = Nom hôpital + Groupe sanguin + Niveau urgence (badge coloré) + Description courte + Localisation + Bouton "Répondre"
  - Filtre rapide : Tous / Groupe sanguin compatible / Région

Navigation bas (mobile) :
  Accueil · Localisation · Historique · Profil
```

#### 2.2 Détail d'une Demande
```
- Nom hôpital + adresse
- Groupe sanguin requis (grande icône)
- Niveau d'urgence (badge prominent)
- Quantité demandée
- Description complète
- Mini-carte de localisation (statique)
- CTA : "Je peux donner" [rouge] + "Fermer"
```

#### 2.3 Localisation des Hôpitaux
```
- Vue carte (MapBox / Google Maps embed)
- Liste des hôpitaux en bas (scrollable)
- Filtre par région
- Marqueurs rouges sur la carte
- Card hôpital : nom + distance + contact
```

#### 2.4 Historique Donneur
```
- Liste chronologique des réponses passées
- Chaque item : date + hôpital + groupe sanguin + statut (Répondu / Expiré)
- Filtre : Tous / Ce mois / Cette année
- État vide : illustration + "Aucun historique pour l'instant"
```

#### 2.5 Profil Donneur
```
- Avatar (initiales ou photo)
- Nom complet + téléphone + email (si renseigné)
- Groupe sanguin (badge proéminent rouge)
- Région / lieu de résidence
- Bouton "Modifier le profil"
- Bouton "Changer la langue" (FR / EN)
- Bouton "Déconnexion"
```

#### 2.6 Notifications Donneur
```
- Liste des notifications triées par date
- Types : Nouvelle demande compatible · Confirmation de don · Info système
- Badge non-lu (point rouge)
- Bouton "Tout marquer comme lu"
```

---

### MODULE 3 — Espace Hôpital

#### 3.1 Dashboard Hôpital
```
Header : Nom de l'hôpital + statut compte (badge) + cloche notif

Stats résumé (4 cards) :
  [Demandes totales] [Demandes actives] [Dons reçus] [Taux de réponse]

Bouton flottant : "+ Nouvelle demande d'urgence" [rouge]

Demandes récentes :
  - Tableau ou liste des dernières demandes
  - Colonnes : Date · Groupe sanguin · Quantité · Urgence · Statut

Navigation latérale (desktop) ou bas (mobile) :
  Dashboard · Demandes · Stats · Localisation · Profil · Notifications
```

#### 3.2 Soumettre une Demande d'Urgence
```
Formulaire :
  - Groupe sanguin (requis) — sélecteur visuel (comme inscription donneur)
  - Quantité en poches (requis) — input numérique avec +/-
  - Niveau d'urgence (requis) :
      [Critique]  [Modérée]  [Faible]
      (Cards avec couleur rouge / orange / vert)
  - Description (optionnel) — textarea 4 lignes max
  - Bouton : "Soumettre la demande" [rouge]

Confirmation : Modal succès avec résumé de la demande
```

#### 3.3 Historique des Demandes Hôpital
```
- Tableau complet paginé
- Colonnes : Date · Groupe sanguin · Quantité · Urgence · Description · Statut · Actions
- Filtre : Statut (Active/Clôturée) + Groupe sanguin + Date
- Export CSV bouton [contour rouge]
```

#### 3.4 Statistiques Hôpital
```
- Graphique bar : Demandes par mois
- Graphique donut : Répartition par groupe sanguin
- KPIs : Nombre total demandes · Nombre total receptions
- Période sélectionnable : 7j / 30j / 3m / 1an
```

#### 3.5 Profil Hôpital
```
- Nom hôpital
- Email institutionnel
- Numéro d'agrément
- Contact
- Région
- Statut du compte (badge : Validé / En attente / Suspendu)
- Bouton "Modifier"
```

#### 3.6 Localisation (Hôpital)
```
- Carte avec position de l'hôpital
- Option : modifier l'adresse / coordonnées GPS
- Vue des autres hôpitaux alentour
```

#### 3.7 Voir Statuts Utilisateurs (Hôpital)
```
- Liste des donneurs ayant répondu aux demandes
- Colonnes : Nom masqué · Groupe sanguin · Statut (Actif/Inactif) · Date de réponse
- Pas d'infos personnelles visibles (données sensibles protégées)
```

---

### MODULE 4 — Espace Admin

#### 4.1 Dashboard Admin
```
Sidebar gauche (desktop) :
  - Logo + avatar admin
  - Navigation : Dashboard · Hôpitaux · Utilisateurs · Rapports · Stats · Paramètres

Stats globales (5 cards) :
  [Hôpitaux inscrits] [En attente validation] [Donneurs actifs] [Demandes totales] [Dons réalisés]

Section : Comptes hôpitaux en attente
  - Tableau avec actions rapides Valider / Rejeter

Section : Dernières activités système
```

#### 4.2 Gestion des Comptes Hôpitaux
```
Tableau principal :
  Colonnes : Nom · Région · Email · Agrément · Statut · Date inscription · Actions

Filtres :
  - Statut (Tous / En attente / Validé / Suspendu)
  - Région
  - Recherche par nom

Actions par ligne :
  [Voir] [Valider] [Suspendre] [Supprimer]

Validation :
  Modal de confirmation avec résumé du compte + bouton "Valider le compte" [rouge]

Suppression / Désactivation :
  Modal de confirmation avec message d'avertissement
  Options : Désactiver temporairement · Supprimer définitivement
```

#### 4.3 Voir Statuts Utilisateurs (Admin)
```
- Tableau donneurs
- Colonnes : ID · Groupe sanguin · Région · Statut donneur · Dernière activité
- Filtre : Actif / Inactif · Région · Groupe sanguin
```

#### 4.4 Génération de Rapports
```
Formulaire :
  - Type de rapport : Dons · Hôpitaux · Activité donneurs
  - Période : date de début / date de fin
  - Format : PDF · CSV · Excel
  - Bouton : "Générer le rapport" [rouge]

Section rapports récents :
  - Liste des rapports générés avec bouton télécharger
```

#### 4.5 Statistiques & Analytics (Admin)
```
- Vue globale multi-graphiques
  · Évolution des dons (ligne temporelle)
  · Demandes par région (carte choroplèthe ou bar chart)
  · Top groupes sanguins demandés (donut)
  · Hôpitaux les plus actifs (classement)
- Filtres période : 7j / 30j / 3m / 6m / 1an
- Bouton "Télécharger les stats" [contour rouge]
```

---

## 🌐 Internationalisation (i18n)

### Gestion des Langues
- **Sélecteur** : Toggle FR 🇫🇷 / EN 🇬🇧 visible dans le header et sur la page profil
- **Persistance** : La langue choisie est mémorisée entre sessions
- Toutes les maquettes sont dupliquées pour les deux langues dans Figma (pages séparées ou via variables de texte Figma)

### Convention de nommage i18n dans Figma
```
[FR] Nom de l'écran   →  ex: [FR] Connexion Donneur
[EN] Screen Name      →  ex: [EN] Donor Login
```

---

## 📂 Structure des Pages Figma

```
📁 SangVie — Design System
   ├── 🎨 Colors & Typography
   ├── 🧩 Components / Atoms
   ├── 📐 Grid & Spacing

📁 [FR] Authentification
   ├── Splash Screen
   ├── Accueil Public
   ├── Connexion Donneur
   ├── Inscription Donneur (3 étapes)
   ├── Connexion Hôpital
   └── Inscription Hôpital

📁 [FR] Donneur (User)
   ├── Feed Accueil
   ├── Détail Demande
   ├── Localisation Hôpitaux
   ├── Historique
   ├── Profil
   └── Notifications

📁 [FR] Hôpital
   ├── Dashboard
   ├── Nouvelle Demande
   ├── Historique Demandes
   ├── Statistiques
   ├── Profil
   ├── Localisation
   └── Statuts Utilisateurs

📁 [FR] Admin
   ├── Dashboard
   ├── Gestion Hôpitaux
   ├── Statuts Utilisateurs
   ├── Rapports
   └── Statistiques

📁 [EN] Authentification
   └── (miroir de [FR] avec textes traduits)

📁 [EN] Donneur / Hospital / Admin
   └── (idem)

📁 Prototype Flows
   ├── Flow Donneur (mobile)
   ├── Flow Hôpital (mobile + desktop)
   └── Flow Admin (desktop)
```

---

## 🔗 Liens & Flows de Navigation

### Donneur (Mobile)
```
Splash → Accueil Public → Connexion → Feed
Feed → Détail Demande → (Répondre / Fermer)
Feed → Localisation (via nav bar)
Feed → Historique (via nav bar)
Feed → Profil (via nav bar)
Profil → Notifications
Profil → Changer langue
```

### Hôpital (Mobile + Desktop)
```
Connexion → Dashboard
Dashboard → Nouvelle Demande → Confirmation
Dashboard → Historique
Dashboard → Statistiques
Dashboard → Profil
Dashboard → Localisation
Dashboard → Statuts Utilisateurs
Dashboard → Notifications
```

### Admin (Desktop prioritaire)
```
Login Admin → Dashboard Admin
Dashboard → Gestion Hôpitaux → Valider/Suspendre/Supprimer
Dashboard → Statuts Utilisateurs
Dashboard → Rapports → Générer / Télécharger
Dashboard → Statistiques → Télécharger stats
```

---

## ✅ Checklist de Livraison Figma

### Design System
- [ ] Palette couleurs définie avec variables Figma
- [ ] Typographie configurée (DM Serif Display + DM Sans)
- [ ] Composants atoms documentés (boutons, inputs, badges, cards)
- [ ] Grille responsive configurée (375 / 768 / 1280px)

### Écrans
- [ ] Tous les écrans donneur (mobile 375px)
- [ ] Tous les écrans hôpital (mobile + desktop)
- [ ] Tous les écrans admin (desktop 1280px)
- [ ] États vides documentés
- [ ] États d'erreur sur les formulaires
- [ ] États loading / skeleton

### Prototypage
- [ ] Flow connexion/inscription cliquable
- [ ] Flow demande d'urgence (hôpital)
- [ ] Flow consultation feed (donneur)
- [ ] Flow validation compte (admin)

### Responsive
- [ ] Mobile 375px ✅ (priorité)
- [ ] Tablet 768px ✅
- [ ] Desktop 1280px ✅ (admin + hôpital)

### i18n
- [ ] Version française complète
- [ ] Version anglaise complète

---

## 🎯 Principes UX Clés

1. **Simplicité médicale** : Interface épurée sans surcharge visuelle. Le contenu médical doit être clair et lisible.
2. **Urgence visible** : Les niveaux d'urgence doivent attirer l'œil immédiatement. Utiliser les badges colorés de façon cohérente.
3. **Accessibilité** : Contrastes suffisants (ratio ≥ 4.5:1 pour le texte). Tailles de touch target ≥ 44px.
4. **Confiance** : Design professionnel et sobre. Le rouge est réservé aux actions et alertes, pas décoratif.
5. **Rapidité** : Minimiser les étapes pour soumettre une demande d'urgence (hôpital) et pour répondre (donneur).
6. **Offline-friendly** : Prévoir les états sans connexion dans les maquettes.

---

*README rédigé pour l'équipe Frontend — SangVie Platform · Mars 2025*