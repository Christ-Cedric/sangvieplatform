# 🩸 SangVie — Plateforme de Don de Sang

> **SangVie** est une plateforme numérique complète de gestion du don de sang, conçue pour connecter les donneurs, les hôpitaux et les administrateurs afin de répondre efficacement aux besoins en sang au Burkina Faso.

---

## 📦 Structure du projet

```
Blood Donation Platform/
├── backend/                              # API REST Node.js / Express
│   └── src/
│       ├── controllers/                  # Logique métier
│       ├── models/                       # Schémas Mongoose (MongoDB)
│       ├── routes/                       # Définition des routes API
│       ├── middleware/                   # Auth & Rôles
│       └── server.js                     # Point d'entrée du serveur
├── Blood-Donnation-Platform--main/       # Application Web (React / TypeScript)
│   └── src/app/
│       ├── pages/
│       │   ├── auth/                     # Pages de connexion / inscription
│       │   ├── donor/                    # Espace donneur
│       │   ├── hospital/                 # Espace hôpital
│       │   └── admin/                    # Espace administrateur
│       └── components/                   # Composants UI réutilisables
└── Blood-Donnation-Platform-mobile--main/ # Application Mobile (Flutter)
    └── mobile/lib/
        ├── presentation/screens/          # Écrans de l'app mobile
        └── core/                          # Navigation & configuration
```

---

## 🚀 Technologies utilisées

| Couche | Technologie |
|--------|-------------|
| **Frontend Web** | React, TypeScript, Vite, TailwindCSS, Framer Motion |
| **Mobile** | Flutter / Dart |
| **Backend** | Node.js, Express.js |
| **Base de données** | MongoDB (Mongoose) |
| **Authentification** | JWT (JSON Web Token) |
| **Documentation API** | Swagger / OpenAPI (`/api-docs`) |

---

## ⚙️ Installation & Démarrage

### Prérequis
- Node.js ≥ 18
- MongoDB (local ou Atlas)
- Flutter SDK ≥ 3.x

### 1. Backend

```bash
cd backend
npm install
# Créer un fichier .env avec les variables :
# MONGO_URI=...
# JWT_SECRET=...
# PORT=5000
npm start
```

> Le serveur démarre sur `http://localhost:5000`  
> Documentation Swagger disponible sur `http://localhost:5000/api-docs`

### 2. Application Web

```bash
cd Blood-Donnation-Platform--main
npm install
npm run dev
```

> L'application démarre sur `http://localhost:5173`

### 3. Application Mobile

```bash
cd Blood-Donnation-Platform-mobile--main/mobile
flutter pub get
flutter run
```

---

## 👥 Rôles utilisateurs

L'application gère **3 types d'acteurs** avec des espaces distincts :

| Rôle | Identifiant de connexion | Description |
|------|--------------------------|-------------|
| **Donneur (User)** | Numéro de téléphone | Particulier souhaitant donner du sang |
| **Hôpital** | Numéro de contact | Établissement de santé gérant les demandes de sang |
| **Administrateur** | Nom d'utilisateur | Gestionnaire du réseau national SangVie |

---

## 🗺️ Scénarios d'utilisation

---

### 🔐 Scénario 1 — Inscription d'un donneur

**Acteur :** Un particulier souhaitant s'enregistrer comme donneur de sang.

**Précondition :** L'utilisateur n'a pas encore de compte.

**Étapes :**

1. L'utilisateur accède à la page **`/register`**.
2. Il sélectionne l'onglet **"Donneur"**.
3. Il renseigne les informations suivantes :
   - Nom complet
   - Numéro de téléphone (identifiant unique)
   - Email
   - Lieu de résidence
   - **Groupe sanguin** (A+, A-, B+, B-, AB+, AB-, O+, O-)
   - Mot de passe + confirmation
4. Il soumet le formulaire.
5. Un **jeton JWT** est généré et l'utilisateur est redirigé vers son **fil d'actualité** (`/donor/feed`).

**Résultat :** Le donneur est enregistré avec le statut **"actif"** par défaut.

**API :** `POST /api/auth/register-user`

---

### 🏥 Scénario 2 — Inscription d'un hôpital

**Acteur :** Un établissement hospitalier souhaitant rejoindre le réseau SangVie.

**Précondition :** L'hôpital possède un numéro d'agrément officiel.

**Étapes :**

1. L'utilisateur accède à **`/register`** et sélectionne l'onglet **"Hôpital"**.
2. Il renseigne :
   - Nom de l'établissement
   - Numéro d'agrément (ID officiel)
   - Email institutionnel
   - Numéro de contact (identifiant unique)
   - Région
   - Localisation
   - Mot de passe + confirmation
3. Il soumet le formulaire.
4. Le compte est créé avec le statut **non vérifié** (`verified: false`).
5. L'hôpital est redirigé vers son **tableau de bord**.

> ⚠️ **Important :** L'hôpital ne peut soumettre de demandes de sang qu'**après validation par l'administrateur**.

**API :** `POST /api/auth/register-hospital`

---

### 🔑 Scénario 3 — Connexion universelle

**Acteur :** Tout utilisateur (Donneur, Hôpital, Administrateur).

**Précondition :** L'utilisateur possède un compte existant.

**Étapes :**

1. L'utilisateur accède à **`/login`**.
2. Il saisit ses identifiants selon son rôle :
   - **Donneur** → Numéro de téléphone + mot de passe
   - **Hôpital** → Numéro de contact + mot de passe
   - **Admin** → Nom d'utilisateur + mot de passe
3. Le système identifie automatiquement le type d'utilisateur.
4. Un jeton JWT est retourné et l'utilisateur est redirigé vers son espace dédié.

**API :** `POST /api/auth/login`

---

### 📋 Scénario 4 — Consultation du fil d'urgences (Donneur)

**Acteur :** Un donneur connecté.

**Précondition :** Le donneur a son statut défini sur **"actif"**.

**Étapes :**

1. Le donneur accède à son espace via **`/donor/feed`**.
2. Il voit la liste des **demandes de sang urgentes** publiées par les hôpitaux à proximité, avec :
   - Le nom de l'hôpital
   - Le groupe sanguin requis
   - Le niveau d'urgence (🔴 **Urgence vitale** / 🟠 **Urgence modérée**)
   - La distance approximative
   - La description médicale
3. Il peut **filtrer** les demandes selon ses préférences.
4. En cliquant sur une demande, une fiche détaillée s'affiche avec :
   - Toutes les informations médicales
   - Un avertissement de préparation (manger, s'hydrater, pièce d'identité)
5. Le donneur clique sur **"Je peux donner"** pour manifester son intérêt.

---

### 🔔 Scénario 5 — Activation / Désactivation du statut de donneur

**Acteur :** Un donneur connecté.

**Étapes :**

1. Sur la page **`/donor/feed`**, le donneur voit un **interrupteur "Statut de don"**.
2. En position **active** : il est visible pour les urgences et reçoit des notifications.
3. En position **inactive** : il est masqué des alertes d'urgence.
4. Il peut mettre à jour son statut à tout moment.

**API :** `PUT /api/users/status` avec `{ "statutDonneur": "actif" | "inactif" }`

---

### 🗺️ Scénario 6 — Localisation des hôpitaux partenaires (Donneur)

**Acteur :** Un donneur connecté souhaitant trouver un centre de collecte.

**Étapes :**

1. Le donneur accède à **`/donor/map`**.
2. Une carte interactive affiche les **marqueurs des hôpitaux** partenaires proches.
3. En cliquant sur un marqueur, une fiche apparaît avec :
   - Nom et distance de l'hôpital
   - Groupes sanguins **urgents** actuellement requis
4. Le donneur peut demander un **itinéraire** ou **appeler** directement l'établissement.

---

### 📅 Scénario 7 — Consultation de l'historique des dons (Donneur)

**Acteur :** Un donneur connecté.

**Étapes :**

1. Le donneur accède à **`/donor/history`**.
2. Il consulte ses statistiques personnelles :
   - Nombre total de dons
   - Nombre estimé de vies sauvées
   - Date du premier don
3. Il voit la **liste chronologique** de ses dons avec :
   - Nom de l'hôpital
   - Date et groupe sanguin
   - Impact généré ("3 vies sauvées")
4. Il voit aussi la **date de son prochain don éligible** (intervalle minimum respecté).

**API :** `GET /api/users/my-donations`

---

### 👤 Scénario 8 — Modification du profil donneur

**Acteur :** Un donneur connecté.

**Étapes :**

1. Le donneur accède à **`/donor/profile`**.
2. Il consulte ses informations personnelles (téléphone, ville, date de naissance, dernier don).
3. Il clique sur **"Modifier"** et met à jour ses informations.
4. Il sauvegarde les modifications.
5. Il peut également :
   - Activer/désactiver les **notifications**
   - Changer la **langue** de l'interface
   - Se **déconnecter**

---

### 🚨 Scénario 9 — Publication d'une demande de sang (Hôpital)

**Acteur :** Un personnel hospitalier connecté et **vérifié**.

**Précondition :** Le compte hôpital a été validé par un administrateur.

**Étapes :**

1. Depuis **`/hospital/dashboard`** ou **`/hospital/requests`**, le personnel clique sur **"Nouvelle demande"**.
2. Un formulaire modal s'affiche. Il renseigne :
   - **Groupe sanguin requis** (sélection parmi 8 groupes)
   - **Quantité** (nombre de poches)
   - **Niveau d'urgence** : Normal / Urgent / Critique
   - **Description médicale** (optionnel : nature de l'intervention)
3. Il soumet la demande.
4. La demande est publiée et **des notifications sont envoyées** automatiquement aux donneurs compatibles actifs.

**API :** `POST /api/hospitals/request`

---

### 📊 Scénario 10 — Suivi des demandes actives (Hôpital)

**Acteur :** Un responsable hospitalier.

**Étapes :**

1. Le responsable accède à **`/hospital/requests`**.
2. Il voit la liste des **demandes actives** avec :
   - Groupe sanguin et quantité requise
   - Raison médicale et date de publication
   - Niveau d'urgence
   - **Nombre de réponses reçues** de donneurs
3. Pour chaque demande, il peut :
   - **Voir les réponses** des donneurs
   - **Clôturer** la demande une fois satisfaite
4. Les demandes satisfaites apparaissent dans une section distincte.

**API :** `GET /api/hospitals/my-requests`

---

### 📈 Scénario 11 — Consultation des statistiques hospitalières

**Acteur :** Un responsable hospitalier.

**Étapes :**

1. Le responsable accède à **`/hospital/stats`**.
2. Il consulte les **KPI clés** :
   - Nombre total de demandes
   - Nombre de donneurs actifs liés à l'hôpital
   - Nombre de poches collectées
   - Taux de réponse moyen
3. Il visualise l'**évolution mensuelle** des dons via un graphique en barres.
4. Il consulte la **répartition par groupe sanguin** des dons reçus.
5. Il suit l'**activité récente** (nouvelles demandes, confirmations, inscriptions).

---

### 🏢 Scénario 12 — Gestion du profil hôpital

**Acteur :** Responsable d'établissement.

**Étapes :**

1. Il accède à **`/hospital/profile`**.
2. Il consulte et peut modifier :
   - Email institutionnel
   - Numéro de téléphone
   - Adresse
   - Capacité d'accueil
3. Il peut configurer les notifications et la langue.
4. Il peut se déconnecter.

---

### ✅ Scénario 13 — Validation d'un compte hôpital (Admin)

**Acteur :** Administrateur système.

**Étapes :**

1. L'admin accède à **`/admin/dashboard`**.
2. Il voit la liste des **hôpitaux en attente de validation** avec leur région et date d'inscription.
3. Après vérification de l'agrément, il clique sur ✅ pour **valider** ou ❌ pour **rejeter** le compte.
4. Une fois validé, l'hôpital peut publier des demandes de sang.

**API :** `PUT /api/admin/verify-hospital/:id`

---

### 🧑‍💼 Scénario 14 — Gestion des utilisateurs (Admin)

**Acteur :** Administrateur système.

**Étapes :**

1. L'admin accède à **`/admin/users`**.
2. Il peut **rechercher** un donneur par nom ou numéro de téléphone.
3. Il consulte pour chaque donneur :
   - Statut (Actif / Inactif)
   - Groupe sanguin
   - Nombre de dons effectués
   - Date du dernier don et date d'inscription
4. Il peut **voir le profil**, consulter l'**historique** ou **contacter** un donneur.
5. Il peut **supprimer** un compte problématique.

**API :**
- `GET /api/admin/stats`
- `DELETE /api/admin/account/:id?type=User`

---

### 🏥 Scénario 15 — Gestion des hôpitaux (Admin)

**Acteur :** Administrateur système.

**Étapes :**

1. L'admin accède à **`/admin/hospitals`**.
2. Il consulte la liste de tous les hôpitaux inscrits avec leur statut de vérification.
3. Il peut valider, suspendre ou supprimer un compte hôpital.

**API :** `DELETE /api/admin/account/:id?type=Hospital`

---

### 📊 Scénario 16 — Consultation des rapports nationaux (Admin)

**Acteur :** Administrateur système.

**Étapes :**

1. L'admin accède à **`/admin/reports`**.
2. Il consulte les **KPI nationaux** :
   - Total des dons du mois
   - Nombre de donneurs actifs
   - Nombre d'hôpitaux partenaires
   - Taux de satisfaction des demandes
3. Il visualise l'**évolution mensuelle** des dons (graphique sur 6 mois).
4. Il consulte la **répartition régionale** avec taux de croissance par région.
5. Il peut **exporter le rapport** complet.

---

### 🔔 Scénario 17 — Réception de notifications (Donneur / Hôpital)

**Acteur :** Tout utilisateur connecté.

**Déclencheur automatique** : Lors de la publication d'une demande de sang urgente par un hôpital.

**Étapes :**

1. L'hôpital publie une demande de sang (`POST /api/hospitals/request`).
2. Le système identifie les **donneurs actifs** avec le groupe sanguin compatible.
3. Une **notification** est envoyée automatiquement à chaque donneur éligible.
4. Le donneur reçoit la notification dans l'application et peut y répondre directement.

**Types de notifications :**
- `demande_urgence` — Nouvelle demande de sang urgente
- `rappel_don` — Rappel de don périodique
- `systeme` — Notification générale du système

---

## 📡 API REST — Résumé des endpoints

| Méthode | Endpoint | Rôle requis | Description |
|---------|----------|-------------|-------------|
| `POST` | `/api/auth/register-user` | Public | Inscription donneur |
| `POST` | `/api/auth/register-hospital` | Public | Inscription hôpital |
| `POST` | `/api/auth/login` | Public | Connexion universelle |
| `PUT` | `/api/users/status` | User | Changer statut donneur |
| `GET` | `/api/users/my-donations` | User | Historique de mes dons |
| `POST` | `/api/hospitals/request` | Hospital | Créer une demande de sang |
| `GET` | `/api/hospitals/my-requests` | Hospital | Mes demandes de sang |
| `GET` | `/api/requests` | Public | Fil d'urgences public |
| `PUT` | `/api/admin/verify-hospital/:id` | Admin | Valider un hôpital |
| `DELETE` | `/api/admin/account/:id` | Admin | Supprimer un compte |
| `GET` | `/api/admin/stats` | Admin | Statistiques globales |

> 📖 Documentation interactive complète : **`http://localhost:5000/api-docs`** (Swagger UI)

---

## 🗄️ Modèles de données

### User (Donneur)
| Champ | Type | Description |
|-------|------|-------------|
| `nom`, `prenom` | String | Identité civile |
| `email` | String | Email unique |
| `telephone` | String | Identifiant unique de connexion |
| `lieuResidence` | String | Ville/Quartier |
| `groupeSanguin` | Enum | A+, A-, B+, B-, AB+, AB-, O+, O- |
| `statutDonneur` | Enum | `actif` / `inactif` |
| `role` | String | `user` (par défaut) |

### Hospital (Hôpital)
| Champ | Type | Description |
|-------|------|-------------|
| `nom` | String | Nom de l'établissement |
| `contact` | String | Téléphone (identifiant unique) |
| `numeroAgrement` | String | Numéro officiel d'agrément |
| `region`, `localisation` | String | Situation géographique |
| `verified` | Boolean | Validé par l'admin (défaut: false) |

### BloodRequest (Demande de sang)
| Champ | Type | Description |
|-------|------|-------------|
| `hospitalId` | ObjectId | Hôpital demandeur |
| `groupeSanguin` | Enum | Groupe sanguin requis |
| `quantitePoches` | Number | Nombre de poches nécessaires |
| `niveauUrgence` | Enum | `normal` / `urgent` / `critique` |
| `statut` | Enum | `en_attente` / `satisfait` / `annule` |

### Donation (Don)
| Champ | Type | Description |
|-------|------|-------------|
| `userId` | ObjectId | Donneur |
| `hospitalId` | ObjectId | Hôpital bénéficiaire |
| `groupeSanguin` | String | Groupe sanguin donné |
| `quantitePoches` | Number | Nombre de poches |
| `lieuDon` | String | Lieu du don |
| `statut` | Enum | `prevu` / `complete` / `annule` |

### Notification
| Champ | Type | Description |
|-------|------|-------------|
| `destinataire` | ObjectId | Cible (User ou Hospital) |
| `type` | Enum | `demande_urgence` / `rappel_don` / `systeme` |
| `message` | String | Contenu de la notification |
| `lue` | Boolean | Lu ou non lu |

---

## 🌍 Internationalisation

L'application web supporte la **multilingue** via un système i18n intégré. La langue peut être changée dans le profil de l'utilisateur.

---

## 📱 Application Mobile

L'application Flutter reprend les mêmes fonctionnalités que la version web :
- Authentification (connexion/inscription)
- Fil d'urgences donneur
- Carte des hôpitaux
- Historique des dons
- Gestion du profil
- Interface hospitalière (demandes, statistiques)
- Interface administrateur

---

## 🔒 Sécurité

- **Mots de passe** hashés avec `bcryptjs` (salt 10)
- **Authentification** par JWT (validité 30 jours)
- **Contrôle d'accès par rôle** (middleware `authorize`)
- **Isolation des routes** : chaque rôle n'accède qu'à ses propres endpoints

---

## 📄 Licence

Ce projet est développé dans le cadre d'une initiative de santé publique pour le Burkina Faso.

---

*README généré le 12 Mars 2026 — SangVie Platform v1.0*
"# Blood-PlateForm" 
#   s a n g v i e p l a t f o r m  
 #   s a n g v i e p l a t f o r m  
 #   s a n g v i e p l a t f o r m  
 