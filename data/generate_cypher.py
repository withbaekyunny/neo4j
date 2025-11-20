import csv
import re
import os
import sqlite3

# --- Configuration ---
CSV_PATH = '/home/ubuntu/cosmetic_ingredient_system/data/skincare_products.csv'
CYPHER_PATH = '/home/ubuntu/cosmetic_ingredient_system/data/neo4j_import_products.cypher'
SQLITE_DB_PATH = '/home/ubuntu/cosmetic_ingredient_system/backend/cosmetic.db' # Path is correct, the issue must be in the table name or schema.

# --- Ingredient Cleaning and Normalization ---
def normalize_ingredient(ing):
    """Cleans up and normalizes an ingredient string."""
    ing = ing.strip()
    # Remove parentheses and content inside them
    ing = re.sub(r'\(.*?\)', '', ing).strip()
    # Remove common prefixes/suffixes like "Extract", "Oil", "Water"
    ing = re.sub(r'\b(Extract|Oil|Water|Powder|Juice|Acid|Salt|Ester)\b', '', ing, flags=re.IGNORECASE).strip()
    # Remove common punctuation/separators
    ing = re.sub(r'[/\\-]', ' ', ing).strip()
    # Remove extra spaces
    ing = re.sub(r'\s+', ' ', ing).strip()
    # Convert to title case for better matching
    ing = ing.title()
    return ing

# --- Load Master Ingredient List from SQLite ---
def load_master_ingredients(db_path):
    """Loads the master ingredient list (name and ID) from the SQLite DB."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    # We only need the name of the ingredient from the old system
    cursor.execute("SELECT id, name FROM ingredients")
    master_ingredients = {normalize_ingredient(name): (id, name) for id, name in cursor.fetchall()}
    conn.close()
    return master_ingredients

# --- Main Processing Function ---
def generate_cypher_script():
    if not os.path.exists(CSV_PATH):
        print(f"Error: CSV file not found at {CSV_PATH}")
        return

    master_ingredients_map = load_master_ingredients(SQLITE_DB_PATH)
    
    # We will use the existing ingredient names as the canonical name for Neo4j nodes
    # We will also track all unique ingredient names found in the CSV for new nodes
    unique_ingredients_from_csv = set()
    
    cypher_commands = []
    
    # 1. Create Efficacy and Master Ingredient Nodes (using the old data as the source)
    # This is a placeholder. A separate step will handle full data migration.
    # For now, we only create the Product nodes and their relationships.
    
    # 2. Process Products and Relationships
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        # The CSV is not perfectly standard, so we'll use a robust reader and skip the header
        reader = csv.reader(f)
        header = next(reader) # Skip header
        
        for i, row in enumerate(reader):
            if len(row) < 5:
                # Skip incomplete rows
                continue

            product_name = row[0].replace("'", "\\\\'") # Escape single quotes for Cypher
            product_url = row[1]
            product_type = row[2].replace("'", "\\'")
            ingredients_raw = row[3]
            price = row[4].replace('£', '').strip()
            
            # Extract brand from product name (simple heuristic)
            brand = product_name.split(' ')[0]
            
            # Split and clean ingredients
            # Ingredients are often separated by commas, sometimes with a space, sometimes with a dot-space.
            # We will split by comma and then clean each part.
            ingredients_list = [
                normalize_ingredient(ing) 
                for ing in re.split(r',\s*(?![^()]*\))', ingredients_raw) # Split by comma, ignoring commas inside parentheses
                if normalize_ingredient(ing)
            ]
            
            if not ingredients_list:
                continue

            # Create Product Node
            cypher_commands.append(
                f"MERGE (p:Product {{name: '{product_name}', brand: '{brand}', type: '{product_type}', url: '{product_url}', price: '{price}', source: 'Kaggle'}}) RETURN p;"
            )

            # Create Relationships
            for j, ing_name_normalized in enumerate(ingredients_list):
                # Determine concentration level based on position (simple heuristic for now)
                # 1-3: High, 4-6: Medium, 7+: Low
                if j < 3:
                    concentration_level = 'High'
                elif j < 6:
                    concentration_level = 'Medium'
                else:
                    concentration_level = 'Low'
                
                # Use the normalized name for matching, but the original for the node (if needed later)
                
                # We prioritize creating relationships to the existing master ingredients
                if ing_name_normalized in master_ingredients_map:
                    # Use the canonical name from the master list
                    canonical_name = master_ingredients_map[ing_name_normalized][1].replace("'", "\\\\'")
                    
                    # MERGE or CREATE the Ingredient node (if it doesn't exist yet)
                    # We will use the canonical name as the key
                    cypher_commands.append(
                        f"MERGE (i:Ingredient {{name: '{canonical_name}'}}) ON CREATE SET i.source = 'Master';"
                    )
                    
                    # Create the relationship
                    cypher_commands.append(
                        f"MATCH (p:Product {{name: '{product_name}'}}), (i:Ingredient {{name: '{canonical_name}'}}) "
                        f"MERGE (p)-[:CONTAINS {{concentration_level: '{concentration_level}', position: {j+1}}}]->(i);"
                    )
                else:
                    # If it's a new ingredient, we still create the node and relationship
                    # We use the normalized name as the key for the new ingredient
                    unique_ingredients_from_csv.add(ing_name_normalized)
                    
                    escaped_ing_name = ing_name_normalized.replace("'", "\\\\'")
                    
                    cypher_commands.append(
                        f"MERGE (i:Ingredient {{name: '{escaped_ing_name}', source: 'Kaggle'}}) ON CREATE SET i.source = 'Kaggle';"
                    )
                    
                    cypher_commands.append(
                        f"MATCH (p:Product {{name: '{product_name}'}}), (i:Ingredient {{name: '{escaped_ing_name}'}}) "
                        f"MERGE (p)-[:CONTAINS {{concentration_level: '{concentration_level}', position: {j+1}}}]->(i);"
                    )

    # Write the Cypher script
    with open(CYPHER_PATH, 'w', encoding='utf-8') as f:
        f.write("\n".join(cypher_commands))
        
    print(f"\nSuccessfully generated Cypher script with {len(cypher_commands)} commands at {CYPHER_PATH}")
    print(f"Found {len(unique_ingredients_from_csv)} new unique ingredients in the CSV.")
    print("Next step: Run the full data migration script to move Efficacies, SkinTypes, and Master Ingredients to Neo4j first, then import the products.")

# Execute the function
generate_cypher_script()
