# DIGIT Core Services - Local Development Stack

Run a complete DIGIT development environment locally with all core services, PGR module, and the DIGIT UI.

## Quick Start

```bash
# 1. Clone this repo
git clone <this-repo> digit-core
cd digit-core

# 2. Clone CCRS repo (UI + PGR configs) as sibling directory
git clone https://github.com/egovernments/Citizen-Complaint-Resolution-System.git ../Citizen-Complaint-Resolution-System

# 3. Start with Tilt (recommended)
tilt up

# 4. Access DIGIT UI
open http://localhost:18000/digit-ui/
```

## Prerequisites

- Docker Desktop (or Docker Engine + Compose v2)
- [Tilt](https://docs.tilt.dev/install.html) (recommended for development)
- 8+ GB RAM available for Docker

## What's Included

### Infrastructure
| Service | Port | Description |
|---------|------|-------------|
| Postgres | 15432 | Database |
| Redis | 16379 | Cache |
| Redpanda | 19092 | Kafka-compatible messaging |
| Elasticsearch | 19200 | Search & indexing |

### Core Services
| Service | Port | Health Check |
|---------|------|--------------|
| MDMS v2 | 18094 | `/mdms-v2/health` |
| User | 18107 | `/user/health` |
| Workflow v2 | 18109 | `/egov-workflow-v2/health` |
| Localization | 18096 | `/localization/actuator/health` |
| Location | 18084 | `/egov-location/health` |
| Boundary v2 | 18081 | `/boundary-service/actuator/health` |
| Access Control | 18090 | `/access/health` |
| IDGEN | 18088 | `/egov-idgen/health` |
| ENC | 11234 | `/egov-enc-service/actuator/health` |
| Persister | 18091 | `/common-persist/actuator/health` |

### Application
| Service | Port | URL |
|---------|------|-----|
| Kong Gateway | 18000 | Main entry point |
| DIGIT UI | 18080 | Static assets only |
| PGR Services | 18083 | `/pgr-services/health` |

## Development with Tilt

Tilt provides a better development experience with:
- Dashboard at http://localhost:10350
- Live logs for all services
- One-click restarts
- Health status monitoring

```bash
# Start everything
tilt up

# Stop everything
tilt down
```

### Tilt Dashboard Features
- **Health Check** button - runs all health checks
- **Smoke Tests** button - validates API functionality
- **Nuke DB** button - reset database (destructive)
- **Start Jupyter** - launch Jupyter Lab for data exploration
- **Start Gatus** - launch health monitoring dashboard

## Alternative: Docker Compose Only

```bash
# Start
docker compose up -d

# Watch logs
docker compose logs -f

# Stop
docker compose down

# Reset (remove volumes)
docker compose down -v
```

## UI Development

The DIGIT UI is built from the CCRS repository. For live development:

### Setup
```bash
# Ensure CCRS repo is cloned as sibling
ls ../Citizen-Complaint-Resolution-System/frontend/micro-ui

# Or set custom path
export CCRS_PATH=/path/to/Citizen-Complaint-Resolution-System
tilt up
```

### Live Updates
1. Make changes in `../Citizen-Complaint-Resolution-System/frontend/micro-ui/`
2. Build locally: `cd ../Citizen-Complaint-Resolution-System/frontend/micro-ui/web && yarn build`
3. Tilt automatically syncs the `build/` folder to the container

### Configuration
- `globalConfigs.js` is mounted from `CCRS/configs/assets/globalConfigsPGR.js`
- Edit this file to change tenant ID, API keys, feature flags

## API Access

All APIs are available through Kong gateway at `http://localhost:18000`:

```bash
# MDMS search
curl -X POST "http://localhost:18000/mdms-v2/v1/_search" \
  -H "Content-Type: application/json" \
  -d '{"MdmsCriteria":{"tenantId":"pg","moduleDetails":[{"moduleName":"tenant","masterDetails":[{"name":"tenants"}]}]},"RequestInfo":{"apiId":"Rainmaker"}}'

# User login
curl -X POST "http://localhost:18000/user/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic ZWdvdi11c2VyLWNsaWVudDo=" \
  -d "username=ADMIN@digit.org&password=admin123&tenantId=pg&grant_type=password&scope=read&userType=EMPLOYEE"
```

## Database Access

```bash
# Connect to Postgres
docker exec -it docker-postgres psql -U egov -d egov

# Common queries
\dt                          # List tables
SELECT * FROM eg_user LIMIT 5;
```

## Troubleshooting

### Services not starting
```bash
# Check service logs
docker compose logs <service-name>

# Restart a specific service
docker compose restart <service-name>
```

### UI showing blank page
- Check browser console for errors
- Verify globalConfigs.js is loaded: `curl http://localhost:18000/digit-ui/globalConfigs.js`
- Ensure CCRS repo is cloned correctly

### API returning errors
- Check Kong is running: `curl http://localhost:18000/`
- Check backend service health: `curl http://localhost:18094/mdms-v2/health`

### Reset everything
```bash
docker compose down -v
docker compose up -d
```

## Resource Usage

Optimized for ~4GB RAM usage:

| Component | Memory |
|-----------|--------|
| Infrastructure (Postgres, Redis, ES, Redpanda) | ~1.5 GB |
| Core Services (Java) | ~2 GB |
| Kong + UI | ~0.3 GB |
| **Total** | **~3.8 GB** |

## Project Structure

```
digit-core/
├── docker-compose.yml    # Service definitions
├── Tiltfile              # Tilt configuration
├── kong/
│   └── kong.yml          # API gateway routes
├── db/
│   └── seed.sql          # Database seed data
├── mdms-data/            # Master data configs
├── scripts/              # Helper scripts
└── postman/              # API collection

../Citizen-Complaint-Resolution-System/   # CCRS repo (sibling)
├── frontend/micro-ui/    # DIGIT UI source
└── configs/assets/       # Runtime configs
```
