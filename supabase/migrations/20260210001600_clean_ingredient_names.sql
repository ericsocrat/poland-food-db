-- Migration: clean ingredient names and rebuild ingredients_raw
-- Date: 2026-02-10
-- Fix 1: Translate 433 non-English ingredient_ref names to English
-- Fix 2: Rebuild ingredients_raw from structured junction data

-- ═══════════════════════════════════════════════════════════════════════════
-- Part 1: Update ingredient_ref.name_en with English translations
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE ingredient_ref SET name_en = 'jalapeno pepper powder' WHERE ingredient_id = 15; -- google
UPDATE ingredient_ref SET name_en = 'vegetable concentrate' WHERE ingredient_id = 16; -- google
UPDATE ingredient_ref SET name_en = 'wheat roll with sesame seeds' WHERE ingredient_id = 27; -- google
UPDATE ingredient_ref SET name_en = 'beef with vegetables' WHERE ingredient_id = 37; -- google
UPDATE ingredient_ref SET name_en = 'and' WHERE ingredient_id = 52; -- google
UPDATE ingredient_ref SET name_en = 'sweet and spicy sauce' WHERE ingredient_id = 53; -- google
UPDATE ingredient_ref SET name_en = 'green jalapeño pepper' WHERE ingredient_id = 64; -- google
UPDATE ingredient_ref SET name_en = 'sugar cane vinegar' WHERE ingredient_id = 65; -- google
UPDATE ingredient_ref SET name_en = 'breaded chicken burger' WHERE ingredient_id = 68; -- google
UPDATE ingredient_ref SET name_en = 'wheat roll with sesame seeds' WHERE ingredient_id = 83; -- google
UPDATE ingredient_ref SET name_en = 'wheat leaven' WHERE ingredient_id = 84; -- google
UPDATE ingredient_ref SET name_en = 'fermented wheat flour' WHERE ingredient_id = 85; -- manual
UPDATE ingredient_ref SET name_en = 'salsa mexicana sauce' WHERE ingredient_id = 86; -- google
UPDATE ingredient_ref SET name_en = 'aromatic and flavor mixture' WHERE ingredient_id = 88; -- google
UPDATE ingredient_ref SET name_en = 'hydrolyzed vegetable proteins from soy' WHERE ingredient_id = 97; -- google
UPDATE ingredient_ref SET name_en = 'wheat roll' WHERE ingredient_id = 102; -- google
UPDATE ingredient_ref SET name_en = 'monodiglycerides of fatty acids esterified with mono and diacetyl tartaric acid' WHERE ingredient_id = 107; -- google
UPDATE ingredient_ref SET name_en = 'pulled pork in bbq sauce' WHERE ingredient_id = 108; -- google
UPDATE ingredient_ref SET name_en = 'sweet and sour bbq sauce' WHERE ingredient_id = 118; -- google
UPDATE ingredient_ref SET name_en = 'cocktail sauce' WHERE ingredient_id = 130; -- google
UPDATE ingredient_ref SET name_en = 'wheat pita cake' WHERE ingredient_id = 133; -- google
UPDATE ingredient_ref SET name_en = 'vegetable salad' WHERE ingredient_id = 135; -- google
UPDATE ingredient_ref SET name_en = 'wheat bread' WHERE ingredient_id = 146; -- google
UPDATE ingredient_ref SET name_en = 'baked chicken fillet' WHERE ingredient_id = 148; -- google
UPDATE ingredient_ref SET name_en = 'basil sauce' WHERE ingredient_id = 151; -- google
UPDATE ingredient_ref SET name_en = 'basil pesto' WHERE ingredient_id = 152; -- google
UPDATE ingredient_ref SET name_en = 'calcium disodium edta' WHERE ingredient_id = 157; -- google
UPDATE ingredient_ref SET name_en = 'dried tomatoes with oil' WHERE ingredient_id = 158; -- google
UPDATE ingredient_ref SET name_en = 'peanuts peanuts' WHERE ingredient_id = 160; -- google
UPDATE ingredient_ref SET name_en = 'and their derivatives' WHERE ingredient_id = 162; -- manual
UPDATE ingredient_ref SET name_en = 'wheat bread' WHERE ingredient_id = 173; -- google
UPDATE ingredient_ref SET name_en = 'wheat flour' WHERE ingredient_id = 174; -- manual
UPDATE ingredient_ref SET name_en = 'flour processing agent' WHERE ingredient_id = 176; -- manual
UPDATE ingredient_ref SET name_en = 'aromatal' WHERE ingredient_id = 177; -- google
UPDATE ingredient_ref SET name_en = 'mayonnaise cream' WHERE ingredient_id = 184; -- manual
UPDATE ingredient_ref SET name_en = 'wheat malt bread' WHERE ingredient_id = 189; -- google
UPDATE ingredient_ref SET name_en = 'raising agent' WHERE ingredient_id = 190; -- manual
UPDATE ingredient_ref SET name_en = 'rye flakes' WHERE ingredient_id = 192; -- manual
UPDATE ingredient_ref SET name_en = 'rye malt grits' WHERE ingredient_id = 193; -- google
UPDATE ingredient_ref SET name_en = 'spirit vinegar' WHERE ingredient_id = 196; -- google
UPDATE ingredient_ref SET name_en = 'baked bacon' WHERE ingredient_id = 197; -- google
UPDATE ingredient_ref SET name_en = 'vanillin sugar' WHERE ingredient_id = 203; -- google
UPDATE ingredient_ref SET name_en = 'carrots and peas' WHERE ingredient_id = 207; -- google
UPDATE ingredient_ref SET name_en = 'buffered vinegar' WHERE ingredient_id = 209; -- google
UPDATE ingredient_ref SET name_en = 'mashed potatoes' WHERE ingredient_id = 211; -- google
UPDATE ingredient_ref SET name_en = 'chicken roulade with butter and dill' WHERE ingredient_id = 212; -- google
UPDATE ingredient_ref SET name_en = 'breaded' WHERE ingredient_id = 213; -- google
UPDATE ingredient_ref SET name_en = 'fried' WHERE ingredient_id = 214; -- manual
UPDATE ingredient_ref SET name_en = 'hop cone extract' WHERE ingredient_id = 236; -- manual
UPDATE ingredient_ref SET name_en = 'dealcoholized red wine' WHERE ingredient_id = 246; -- google
UPDATE ingredient_ref SET name_en = 'wheat baguette' WHERE ingredient_id = 248; -- google
UPDATE ingredient_ref SET name_en = 'improving substance' WHERE ingredient_id = 249; -- google
UPDATE ingredient_ref SET name_en = 'mono and diglycerides of fatty acids esterified with mono and diacetyl tartaric acid' WHERE ingredient_id = 251; -- google
UPDATE ingredient_ref SET name_en = 'breaded chicken strips' WHERE ingredient_id = 256; -- google
UPDATE ingredient_ref SET name_en = 'fried' WHERE ingredient_id = 257; -- manual
UPDATE ingredient_ref SET name_en = 'baked' WHERE ingredient_id = 258; -- google
UPDATE ingredient_ref SET name_en = 'bbq sauce' WHERE ingredient_id = 263; -- google
UPDATE ingredient_ref SET name_en = 'spring onion' WHERE ingredient_id = 267; -- google
UPDATE ingredient_ref SET name_en = 'protein bread' WHERE ingredient_id = 268; -- google
UPDATE ingredient_ref SET name_en = 'wheat flour water' WHERE ingredient_id = 269; -- google
UPDATE ingredient_ref SET name_en = 'soy flour' WHERE ingredient_id = 274; -- google
UPDATE ingredient_ref SET name_en = 'ground roasted soybeans' WHERE ingredient_id = 275; -- google
UPDATE ingredient_ref SET name_en = 'yeast' WHERE ingredient_id = 277; -- google
UPDATE ingredient_ref SET name_en = 'malted barley flour' WHERE ingredient_id = 278; -- google
UPDATE ingredient_ref SET name_en = 'cooked turkey ham' WHERE ingredient_id = 281; -- google
UPDATE ingredient_ref SET name_en = 'gelling agent' WHERE ingredient_id = 283; -- google
UPDATE ingredient_ref SET name_en = 'processed euchema seaweed' WHERE ingredient_id = 284; -- google
UPDATE ingredient_ref SET name_en = 'stabilizers triphosphates diphosphates antioxidant' WHERE ingredient_id = 285; -- google
UPDATE ingredient_ref SET name_en = 'bacon powder' WHERE ingredient_id = 294; -- google
UPDATE ingredient_ref SET name_en = 'canola' WHERE ingredient_id = 305; -- google
UPDATE ingredient_ref SET name_en = 'sunflower' WHERE ingredient_id = 306; -- manual
UPDATE ingredient_ref SET name_en = 'flavor and aroma enhancers' WHERE ingredient_id = 309; -- google
UPDATE ingredient_ref SET name_en = 'a mixture of spices' WHERE ingredient_id = 311; -- google
UPDATE ingredient_ref SET name_en = 'lemon mixture' WHERE ingredient_id = 312; -- google
UPDATE ingredient_ref SET name_en = 'whey preparation from milk' WHERE ingredient_id = 313; -- manual
UPDATE ingredient_ref SET name_en = 'disodium ribonucleotides' WHERE ingredient_id = 314; -- google
UPDATE ingredient_ref SET name_en = 'milk powder cheese' WHERE ingredient_id = 315; -- manual
UPDATE ingredient_ref SET name_en = 'skimmed milk powder was packed in an atmosphere, protective oil deposition inside the packaging is a natural phenomenon due to product defects' WHERE ingredient_id = 316; -- google
UPDATE ingredient_ref SET name_en = 'corn oil' WHERE ingredient_id = 320; -- google
UPDATE ingredient_ref SET name_en = 'cayenne pepper' WHERE ingredient_id = 322; -- google
UPDATE ingredient_ref SET name_en = 'cumin' WHERE ingredient_id = 323; -- google
UPDATE ingredient_ref SET name_en = 'hot pepper' WHERE ingredient_id = 324; -- google
UPDATE ingredient_ref SET name_en = 'paprika extract' WHERE ingredient_id = 327; -- google
UPDATE ingredient_ref SET name_en = 'and wheat' WHERE ingredient_id = 336; -- google
UPDATE ingredient_ref SET name_en = 'annatto bixin' WHERE ingredient_id = 347; -- google
UPDATE ingredient_ref SET name_en = 'paprika-flavored sprinkles' WHERE ingredient_id = 356; -- google
UPDATE ingredient_ref SET name_en = 'grainy cottage cheese' WHERE ingredient_id = 359; -- google
UPDATE ingredient_ref SET name_en = 'salt' WHERE ingredient_id = 361; -- google
UPDATE ingredient_ref SET name_en = 'microfiltered' WHERE ingredient_id = 362; -- google
UPDATE ingredient_ref SET name_en = 'fresh' WHERE ingredient_id = 363; -- google
UPDATE ingredient_ref SET name_en = 'drinking milk pasteurized at high temperature' WHERE ingredient_id = 373; -- google
UPDATE ingredient_ref SET name_en = 'grapefruit juice' WHERE ingredient_id = 392; -- google
UPDATE ingredient_ref SET name_en = 'pitaya puree' WHERE ingredient_id = 393; -- google
UPDATE ingredient_ref SET name_en = 'products derived from cereals' WHERE ingredient_id = 394; -- manual
UPDATE ingredient_ref SET name_en = 'palm unpaved' WHERE ingredient_id = 399; -- google
UPDATE ingredient_ref SET name_en = 'from palm kernel' WHERE ingredient_id = 400; -- google
UPDATE ingredient_ref SET name_en = 'obtained from controlled oil palm plantations' WHERE ingredient_id = 406; -- google
UPDATE ingredient_ref SET name_en = 'that do not threaten tropical forests and their inhabitants' WHERE ingredient_id = 407; -- google
UPDATE ingredient_ref SET name_en = 'whey protein concentrate wpc 80' WHERE ingredient_id = 409; -- google
UPDATE ingredient_ref SET name_en = 'and derivatives' WHERE ingredient_id = 471; -- manual
UPDATE ingredient_ref SET name_en = 'wheat flour 1850' WHERE ingredient_id = 472; -- manual
UPDATE ingredient_ref SET name_en = 'natural butter flavor with other natural flavors' WHERE ingredient_id = 473; -- google
UPDATE ingredient_ref SET name_en = 'dried tomatoes 10 sunflower seeds' WHERE ingredient_id = 477; -- google
UPDATE ingredient_ref SET name_en = 'natural honey' WHERE ingredient_id = 479; -- google
UPDATE ingredient_ref SET name_en = 'multi-flower' WHERE ingredient_id = 480; -- manual
UPDATE ingredient_ref SET name_en = 'the product contains naturally occurring sugars' WHERE ingredient_id = 497; -- google
UPDATE ingredient_ref SET name_en = 'cereal granola' WHERE ingredient_id = 515; -- google
UPDATE ingredient_ref SET name_en = 'cocoa corn flakes' WHERE ingredient_id = 517; -- google
UPDATE ingredient_ref SET name_en = 'honey soufflé' WHERE ingredient_id = 518; -- google
UPDATE ingredient_ref SET name_en = 'water' WHERE ingredient_id = 530; -- manual
UPDATE ingredient_ref SET name_en = 'słody jeczmienne' WHERE ingredient_id = 531; -- google
UPDATE ingredient_ref SET name_en = 'mackerel fillet' WHERE ingredient_id = 548; -- google
UPDATE ingredient_ref SET name_en = 'tomato sauce' WHERE ingredient_id = 549; -- google
UPDATE ingredient_ref SET name_en = 'modified corn starch' WHERE ingredient_id = 551; -- manual
UPDATE ingredient_ref SET name_en = 'dried' WHERE ingredient_id = 552; -- google
UPDATE ingredient_ref SET name_en = 'spices' WHERE ingredient_id = 553; -- manual
UPDATE ingredient_ref SET name_en = 'natural paprika aroma' WHERE ingredient_id = 554; -- google
UPDATE ingredient_ref SET name_en = 'coconut extract' WHERE ingredient_id = 558; -- google
UPDATE ingredient_ref SET name_en = 'sliced ​​cherry tomatoes' WHERE ingredient_id = 562; -- google
UPDATE ingredient_ref SET name_en = 'conditioned under protective atmosphere' WHERE ingredient_id = 564; -- google
UPDATE ingredient_ref SET name_en = 'katsuwonus pelamis fish' WHERE ingredient_id = 571; -- google
UPDATE ingredient_ref SET name_en = 'wheat milling products' WHERE ingredient_id = 581; -- manual
UPDATE ingredient_ref SET name_en = 'miso soy paste powder' WHERE ingredient_id = 584; -- google
UPDATE ingredient_ref SET name_en = 'pork bone extract' WHERE ingredient_id = 585; -- google
UPDATE ingredient_ref SET name_en = 'hydrolyzed corn protein' WHERE ingredient_id = 587; -- google
UPDATE ingredient_ref SET name_en = 'caramelizer sugar' WHERE ingredient_id = 590; -- google
UPDATE ingredient_ref SET name_en = 'sachet with sauce' WHERE ingredient_id = 604; -- google
UPDATE ingredient_ref SET name_en = 'sachet with spice mixture' WHERE ingredient_id = 610; -- google
UPDATE ingredient_ref SET name_en = 'sachet with dried carrots and fried sesame seeds' WHERE ingredient_id = 612; -- google
UPDATE ingredient_ref SET name_en = 'instant noodles' WHERE ingredient_id = 614; -- manual
UPDATE ingredient_ref SET name_en = 'beams to lift' WHERE ingredient_id = 615; -- google
UPDATE ingredient_ref SET name_en = 'soy sauce 41 a soybeans' WHERE ingredient_id = 616; -- google
UPDATE ingredient_ref SET name_en = 'wheat soybeans' WHERE ingredient_id = 622; -- google
UPDATE ingredient_ref SET name_en = 'cider vinegar powder' WHERE ingredient_id = 623; -- google
UPDATE ingredient_ref SET name_en = 'apple cider vinegar maltodextrin' WHERE ingredient_id = 624; -- google
UPDATE ingredient_ref SET name_en = 'garlic powder flavor acidity corrector' WHERE ingredient_id = 626; -- google
UPDATE ingredient_ref SET name_en = 'maltodextrin' WHERE ingredient_id = 638; -- manual
UPDATE ingredient_ref SET name_en = 'flavor enhancers' WHERE ingredient_id = 640; -- google
UPDATE ingredient_ref SET name_en = 'caramelized sugar' WHERE ingredient_id = 644; -- google
UPDATE ingredient_ref SET name_en = 'flavors' WHERE ingredient_id = 645; -- google
UPDATE ingredient_ref SET name_en = 'in total product product contain traces of' WHERE ingredient_id = 659; -- google
UPDATE ingredient_ref SET name_en = 'instant wheat noodle soup powders' WHERE ingredient_id = 668; -- google
UPDATE ingredient_ref SET name_en = 'miso flavor and leavening vegetables' WHERE ingredient_id = 669; -- google
UPDATE ingredient_ref SET name_en = 'miso soy paste powder' WHERE ingredient_id = 670; -- google
UPDATE ingredient_ref SET name_en = 'milk lactose' WHERE ingredient_id = 671; -- google
UPDATE ingredient_ref SET name_en = 'powdered pork extract' WHERE ingredient_id = 672; -- google
UPDATE ingredient_ref SET name_en = 'chicken extract' WHERE ingredient_id = 674; -- manual
UPDATE ingredient_ref SET name_en = 'pepper mix of freeze-dried vegetables' WHERE ingredient_id = 676; -- google
UPDATE ingredient_ref SET name_en = 'eggs' WHERE ingredient_id = 677; -- google
UPDATE ingredient_ref SET name_en = 'tamarind paste' WHERE ingredient_id = 681; -- google
UPDATE ingredient_ref SET name_en = 'flavor additives' WHERE ingredient_id = 701; -- google
UPDATE ingredient_ref SET name_en = 'hearts' WHERE ingredient_id = 702; -- google
UPDATE ingredient_ref SET name_en = 'dried wakame algae' WHERE ingredient_id = 704; -- google
UPDATE ingredient_ref SET name_en = 'whitener' WHERE ingredient_id = 706; -- google
UPDATE ingredient_ref SET name_en = 'caseinates' WHERE ingredient_id = 708; -- google
UPDATE ingredient_ref SET name_en = 'dried mushrooms, pepper extract' WHERE ingredient_id = 712; -- google
UPDATE ingredient_ref SET name_en = 'high oleic sunflower oil' WHERE ingredient_id = 714; -- manual
UPDATE ingredient_ref SET name_en = 'flavoring mix' WHERE ingredient_id = 718; -- manual
UPDATE ingredient_ref SET name_en = 'soup' WHERE ingredient_id = 730; -- google
UPDATE ingredient_ref SET name_en = 'monosodium l glutamate' WHERE ingredient_id = 733; -- google
UPDATE ingredient_ref SET name_en = 'mixed hot spice' WHERE ingredient_id = 734; -- google
UPDATE ingredient_ref SET name_en = 'fully hydrogenated palm oil' WHERE ingredient_id = 738; -- google
UPDATE ingredient_ref SET name_en = 'anti-brittle agent' WHERE ingredient_id = 740; -- google
UPDATE ingredient_ref SET name_en = 'bran rice oil' WHERE ingredient_id = 741; -- google
UPDATE ingredient_ref SET name_en = 'flavor mixture' WHERE ingredient_id = 744; -- manual
UPDATE ingredient_ref SET name_en = 'powdered flavor additives' WHERE ingredient_id = 745; -- google
UPDATE ingredient_ref SET name_en = 'accessories in pieces' WHERE ingredient_id = 747; -- google
UPDATE ingredient_ref SET name_en = 'fish cake' WHERE ingredient_id = 748; -- google
UPDATE ingredient_ref SET name_en = 'high oleic' WHERE ingredient_id = 750; -- google
UPDATE ingredient_ref SET name_en = 'high-oleic in variable proportions' WHERE ingredient_id = 751; -- google
UPDATE ingredient_ref SET name_en = 'a mixture of dried vegetables' WHERE ingredient_id = 752; -- google
UPDATE ingredient_ref SET name_en = 'roasted' WHERE ingredient_id = 761; -- google
UPDATE ingredient_ref SET name_en = 'blanched' WHERE ingredient_id = 762; -- google
UPDATE ingredient_ref SET name_en = 'shelled hazelnuts' WHERE ingredient_id = 765; -- manual
UPDATE ingredient_ref SET name_en = 'salt compared to the average content of salted pistachios on the market' WHERE ingredient_id = 773; -- google
UPDATE ingredient_ref SET name_en = 'marinated atlantic herring fillets' WHERE ingredient_id = 775; -- google
UPDATE ingredient_ref SET name_en = 'tycki' WHERE ingredient_id = 776; -- google
UPDATE ingredient_ref SET name_en = 'strength' WHERE ingredient_id = 778; -- google
UPDATE ingredient_ref SET name_en = 'cereals containing gluten and celery' WHERE ingredient_id = 779; -- google
UPDATE ingredient_ref SET name_en = 'fried onion with mushrooms' WHERE ingredient_id = 787; -- google
UPDATE ingredient_ref SET name_en = 'pickled' WHERE ingredient_id = 794; -- google
UPDATE ingredient_ref SET name_en = 'spices' WHERE ingredient_id = 804; -- google
UPDATE ingredient_ref SET name_en = 'including chicken breast meat' WHERE ingredient_id = 808; -- google
UPDATE ingredient_ref SET name_en = 'semolina' WHERE ingredient_id = 818; -- manual
UPDATE ingredient_ref SET name_en = 'chicken raw material content' WHERE ingredient_id = 819; -- google
UPDATE ingredient_ref SET name_en = 'containing gluten' WHERE ingredient_id = 822; -- google
UPDATE ingredient_ref SET name_en = 'wheat protein hydrolyzate' WHERE ingredient_id = 824; -- google
UPDATE ingredient_ref SET name_en = 'cheese la maar' WHERE ingredient_id = 829; -- google
UPDATE ingredient_ref SET name_en = 'bacterial cultures' WHERE ingredient_id = 831; -- google
UPDATE ingredient_ref SET name_en = 'alder' WHERE ingredient_id = 835; -- google
UPDATE ingredient_ref SET name_en = 'the product may contain traces of' WHERE ingredient_id = 837; -- google
UPDATE ingredient_ref SET name_en = 'potassium chlorate' WHERE ingredient_id = 844; -- google
UPDATE ingredient_ref SET name_en = 'herbal spice extract' WHERE ingredient_id = 845; -- google
UPDATE ingredient_ref SET name_en = 'formula milk' WHERE ingredient_id = 850; -- google
UPDATE ingredient_ref SET name_en = 'demineralized whey powder' WHERE ingredient_id = 851; -- google
UPDATE ingredient_ref SET name_en = 'high oleic sunflower' WHERE ingredient_id = 852; -- manual
UPDATE ingredient_ref SET name_en = 'whole grain flours' WHERE ingredient_id = 855; -- google
UPDATE ingredient_ref SET name_en = 'pear flakes' WHERE ingredient_id = 856; -- manual
UPDATE ingredient_ref SET name_en = 'low-erucic rapeseed oil' WHERE ingredient_id = 864; -- google
UPDATE ingredient_ref SET name_en = 'parsley' WHERE ingredient_id = 865; -- google
UPDATE ingredient_ref SET name_en = 'refined rapeseed oil from the first pressing' WHERE ingredient_id = 880; -- google
UPDATE ingredient_ref SET name_en = 'cold filtered' WHERE ingredient_id = 881; -- google
UPDATE ingredient_ref SET name_en = 'bright' WHERE ingredient_id = 882; -- google
UPDATE ingredient_ref SET name_en = 'bavarian' WHERE ingredient_id = 883; -- google
UPDATE ingredient_ref SET name_en = 'burned' WHERE ingredient_id = 884; -- google
UPDATE ingredient_ref SET name_en = 'buckwheat nectar honey' WHERE ingredient_id = 893; -- google
UPDATE ingredient_ref SET name_en = 'possible presence of hazelnuts' WHERE ingredient_id = 896; -- google
UPDATE ingredient_ref SET name_en = 'cocoa decoration' WHERE ingredient_id = 908; -- google
UPDATE ingredient_ref SET name_en = 'in cocoa coating' WHERE ingredient_id = 909; -- manual
UPDATE ingredient_ref SET name_en = 'sponge cakes' WHERE ingredient_id = 919; -- google
UPDATE ingredient_ref SET name_en = 'wholegrain cereal flakes' WHERE ingredient_id = 921; -- manual
UPDATE ingredient_ref SET name_en = 'wholegrain wheat' WHERE ingredient_id = 922; -- manual
UPDATE ingredient_ref SET name_en = 'whole grain rye' WHERE ingredient_id = 923; -- google
UPDATE ingredient_ref SET name_en = 'dried' WHERE ingredient_id = 924; -- google
UPDATE ingredient_ref SET name_en = 'candied' WHERE ingredient_id = 926; -- google
UPDATE ingredient_ref SET name_en = 'extruded rice' WHERE ingredient_id = 927; -- manual
UPDATE ingredient_ref SET name_en = 'wheat' WHERE ingredient_id = 929; -- manual
UPDATE ingredient_ref SET name_en = 'pieces of milk chocolate with white chocolate' WHERE ingredient_id = 930; -- google
UPDATE ingredient_ref SET name_en = 'pieces of milk chocolate' WHERE ingredient_id = 931; -- google
UPDATE ingredient_ref SET name_en = 'full fat powder' WHERE ingredient_id = 932; -- google
UPDATE ingredient_ref SET name_en = 'dried' WHERE ingredient_id = 935; -- google
UPDATE ingredient_ref SET name_en = 'baked wheat flakes' WHERE ingredient_id = 936; -- manual
UPDATE ingredient_ref SET name_en = 'cereal granola' WHERE ingredient_id = 940; -- google
UPDATE ingredient_ref SET name_en = 'spelt flakes' WHERE ingredient_id = 941; -- manual
UPDATE ingredient_ref SET name_en = 'roasted peanuts 10 pumpkin seeds' WHERE ingredient_id = 944; -- google
UPDATE ingredient_ref SET name_en = 'extruded soy crispies' WHERE ingredient_id = 946; -- google
UPDATE ingredient_ref SET name_en = 'dried goji berries' WHERE ingredient_id = 949; -- google
UPDATE ingredient_ref SET name_en = 'whole grain barley' WHERE ingredient_id = 950; -- google
UPDATE ingredient_ref SET name_en = 'pieces' WHERE ingredient_id = 951; -- manual
UPDATE ingredient_ref SET name_en = 'roasted barley petals' WHERE ingredient_id = 955; -- google
UPDATE ingredient_ref SET name_en = 'pecan pieces' WHERE ingredient_id = 958; -- google
UPDATE ingredient_ref SET name_en = 'brazil nut pieces' WHERE ingredient_id = 959; -- manual
UPDATE ingredient_ref SET name_en = 'tamane grain of corn' WHERE ingredient_id = 961; -- google
UPDATE ingredient_ref SET name_en = 'caramel paste' WHERE ingredient_id = 962; -- google
UPDATE ingredient_ref SET name_en = 'whole oats' WHERE ingredient_id = 965; -- manual
UPDATE ingredient_ref SET name_en = 'cane sugar' WHERE ingredient_id = 967; -- google
UPDATE ingredient_ref SET name_en = 'rice syrup' WHERE ingredient_id = 968; -- google
UPDATE ingredient_ref SET name_en = 'freeze-dried oranges' WHERE ingredient_id = 969; -- google
UPDATE ingredient_ref SET name_en = 'sodium carbonates' WHERE ingredient_id = 970; -- google
UPDATE ingredient_ref SET name_en = 'water used for preparation' WHERE ingredient_id = 975; -- google
UPDATE ingredient_ref SET name_en = 'powdered eggs 3 61' WHERE ingredient_id = 978; -- google
UPDATE ingredient_ref SET name_en = 'anti-caking agent e551' WHERE ingredient_id = 980; -- google
UPDATE ingredient_ref SET name_en = 'oleoresin pepper' WHERE ingredient_id = 981; -- google
UPDATE ingredient_ref SET name_en = 'the product may contain other nuts' WHERE ingredient_id = 982; -- google
UPDATE ingredient_ref SET name_en = 'skinless atlantic herring fillets' WHERE ingredient_id = 983; -- google
UPDATE ingredient_ref SET name_en = 'clupea harengus 12 onion' WHERE ingredient_id = 984; -- google
UPDATE ingredient_ref SET name_en = 'red' WHERE ingredient_id = 993; -- google
UPDATE ingredient_ref SET name_en = 'black pepper' WHERE ingredient_id = 994; -- google
UPDATE ingredient_ref SET name_en = 'dehydrated carrots' WHERE ingredient_id = 995; -- google
UPDATE ingredient_ref SET name_en = 'method of preparation' WHERE ingredient_id = 996; -- google
UPDATE ingredient_ref SET name_en = 'flat waffle' WHERE ingredient_id = 997; -- google
UPDATE ingredient_ref SET name_en = 'flat-pod green beans' WHERE ingredient_id = 1007; -- google
UPDATE ingredient_ref SET name_en = 'spices in a sachet' WHERE ingredient_id = 1008; -- google
UPDATE ingredient_ref SET name_en = 'in variable proportions' WHERE ingredient_id = 1009; -- google
UPDATE ingredient_ref SET name_en = 'edam' WHERE ingredient_id = 1013; -- google
UPDATE ingredient_ref SET name_en = 'pesto sauce' WHERE ingredient_id = 1016; -- google
UPDATE ingredient_ref SET name_en = 'steamed pork ham' WHERE ingredient_id = 1021; -- google
UPDATE ingredient_ref SET name_en = 'and milk derivatives including lactose' WHERE ingredient_id = 1022; -- google
UPDATE ingredient_ref SET name_en = 'broccoli sauce' WHERE ingredient_id = 1027; -- google
UPDATE ingredient_ref SET name_en = 'loose breading' WHERE ingredient_id = 1028; -- google
UPDATE ingredient_ref SET name_en = 'green flat beans' WHERE ingredient_id = 1031; -- google
UPDATE ingredient_ref SET name_en = 'yellow carrot' WHERE ingredient_id = 1032; -- google
UPDATE ingredient_ref SET name_en = 'orange carrot' WHERE ingredient_id = 1033; -- google
UPDATE ingredient_ref SET name_en = 'mini corn on the cob' WHERE ingredient_id = 1034; -- google
UPDATE ingredient_ref SET name_en = 'mace powder' WHERE ingredient_id = 1035; -- google
UPDATE ingredient_ref SET name_en = 'waffle cup' WHERE ingredient_id = 1040; -- google
UPDATE ingredient_ref SET name_en = 'scorzonera' WHERE ingredient_id = 1042; -- google
UPDATE ingredient_ref SET name_en = 'pieces of roasted almonds' WHERE ingredient_id = 1043; -- google
UPDATE ingredient_ref SET name_en = 'ground extracted vanilla beans' WHERE ingredient_id = 1044; -- google
UPDATE ingredient_ref SET name_en = 'with Madagascar vanilla' WHERE ingredient_id = 1046; -- manual
UPDATE ingredient_ref SET name_en = 'cocoa mass in milk chocolate' WHERE ingredient_id = 1047; -- google
UPDATE ingredient_ref SET name_en = 'milk chocolate contains vegetable fats in addition to cocoa fat' WHERE ingredient_id = 1048; -- google
UPDATE ingredient_ref SET name_en = 'derived products' WHERE ingredient_id = 1049; -- google
UPDATE ingredient_ref SET name_en = 'sliced marinated skinless Atlantic herring fillets' WHERE ingredient_id = 1053; -- manual
UPDATE ingredient_ref SET name_en = 'herring fillets, breaded and fried' WHERE ingredient_id = 1055; -- google
UPDATE ingredient_ref SET name_en = 'are also processed at the plant' WHERE ingredient_id = 1058; -- google
UPDATE ingredient_ref SET name_en = 'from cow''s milk' WHERE ingredient_id = 1071; -- google
UPDATE ingredient_ref SET name_en = 'cooked' WHERE ingredient_id = 1072; -- google
UPDATE ingredient_ref SET name_en = 'iron fumarate' WHERE ingredient_id = 1073; -- google
UPDATE ingredient_ref SET name_en = 'contains naturally occurring sugars' WHERE ingredient_id = 1077; -- google
UPDATE ingredient_ref SET name_en = 'apples ⁾' WHERE ingredient_id = 1080; -- google
UPDATE ingredient_ref SET name_en = 'bananas ⁾' WHERE ingredient_id = 1081; -- google
UPDATE ingredient_ref SET name_en = 'thickening agent' WHERE ingredient_id = 1083; -- google
UPDATE ingredient_ref SET name_en = 'peanut cream' WHERE ingredient_id = 1087; -- google
UPDATE ingredient_ref SET name_en = 'milk chocolate with whey protein without added sugar' WHERE ingredient_id = 1090; -- google
UPDATE ingredient_ref SET name_en = 'in chocolate' WHERE ingredient_id = 1092; -- google
UPDATE ingredient_ref SET name_en = '1 concentrated raspberry juice in the filling' WHERE ingredient_id = 1094; -- google
UPDATE ingredient_ref SET name_en = 'collagen protein' WHERE ingredient_id = 1097; -- manual
UPDATE ingredient_ref SET name_en = 'soy crisps' WHERE ingredient_id = 1098; -- google
UPDATE ingredient_ref SET name_en = 'soy isolate' WHERE ingredient_id = 1099; -- google
UPDATE ingredient_ref SET name_en = 'grain part' WHERE ingredient_id = 1100; -- google
UPDATE ingredient_ref SET name_en = 'yogurt flavored topping' WHERE ingredient_id = 1101; -- google
UPDATE ingredient_ref SET name_en = 'baker''s honey' WHERE ingredient_id = 1103; -- google
UPDATE ingredient_ref SET name_en = 'whole grain ingredients' WHERE ingredient_id = 1105; -- google
UPDATE ingredient_ref SET name_en = 'roasted wheat germ' WHERE ingredient_id = 1107; -- google
UPDATE ingredient_ref SET name_en = 'buttermilk powder from milk' WHERE ingredient_id = 1108; -- google
UPDATE ingredient_ref SET name_en = 'raising agent' WHERE ingredient_id = 1109; -- google
UPDATE ingredient_ref SET name_en = '5 sodium ribonucleotides' WHERE ingredient_id = 1110; -- google
UPDATE ingredient_ref SET name_en = 'green' WHERE ingredient_id = 1111; -- google
UPDATE ingredient_ref SET name_en = 'may also contain other gluten-containing cereals' WHERE ingredient_id = 1112; -- manual
UPDATE ingredient_ref SET name_en = 'quinoa crisps' WHERE ingredient_id = 1113; -- google
UPDATE ingredient_ref SET name_en = 'and fruit seeds and their fragments' WHERE ingredient_id = 1116; -- google
UPDATE ingredient_ref SET name_en = 'cheese flavored spice mix' WHERE ingredient_id = 1119; -- google
UPDATE ingredient_ref SET name_en = 'milk proteins including lactose' WHERE ingredient_id = 1120; -- google
UPDATE ingredient_ref SET name_en = 'contains milk proteins including lactose' WHERE ingredient_id = 1121; -- manual
UPDATE ingredient_ref SET name_en = 'salad' WHERE ingredient_id = 1128; -- manual
UPDATE ingredient_ref SET name_en = 'wheat couscous' WHERE ingredient_id = 1129; -- google
UPDATE ingredient_ref SET name_en = 'wholegrain' WHERE ingredient_id = 1138; -- google
UPDATE ingredient_ref SET name_en = 'pasteurized product' WHERE ingredient_id = 1141; -- google
UPDATE ingredient_ref SET name_en = 'extract content 30' WHERE ingredient_id = 1142; -- google
UPDATE ingredient_ref SET name_en = 'refined vegetable oils' WHERE ingredient_id = 1143; -- google
UPDATE ingredient_ref SET name_en = 'cold-pressed rapeseed oil' WHERE ingredient_id = 1144; -- manual
UPDATE ingredient_ref SET name_en = 'natural cocoa' WHERE ingredient_id = 1149; -- google
UPDATE ingredient_ref SET name_en = 'plums' WHERE ingredient_id = 1151; -- google
UPDATE ingredient_ref SET name_en = 'whole grain oat flakes' WHERE ingredient_id = 1152; -- google
UPDATE ingredient_ref SET name_en = 'wheat extrudate' WHERE ingredient_id = 1153; -- google
UPDATE ingredient_ref SET name_en = 'rennet cheese' WHERE ingredient_id = 1154; -- manual
UPDATE ingredient_ref SET name_en = 'black sesame' WHERE ingredient_id = 1155; -- google
UPDATE ingredient_ref SET name_en = 'hungarian plums' WHERE ingredient_id = 1156; -- google
UPDATE ingredient_ref SET name_en = 'the product may contain seeds and their fragments' WHERE ingredient_id = 1157; -- google
UPDATE ingredient_ref SET name_en = 'concentrates' WHERE ingredient_id = 1158; -- google
UPDATE ingredient_ref SET name_en = 'schisandra fruit extract' WHERE ingredient_id = 1167; -- google
UPDATE ingredient_ref SET name_en = 'natural lime flavor with other natural flavors' WHERE ingredient_id = 1169; -- google
UPDATE ingredient_ref SET name_en = 'aromatic hops styrian goldig' WHERE ingredient_id = 1171; -- google
UPDATE ingredient_ref SET name_en = 'magnum bitter hops' WHERE ingredient_id = 1172; -- google
UPDATE ingredient_ref SET name_en = 'hercules' WHERE ingredient_id = 1173; -- google
UPDATE ingredient_ref SET name_en = 'bottom fermenting yeast' WHERE ingredient_id = 1174; -- google
UPDATE ingredient_ref SET name_en = 'pasteurized' WHERE ingredient_id = 1175; -- google
UPDATE ingredient_ref SET name_en = 'extra' WHERE ingredient_id = 1176; -- google
UPDATE ingredient_ref SET name_en = 'weight' WHERE ingredient_id = 1177; -- google
UPDATE ingredient_ref SET name_en = 'alk 5 4 vol' WHERE ingredient_id = 1178; -- google
UPDATE ingredient_ref SET name_en = 'apple juice' WHERE ingredient_id = 1181; -- google
UPDATE ingredient_ref SET name_en = 'barley malt' WHERE ingredient_id = 1182; -- google
UPDATE ingredient_ref SET name_en = 'protein grain extrudate' WHERE ingredient_id = 1183; -- google
UPDATE ingredient_ref SET name_en = 'rice-bran extrudate' WHERE ingredient_id = 1185; -- google
UPDATE ingredient_ref SET name_en = 'mineral substance' WHERE ingredient_id = 1189; -- manual
UPDATE ingredient_ref SET name_en = 'sunflower lecithin emulsifier' WHERE ingredient_id = 1190; -- google
UPDATE ingredient_ref SET name_en = 'antioxidant extract rich in tocopherol' WHERE ingredient_id = 1191; -- google
UPDATE ingredient_ref SET name_en = 'malt extract from roasted barley' WHERE ingredient_id = 1192; -- google
UPDATE ingredient_ref SET name_en = 'norbixin annatto dye' WHERE ingredient_id = 1193; -- google
UPDATE ingredient_ref SET name_en = 'may contain milk' WHERE ingredient_id = 1197; -- google
UPDATE ingredient_ref SET name_en = 'varieties of nuts' WHERE ingredient_id = 1198; -- google
UPDATE ingredient_ref SET name_en = 'cereal flakes' WHERE ingredient_id = 1199; -- manual
UPDATE ingredient_ref SET name_en = 'cane sugar molasses' WHERE ingredient_id = 1200; -- google
UPDATE ingredient_ref SET name_en = 'cinnamon' WHERE ingredient_id = 1201; -- google
UPDATE ingredient_ref SET name_en = 'SK composition' WHERE ingredient_id = 1203; -- manual
UPDATE ingredient_ref SET name_en = 'corn semolina' WHERE ingredient_id = 1204; -- manual
UPDATE ingredient_ref SET name_en = 'brown sugar' WHERE ingredient_id = 1205; -- manual
UPDATE ingredient_ref SET name_en = 'invert sugar syrup' WHERE ingredient_id = 1206; -- manual
UPDATE ingredient_ref SET name_en = 'cane sugar molasses' WHERE ingredient_id = 1207; -- manual
UPDATE ingredient_ref SET name_en = 'sodium phosphates' WHERE ingredient_id = 1208; -- manual
UPDATE ingredient_ref SET name_en = '6 refer to the content components in the entire product' WHERE ingredient_id = 1210; -- google
UPDATE ingredient_ref SET name_en = 'wholegrain' WHERE ingredient_id = 1215; -- manual
UPDATE ingredient_ref SET name_en = 'banana juice from concentrated banana juice' WHERE ingredient_id = 1217; -- google
UPDATE ingredient_ref SET name_en = 'sprinkles' WHERE ingredient_id = 1219; -- google
UPDATE ingredient_ref SET name_en = 'baking mix' WHERE ingredient_id = 1222; -- manual
UPDATE ingredient_ref SET name_en = 'mature wheat sourdough' WHERE ingredient_id = 1224; -- manual
UPDATE ingredient_ref SET name_en = 'may additionally contain' WHERE ingredient_id = 1230; -- google
UPDATE ingredient_ref SET name_en = 'the product may additionally contain eggs' WHERE ingredient_id = 1231; -- google
UPDATE ingredient_ref SET name_en = 'wheat and rye flour' WHERE ingredient_id = 1232; -- google
UPDATE ingredient_ref SET name_en = 'may contain sesame seeds' WHERE ingredient_id = 1234; -- google
UPDATE ingredient_ref SET name_en = 'dry leaven from durum wheat' WHERE ingredient_id = 1235; -- google
UPDATE ingredient_ref SET name_en = 'acerola fruit extract powder' WHERE ingredient_id = 1236; -- google
UPDATE ingredient_ref SET name_en = 'swelling flour' WHERE ingredient_id = 1238; -- google
UPDATE ingredient_ref SET name_en = 'light rye malt' WHERE ingredient_id = 1239; -- google
UPDATE ingredient_ref SET name_en = 'light wheat malt' WHERE ingredient_id = 1241; -- google
UPDATE ingredient_ref SET name_en = 'from concentrated orange juice' WHERE ingredient_id = 1243; -- google
UPDATE ingredient_ref SET name_en = 'lemon balm extract' WHERE ingredient_id = 1245; -- google
UPDATE ingredient_ref SET name_en = 'from carrots 25 vitamin c' WHERE ingredient_id = 1247; -- google
UPDATE ingredient_ref SET name_en = 'cherry' WHERE ingredient_id = 1248; -- manual
UPDATE ingredient_ref SET name_en = 'cactus fig' WHERE ingredient_id = 1251; -- google
UPDATE ingredient_ref SET name_en = 'passion flower' WHERE ingredient_id = 1252; -- google
UPDATE ingredient_ref SET name_en = 'limes' WHERE ingredient_id = 1253; -- google
UPDATE ingredient_ref SET name_en = 'cactus' WHERE ingredient_id = 1256; -- google
UPDATE ingredient_ref SET name_en = 'oat base' WHERE ingredient_id = 1257; -- google

-- Final 8 manual fixes for remaining non-ASCII
UPDATE ingredient_ref SET name_en = 'green jalapeno pepper' WHERE ingredient_id = 64;
UPDATE ingredient_ref SET name_en = 'hops and hop cone extract' WHERE ingredient_id = 532;
UPDATE ingredient_ref SET name_en = 'honey-puffed wheat' WHERE ingredient_id = 518;
UPDATE ingredient_ref SET name_en = 'barley malt' WHERE ingredient_id = 531;
UPDATE ingredient_ref SET name_en = 'sliced cherry tomatoes' WHERE ingredient_id = 562;
UPDATE ingredient_ref SET name_en = 'footnote' WHERE ingredient_id = 1082;
UPDATE ingredient_ref SET name_en = 'bananas' WHERE ingredient_id = 1081;
UPDATE ingredient_ref SET name_en = 'apples' WHERE ingredient_id = 1080;

-- ═══════════════════════════════════════════════════════════════════════════
-- Part 2: Rebuild ingredients_raw from structured product_ingredient data
-- Each product gets a clean comma-separated English ingredient list
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE ingredients i
SET ingredients_raw = sub.clean_list
FROM (
  SELECT
    pi.product_id,
    STRING_AGG(
      CASE
        WHEN pi.percent IS NOT NULL THEN ir.name_en || ' ' || pi.percent || '%'
        ELSE ir.name_en
      END,
      ', '
      ORDER BY pi.position
    ) AS clean_list
  FROM product_ingredient pi
  JOIN ingredient_ref ir ON ir.ingredient_id = pi.ingredient_id
  GROUP BY pi.product_id
) sub
WHERE sub.product_id = i.product_id
  AND sub.clean_list IS NOT NULL
  AND LENGTH(sub.clean_list) > 0;
