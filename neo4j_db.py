from neo4j import GraphDatabase
import os

# --- Configuration ---
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USER = "neo4j"
NEO4J_PASSWORD = "CosmeticGraph2025" # The password set in the previous step

class Neo4jDB:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def _execute_read(self, query, parameters=None):
        with self.driver.session() as session:
            result = session.run(query, parameters)
            return [record for record in result]

    def _execute_write(self, query, parameters=None):
        with self.driver.session() as session:
            return session.execute_write(self._execute_write_tx, query, parameters)

    @staticmethod
    def _execute_write_tx(tx, query, parameters):
        result = tx.run(query, parameters)
        return result.consume().counters

    # --- API Implementation ---

    def get_efficacies(self):
        """Retrieves all efficacy categories."""
        query = "MATCH (e:Efficacy) RETURN e.id AS id, e.name AS name, e.description AS description ORDER BY e.id"
        records = self._execute_read(query)
        return [dict(record) for record in records]

    def get_ingredients_by_efficacy(self, efficacy_id):
        """Retrieves ingredients associated with a specific efficacy, sorted by efficacy_score.
        Updated to include safety_level_score and clinical_data."""
        query = """
        MATCH (e:Efficacy {id: $efficacy_id})<-[:HAS_EFFICACY]-(i:Ingredient)
        RETURN i.id AS id, i.name AS name, i.english_name AS english_name, i.mechanism AS mechanism, 
               i.efficacy_score AS efficacy_score, i.evidence_level AS evidence_level,
               i.safety_level AS safety_level, i.safety_level_score AS safety_level_score,
               i.clinical_data AS clinical_data
        ORDER BY i.efficacy_score DESC
        """
        records = self._execute_read(query, {"efficacy_id": efficacy_id})
        return [dict(record) for record in records]

    def get_products_by_ingredient(self, ingredient_name):
        """Retrieves products containing a specific ingredient, sorted by concentration level."""
        query = """
        MATCH (p:Product)-[c:CONTAINS]->(i:Ingredient {name: $ingredient_name})
        OPTIONAL MATCH (p)-[:SUITABLE_FOR]->(st:SkinType)
        RETURN 
            p.name AS name, p.brand AS brand, p.price AS price, p.url AS url, p.type AS type, 
            c.concentration_level AS concentration_level, c.position AS position,
            collect(st.name) AS suitable_skin_types
        ORDER BY 
            CASE c.concentration_level 
                WHEN 'High' THEN 1 
                WHEN 'Medium' THEN 2 
                WHEN 'Low' THEN 3 
                ELSE 4 
            END, c.position
        """
        records = self._execute_read(query, {"ingredient_name": ingredient_name})
        return [dict(record) for record in records]

    def get_products_by_ingredient_and_skintypes(self, ingredient_name, skin_type_names):
        """根据成分名称和肤质名称列表获取产品列表，按浓度等级排序"""
        query = """
        MATCH (i:Ingredient {name: $ingredient_name})<-[c:CONTAINS]-(p:Product)
        WHERE ALL(st_name IN $skin_type_names WHERE EXISTS {
            (p)-[:SUITABLE_FOR]->(:SkinType {name: st_name})
        })
        OPTIONAL MATCH (p)-[:SUITABLE_FOR]->(st:SkinType)
        RETURN 
            p.name AS name, p.brand AS brand, p.price AS price, p.url AS url, p.type AS type, 
            c.concentration_level AS concentration_level, c.position AS position,
            collect(st.name) AS suitable_skin_types
        ORDER BY 
            CASE c.concentration_level
                WHEN 'High' THEN 1
                WHEN 'Medium' THEN 2
                WHEN 'Low' THEN 3
                ELSE 4
            END, c.position
        """
        records = self._execute_read(query, {"ingredient_name": ingredient_name, "skin_type_names": skin_type_names})
        return [dict(record) for record in records]

    def get_skin_types(self):
        """Retrieves all skin types."""
        query = "MATCH (s:SkinType) RETURN s.id AS id, s.name AS name, s.description AS description ORDER BY s.id"
        records = self._execute_read(query)
        return [dict(record) for record in records]

    def get_ingredient_interactions(self, ingredient_name):
        """Retrieves interactions (synergy/contraindication) for a given ingredient."""
        query = """
        MATCH (i1:Ingredient {name: $ingredient_name})-[r:INTERACTS_WITH]->(i2:Ingredient)
        RETURN i2.name AS target_ingredient, r.type AS interaction_type, r.description AS description
        """
        records = self._execute_read(query, {"ingredient_name": ingredient_name})
        return [dict(record) for record in records]

    def get_synergy_recommendations(self, ingredient_name):
        """基于成分协同作用的智能推荐"""
        query = """
        MATCH (i1:Ingredient {name: $ingredient_name})-[r:INTERACTS_WITH]->(i2:Ingredient)
        WHERE r.type = 'Synergy'
        MATCH (i2)<-[:CONTAINS]-(p:Product)
        OPTIONAL MATCH (p)-[:SUITABLE_FOR]->(st:SkinType)
        RETURN 
            p.name AS name, p.brand AS brand, p.price AS price, p.url AS url, p.type AS type, 
            collect(st.name) AS suitable_skin_types,
            i2.name AS synergistic_ingredient,
            r.description AS synergy_description
        LIMIT 5
        """
        records = self._execute_read(query, {"ingredient_name": ingredient_name})
        return [dict(record) for record in records]

    def get_evidence_level_explanation(self):
        """Retrieves the explanation for evidence levels."""
        query = "MATCH (n:Explanation {type: 'EvidenceLevel'}) RETURN n.A AS A, n.B AS B, n.C AS C"
        records = self._execute_read(query)
        if records:
            return dict(records[0])
        return {}

# Initialize the database connection
neo4j_db = Neo4jDB(NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD)
