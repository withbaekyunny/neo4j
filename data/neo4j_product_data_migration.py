import csv
import re
import os
import sqlite3
from neo4j import GraphDatabase

# --- Configuration ---
CSV_PATH = '/home/ubuntu/cosmetic_ingredient_system/data/skincare_products.csv'
SQLITE_DB_PATH = '/home/ubuntu/cosmetic_ingredient_system/backend/cosmetic.db'
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "CosmeticGraph2025"

# --- Ingredient Cleaning and Normalization (Same as before) ---
def normalize_ingredient(ing):
    """Cleans up and normalizes an ingredient string."""
    ing = ing.strip()
    ing = re.sub(r'\([^)]*\)', '', ing).strip() # Remove parentheses and content inside them
    ing = re.sub(r'\b(Extract|Oil|Water|Powder|Juice|Acid|Salt|Ester)\b', '', ing, flags=re.IGNORECASE).strip()
    ing = re.sub(r'[/\\-]', ' ', ing).strip()
    ing = re.sub(r'\s+', ' ', ing).strip()
    ing = ing.title()
    return ing

# --- Load Master Ingredient List from SQLite ---
def load_master_ingredients(db_path):
    """Loads the master ingredient list (name and ID) from the SQLite DB."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT id, name FROM ingredients")
    master_ingredients = {normalize_ingredient(name): (id, name) for id, name in cursor.fetchall()}
    conn.close()
    return master_ingredients

# --- Neo4j Connection ---
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

def close_driver():
    driver.close()

def import_products_and_relationships(tx, product_data, master_ingredients_map):
    """Imports a batch of product data into Neo4j."""
    
    # Use UNWIND for efficient batching
    cypher_query = """
    UNWIND $product_data AS data
    
    // 1. Create or Merge Product Node
    MERGE (p:Product {name: data.product_name})
    ON CREATE SET
        p.brand = data.brand,
        p.type = data.product_type,
        p.url = data.product_url,
        p.price = data.price,
        p.source = 'Kaggle'
    
    // 2. Process Ingredients and Relationships
    WITH p, data
    UNWIND data.ingredients AS ingredient_info
    
    // 3. Create or Merge Ingredient Node
    MERGE (i:Ingredient {name: ingredient_info.canonical_name})
    ON CREATE SET
        i.source = ingredient_info.source
    
    // 4. Create CONTAINS relationship
    MERGE (p)-[c:CONTAINS]->(i)
    ON CREATE SET
        c.concentration_level = ingredient_info.concentration_level,
        c.position = ingredient_info.position
    """
    
    tx.run(cypher_query, product_data=product_data)

def migrate_product_data():
    """Reads CSV and batches data for Neo4j import."""
    
    if not os.path.exists(CSV_PATH):
        print(f"Error: CSV file not found at {CSV_PATH}")
        return

    master_ingredients_map = load_master_ingredients(SQLITE_DB_PATH)
    product_batch = []
    BATCH_SIZE = 1000 # Process 1000 products at a time
    total_products = 0
    
    with driver.session() as session:
        with open(CSV_PATH, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader) # Skip header
            
            for i, row in enumerate(reader):
                if len(row) < 5:
                    continue

                product_name = row[0].strip()
                product_url = row[1].strip()
                product_type = row[2].strip()
                ingredients_raw = row[3].strip()
                price = row[4].replace('£', '').strip()
                
                brand = product_name.split(' ')[0].strip()
                
                ingredients_list = []
                # Split by comma, ignoring commas inside parentheses
                raw_ingredients = [ing.strip() for ing in re.split(r',\s*(?![^()]*\))', ingredients_raw) if ing.strip()]
                
                for j, ing_name_raw in enumerate(raw_ingredients):
                    ing_name_normalized = normalize_ingredient(ing_name_raw)
                    
                    if not ing_name_normalized:
                        continue

                    # Determine concentration level based on position
                    concentration_level = 'Low'
                    if j < 3:
                        concentration_level = 'High'
                    elif j < 6:
                        concentration_level = 'Medium'
                    
                    ingredient_info = {
                        'position': j + 1,
                        'concentration_level': concentration_level,
                    }
                    
                    # Check if it's a master ingredient
                    if ing_name_normalized in master_ingredients_map:
                        ingredient_info['canonical_name'] = master_ingredients_map[ing_name_normalized][1]
                        ingredient_info['source'] = 'Master'
                    else:
                        # Use the normalized name for new ingredients
                        ingredient_info['canonical_name'] = ing_name_normalized
                        ingredient_info['source'] = 'Kaggle'
                        
                    ingredients_list.append(ingredient_info)

                if not ingredients_list:
                    continue

                product_batch.append({
                    'product_name': product_name,
                    'brand': brand,
                    'product_type': product_type,
                    'product_url': product_url,
                    'price': price,
                    'ingredients': ingredients_list
                })
                total_products += 1

                if len(product_batch) >= BATCH_SIZE:
                    session.execute_write(import_products_and_relationships, product_batch, master_ingredients_map)
                    print(f"Imported {len(product_batch)} products. Total imported: {total_products}")
                    product_batch = []
            
            # Import remaining products
            if product_batch:
                session.execute_write(import_products_and_relationships, product_batch, master_ingredients_map)
                print(f"Imported final batch of {len(product_batch)} products. Total imported: {total_products}")
                
    print(f"Product data migration complete. Total products processed: {total_products}")

if __name__ == "__main__":
    try:
        migrate_product_data()
    except Exception as e:
        print(f"An error occurred during product migration: {e}")
    finally:
        close_driver()
