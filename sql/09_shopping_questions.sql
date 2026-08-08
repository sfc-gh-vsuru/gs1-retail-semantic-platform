-- ============================================================
-- GS1 Retail Observability Platform — Pilot Comparison
-- File: sql/09_shopping_questions.sql
-- Purpose: 25 standardized shopping questions with gold-standard answers
--          Used to benchmark AI agent accuracy across 3 grounding paths
--
-- Categories:
--   ALLERGEN (5)  — tests structured allergen data
--   NUTRITION (5) — tests nutritional completeness + accuracy
--   DISCOVERY (5) — tests category/taxonomy quality
--   ATTRIBUTE (5) — tests attribute completeness
--   MULTI (5)     — tests combined criteria filtering
-- ============================================================

USE DATABASE GS1_DB;
USE SCHEMA DEMO;

CREATE OR REPLACE TABLE GS1_DB.DEMO.SHOPPING_QUESTIONS (
    question_id         VARCHAR(10)   NOT NULL,
    question_text       VARCHAR(500)  NOT NULL,
    question_category   VARCHAR(20)   NOT NULL,
    gold_standard_answer VARCHAR(2000) NOT NULL,
    required_attributes VARCHAR(500),
    difficulty          VARCHAR(10),
    CONSTRAINT pk_question PRIMARY KEY (question_id)
) COMMENT = 'AI Shopping Agent test suite — 25 questions with gold-standard answers for three-way grounding comparison';

INSERT INTO GS1_DB.DEMO.SHOPPING_QUESTIONS VALUES

-- ── ALLERGEN QUESTIONS (5) ───────────────────────────────────
('Q01',
 'Which products are gluten-free?',
 'ALLERGEN',
 'Full Fat Milk 1L, Greek Yoghurt 500g, Cheddar Cheese 400g, Sea Salt Crisps 150g, Dark Chocolate Bar 100g, Orange Juice 1L, Sparkling Water 500ml, Green Tea 20 Bags (8 products)',
 'contains_gluten (boolean)',
 'EASY'),

('Q02',
 'Which products contain dairy/milk?',
 'ALLERGEN',
 'Full Fat Milk 1L, Greek Yoghurt 500g, Cheddar Cheese 400g, Dark Chocolate Bar 100g (4 products)',
 'contains_dairy (boolean)',
 'EASY'),

('Q03',
 'Are there any products containing nuts?',
 'ALLERGEN',
 'Muesli Mixed Fruit 750g (1 product). Note: Oat Flakes may contain traces of nuts but does not contain nuts as an ingredient.',
 'contains_nuts (boolean), allergen_statement',
 'MEDIUM'),

('Q04',
 'Which products are safe for someone with a soy allergy?',
 'ALLERGEN',
 'All products except Dark Chocolate Bar 100g (9 products are soy-free)',
 'contains_soy (boolean)',
 'MEDIUM'),

('Q05',
 'List all products suitable for vegans (no dairy, no eggs, no fish).',
 'ALLERGEN',
 'Sea Salt Crisps 150g, Orange Juice 1L, Sparkling Water 500ml, Green Tea 20 Bags (4 products)',
 'contains_dairy, contains_eggs, contains_fish (all FALSE)',
 'HARD'),

-- ── NUTRITION QUESTIONS (5) ──────────────────────────────────
('Q06',
 'Which product has the highest protein content per 100g?',
 'NUTRITION',
 'Cheddar Cheese 400g (25.4g protein per 100g)',
 'protein_g_per100g',
 'EASY'),

('Q07',
 'Which cereals have less than 5g of sugar per 100g?',
 'NUTRITION',
 'Oat Flakes 500g (1.1g sugar per 100g). Muesli has 18.5g so it does NOT qualify.',
 'sugars_g_per100g, gpc_brick_name (category filter)',
 'MEDIUM'),

('Q08',
 'What is the calorie count per serving of the Greek Yoghurt?',
 'NUTRITION',
 '172.5 kcal per serving (115 kcal per 100g x 150g serving size)',
 'energy_kcal_per100g, serving_size_g',
 'MEDIUM'),

('Q09',
 'Which product has the most fibre per 100g?',
 'NUTRITION',
 'Oat Flakes 500g (9.8g fibre per 100g), followed by Dark Chocolate (9.0g)',
 'fibre_g_per100g',
 'EASY'),

('Q10',
 'Compare the fat content of Cheddar Cheese vs Greek Yoghurt.',
 'NUTRITION',
 'Cheddar: 34.4g fat per 100g (21.7g saturates). Greek Yoghurt: 9.2g fat per 100g (6.1g saturates). Cheddar has 3.7x more fat.',
 'fat_g_per100g, saturates_g_per100g',
 'MEDIUM'),

-- ── DISCOVERY QUESTIONS (5) ──────────────────────────────────
('Q11',
 'What dairy products are available?',
 'DISCOVERY',
 'Full Fat Milk 1L, Greek Yoghurt 500g, Cheddar Cheese 400g (3 products in Dairy Products/Alternatives family)',
 'gpc_brick_name or family_name containing Dairy',
 'EASY'),

('Q12',
 'Show me all beverages.',
 'DISCOVERY',
 'Orange Juice 1L, Sparkling Water 500ml, Green Tea 20 Bags (3 products in Beverages Non-Alcoholic family)',
 'gpc family_name or segment containing Beverages',
 'EASY'),

('Q13',
 'What snack options do you have?',
 'DISCOVERY',
 'Sea Salt Crisps 150g, Dark Chocolate Bar 100g (2 products in Snack/Cereal/Pulse Bar Products family)',
 'gpc_brick_name or family_name containing Snack',
 'EASY'),

('Q14',
 'Are there any breakfast items?',
 'DISCOVERY',
 'Oat Flakes 500g, Muesli Mixed Fruit 750g (2 products in Breakfast Cereals/Grains class)',
 'gpc_brick_name containing Breakfast or Cereals',
 'EASY'),

('Q15',
 'What products come in a bottle?',
 'DISCOVERY',
 'Full Fat Milk 1L, Sparkling Water 500ml (2 products with packaging_type = BOTTLE)',
 'packaging_type',
 'MEDIUM'),

-- ── ATTRIBUTE QUESTIONS (5) ──────────────────────────────────
('Q16',
 'What is the net weight of the Cheddar Cheese?',
 'ATTRIBUTE',
 '400 grams',
 'net_weight_value, net_weight_uom',
 'EASY'),

('Q17',
 'How many units of Oat Flakes come in a case?',
 'ATTRIBUTE',
 '12 units per case',
 'units_per_case',
 'EASY'),

('Q18',
 'What country is the Orange Juice made in?',
 'ATTRIBUTE',
 'United Kingdom (GB)',
 'country_of_origin',
 'EASY'),

('Q19',
 'What is the dimensions (width x height x depth) of the Muesli bag?',
 'ATTRIBUTE',
 '210mm x 310mm x 90mm',
 'width_mm, height_mm, depth_mm',
 'MEDIUM'),

('Q20',
 'When was the Green Tea product data last updated?',
 'ATTRIBUTE',
 '2025-06-15 (GDSN last sync date)',
 'gdsn_last_sync_date',
 'EASY'),

-- ── MULTI-CRITERIA QUESTIONS (5) ─────────────────────────────
('Q21',
 'Find a dairy-free beverage under 50 calories per 100g.',
 'MULTI',
 'Orange Juice 1L (44 kcal, dairy-free), Sparkling Water 500ml (0 kcal, dairy-free), Green Tea 20 Bags (1 kcal, dairy-free). All 3 qualify.',
 'contains_dairy (FALSE) + gpc family Beverages + energy_kcal_per100g < 50',
 'HARD'),

('Q22',
 'Which gluten-free products have more than 10g of protein per 100g?',
 'MULTI',
 'Cheddar Cheese 400g (25.4g protein, gluten-free). Only 1 product qualifies.',
 'contains_gluten (FALSE) + protein_g_per100g > 10',
 'HARD'),

('Q23',
 'Find a vegan snack with no soy.',
 'MULTI',
 'Sea Salt Crisps 150g (no dairy, no eggs, no fish, no soy). Only 1 product qualifies.',
 'contains_dairy=F, contains_eggs=F, contains_fish=F, contains_soy=F + Snack category',
 'HARD'),

('Q24',
 'What is the cheapest product that is both gluten-free and dairy-free?',
 'MULTI',
 'Cannot determine from GS1 standardized data alone (no price in GS1 data). Retailer or scraped data needed for price. From allergen perspective: Sparkling Water, Orange Juice, Green Tea, and Crisps are both gluten-free and dairy-free.',
 'contains_gluten, contains_dairy + price (not in GS1 path)',
 'HARD'),

('Q25',
 'Which high-protein products (>10g per 100g) are suitable for someone allergic to nuts and gluten?',
 'MULTI',
 'Cheddar Cheese 400g (25.4g protein, no gluten, no nuts) and Greek Yoghurt 500g (5.5g protein — does NOT qualify as >10g). Only Cheddar qualifies.',
 'protein_g_per100g > 10 + contains_nuts=F + contains_gluten=F',
 'HARD');
