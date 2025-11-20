// Neo4j Cosmetic Ingredient System Data Initialization Script - V2 (Addressing User Feedback)
// This script will clear all existing data and import the new dataset with richer, professional data.

// 1. Clear all existing data
MATCH (n) DETACH DELETE n;

// 2. Create Constraints (Ensuring data integrity)
CREATE CONSTRAINT IF NOT EXISTS FOR (e:Efficacy) REQUIRE e.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (i:Ingredient) REQUIRE i.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Product) REQUIRE p.name IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (s:SkinType) REQUIRE s.name IS UNIQUE;

// 3. Import Efficacy Categories (No change needed)
UNWIND [
    {id: 1, name: '美白淡斑', description: '抑制黑色素生成，淡化色斑，提亮肤色', icon: 'brightness'},
    {id: 2, name: '抗衰老', description: '减少皱纹，提升肌肤弹性，延缓衰老', icon: 'anti-aging'},
    {id: 3, name: '保湿补水', description: '增强肌肤保湿能力，维持水油平衡', icon: 'droplet'},
    {id: 4, name: '控油祛痘', description: '调节油脂分泌，抗炎祛痘，改善肌肤状态', icon: 'shield'},
    {id: 5, name: '舒缓修护', description: '舒缓敏感肌肤，修护肌肤屏障', icon: 'heart'},
    {id: 6, name: '去角质', description: '温和去除老化角质，促进肌肤更新', icon: 'refresh'}
] AS data
CREATE (e:Efficacy) SET e = data;

// 4. Import Skin Types (No change needed)
UNWIND [
    {id: 1, name: '干性皮肤', description: '皮脂分泌少，皮肤干燥，缺乏光泽，易产生细纹。', characteristics: '紧绷感，易脱皮，对环境变化敏感。', care_tips: '使用高保湿、高滋润度的产品，注重屏障修复。'},
    {id: 2, name: '油性皮肤', description: '皮脂分泌旺盛，皮肤油光，毛孔粗大，易长粉刺和痤疮。', characteristics: 'T区油光明显，妆容易脱，不易产生皱纹。', care_tips: '使用清爽、控油、非致粉刺性产品，注重清洁和水油平衡。'},
    {id: 3, name: '混合性皮肤', description: 'T区（额头、鼻子、下巴）油腻，U区（脸颊）干燥或正常。', characteristics: '护理难度较大，需分区护理。', care_tips: 'T区控油，U区保湿，避免使用过于滋润或过于刺激的产品。'},
    {id: 4, name: '中性皮肤', description: '水油平衡，皮肤光滑细腻，毛孔不明显，是理想的皮肤类型。', characteristics: '无明显皮肤问题，对外界刺激耐受性好。', care_tips: '维持现状，注重基础保湿和防晒。'},
    {id: 5, name: '敏感性皮肤', description: '皮肤屏障受损，易受外界刺激而产生红肿、刺痛、瘙痒等反应。', characteristics: '皮肤薄，可见红血丝，易过敏。', care_tips: '使用温和、无添加、修复屏障的产品，避免刺激性成分。'}
] AS data
CREATE (s:SkinType) SET s = data;

// 5. Import Ingredients (Master Data - ADDED clinical_data, safety_level_score, professionalized descriptions)
UNWIND [
    {id: 1, name: '烟酰胺', english_name: 'Niacinamide', efficacy_score: 8.5, evidence_level: 'A', mechanism: '阻断黑色素向角质细胞转移，抗炎，修复屏障', safety_level: '非常安全', safety_level_score: 1, clinical_data: '多项临床研究证实，2%-5%浓度的烟酰胺能有效改善皮肤屏障功能，减少皮脂分泌，并对痤疮和色素沉着有显著改善作用。', effects: ['美白淡斑', '控油祛痘', '舒缓修护']},
    {id: 2, name: '维生素C', english_name: 'L-Ascorbic Acid', efficacy_score: 9.2, evidence_level: 'A', mechanism: '强效抗氧化剂，抑制酪氨酸酶活性，促进胶原蛋白合成', safety_level: '安全', safety_level_score: 2, clinical_data: '10%以上浓度的左旋维生素C被证明能有效减少光老化引起的细纹和皱纹，并具有显著的美白效果。', effects: ['美白淡斑', '抗衰老']},
    {id: 3, name: '视黄醇', english_name: 'Retinol', efficacy_score: 9.0, evidence_level: 'A', mechanism: '促进细胞更新，加速黑色素代谢，刺激胶原蛋白生成', safety_level: '需谨慎', safety_level_score: 4, clinical_data: '长期使用（6个月以上）低浓度视黄醇（0.1%-0.3%）能显著改善皮肤纹理和弹性，减少皱纹深度。', effects: ['抗衰老', '去角质']},
    {id: 4, name: '水杨酸', english_name: 'Salicylic Acid', efficacy_score: 7.8, evidence_level: 'A', mechanism: '脂溶性有机酸，深入毛孔剥脱角质，溶解黑头', safety_level: '较安全', safety_level_score: 2, clinical_data: '2%水杨酸溶液是治疗轻度至中度痤疮的有效成分，能显著减少炎性病变和非炎性病变。', effects: ['控油祛痘', '去角质']},
    {id: 5, name: '神经酰胺', english_name: 'Ceramide', efficacy_score: 9.8, evidence_level: 'A', mechanism: '皮肤屏障重要组成部分，修复受损屏障，长效锁水', safety_level: '非常安全', safety_level_score: 1, clinical_data: '外用神经酰胺产品能有效补充皮肤中流失的脂质，改善特应性皮炎和干燥皮肤的症状。', effects: ['保湿补水', '舒缓修护']},
    {id: 6, name: '透明质酸钠', english_name: 'Sodium Hyaluronate', efficacy_score: 9.5, evidence_level: 'A', mechanism: '强效吸湿剂，能吸收并保持自身重量数百倍的水分', safety_level: '非常安全', safety_level_score: 1, clinical_data: '高分子量透明质酸钠在皮肤表面形成水膜，低分子量透明质酸能渗透至表皮层，提供深层保湿。', effects: ['保湿补水']},
    {id: 7, name: '泛醇', english_name: 'Panthenol', efficacy_score: 8.0, evidence_level: 'A', mechanism: '维生素B5前体，具有强大的保湿和抗炎特性，促进伤口愈合', safety_level: '安全', safety_level_score: 1, clinical_data: '5%浓度的泛醇乳液被证明能有效减轻皮肤刺激，加速晒伤后的皮肤修复。', effects: ['保湿补水', '舒缓修护']},
    {id: 8, name: '积雪草提取物', english_name: 'Centella Asiatica Extract', efficacy_score: 9.0, evidence_level: 'A', mechanism: '主要活性成分为积雪草苷和羟基积雪草酸，促进胶原蛋白合成，抗炎', safety_level: '非常安全', safety_level_score: 1, clinical_data: '积雪草提取物在烧伤和伤口愈合中的应用历史悠久，现代研究证实其对疤痕修复和抗炎有显著作用。', effects: ['舒缓修护', '抗衰老']},
    {id: 9, name: '马齿苋提取物', english_name: 'Portulaca Oleracea Extract', efficacy_score: 8.5, evidence_level: 'A', mechanism: '富含多糖和黄酮类化合物，具有抗炎、抗过敏、舒缓镇静作用', safety_level: '非常安全', safety_level_score: 1, clinical_data: '马齿苋提取物常用于敏感肌产品中，临床测试显示其能快速减轻皮肤红斑和瘙痒。', effects: ['舒缓修护']},
    {id: 10, name: '甘油', english_name: 'Glycerin', efficacy_score: 9.0, evidence_level: 'A', mechanism: '经典吸湿剂，通过吸收环境中的水分来滋润皮肤', safety_level: '非常安全', safety_level_score: 1, clinical_data: '甘油是皮肤科医生推荐的基础保湿剂，其保湿效果经过数十年验证，安全可靠。', effects: ['保湿补水']},
    {id: 11, name: '角鲨烷', english_name: 'Squalane', efficacy_score: 9.0, evidence_level: 'A', mechanism: '天然皮脂成分，润肤剂，防止水分经皮流失（TEWL）', safety_level: '非常安全', safety_level_score: 1, clinical_data: '角鲨烷具有良好的生物相容性，适用于所有肤质，包括敏感肌，能有效软化皮肤。', effects: ['保湿补水']},
    {id: 12, name: '抗坏血酸葡糖苷', english_name: 'Ascorbyl Glucoside', efficacy_score: 8.0, evidence_level: 'B', mechanism: '稳定的维生素C衍生物，在皮肤上缓慢释放维生素C，温和美白', safety_level: '安全', safety_level_score: 2, clinical_data: '相比左旋C，其刺激性更低，适合日常使用，但需要更高浓度才能达到相似的美白效果。', effects: ['美白淡斑']},
    {id: 13, name: '二甲氧基甲苯基-4-丙基间苯二酚', english_name: 'Dimethoxytolyl Propylresorcinol', efficacy_score: 8.6, evidence_level: 'A', mechanism: '强效酪氨酸酶抑制剂，美白效果显著', safety_level: '较安全', safety_level_score: 2, clinical_data: '该成分在亚洲人群的美白临床试验中表现出色，被认为是新一代高效美白成分。', effects: ['美白淡斑']},
    {id: 14, name: '维生素E', english_name: 'Tocopherol', efficacy_score: 7.5, evidence_level: 'A', mechanism: '脂溶性抗氧化剂，保护细胞膜免受自由基伤害', safety_level: '安全', safety_level_score: 1, clinical_data: '维生素E常与维生素C协同使用，以增强整体抗氧化能力，单独使用效果有限。', effects: ['抗衰老']},
    {id: 15, name: '阿魏酸', english_name: 'Ferulic Acid', efficacy_score: 8.0, evidence_level: 'A', mechanism: '植物来源的抗氧化剂，能稳定并增强维生素C和E的效果', safety_level: '安全', safety_level_score: 1, clinical_data: '阿魏酸与维生素C和E的复配配方（CEF）是抗氧化领域的黄金标准。', effects: ['抗衰老']},
    {id: 16, name: '二裂酵母发酵产物溶胞产物', english_name: 'Bifida Ferment Lysate', efficacy_score: 8.5, evidence_level: 'B', mechanism: '促进DNA修复，抗光老化，增强皮肤屏障功能', safety_level: '安全', safety_level_score: 1, clinical_data: '体外和体内研究表明，该成分能帮助皮肤抵抗紫外线引起的损伤，并加速皮肤自我修复。', effects: ['抗衰老', '舒缓修护']},
    {id: 17, name: '绿茶提取物', english_name: 'Green Tea Extract', efficacy_score: 8.0, evidence_level: 'A', mechanism: '富含儿茶素（EGCG），强效抗氧化，抗炎，抑制皮脂分泌', safety_level: '安全', safety_level_score: 1, clinical_data: '局部使用绿茶提取物能减轻痤疮患者的皮脂分泌，并具有抗炎作用。', effects: ['控油祛痘', '抗衰老']},
    {id: 18, name: '锌', english_name: 'Zinc PCA', efficacy_score: 7.0, evidence_level: 'B', mechanism: '控油，抗菌，对痤疮有改善作用', safety_level: '安全', safety_level_score: 1, clinical_data: '锌盐被广泛用于控油和抗炎产品中，能有效抑制5α-还原酶活性，减少油脂分泌。', effects: ['控油祛痘']},
    {id: 19, name: '玻色因', english_name: 'Pro-Xylane', efficacy_score: 9.0, evidence_level: 'A', mechanism: '促进糖胺聚糖（GAGs）生成，增加皮肤弹性和紧致度', safety_level: '安全', safety_level_score: 1, clinical_data: '玻色因是欧莱雅集团的专利成分，多项研究证实其能有效改善皮肤真皮层的结构和功能。', effects: ['抗衰老']},
    {id: 20, name: '熊果苷', english_name: 'Arbutin', efficacy_score: 8.2, evidence_level: 'B', mechanism: '通过竞争性抑制酪氨酸酶，减少黑色素生成', safety_level: '需谨慎', safety_level_score: 3, clinical_data: '熊果苷在亚洲市场是常见的美白成分，但其水解产物氢醌存在潜在刺激性，需注意浓度。', effects: ['美白淡斑']},
    {id: 21, name: '果酸', english_name: 'AHA (Glycolic Acid)', efficacy_score: 8.8, evidence_level: 'A', mechanism: '水溶性，加速角质层剥脱，促进细胞更新', safety_level: '需谨慎', safety_level_score: 4, clinical_data: '高浓度果酸（>10%）常用于化学焕肤，低浓度（5%）可用于日常护理，改善肤色不均和细纹。', effects: ['去角质', '抗衰老']}
] AS data
MERGE (i:Ingredient {name: data.name}) SET i = data;

// 6. Create HAS_EFFICACY relationships (No change needed)
MATCH (i:Ingredient)
UNWIND i.effects AS effect_name
MATCH (e:Efficacy {name: effect_name})
CREATE (i)-[:HAS_EFFICACY]->(e);

// 7. Import Products (Increased product volume and added 'url' for professionalism)
UNWIND [
    // 美白淡斑 (Niacinamide, Vit C, Arbutin)
    {id: 1, name: '修丽可CEF精华', brand: 'Skinceuticals', category: '精华', price: 1490.00, url: 'https://www.skinceuticals.com.cn/cef', description: '经典抗氧化精华，抗氧黄金配方。', ingredients: ['维生素C', '维生素E', '阿魏酸'], skintypes: ['中性皮肤', '干性皮肤', '混合性皮肤']},
    {id: 11, name: 'Olay光感小白瓶', brand: 'Olay', category: '精华', price: 280.00, url: 'https://www.olay.com.cn/white', description: '主打高浓度烟酰胺，平价美白首选。', ingredients: ['烟酰胺', '抗坏血酸葡糖苷'], skintypes: ['油性皮肤', '混合性皮肤']},
    {id: 12, name: '科颜氏美白淡斑精华', brand: 'Kiehl\'s', category: '精华', price: 520.00, url: 'https://www.kiehls.com.cn/clearly-corrective', description: '主打玻色因和活性维C，温和美白。', ingredients: ['抗坏血酸葡糖苷', '玻色因'], skintypes: ['中性皮肤', '敏感性皮肤']},
    {id: 13, name: '倩碧302美白精华', brand: 'Clinique', category: '精华', price: 520.00, url: 'https://www.clinique.com.cn/302', description: '主打302美白成分，针对顽固色斑。', ingredients: ['二甲氧基甲苯基-4-丙基间苯二酚', '抗坏血酸葡糖苷'], skintypes: ['中性皮肤', '混合性皮肤']},
    
    // 抗衰老 (Retinol, Pro-Xylane, Bifida)
    {id: 2, name: '雅诗兰黛小棕瓶', brand: 'Estee Lauder', category: '精华', price: 850.00, url: 'https://www.esteelauder.com.cn/anr', description: '主打二裂酵母，夜间修护。', ingredients: ['二裂酵母发酵产物溶胞产物', '透明质酸钠'], skintypes: ['中性皮肤', '干性皮肤', '混合性皮肤', '敏感性皮肤']},
    {id: 6, name: '露得清A醇晚霜', brand: 'Neutrogena', category: '面霜', price: 150.00, url: 'https://www.neutrogena.com/retinol', description: '含有视黄醇，入门级抗老。', ingredients: ['视黄醇', '透明质酸钠'], skintypes: ['中性皮肤', '干性皮肤']},
    {id: 10, name: '赫莲娜黑绷带面霜', brand: 'Helena Rubinstein', category: '面霜', price: 3480.00, url: 'https://www.hr.com/pro-xylane', description: '高浓度玻色因，奢华抗老。', ingredients: ['玻色因', '甘油', '透明质酸钠'], skintypes: ['干性皮肤', '中性皮肤', '敏感性皮肤']},
    {id: 14, name: '兰蔻小黑瓶', brand: 'Lancome', category: '精华', price: 760.00, url: 'https://www.lancome.com.cn/genifique', description: '促进皮肤微生态平衡，抗初老。', ingredients: ['二裂酵母发酵产物溶胞产物', '维生素C'], skintypes: ['所有肤质']},
    
    // 控油祛痘 (Salicylic Acid, Niacinamide, Zinc)
    {id: 3, name: '宝拉珍选2%水杨酸精华液', brand: 'Paula\'s Choice', category: '精华', price: 290.00, url: 'https://www.paulaschoice.com/bha', description: '含有2%水杨酸，疏通毛孔。', ingredients: ['水杨酸', '绿茶提取物'], skintypes: ['油性皮肤', '混合性皮肤']},
    {id: 5, name: 'The Ordinary 10%烟酰胺+1%锌精华', brand: 'The Ordinary', category: '精华', price: 80.00, url: 'https://theordinary.com/niacinamide', description: '高浓度烟酰胺+锌，有效控油。', ingredients: ['烟酰胺', '锌'], skintypes: ['油性皮肤', '混合性皮肤']},
    {id: 15, name: '理肤泉K+乳', brand: 'La Roche-Posay', category: '乳液', price: 220.00, url: 'https://www.laroche-posay.com/effaclar-k', description: '微剥脱性水杨酸，改善黑头。', ingredients: ['水杨酸', '烟酰胺'], skintypes: ['油性皮肤']},
    
    // 保湿补水 (Ceramide, HA, Glycerin)
    {id: 4, name: '理肤泉B5修复霜', brand: 'La Roche-Posay', category: '面霜', price: 199.00, url: 'https://www.laroche-posay.com/cicaplast', description: '含有5%泛醇，修复受损肌肤。', ingredients: ['泛醇', '积雪草提取物', '神经酰胺'], skintypes: ['敏感性皮肤', '干性皮肤', '中性皮肤']},
    {id: 7, name: '科颜氏高保湿面霜', brand: 'Kiehl\'s', category: '面霜', price: 310.00, url: 'https://www.kiehls.com.cn/ultra-facial', description: '经典保湿面霜，长效锁水。', ingredients: ['角鲨烷', '甘油'], skintypes: ['干性皮肤', '中性皮肤', '敏感性皮肤']},
    {id: 16, name: '珂润润浸保湿面霜', brand: 'Curel', category: '面霜', price: 188.00, url: 'https://www.curel.com/cream', description: '主打神经酰胺功能成分，针对干燥敏感肌。', ingredients: ['神经酰胺', '角鲨烷'], skintypes: ['敏感性皮肤', '干性皮肤']},
    
    // 舒缓修护 (Centella, Ceramide, Panthenol)
    {id: 8, name: '薇诺娜舒敏保湿特护霜', brand: 'Winona', category: '面霜', price: 268.00, url: 'https://www.winona.cn/sensitive', description: '针对敏感肌设计，马齿苋提取物舒缓。', ingredients: ['马齿苋提取物', '神经酰胺'], skintypes: ['敏感性皮肤', '干性皮肤']},
    {id: 17, name: '修丽可色修精华', brand: 'Skinceuticals', category: '精华', price: 680.00, url: 'https://www.skinceuticals.com.cn/phytocorrective', description: '积雪草和透明质酸，镇静泛红。', ingredients: ['积雪草提取物', '透明质酸钠'], skintypes: ['敏感性皮肤', '油性皮肤']},
    
    // 去角质 (AHA, BHA, Retinol)
    {id: 18, name: 'The Ordinary 7%果酸水', brand: 'The Ordinary', category: '爽肤水', price: 90.00, url: 'https://theordinary.com/glycolic-acid', description: '7%果酸，温和去角质，提亮肤色。', ingredients: ['果酸', '透明质酸钠'], skintypes: ['中性皮肤', '油性皮肤']}
] AS data
CREATE (p:Product) SET p = data;

// 8. Create CONTAINS relationships (Product -> Ingredient) - Added position property
UNWIND [
    // 修丽可CEF精华
    {product: '修丽可CEF精华', ingredient: '维生素C', concentration: 'High', position: 1},
    {product: '修丽可CEF精华', ingredient: '维生素E', concentration: 'Medium', position: 2},
    {product: '修丽可CEF精华', ingredient: '阿魏酸', concentration: 'Medium', position: 3},
    // 雅诗兰黛小棕瓶
    {product: '雅诗兰黛小棕瓶', ingredient: '二裂酵母发酵产物溶胞产物', concentration: 'High', position: 1},
    {product: '雅诗兰黛小棕瓶', ingredient: '透明质酸钠', concentration: 'Medium', position: 2},
    // 宝拉珍选2%水杨酸精华液
    {product: '宝拉珍选2%水杨酸精华液', ingredient: '水杨酸', concentration: 'High', position: 1},
    {product: '宝拉珍选2%水杨酸精华液', ingredient: '绿茶提取物', concentration: 'Low', position: 2},
    // 理肤泉B5修复霜
    {product: '理肤泉B5修复霜', ingredient: '泛醇', concentration: 'High', position: 1},
    {product: '理肤泉B5修复霜', ingredient: '积雪草提取物', concentration: 'Medium', position: 2},
    {product: '理肤泉B5修复霜', ingredient: '神经酰胺', concentration: 'Medium', position: 3},
    // The Ordinary 10%烟酰胺+1%锌精华
    {product: 'The Ordinary 10%烟酰胺+1%锌精华', ingredient: '烟酰胺', concentration: 'High', position: 1},
    {product: 'The Ordinary 10%烟酰胺+1%锌精华', ingredient: '锌', concentration: 'Medium', position: 2},
    // 露得清A醇晚霜
    {product: '露得清A醇晚霜', ingredient: '视黄醇', concentration: 'Medium', position: 1},
    {product: '露得清A醇晚霜', ingredient: '透明质酸钠', concentration: 'Medium', position: 2},
    // 科颜氏高保湿面霜
    {product: '科颜氏高保湿面霜', ingredient: '角鲨烷', concentration: 'High', position: 1},
    {product: '科颜氏高保湿面霜', ingredient: '甘油', concentration: 'High', position: 2},
    // 薇诺娜舒敏保湿特护霜
    {product: '薇诺娜舒敏保湿特护霜', ingredient: '马齿苋提取物', concentration: 'Medium', position: 1},
    {product: '薇诺娜舒敏保湿特护霜', ingredient: '神经酰胺', concentration: 'Medium', position: 2},
    // 赫莲娜黑绷带面霜
    {product: '赫莲娜黑绷带面霜', ingredient: '玻色因', concentration: 'High', position: 1},
    {product: '赫莲娜黑绷带面霜', ingredient: '甘油', concentration: 'Medium', position: 2},
    {product: '赫莲娜黑绷带面霜', ingredient: '透明质酸钠', concentration: 'Medium', position: 3},
    // Olay光感小白瓶
    {product: 'Olay光感小白瓶', ingredient: '烟酰胺', concentration: 'High', position: 1},
    {product: 'Olay光感小白瓶', ingredient: '抗坏血酸葡糖苷', concentration: 'Medium', position: 2},
    // 科颜氏美白淡斑精华
    {product: '科颜氏美白淡斑精华', ingredient: '抗坏血酸葡糖苷', concentration: 'Medium', position: 1},
    {product: '科颜氏美白淡斑精华', ingredient: '玻色因', concentration: 'Low', position: 2},
    // 倩碧302美白精华
    {product: '倩碧302美白精华', ingredient: '二甲氧基甲苯基-4-丙基间苯二酚', concentration: 'Medium', position: 1},
    {product: '倩碧302美白精华', ingredient: '抗坏血酸葡糖苷', concentration: 'Medium', position: 2},
    // 兰蔻小黑瓶
    {product: '兰蔻小黑瓶', ingredient: '二裂酵母发酵产物溶胞产物', concentration: 'High', position: 1},
    {product: '兰蔻小黑瓶', ingredient: '维生素C', concentration: 'Low', position: 2},
    // 理肤泉K+乳
    {product: '理肤泉K+乳', ingredient: '水杨酸', concentration: 'Medium', position: 1},
    {product: '理肤泉K+乳', ingredient: '烟酰胺', concentration: 'Medium', position: 2},
    // 珂润润浸保湿面霜
    {product: '珂润润浸保湿面霜', ingredient: '神经酰胺', concentration: 'High', position: 1},
    {product: '珂润润浸保湿面霜', ingredient: '角鲨烷', concentration: 'Medium', position: 2},
    // 修丽可色修精华
    {product: '修丽可色修精华', ingredient: '积雪草提取物', concentration: 'Medium', position: 1},
    {product: '修丽可色修精华', ingredient: '透明质酸钠', concentration: 'Medium', position: 2},
    // The Ordinary 7%果酸水
    {product: 'The Ordinary 7%果酸水', ingredient: '果酸', concentration: 'High', position: 1},
    {product: 'The Ordinary 7%果酸水', ingredient: '透明质酸钠', concentration: 'Medium', position: 2}
] AS data
MATCH (p:Product {name: data.product})
MATCH (i:Ingredient {name: data.ingredient})
CREATE (p)-[:CONTAINS {concentration_level: data.concentration, position: data.position}]->(i);

// 9. Create SUITABLE_FOR relationships (Product -> SkinType) - No change needed
MATCH (p:Product)
UNWIND p.skintypes AS skintype_name
MATCH (s:SkinType {name: skintype_name})
CREATE (p)-[:SUITABLE_FOR]->(s);

// 10. Import Ingredient Interactions (Professionalized descriptions and removed "小巧思")
UNWIND [
    {i1: '维生素C', i2: '维生素E', type: 'Synergy', description: '两者协同作用，抗氧化效果显著增强，是抗氧化领域的经典复配。'},
    {i1: '维生素C', i2: '阿魏酸', type: 'Synergy', description: '阿魏酸能稳定并增强维生素C和E的抗氧化活性，形成高效的抗氧化体系。'},
    {i1: '视黄醇', i2: '维生素C', type: 'Contraindication', description: '两者均具有刺激性，不建议同时使用高浓度产品，建议分早晚或隔天使用。'},
    {i1: '水杨酸', i2: '视黄醇', type: 'Contraindication', description: '两者均有去角质和刺激性，同时使用可能导致过度剥脱和皮肤敏感，需谨慎。'},
    {i1: '烟酰胺', i2: '维生素C', type: 'Neutral', description: '现代配方技术已解决两者冲突问题，可共存并协同美白，但敏感肌仍需注意耐受性。'},
    {i1: '神经酰胺', i2: '透明质酸钠', type: 'Synergy', description: '神经酰胺修复皮肤屏障，透明质酸钠提供深层保湿，两者共同作用能最大化保湿和修护效果。'},
    {i1: '果酸', i2: '视黄醇', type: 'Contraindication', description: '强效去角质和促细胞更新成分，同时使用极易引起刺激、泛红和脱皮。'},
    {i1: '烟酰胺', i2: '水杨酸', type: 'Synergy', description: '烟酰胺控油抗炎，水杨酸疏通毛孔，是治疗痤疮和控油的有效组合。'}
] AS data
MATCH (i1:Ingredient {name: data.i1})
MATCH (i2:Ingredient {name: data.i2})
CREATE (i1)-[:INTERACTS_WITH {type: data.type, description: data.description}]->(i2)
CREATE (i2)-[:INTERACTS_WITH {type: data.type, description: data.description}]->(i1);

// 11. Create a dedicated node for Evidence Level Explanation
CREATE (n:Explanation {
    type: 'EvidenceLevel',
    A: 'A级：强有力的临床证据支持，多项高质量随机对照试验（RCT）证实有效。',
    B: 'B级：中等强度的临床证据支持，有少数RCT或大量观察性研究支持。',
    C: 'C级：有限的临床证据支持，主要基于专家意见或体外/动物实验。'
});
