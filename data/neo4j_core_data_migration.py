import sqlite3
from neo4j import GraphDatabase
import os

# --- Configuration ---
SQLITE_DB_PATH = '/home/ubuntu/cosmetic_ingredient_system/backend/cosmetic.db'
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "CosmeticGraph2025" # The password set in the previous step

# --- Neo4j Connection ---
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

def close_driver():
    driver.close()

def run_cypher(tx, cypher, params=None):
    result = tx.run(cypher, params)
    return result.consume().counters

def migrate_core_data():
    """Migrates Efficacies, SkinTypes, Master Ingredients, and Interactions from SQLite to Neo4j."""
    
    conn = sqlite3.connect(SQLITE_DB_PATH)
    cursor = conn.cursor()
    
    with driver.session() as session:
        # 1. Clear existing data (optional, but good for clean migration)
        session.execute_write(run_cypher, "MATCH (n) DETACH DELETE n")
        print("Cleared existing Neo4j graph data.")
        
        # 2. Migrate Effect Categories (Efficacy)
        cursor.execute("SELECT id, name, description FROM effect_categories")
        effects = cursor.fetchall()
        for effect_id, name, description in effects:
            session.execute_write(run_cypher, 
                "CREATE (e:Efficacy {id: $id, name: $name, description: $description})",
                {'id': effect_id, 'name': name, 'description': description}
            )
        print(f"Migrated {len(effects)} Efficacy nodes.")
        
        # 3. Migrate Skin Types
        cursor.execute("SELECT id, name, description FROM skin_types")
        skin_types = cursor.fetchall()
        for st_id, name, description in skin_types:
            session.execute_write(run_cypher, 
                "CREATE (s:SkinType {id: $id, name: $name, description: $description})",
                {'id': st_id, 'name': name, 'description': description}
            )
        print(f"Migrated {len(skin_types)} SkinType nodes.")
        
        # 4. Migrate Master Ingredients
        cursor.execute("SELECT id, name, english_name, mechanism, efficacy_score, evidence_level FROM ingredients")
        ingredients = cursor.fetchall()
        for ing_id, name, english_name, mechanism, efficacy_score, evidence_level in ingredients:
            session.execute_write(run_cypher, 
                "CREATE (i:Ingredient {id: $id, name: $name, english_name: $en_name, mechanism: $mech, efficacy_score: $score, evidence_level: $level, source: 'Master'})",
                {'id': ing_id, 'name': name, 'en_name': english_name, 'mech': mechanism, 'score': efficacy_score, 'level': evidence_level}
            )
        print(f"Migrated {len(ingredients)} Master Ingredient nodes.")
        
        # 5. Migrate Efficacy-Ingredient Relationships
        cursor.execute("SELECT effect_id, ingredient_id FROM effect_ingredient")
        effect_ingredient_rels = cursor.fetchall()
        for effect_id, ingredient_id in effect_ingredient_rels:
            session.execute_write(run_cypher, 
                "MATCH (e:Efficacy {id: $eid}), (i:Ingredient {id: $iid}) "
                "CREATE (i)-[:HAS_EFFICACY]->(e)",
                {'eid': effect_id, 'iid': ingredient_id}
            )
        print(f"Migrated {len(effect_ingredient_rels)} HAS_EFFICACY relationships.")
        
        # 6. Migrate Ingredient Interactions (The "小巧思")
        cursor.execute("SELECT ingredient1_id, ingredient2_id, interaction_type, description FROM ingredient_interactions")
        interactions = cursor.fetchall()
        for id1, id2, type, description in interactions:
            session.execute_write(run_cypher, 
                "MATCH (i1:Ingredient {id: $id1}), (i2:Ingredient {id: $id2}) "
                "CREATE (i1)-[:INTERACTS_WITH {type: $type, description: $desc}]->(i2)",
                {'id1': id1, 'id2': id2, 'type': type, 'desc': description}
            )
        print(f"Migrated {len(interactions)} INTERACTS_WITH relationships.")

    conn.close()
    print("Core data migration complete.")

if __name__ == "__main__":
    try:
        migrate_core_data()
    except Exception as e:
        print(f"An error occurred during migration: {e}")
    finally:
        close_driver()
