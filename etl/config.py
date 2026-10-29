import os
from dotenv import load_dotenv

# Load variables from .env located at project root
load_dotenv()

SHOP_DOMAIN = os.getenv("SHOPIFY_SHOP_DOMAIN")
CLIENT_ID = os.getenv("SHOPIFY_CLIENT_ID")
CLIENT_SECRET = os.getenv("SHOPIFY_CLIENT_SECRET")
API_VERSION = os.getenv("SHOPIFY_API_VERSION", "2026-10")

TOKEN_URL = f"https://{SHOP_DOMAIN}/admin/oauth/access_token"
GRAPHQL_URL = f"https://{SHOP_DOMAIN}/admin/api/{API_VERSION}/graphql.json"