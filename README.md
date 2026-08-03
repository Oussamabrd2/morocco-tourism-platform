# Morocco Tourism — API et plateforme d’administration

Backend Laravel destiné à une application touristique. Le projet fournit une **API REST sécurisée** pour les utilisateurs, publications, destinations, évaluations, activités et plans de voyage, ainsi qu’un espace web d’administration.

## Fonctionnalités principales

| Module | Fonctionnalités |
|---|---|
| Authentification | Inscription, connexion, déconnexion et authentification Google |
| Profils | Consultation et modification du profil, biographie et photo de profil |
| Publications | Création, consultation et suppression de publications touristiques |
| Destinations | Liste et détails des lieux touristiques |
| Évaluations | Notes et avis associés aux destinations |
| Activités | Création, consultation, inscription et annulation de participation |
| Plan de voyage | Génération d’un parcours touristique |
| Administration | Gestion des utilisateurs, rôles, blocage, publications, activités et lieux |
| Export | Export des utilisateurs depuis le tableau de bord administrateur |

## Rôles

- **Utilisateur** : gère son profil, publie du contenu, évalue les destinations et rejoint des activités.
- **Organisateur** : crée et gère des activités touristiques.
- **Administrateur** : supervise les utilisateurs, contenus, activités, participants et destinations.

## Technologies

- PHP 8.2+
- Laravel 12
- Laravel Sanctum
- SQLite par défaut
- Blade
- Vite 7
- Tailwind CSS 4
- Axios

## API REST

Les routes sont préfixées par `/api/v1`.

### Routes publiques

```text
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/google
GET    /api/v1/posts
GET    /api/v1/posts/{id}
GET    /api/v1/locations
GET    /api/v1/locations/{id}
GET    /api/v1/activities
GET    /api/v1/activities/{id}
GET    /api/v1/travel-plan
```

### Routes protégées

Les routes protégées utilisent un token Laravel Sanctum.

```text
POST   /api/v1/auth/logout
GET    /api/v1/user
PUT    /api/v1/user
POST   /api/v1/user/avatar
POST   /api/v1/posts
DELETE /api/v1/posts/{id}
POST   /api/v1/locations/{id}/ratings
POST   /api/v1/activities
POST   /api/v1/activities/{id}/join
DELETE /api/v1/activities/{id}/join
```

## Installation locale

### Prérequis

- PHP 8.2 ou version ultérieure
- Composer
- Node.js et npm
- Extensions PHP requises par Laravel

### 1. Cloner le dépôt

```bash
git clone https://github.com/Oussamabrd2/touriste-app.git
cd touriste-app
```

### 2. Installer et configurer le projet

```bash
composer install
npm install
cp .env.example .env
php artisan key:generate
```

Créez la base SQLite si elle n’existe pas :

```bash
touch database/database.sqlite
```

Sous Windows PowerShell :

```powershell
New-Item database/database.sqlite -ItemType File
```

Lancez ensuite les migrations :

```bash
php artisan migrate
```

### 3. Démarrer l’application

```bash
composer run dev
```

Vous pouvez aussi démarrer les services séparément :

```bash
php artisan serve
npm run dev
```

## Tests

```bash
php artisan test
```

## Sécurité

- authentification par tokens avec Laravel Sanctum ;
- mots de passe hachés automatiquement ;
- contrôle d’accès par rôles ;
- blocage des comptes utilisateurs ;
- variables sensibles exclues du dépôt grâce à `.gitignore`.

> Ne publiez jamais votre fichier `.env`. Utilisez `.env.example` uniquement comme modèle de configuration.

## Structure principale

```text
app/
├── Http/Controllers/Api/       # Contrôleurs de l’API REST
├── Http/Controllers/Admin/     # Tableau de bord administrateur
├── Models/                     # Modèles Eloquent
routes/
├── api.php                     # Routes API v1
└── web.php                     # Authentification et administration
database/
├── migrations/
├── factories/
└── seeders/
```

## Contexte

Projet académique réalisé dans le cadre de la formation en **Développement d’Applications Web et Mobile**.

## Auteur

**Oussama Baghdadi**  
Développeur web et mobile

## Licence

Ce projet est présenté à des fins académiques et de démonstration. Tous droits réservés.
