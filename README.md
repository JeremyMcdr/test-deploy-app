# Test Deploy App

Application de test pour valider le pipeline de déploiement VPS Central Command.

## Structure

```
test-deploy-app/
├── src/
│   └── index.html      # Page web statique
├── .github/
│   └── workflows/
│       └── deploy.yml  # GitHub Actions workflow
├── Dockerfile          # Image Docker nginx
├── nginx.conf          # Configuration nginx
├── docker-compose.yml  # Pour test local
└── README.md
```

## Test local

```bash
# Build et run
docker compose up -d

# Accéder à l'app
open http://localhost:8080

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down
```

## Configuration VPS Central Command

### 1. Créer un serveur

Dans VPS Central Command, ajouter un serveur avec ses credentials SSH.

### 2. Créer le projet et la stack

```bash
# Via l'API ou l'interface web

# 1. Créer un projet
POST /api/projects
{
  "name": "Test Deploy App",
  "slug": "test-deploy-app",
  "base_domain": "example.com"
}

# 2. Créer une stack
POST /api/stacks
{
  "projectId": "<project-uuid>",
  "name": "Production",
  "environment": "production",
  "services": [{
    "name": "web",
    "type": "web",
    "image": "nginx:alpine",
    "serverId": "<server-uuid>",
    "port": 8080,
    "containerPort": 80,
    "domain": "test-app.example.com",
    "isPublic": true,
    "sslEnabled": true
  }]
}
```

### 3. Créer un deploy token

Dans l'interface VPS Central Command:
- Settings → Deploy Tokens → Create
- Permissions: `can_deploy`, `can_view_logs`

### 4. Configurer les secrets GitHub

Dans le repo GitHub → Settings → Secrets and variables → Actions:

| Secret | Description |
|--------|-------------|
| `VCC_URL` | URL de VPS Central Command (ex: `https://vcc.example.com`) |
| `VCC_STACK_ID` | UUID de la stack créée |
| `VCC_DEPLOY_TOKEN` | Token de déploiement |

## Pipeline de déploiement

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   GitHub    │────▶│   Actions   │────▶│    VCC      │────▶│    VPS      │
│   (push)    │     │   (build)   │     │  (deploy)   │     │  (docker)   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                          │
                          ▼
                    ┌─────────────┐
                    │    GHCR     │
                    │   (image)   │
                    └─────────────┘
```

1. **Push** sur `main` → déclenche GitHub Actions
2. **Build** de l'image Docker → push sur GHCR
3. **Deploy** → appel API VPS Central Command
4. **VCC** → configure DNS + Proxy + Docker sur le VPS

## Modifier la version

Pour tester un nouveau déploiement, modifiez `src/index.html`:

```javascript
// Changer la version affichée
document.getElementById('version').textContent = 'v1.1.0';
```

Puis commit et push - le déploiement sera automatique.
