# E-Commerce Migration & Data Audit ETL Pipeline

An end-to-end data extraction, transformation, and validation pipeline for e-commerce platform migrations. Extracts source catalog, customer, and order data from **WooCommerce**, **PrestaShop**, and **OpenCart** (running locally via MariaDB), transforms and audits records using **Polars**, **PyArrow**, and **DuckDB**, and loads/validates data against **Shopify** via the Admin GraphQL API and Bulk Operations API.

---

## Architecture & Directory Structure

```text
e_commerce/
├── data/                  # Output JSONL dumps, Parquet files, and DuckDB audits
├── etl/                   # Python ETL Pipeline Application
│   ├── extract/           # SQL queries for WooCommerce, PrestaShop, and OpenCart
│   ├── transform/         # Polars/PyArrow data normalization and audit rules
│   ├── load/              # Shopify GraphQL mutations and Bulk API client
│   ├── config.py          # Environment configuration & credential loader
│   └── main.py            # Main pipeline execution entry point
├── opencart_src/          # OpenCart PHP core source files
├── .env.example           # Template for environment variables
├── docker-compose.yml     # Infrastructure stack (MariaDB, phpMyAdmin, Web stores)
├── Dockerfile.opencart    # Apache/PHP image for OpenCart
├── init.sql               # Database initialization script
└── setup.sh               # OpenCart source downloader script
```

---

## Prerequisites

- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/)
- [uv](https://github.com/astral-sh/uv) (Fast Python package manager)
- [Git](https://git-scm.com/)

---

## Local Setup & Infrastructure

### 1. Configure Environment Variables

Copy the example environment file and update credentials if necessary:

```bash
cp .env.example .env
```

### 2. Download Dependencies & Start Docker Stack

Run the setup script to pull OpenCart source files, then spin up the container infrastructure:

```bash
./setup.sh
docker compose up -d --build
```

### 3. Complete Store Web Installations

Open your browser and complete the initial web installation wizards for each store:

- **WooCommerce:** `http://localhost:8081`
- **PrestaShop:** `http://localhost:8082`  
  _(Installation takes 2–3 minutes. Follow logs via `docker logs --tail 30 -f ecom_prestashop`)_
- **OpenCart:** `http://localhost:8083`
  - **Database Host:** `db`
  - **Database Name:** `opencart`
  - **DB User:** `root` | **DB Pass:** `root_pass` | **Port:** `3306`

### 4. Post-Install OpenCart Hardening & Cleanup

Once the OpenCart wizard finishes, remove the installer directory and move storage outside the web root:

```bash
# Remove installation files
rm -rf opencart_src/install

# Move storage directory and update config paths
docker exec ecom_opencart bash -c "mkdir -p /var/www/storage && cp -rn /var/www/html/system/storage/* /var/www/storage/ && chown -R www-data:www-data /var/www/storage"
sed -i "s|define('DIR_STORAGE',.*);|define('DIR_STORAGE', '/var/www/storage/');|g" opencart_src/config.php opencart_src/admin/config.php
```

### 5. Shopify Development Store Setup

To test and execute the loading phase (`etl.load.shopify`), you need access to a Shopify Development Store:

1. Sign up for a free [Shopify Partner Account](https://partners.shopify.com/).
2. Create a **Development Store** (e.g., `your-store-sandbox.myshopify.com`).
3. Open the **Dev Dashboard** (`dev.shopify.com`) and create a new app.
4. Set required API scopes (e.g., `read_products`, `write_products`, `read_customers`, `write_customers`).
5. Release a version and install the app to your development store.
6. Copy the **Client ID** and **Client Secret** into your `.env` file.

---

## Python ETL Setup

### 1. Install Dependencies & Virtual Environment

Initialize the local Python environment using `uv`:

```bash
uv sync
```

### 2. Run Pipeline Scripts

Execute the ETL modules directly using `uv run`:

```bash
# Test Shopify GraphQL API connectivity
uv run python -m etl.load.shopify

# Run full ETL audit pipeline
uv run python -m etl.main
```

---

## Useful Infrastructure Commands

```bash
# View running container logs
docker compose logs -f

# Pause containers without removing them (quick resume via `docker compose start`)
docker compose stop

# Stop and remove containers and networks (keeps database volume intact)
docker compose down

# Complete reset (clears databases, volumes, and containers)
docker compose down -v --rmi all --remove-orphans
```
