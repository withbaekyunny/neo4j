import csv
from neo4j import GraphDatabase
import random
import os

# --- Configuration ---
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "CosmeticGraph2025"

# --- Skin Type Mapping ---
# 1: Dry, 2: Oily, 3: Combination, 4: Sensitive
SKIN_TYPES = {
    1: "Dry",
    2: "Oily",
    3: "Combination",
    4: "Sensitive"
}

def migrate_skintype_data():
    driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    
    # 1. Get all product names from Neo4j
    with driver.session() as session:
        result = session.run("MATCH (p:Product) RETURN p.name AS name")
        product_names = [record["name"] for record in result]

    # 2. Assign random skin types to each product and prepare for batching
    relationships_to_create = []
    for product_name in product_names:
        num_skin_types = random.randint(1, 3)
        selected_skintype_ids = random.sample(list(SKIN_TYPES.keys()), num_skin_types)
        for skintype_id in selected_skintype_ids:
            skintype_name = SKIN_TYPES[skintype_id]
            relationships_to_create.append({
                "product_name": product_name, 
                "skintype_name": skintype_name
            })

    # 3. Execute the Cypher statements in batches using parameterization
    def create_relationships_tx(tx, relationships):
        # This query is now safe from injection and syntax errors
        query = """
        MATCH (p:Product {name: $product_name})
        MATCH (st:SkinType {name: $skintype_name})
        MERGE (p)-[:SUITABLE_FOR]->(st)
        """
        for rel in relationships:
            tx.run(query, product_name=rel["product_name"], skintype_name=rel["skintype_name"])
        
    batch_size = 1000
    total_batches = (len(relationships_to_create) + batch_size - 1) // batch_size
    for i in range(0, len(relationships_to_create), batch_size):
        batch = relationships_to_create[i:i + batch_size]
        with driver.session() as session:
            session.execute_write(create_relationships_tx, batch)
            print(f"Migrated batch {i//batch_size + 1} of {total_batches}")

    driver.close()
    print("Skin type migration complete.")

if __name__ == "__main__":
    migrate_skintype_data()

