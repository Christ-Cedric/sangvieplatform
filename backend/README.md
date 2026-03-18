# 🩸 Plateforme de Don de Sang - Backend API (UML Aligned)

Ce backend est strictement conforme aux diagrammes de classes et de cas d'utilisation fournis.

## 🚀 Architecture & Fonctionnalités

### 1. Utilisateurs (Donneurs)
- **Modèle** : `nom`, `prenom`, `email`, `telephone`, `lieuResidence`, `groupeSanguin`, `motDePasse`, `statutDonneur`.
- **Actions** : Inscription, Connexion, Gestion du statut de donneur (actif/inactif), Historique des dons.

### 2. Hôpitaux
- **Modèle** : `nom`, `email`, `numeroAgrement`, `contact`, `region`, `localisation`, `motDePasse`.
- **Actions** : Inscription, Connexion, Soumission de demandes de sang urgentes, Historique des demandes.

### 3. Administrateurs
- **Modèle** : `nomUtilisateur`, `motDePasse`.
- **Actions** : Validation/Vérification des hôpitaux, Suppression de comptes, Statistiques globales.

### 4. Système de Demandes & Dons
- Les hôpitaux émettent des **Demandes de Sang** (`groupeSanguin`, `quantitePoches`, `niveauUrgence`).
- Les **Dons** sont enregistrés pour chaque utilisateur avec le lieu et la quantité.
- **Notifications** : Automatiquement envoyées aux donneurs éligibles lors d'une demande urgente.

## �️ API Endpoints

### Authentification
- `POST /api/auth/register-user` : Inscription donneur.
- `POST /api/auth/register-hospital` : Inscription hôpital.
- `POST /api/auth/login` : Connexion (email/nomUtilisateur + motDePasse).

### Donneur (Privé)
- `PUT /api/users/status` : Changer statut (actif/inactif).
- `GET /api/users/my-donations` : Historique des dons.

### Hôpital (Privé)
- `POST /api/hospitals/request` : Créer une demande de sang urgente.
- `GET /api/hospitals/my-requests` : Liste des demandes de l'hôpital.

### Administration (Privé)
- `PUT /api/admin/verify-hospital/:id` : Valider un hôpital.
- `DELETE /api/admin/account/:id` : Supprimer un compte.
- `GET /api/admin/stats` : Statistiques du système.

### Public
- `GET /api/requests` : Fil d'actualité des demandes en cours.

## 📦 Installation
```bash
cd backend
npm install
npm run dev
```

---
*Développement basé sur les spécifications UML du projet.*
