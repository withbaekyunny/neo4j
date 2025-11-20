# Neo4j Graph Data Model for Cosmetic Ingredient System

This document outlines the proposed Graph Data Model for the "Neo4j-based Intelligent Cosmetic Recommendation System" project.

## 1. Node Labels and Properties

| Label | Description | Key Properties |
| :--- | :--- | :--- |
| **Efficacy** | 功效类别，如美白、抗衰老 | `id` (INT), `name` (STRING), `description` (STRING) |
| **Ingredient** | 化妆品成分 | `id` (INT), `name` (STRING), `english_name` (STRING), `mechanism` (STRING), `clinical_data` (STRING), `efficacy_score` (FLOAT), `evidence_level` (STRING), `safety_level` (STRING), `side_effects` (STRING), `is_banned` (BOOLEAN) |
| **Product** | 具体产品，如面霜、精华液 | `id` (INT), `name` (STRING), `brand` (STRING), `price` (FLOAT), `volume` (STRING), `description` (STRING), `full_ingredients` (STRING), `purchase_link` (STRING), `image_url` (STRING) |
| **SkinType** | 适用肤质，如油性、干性 | `id` (INT), `name` (STRING), `description` (STRING) |

## 2. Relationship Types and Properties

| Relationship Type | Description | Structure | Key Properties |
| :--- | :--- | :--- | :--- |
| **HAS_EFFICACY** | 成分具有某种功效 | `(Ingredient)-[:HAS_EFFICACY]->(Efficacy)` | `score` (FLOAT) - Redundant with Ingredient.efficacy_score, but useful for filtering. |
| **CONTAINS** | 产品包含某种成分 | `(Product)-[:CONTAINS]->(Ingredient)` | `concentration_level` (STRING: 'High', 'Medium', 'Low'), `position_in_list` (INT) - For sorting based on ingredient list order. |
| **SUITABLE_FOR** | 产品适用于某种肤质 | `(Product)-[:SUITABLE_FOR]->(SkinType)` | None |
| **INTERACTS_WITH** | 成分之间的相互作用 | `(Ingredient)-[:INTERACTS_WITH]->(Ingredient)` | `type` (STRING: 'Synergy', 'Contraindication'), `description` (STRING), `recommendation` (STRING) |

## 3. Core Cypher Queries (Examples)

### 3.1. Get Ingredients by Efficacy (Sorted by Score)

```cypher
MATCH (e:Efficacy {name: $efficacyName})<-[:HAS_EFFICACY]-(i:Ingredient)
RETURN i.name, i.efficacy_score, i.mechanism
ORDER BY i.efficacy_score DESC
```

### 3.2. Get Products by Ingredient (Sorted by Concentration)

```cypher
MATCH (i:Ingredient {name: $ingredientName})<-[c:CONTAINS]-(p:Product)
RETURN p.name, p.brand, c.concentration_level
ORDER BY 
    CASE c.concentration_level 
        WHEN 'High' THEN 1 
        WHEN 'Medium' THEN 2 
        WHEN 'Low' THEN 3 
        ELSE 4 
    END
```

### 3.3. Intelligent Recommendation: Ingredient Synergy

```cypher
// Find products containing the selected ingredient AND a synergistic partner
MATCH (selected:Ingredient {name: $selectedIngredient})-[interacts:INTERACTS_WITH {type: 'Synergy'}]->(partner:Ingredient)
MATCH (p:Product)-[:CONTAINS]->(selected)
MATCH (p)-[:CONTAINS]->(partner)
RETURN p.name, p.brand, interacts.description
```

This model is robust and supports all the required features, including the "小巧思" of ingredient interaction and the core filtering logic.

