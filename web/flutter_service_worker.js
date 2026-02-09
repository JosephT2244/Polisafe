'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "a6221a4970c5d3b116387ba0840055fb",
"assets/AssetManifest.bin.json": "2973e78105f34b68a74f0ea8d7acebbe",
"assets/assets/data/medicamentos.json": "be40e347e6e7585c5e3363f982adaa25",
"assets/assets/data/nanda.pdf": "b6ca9dd4dcb55905aa08a6cb82cee717",
"assets/assets/data/nanda_2026.json": "a31f5983e4ff1b7457db692915af2781",
"assets/assets/data/nic.pdf": "c6c4911d6e0dad1ae34a2ec493025a6c",
"assets/assets/data/nic_2024.json": "8a618b9b520fd2c7f453ad69059ebd3d",
"assets/assets/data/noc.pdf": "6cc4fdc1368338a2507805a00a8cb739",
"assets/assets/data/noc_2024.json": "eb8134f7cb698d7e3fd199087bc09563",
"assets/assets/estudio/normas/1.png": "ce3506a58892ef82704dd8e075198328",
"assets/assets/estudio/normas/10.png": "14998f94f13bb2db1a8d028988a84e92",
"assets/assets/estudio/normas/11.png": "f8a5175136e9ebc0a3c1d6d54fc5f5df",
"assets/assets/estudio/normas/2.png": "6fa3ba70b0c2d426a7f73deda3f4ade4",
"assets/assets/estudio/normas/3.png": "a688ae4546dead6e94aaa18671984f7e",
"assets/assets/estudio/normas/4.png": "02404b9d96150edeb2024b02fdeae3b5",
"assets/assets/estudio/normas/5.png": "4d6c7b8de68e8c7cbefc2950fe5bff2b",
"assets/assets/estudio/normas/6.png": "f2e8109e7c5b15f7a459b05bd231f7a4",
"assets/assets/estudio/normas/7.png": "4f09b0f69b41e2b14d7acb484014f1ec",
"assets/assets/estudio/normas/8.png": "07a5df02bca6a9d0f0a006fac45e94b5",
"assets/assets/estudio/normas/9.png": "62e4cd7c2e438270e870fd6c0f275e5e",
"assets/assets/estudio/tablas/5_momentos.jpg": "6040d97bb5d13ea5d97aa4ec26082a6a",
"assets/assets/estudio/tablas/cateter.jpg": "92d3b81df2219bf72d916e9d3c6fc957",
"assets/assets/estudio/tablas/imc.jpg": "4f7f941c93692b8dc141ada07159d6af",
"assets/assets/estudio/tablas/lavado_manos.jpg": "ed2a7f1b57ed557332e3854d1fa29482",
"assets/assets/fonts/Roboto-Black.ttf": "dc44e38f98466ebcd6c013be9016fa1f",
"assets/assets/fonts/Roboto-BlackItalic.ttf": "792016eae54d22079ccf6f0760938b0a",
"assets/assets/fonts/Roboto-Bold.ttf": "dd5415b95e675853c6ccdceba7324ce7",
"assets/assets/fonts/Roboto-BoldItalic.ttf": "dc10ada6fd67b557d811d9a6d031c4de",
"assets/assets/fonts/Roboto-ExtraBold.ttf": "27fd63e58793434ce14a41e30176a4de",
"assets/assets/fonts/Roboto-ExtraBoldItalic.ttf": "80b61563f9e8f51aa379816e1c6016ef",
"assets/assets/fonts/Roboto-ExtraLight.ttf": "83e5ab4249b88f89ccf80e15a98b92f0",
"assets/assets/fonts/Roboto-ExtraLightItalic.ttf": "41c80845424f35477f8ecadfb646a67d",
"assets/assets/fonts/Roboto-Italic.ttf": "1fc3ee9d387437d060344e57a179e3dc",
"assets/assets/fonts/Roboto-Light.ttf": "25e374a16a818685911e36bee59a6ee4",
"assets/assets/fonts/Roboto-LightItalic.ttf": "00b6f1f0c053c61b8048a6dbbabecaa2",
"assets/assets/fonts/Roboto-Medium.ttf": "7d752fb726f5ece291e2e522fcecf86d",
"assets/assets/fonts/Roboto-MediumItalic.ttf": "918982b4cec9e30df58aca1e12cf6445",
"assets/assets/fonts/Roboto-Regular.ttf": "303c6d9e16168364d3bc5b7f766cfff4",
"assets/assets/fonts/Roboto-SemiBold.ttf": "dae3c6eddbf79c41f922e4809ca9d09c",
"assets/assets/fonts/Roboto-SemiBoldItalic.ttf": "2d365b1721b9ba2ff4771393a0ce2e46",
"assets/assets/fonts/Roboto-Thin.ttf": "1e6f2d32ab9876b49936181f9c0b8725",
"assets/assets/fonts/Roboto-ThinItalic.ttf": "dca165220aefe216510c6de8ae9578ff",
"assets/assets/fonts/Roboto_Condensed-Black.ttf": "b8e3ed03047190a170b330b99cb497cf",
"assets/assets/fonts/Roboto_Condensed-BlackItalic.ttf": "77716aa38d5bfb3b7a8707797e6d6d65",
"assets/assets/fonts/Roboto_Condensed-Bold.ttf": "5340a8744e1c9e34870f54f557d67b17",
"assets/assets/fonts/Roboto_Condensed-BoldItalic.ttf": "757801f54a84d6503d7bc9c56e763b75",
"assets/assets/fonts/Roboto_Condensed-ExtraBold.ttf": "e7921919c3021ad88323d48eb9294917",
"assets/assets/fonts/Roboto_Condensed-ExtraBoldItalic.ttf": "17772988c821639e9fe36044d6931208",
"assets/assets/fonts/Roboto_Condensed-ExtraLight.ttf": "cf9840bb59a0b4ef1f6441efde262ec0",
"assets/assets/fonts/Roboto_Condensed-ExtraLightItalic.ttf": "2c2c1df1100801d8a4b345d27f302980",
"assets/assets/fonts/Roboto_Condensed-Italic.ttf": "58ab0145561cf8b4782eea242cb30f5b",
"assets/assets/fonts/Roboto_Condensed-Light.ttf": "0f3de38ef164b0a65a8a0a686e08bbff",
"assets/assets/fonts/Roboto_Condensed-LightItalic.ttf": "d86a4886b06b3be02dd8c06db6c7b53d",
"assets/assets/fonts/Roboto_Condensed-Medium.ttf": "b9f98617f7bc110311f054d264f43b58",
"assets/assets/fonts/Roboto_Condensed-MediumItalic.ttf": "a887fedb5da68c3987dcaf272f685228",
"assets/assets/fonts/Roboto_Condensed-Regular.ttf": "6f1c323492d1266a46461cbc57101ad4",
"assets/assets/fonts/Roboto_Condensed-SemiBold.ttf": "e9bd6495779750596421effa84fdd4f5",
"assets/assets/fonts/Roboto_Condensed-SemiBoldItalic.ttf": "9f8f19b06543707a34bda741211fd833",
"assets/assets/fonts/Roboto_Condensed-Thin.ttf": "38ca91dbce841a3c3c20a3024a00fb93",
"assets/assets/fonts/Roboto_Condensed-ThinItalic.ttf": "66aeec1eb99fd707bbda2c23c0d88dbd",
"assets/assets/fonts/Roboto_SemiCondensed-Black.ttf": "4e83f16b2aae530ed5a9eea2c6fcba0e",
"assets/assets/fonts/Roboto_SemiCondensed-BlackItalic.ttf": "cee6c277748569381168fa4873f17951",
"assets/assets/fonts/Roboto_SemiCondensed-Bold.ttf": "6176c398124c086287f8f2704e447d89",
"assets/assets/fonts/Roboto_SemiCondensed-BoldItalic.ttf": "becb41b38acfe0bb5d4101cde6db0029",
"assets/assets/fonts/Roboto_SemiCondensed-ExtraBold.ttf": "cd66a60e5be720ca2c368e6b60348cd4",
"assets/assets/fonts/Roboto_SemiCondensed-ExtraBoldItalic.ttf": "76b49fa5b22fb20fd69561f17237e80d",
"assets/assets/fonts/Roboto_SemiCondensed-ExtraLight.ttf": "83c6c6b25720032a079c86b8244ece58",
"assets/assets/fonts/Roboto_SemiCondensed-ExtraLightItalic.ttf": "c5105f6fbcd6f492a2a6f99f92936d22",
"assets/assets/fonts/Roboto_SemiCondensed-Italic.ttf": "5cae5cd3f40c671315aea0e55f8aa469",
"assets/assets/fonts/Roboto_SemiCondensed-Light.ttf": "7f35ecca19fa7286023e6d5d29d98fee",
"assets/assets/fonts/Roboto_SemiCondensed-LightItalic.ttf": "ee86d3beb5d7e6f711f0f12f09179d48",
"assets/assets/fonts/Roboto_SemiCondensed-Medium.ttf": "ec198bede12e04919f81c2deabbfddfe",
"assets/assets/fonts/Roboto_SemiCondensed-MediumItalic.ttf": "4404af13d7c2b95be24b367e5dfaa726",
"assets/assets/fonts/Roboto_SemiCondensed-Regular.ttf": "1a494bea2b882849db6c932aee6a4302",
"assets/assets/fonts/Roboto_SemiCondensed-SemiBold.ttf": "4cd0ff27a44b68f74262ec5d63d9f304",
"assets/assets/fonts/Roboto_SemiCondensed-SemiBoldItalic.ttf": "60a345becd1b883beef9d02bbb655af6",
"assets/assets/fonts/Roboto_SemiCondensed-Thin.ttf": "4f2191b28015879bcd1836c2d03b9ac5",
"assets/assets/fonts/Roboto_SemiCondensed-ThinItalic.ttf": "b1b3f970c13ebd8f93345d10d6ac3626",
"assets/assets/images/ajustes.jpeg": "fd0058364e1a0197e8747b397385325f",
"assets/assets/images/calculadora.jpeg": "a33f90082bb36337d2564f55fa0850c3",
"assets/assets/images/cecyt16_logo.png": "82a6f097d5d9080bf4c69bce9c7c5f25",
"assets/assets/images/estudio.jpeg": "3a52f2a8df49cff7e2e5f04bd0303cee",
"assets/assets/images/ipn_logo.png": "22512ffe42d2b413ecb7b940a43f6497",
"assets/assets/images/logo.jpg": "e85fed43a47025b34862d33ae6aae944",
"assets/assets/images/medicamentos/Acenocumarol_contra1.jpg": "dba336c74e1398a3f33015b093a5b6ab",
"assets/assets/images/medicamentos/Acenocumarol_contra2.jpg": "3330da2a22eff3b73e85c8f03575d2ac",
"assets/assets/images/medicamentos/Acenocumarol_nombre1.jpg": "5e4793975ab567a2b3026558d3d24788",
"assets/assets/images/medicamentos/Acenocumarol_reacciones1.jpg": "dc09405be14c8afcc3eb331e1c792e64",
"assets/assets/images/medicamentos/albumina_contra1.jpg": "e7f27f76c250cc3a782d6c9a6a94ed3f",
"assets/assets/images/medicamentos/albumina_nombre1.jpg": "15f01045a6998b265d18a3bf40317c4a",
"assets/assets/images/medicamentos/albumina_reacciones1.jpg": "f922c43924019f4c9868a9449ab82fe1",
"assets/assets/images/medicamentos/amikacina_indicaciones.jpg": "71251e567c1445906c42dc142e0961fd",
"assets/assets/images/medicamentos/amikacina_mecanismo.jpg": "482247ed62325e15daf3578dbb39b598",
"assets/assets/images/medicamentos/amikacina_reacciones1.jpg": "79b9762d75565ef158575061583db27b",
"assets/assets/images/medicamentos/amlodipino_contra1.jpg": "90ad967fab18afd4c7a7ac329d4cd4ef",
"assets/assets/images/medicamentos/amlodipino_indicaciones.jpg": "3d96210a366856c3c73d3b3311a665fe",
"assets/assets/images/medicamentos/amlodipino_mecanismo.jpg": "398c50e30bc572c901e9ef2b09fd42ed",
"assets/assets/images/medicamentos/amlodipino_reacciones1.jpg": "7549f2b99dc593bff72878e4d6e0ef9c",
"assets/assets/images/medicamentos/amoxicilina_ac_indicaciones.jpg": "6257662989aa9e288f9f9fba4e5acdfc",
"assets/assets/images/medicamentos/amoxicilina_ac_mecanismo.jpg": "351af44b1635b99ef01b2d0bd1ed74b8",
"assets/assets/images/medicamentos/amoxicilina_ac_reacciones1.jpg": "7e2036602ccf15b4fa207f1faf2353aa",
"assets/assets/images/medicamentos/butilhioscina_contra1.jpg": "137d2461a4c5257a31ba6cefc7c22db7",
"assets/assets/images/medicamentos/butilhioscina_indicaciones.jpg": "13d3adf15d681d45f0fb24803f7299c2",
"assets/assets/images/medicamentos/butilhioscina_mecanismo.jpg": "ad3779ac8e4f05a65d6e62886921a0d4",
"assets/assets/images/medicamentos/butilhioscina_reacciones1.jpg": "2b7a8213c89128255115c800ccd5f1e6",
"assets/assets/images/medicamentos/captopril_contra1.jpg": "92952ca227e01c0bd9051159e793170f",
"assets/assets/images/medicamentos/captopril_indicaciones.jpg": "8006a2fc4e9755987645ca445e97d831",
"assets/assets/images/medicamentos/captopril_mecanismo.jpg": "000bca321e7f2ff91a6b550cb290b9dc",
"assets/assets/images/medicamentos/captopril_reacciones1.jpg": "ced0e0a9acaccc93d4e76e1e8071d01d",
"assets/assets/images/medicamentos/ceftriaxona_contra1.jpg": "3d2d18452f465d188b50fc04f01fd9bb",
"assets/assets/images/medicamentos/ceftriaxona_indicaciones.jpg": "44958570f02da2b1aa15aa667027fb80",
"assets/assets/images/medicamentos/ceftriaxona_mecanismo.jpg": "5810d897e5f6a93dfafdec8d503fde6c",
"assets/assets/images/medicamentos/ceftriaxona_reacciones1.jpg": "8930134401082ddd57cd5fe5e55e2385",
"assets/assets/images/medicamentos/celecoxib_contra1.jpg": "4b226f1975d903b5a23e7f18f51e35ac",
"assets/assets/images/medicamentos/celecoxib_indicaciones.jpg": "0fc3321d5c513c2e186656b5b5e4a950",
"assets/assets/images/medicamentos/celecoxib_mecanismo.jpg": "830c539fdc316a6da6549e4996c46d8a",
"assets/assets/images/medicamentos/celecoxib_reacciones1.jpg": "de88baa3e44740d58fccffe7adedcf3f",
"assets/assets/images/medicamentos/ciprofloxacino_indicaciones.jpg": "8a1be69409c43a089a387e98e31585db",
"assets/assets/images/medicamentos/ciprofloxacino_mecanismo.jpg": "8bafee865b31c7e3cb4fa42733dabcd8",
"assets/assets/images/medicamentos/ciprofloxacino_reacciones1.jpg": "cdac3b14f111099c8d9795e750a44762",
"assets/assets/images/medicamentos/clindamicina_indicaciones.jpg": "bbae02347344f7cd92463495606b7ec7",
"assets/assets/images/medicamentos/clindamicina_mecanismo.jpg": "a70f2c228f5dc1acb2d337bec731e1e9",
"assets/assets/images/medicamentos/clindamicina_reacciones1.jpg": "e072dd24fde4ad0989c6cdc10b88fa33",
"assets/assets/images/medicamentos/Clopidogrel_contra1.jpg": "0ae589cd1f1d92efdd8e92b822553e43",
"assets/assets/images/medicamentos/Clopidogrel_nombre1.jpg": "95170ad1b6c3aa3c52410ed10c0394bd",
"assets/assets/images/medicamentos/Clopidogrel_reacciones1.jpg": "27390bfbd376c37dfad5b93c274757f9",
"assets/assets/images/medicamentos/dapagliflozina_mecanismo.jpg": "0284fd6165d6f16edbd06b5fe62ee5e4",
"assets/assets/images/medicamentos/dapagliflozina_reacciones1.jpg": "ce54b3e1a9d9412b101f16fb73774b75",
"assets/assets/images/medicamentos/Dexametasona_contra1.jpg": "72e8b3b2258eab2233320686dbe57850",
"assets/assets/images/medicamentos/Dexametasona_nombre1.jpg": "d4a9790dbd67f799f39f464b73bc582e",
"assets/assets/images/medicamentos/Dexametasona_reacciones1.jpg": "2db1c04fe1ca13847b42cd0ea748a1f2",
"assets/assets/images/medicamentos/Dexametasona_reacciones2.jpg": "8296b00d92381f62daf59f78bf14629b",
"assets/assets/images/medicamentos/diclofenaco_indicaciones.jpg": "2b4335a330760ca874323114733445e0",
"assets/assets/images/medicamentos/diclofenaco_mecanismo.jpg": "77026a85282af410f88435aa4227d59d",
"assets/assets/images/medicamentos/diclofenaco_reacciones1.jpg": "15fc1738f91c5ffc227d0fb30c0d93bf",
"assets/assets/images/medicamentos/Enoxaparina_contra1.jpg": "d4741cec7a78d54fadf9a8b610b8f500",
"assets/assets/images/medicamentos/Enoxaparina_contra2.jpg": "57d5b864724d904f446b22ccda444899",
"assets/assets/images/medicamentos/Enoxaparina_nombre1.jpg": "ace52b2d48ecfdbce7f0cabfda2cb080",
"assets/assets/images/medicamentos/Enoxaparina_reacciones1.jpg": "a2dba7cba74bceb55731a59b4387d8a8",
"assets/assets/images/medicamentos/Famotidina_contra1.jpg": "9ecd3aa5a3eec1025e2c8f4f7353a0a7",
"assets/assets/images/medicamentos/Famotidina_nombre1.jpg": "2d238353610a5ff132a6fd1a2eae2491",
"assets/assets/images/medicamentos/Famotidina_reacciones1.jpg": "b4b3a5ccd936e4a6454107bd5d162726",
"assets/assets/images/medicamentos/fisiologica_contra1.jpg": "b33a73e50654995c88bd1bb77c8af3be",
"assets/assets/images/medicamentos/fisiologica_contra2.jpg": "ad5f013239dd7ac6988d1d61cb0e1705",
"assets/assets/images/medicamentos/fisiologica_nombre1.jpg": "9516c0daae0b1ae54363b617f7631768",
"assets/assets/images/medicamentos/fisiologica_reacciones1.jpg": "87114269644d1f69acf8184bef6fac22",
"assets/assets/images/medicamentos/glibenclamida_mecanismo.jpg": "b1e039ed2976bd25a1a7cf8984d07aed",
"assets/assets/images/medicamentos/glibenclamida_reacciones1.jpg": "d7092125e09feacd0d7fce38e496fb40",
"assets/assets/images/medicamentos/glibenclamida_reacciones2.jpg": "94e5cf6468083e5609702c21993c9b40",
"assets/assets/images/medicamentos/glucosada5_contra1.jpg": "a21b4bacd37927e0dfefc71e85dea5ad",
"assets/assets/images/medicamentos/glucosada5_contra2.jpg": "cad127342435152850fff545647a4663",
"assets/assets/images/medicamentos/glucosada5_nombre1.jpg": "b10a6f129970d5b9ad826bc0d784e74a",
"assets/assets/images/medicamentos/glucosada5_reacciones1.jpg": "fd3ca5aedd3db186ce71399addba2f78",
"assets/assets/images/medicamentos/hartmann_contra1.jpg": "3dc1a02c53eeeab18458e46bf87a4844",
"assets/assets/images/medicamentos/hartmann_nombre1.jpg": "c231e9ccb85f63048239fa795225225b",
"assets/assets/images/medicamentos/hartmann_reacciones1.jpg": "609f4ff3abd751395e78652d3ab4e248",
"assets/assets/images/medicamentos/Heparina_contra1.jpg": "76d427a35eebb922a1766d90820776d4",
"assets/assets/images/medicamentos/Heparina_nombre1.jpg": "dc8733c77a50390c2b82cd393da88f94",
"assets/assets/images/medicamentos/Heparina_reacciones1.jpg": "0b998aa07982baedb8f919a90d6e0c7f",
"assets/assets/images/medicamentos/hidralazina_contra1.jpg": "afa6c20e39d5f28e141975d7a8d1cbf6",
"assets/assets/images/medicamentos/hidralazina_indicaciones.jpg": "110a811db402d59c5619b3106ebabe69",
"assets/assets/images/medicamentos/hidralazina_mecanismo.jpg": "b07e7b81c0b54fb2608771b7b5533d1b",
"assets/assets/images/medicamentos/hidralazina_reacciones1.jpg": "b4fce07c2270c089d6410c71696c7be9",
"assets/assets/images/medicamentos/hidralazina_reacciones2.jpg": "aad450afdcd378fdffc07e91b30c5311",
"assets/assets/images/medicamentos/hidroclorotiazida_contra1.jpg": "26b94accf202f3a48c780c7d8241ed43",
"assets/assets/images/medicamentos/hidroclorotiazida_indicaciones.jpg": "2476d9398c19f48db6956ecf2ef200e6",
"assets/assets/images/medicamentos/hidroclorotiazida_mecanismo.jpg": "53deae37c1f71f39624790f814b2ac7e",
"assets/assets/images/medicamentos/hidroclorotiazida_reacciones1.jpg": "91e9963d1256d63582c6b66fb7c1ce9b",
"assets/assets/images/medicamentos/hidroclorotiazida_reacciones2.jpg": "18d2e830376b5c6ed2cdd29c9cf6553e",
"assets/assets/images/medicamentos/Hidrocortisona_contra1.jpg": "52fbb8f88b456687927c6b1350635f3b",
"assets/assets/images/medicamentos/Hidrocortisona_contra2.jpg": "a9c01805af2672d8104c0fa1db3e4959",
"assets/assets/images/medicamentos/Hidrocortisona_nombre1.jpg": "fe18d4782d3a22be930e0a2321409a09",
"assets/assets/images/medicamentos/Hidrocortisona_reacciones1.jpg": "6b845ad06b89b2eb12f604a456b8d876",
"assets/assets/images/medicamentos/Hidrocortisona_reacciones2.jpg": "872d1afdcd1a73ae09b8f80a4f770b17",
"assets/assets/images/medicamentos/insulina_contra1.jpg": "6f145e6ac8b4703830472c1136dbe5f0",
"assets/assets/images/medicamentos/insulina_glargina_mecanismo.jpg": "ec341b2f9780ce88cdd4b88c256041fc",
"assets/assets/images/medicamentos/insulina_glargina_reacciones1.jpg": "e4db6fb1b9519053a9165a4f1d716a89",
"assets/assets/images/medicamentos/insulina_mecanismo.jpg": "f30d09b18310e765cd29b9edceec592b",
"assets/assets/images/medicamentos/ketorolaco_contra1.jpg": "a962ac0efd1a776d2ca3e6e37d977b50",
"assets/assets/images/medicamentos/ketorolaco_mecanismo.jpg": "f46024f1629d79d80f2eda0b70220c64",
"assets/assets/images/medicamentos/ketorolaco_reacciones1.jpg": "1acccccdd9faad5654cbf1f85683041c",
"assets/assets/images/medicamentos/linagliptina_mecanismo.jpg": "ef162815589342c994475056baa1d400",
"assets/assets/images/medicamentos/linagliptina_reacciones1.jpg": "9e2405d5d6fbebb895db7e69de40955e",
"assets/assets/images/medicamentos/liraglutida_mecanismo.jpg": "e26971e60348ee92bdb91898a17c6e15",
"assets/assets/images/medicamentos/liraglutida_reacciones1.jpg": "12f52ae52127189f80be4c50307a1e0a",
"assets/assets/images/medicamentos/losartan_contra1.jpg": "bf921da35da52cd7646852adba99a28f",
"assets/assets/images/medicamentos/losartan_indicaciones.jpg": "1aa443c2ee23813a9ba89addbbb27281",
"assets/assets/images/medicamentos/losartan_mecanismo.jpg": "026ab499ed5bcd58dc754c696d774fa1",
"assets/assets/images/medicamentos/losartan_reacciones1.jpg": "c4a2bbd715908bbd29c940633bff150f",
"assets/assets/images/medicamentos/Magaldrato_contra1.jpg": "72225151098475384cb596fe5ac5796c",
"assets/assets/images/medicamentos/Magaldrato_contra2.jpg": "8ccfbf34ad887949d7d464797da5d5d9",
"assets/assets/images/medicamentos/Magaldrato_nombre1.jpg": "46478f54b2fa27062f537b2043d732fb",
"assets/assets/images/medicamentos/Magaldrato_reacciones1.jpg": "c41197e689facfd50833b69347ec02c6",
"assets/assets/images/medicamentos/mecanismo.jpg": "a4428428b6c07f21449680b329b489d2",
"assets/assets/images/medicamentos/metamizol_contra1.jpg": "b41e676085fa369dd4478509b142170e",
"assets/assets/images/medicamentos/metamizol_indicaciones.jpg": "02b4117f1aaa44d40794f22a4e7289f6",
"assets/assets/images/medicamentos/metamizol_mecanismo.jpg": "c4e1f4603e2dca9429f474e90e29d7b3",
"assets/assets/images/medicamentos/metamizol_reacciones1.jpg": "d1427193184bb828b8af1a9db853d361",
"assets/assets/images/medicamentos/metformina_contra1.jpg": "94c401cbc33457a1c4518835c63a92a0",
"assets/assets/images/medicamentos/metformina_indicaciones.jpg": "acc2d15bf0b7e4e0ca99daf0b466d2e6",
"assets/assets/images/medicamentos/metformina_mecanismo.jpg": "e931bd8e77db31198604286f4c2bd331",
"assets/assets/images/medicamentos/metformina_reacciones1.jpg": "247b54a72fac3e760a0838675f280b12",
"assets/assets/images/medicamentos/Metilprednisolona_contra1.jpg": "43c2242621f28b8ce274051130f2111b",
"assets/assets/images/medicamentos/Metilprednisolona_contra2.jpg": "15f08769a43af6e257b4a28870a5f275",
"assets/assets/images/medicamentos/Metilprednisolona_nombre1.jpg": "9d4338c7ab9854ae261e88ef11b5be0c",
"assets/assets/images/medicamentos/Metilprednisolona_reacciones1.jpg": "cc1b5b77434f6609e87e819cd556949c",
"assets/assets/images/medicamentos/Metilprednisolona_reacciones2.jpg": "8fed88d177a1fe8a3dded034dcf0d6e0",
"assets/assets/images/medicamentos/metoprolol_contra1.jpg": "f68e768342f986bd4b0e6ce1b66ee6d4",
"assets/assets/images/medicamentos/metoprolol_contra2.jpg": "da90f52e4d9bd92d7dd81748371d7376",
"assets/assets/images/medicamentos/metoprolol_indicaciones.jpg": "139cf9be547bc4fc878765e7fb507b02",
"assets/assets/images/medicamentos/metoprolol_mecanismo.jpg": "aa1b234171ed90d72a81391b30ec69c4",
"assets/assets/images/medicamentos/metoprolol_reacciones1.jpg": "5b44b186987f04a743a94c26bdf0d69c",
"assets/assets/images/medicamentos/metoprolol_reacciones2.jpg": "abc276797c43f6e30b82bb7664b4ab16",
"assets/assets/images/medicamentos/metronidazol_indicaciones.jpg": "8cf3f8f464df38e678ab18e0db039fe4",
"assets/assets/images/medicamentos/metronidazol_mecanismo.jpg": "1ebd16a4cea2afb400cba74da794f671",
"assets/assets/images/medicamentos/metronidazol_reacciones1.jpg": "2f5de87afec082661992557688673dc9",
"assets/assets/images/medicamentos/mixta_contra1.jpg": "0b6d2e3bde866d9122a80a2f2c2cb62d",
"assets/assets/images/medicamentos/mixta_contra2.jpg": "0d97d11e04b265873024e67f91aff888",
"assets/assets/images/medicamentos/mixta_nombre1.jpg": "a4c6c862927cfe46507574178954344f",
"assets/assets/images/medicamentos/nifedipino_contra1.jpg": "f5bcf1efb80c61bf2281f129054c4f00",
"assets/assets/images/medicamentos/nifedipino_indicaciones.jpg": "6ccb9953068929fa7bd94f06efb1fbbc",
"assets/assets/images/medicamentos/nifedipino_mecanismo.jpg": "c663c3320bb102e9833fa42fba6b57a0",
"assets/assets/images/medicamentos/nifedipino_reacciones1.jpg": "72bfae707017632e8e09fa1da420046b",
"assets/assets/images/medicamentos/nifedipino_reacciones2.jpg": "35bd19253775f14b8a3dce9c5f2d0c88",
"assets/assets/images/medicamentos/Omeprazol_contra1.jpg": "92e5cec858886ffe389bf57896421e20",
"assets/assets/images/medicamentos/Omeprazol_contra2.jpg": "78da3dee9abe2d7c74d0cd5b066cafbf",
"assets/assets/images/medicamentos/Omeprazol_nombre1.jpg": "736e463d83d8f237ced5c45959e9d443",
"assets/assets/images/medicamentos/Omeprazol_reacciones1.jpg": "0c13eed12fbc289d296a887642dfe33c",
"assets/assets/images/medicamentos/Pantoprazol_contra1.jpg": "b887c041a7b98800def38e486124570b",
"assets/assets/images/medicamentos/Pantoprazol_nombre1.jpg": "8fffe2204ef6e10f27049d31774e2c67",
"assets/assets/images/medicamentos/Pantoprazol_reacciones1.jpg": "6f06229f609a09219bc5ca58ac5db57c",
"assets/assets/images/medicamentos/Pantoprazol_reacciones2.jpg": "8b2952144035e20a13686faafc2a286a",
"assets/assets/images/medicamentos/paracetamol_contra1.jpg": "3348fed4f5729853bea2c02561099411",
"assets/assets/images/medicamentos/paracetamol_mecanismo.jpg": "5b6173af15f09ee979899de0cdc85b77",
"assets/assets/images/medicamentos/paracetamol_reacciones1.jpg": "fa97ce248a85c645cfc8ca405b0f8e6c",
"assets/assets/images/medicamentos/prazosina_contra1.jpg": "04ed79e15ec213dcef48169cffde41f6",
"assets/assets/images/medicamentos/prazosina_indicaciones.jpg": "24070cef96fadb5ac457ad55e6f07383",
"assets/assets/images/medicamentos/prazosina_mecanismo.jpg": "d11358d0d29a60165d170b8bfbc56382",
"assets/assets/images/medicamentos/prazosina_reacciones1.jpg": "943e2573a64d371bd730e44aa113ab36",
"assets/assets/images/medicamentos/prazosina_reacciones2.jpg": "8c8e6f007585c49b8e4a7b20245b9e55",
"assets/assets/images/medicamentos/Prednisona_contra1.jpg": "9f908f54ba4f71b9561a1e81525ed361",
"assets/assets/images/medicamentos/Prednisona_contra2.jpg": "166fca463832e42aff9437e039b8ca97",
"assets/assets/images/medicamentos/Prednisona_nombre1.jpg": "6e7715e7422ea98dcc1b138216b75f26",
"assets/assets/images/medicamentos/Prednisona_reacciones1.jpg": "25ac1606c730478b0323b75daef29983",
"assets/assets/images/medicamentos/Prednisona_reacciones2.jpg": "c8d2f1a1a4f44d87f4b8b509dd7a42b0",
"assets/assets/images/medicamentos/Rivaroxaban_contra1.jpg": "e03c9641659c50d774277bf8306b8ef0",
"assets/assets/images/medicamentos/Rivaroxaban_contra2.jpg": "8404e49f8cb5d10701f4fc831df34f92",
"assets/assets/images/medicamentos/Rivaroxaban_nombre1.jpg": "c4fb022ed8cc52e41c63a380472f6655",
"assets/assets/images/medicamentos/Rivaroxaban_reacciones1.jpg": "7366f27221b9a263aa88d3eec7fef6d7",
"assets/assets/images/medicamentos/Rivaroxaban_reacciones2.jpg": "84d81bc63e21b5f45038dc2f7c4c5dea",
"assets/assets/images/medicamentos/Sucralfato_contra1.jpg": "22d410bd52327e8ba434e4ed48c03d1c",
"assets/assets/images/medicamentos/Sucralfato_nombre1.jpg": "92a4d6be276a965aa8d0ec1c5186a8b1",
"assets/assets/images/medicamentos/Sucralfato_reacciones1.jpg": "6d1c584faf8697d43ac5e1b6c8422727",
"assets/assets/images/medicamentos/tazobactam_indicaciones.jpg": "3b6033f786ad448714e7f0a6ec10a498",
"assets/assets/images/medicamentos/tazobactam_mecanismo.jpg": "0a14a3d2354f81078c714fcdcaa6c40e",
"assets/assets/images/medicamentos/tazobactam_reacciones1.jpg": "f00e8f2edb54755a345a872557e7bb55",
"assets/assets/images/medicamentos/telmisartan_contra1.jpg": "52e0ef68ccd71cbffcbf0d31427a0168",
"assets/assets/images/medicamentos/telmisartan_indicaciones.jpg": "6dd91507fd4acf700088f8ad90a47c4f",
"assets/assets/images/medicamentos/telmisartan_mecanismo.jpg": "f557f642b14e86e4366e790f000eb9d7",
"assets/assets/images/medicamentos/telmisartan_reacciones1.jpg": "f8717c52e7eeb6f37b6629325b249b8e",
"assets/assets/images/medicamentos/telmisartan_reacciones2.jpg": "99ac458e2854d8f27f8f58515d6786a7",
"assets/assets/images/medicamentos/tramadol_mecanismo.jpg": "7562fb25e2fa3abb740b243b1ac7cc68",
"assets/assets/images/medicamentos/tramadol_reacciones1.jpg": "486af603230e055eb7c85093e0e13f3f",
"assets/assets/images/medicamentos/vancomicina_indicaciones.jpg": "46bbc2bed216c9a1e602c43bef28694f",
"assets/assets/images/medicamentos/vancomicina_mecanismo.jpg": "1a6a4b65864e17065fe677fd074efec6",
"assets/assets/images/medicamentos/vancomicina_reacciones1.jpg": "027c0004113a720e3240e1d97e227690",
"assets/assets/images/medicamentos.jpeg": "82f045df2c7d35bf833289cd3a70a235",
"assets/assets/images/paes.jpeg": "3fb552a7ed384b95eff2f9cdd73d6df9",
"assets/assets/images/quirurgico/allis.png": "a6e302b032e3072c07e1642006548292",
"assets/assets/images/quirurgico/amigdalectomia.png": "8bb8e17dd1a4ce4fe6b3ef5c4f12bf30",
"assets/assets/images/quirurgico/apendicectomia.png": "4c66a148d8c081a0f18b9c318671ca6c",
"assets/assets/images/quirurgico/artroplastia.png": "619a52fb76625e024f81ded7cbe29e50",
"assets/assets/images/quirurgico/artroscopia_rodilla.png": "6ade0d528c0a0e29e210e45a76b50ff5",
"assets/assets/images/quirurgico/babcock.png": "adf6dbf5d321c90ed47a557f78d5dec5",
"assets/assets/images/quirurgico/backhaus.png": "bc502e4a7693c063202b30c5e1c5e75b",
"assets/assets/images/quirurgico/backhaus2.png": "e74d746fac9b7a1ac5a9c45f3638bb34",
"assets/assets/images/quirurgico/cesarea.png": "b772453796948723c463cd27405ff8fe",
"assets/assets/images/quirurgico/cirugia_bariatrica.png": "e99f266f51fbf41a1bd7929d923b02c4",
"assets/assets/images/quirurgico/colecistectomia.png": "23d87862599608f4ed7ed6cb7a60afa8",
"assets/assets/images/quirurgico/collin_duval.png": "d0a6d22f8e49b9544a3e5a1a9213b81e",
"assets/assets/images/quirurgico/Corte_Incisi%25C3%25B3n.png": "fd40a5abb09cb0056611748065ed11b1",
"assets/assets/images/quirurgico/deaver.png": "901c50805595074355b7e2b3c06f51e4",
"assets/assets/images/quirurgico/desbridamiento_pie_diabetico.png": "1184b1f1c55224c18fb48cd934c2bfae",
"assets/assets/images/quirurgico/Disecci%25C3%25B3n.png": "4d71ebaab7bcc7d58f8b68f5ff965124",
"assets/assets/images/quirurgico/engrapadora_piel.png": "d78d36538dcc9357011ed52d19eb80f0",
"assets/assets/images/quirurgico/Exposici%25C3%25B3n.png": "fe07d0283292300fb1748fb367939e36",
"assets/assets/images/quirurgico/facoemulsificacion.png": "33501037c9ea1c9f577b5413f4eb48a8",
"assets/assets/images/quirurgico/foerster.png": "63ac87fe88a783bfa9f031509dbee42c",
"assets/assets/images/quirurgico/frazier.png": "b409a7670fd757f89f862ce7c608c4a5",
"assets/assets/images/quirurgico/gastroviejo.png": "e4dc04c44324d3a07df53ad00fdb2a58",
"assets/assets/images/quirurgico/gelpi.png": "b79f81032fd41a1a11a1ab6ea39867a0",
"assets/assets/images/quirurgico/hemorroidectomia.png": "b7314bc55101e0613709b96955605395",
"assets/assets/images/quirurgico/Hemostasia.png": "c56f34ae71220ee9438f5b8206aa6fc3",
"assets/assets/images/quirurgico/hernioplastia.png": "1b8c16c3094d93f00cdd0ad5f752bf30",
"assets/assets/images/quirurgico/histerectomia.png": "09cfef4d82a4b90568839a8822c0216f",
"assets/assets/images/quirurgico/hoja_10.png": "99bde76522b973b7b6181214422e98b6",
"assets/assets/images/quirurgico/hoja_11.png": "c56234f605ccdfecc10a04493e73c9bd",
"assets/assets/images/quirurgico/hoja_20.png": "42f767823651a6eff223d767c98fd721",
"assets/assets/images/quirurgico/kelly_curvas.png": "f230cdca84cca93e1965bb1254b28f74",
"assets/assets/images/quirurgico/kocher.png": "3228d3fa1ac3f22d7ee16e328846170c",
"assets/assets/images/quirurgico/laparotomia_exploradora.png": "880730f4a6fa3526a59cb46224f95610",
"assets/assets/images/quirurgico/lapiz_electroquirurgico.png": "e702c189df7789d25438393a6fda4e9e",
"assets/assets/images/quirurgico/lavado_quirurgico.png": "9170112a9be851406d681559172eeaf3",
"assets/assets/images/quirurgico/legrado_uterino_lui.png": "3dac69c71589fc16b3a1a05c007ba753",
"assets/assets/images/quirurgico/lister.png": "998b0c3e1675bd9be4e46cca5babe409",
"assets/assets/images/quirurgico/mango_bisturi_3.png": "11c7de1614a93fa70d16a1f11f9936b1",
"assets/assets/images/quirurgico/mango_bisturi_4.png": "a1482150a5298c56fc79b21911529401",
"assets/assets/images/quirurgico/mathieu.png": "05a0dea1c51b8adecf6bd67c1b453baf",
"assets/assets/images/quirurgico/mayo_curvas.png": "fef88ed66b1fbf6119cabfcd437fe9ef",
"assets/assets/images/quirurgico/mayo_hegar.png": "3fb883e9db07233eab29e5ed3ad76318",
"assets/assets/images/quirurgico/mayo_rectas.png": "c7b262c89e643c845f02b5eef0d1d969",
"assets/assets/images/quirurgico/metzembaum.png": "de60ad6a4b4d887ed4a12ba9ddc4e8e1",
"assets/assets/images/quirurgico/mixter.png": "5b30d582ac5f6c93afa77060e9a3bf98",
"assets/assets/images/quirurgico/mosquito_rectas.png": "15285ac6de1e4850fb31d443e3d68fc9",
"assets/assets/images/quirurgico/oclusion_tubaria_bilateral.png": "5885c94f259ae3cebec9a9b476b799c3",
"assets/assets/images/quirurgico/pinzas_diseccion.png": "7d6f1fe97917ecd9168e437d611448c6",
"assets/assets/images/quirurgico/pinzas_diseccion_debakey.png": "429b25b7206469f9f834abea0edeeb37",
"assets/assets/images/quirurgico/pinzas_diseccion_dientes.png": "2abcacd3d25c822b17ba2802c39348cb",
"assets/assets/images/quirurgico/pinzas_diseccion_rusas.png": "ec87caaadaace92871e7fd31fcdcb8ef",
"assets/assets/images/quirurgico/pinzas_diseccion_simples.png": "bd946a7e2f7d1c5ae2057d4cdc7c13f6",
"assets/assets/images/quirurgico/poole.png": "bda4896480cbb9407d5a309771e1f3c7",
"assets/assets/images/quirurgico/quistectomia_ovario.png": "f15869f7be07faa6d5b123cde02e184a",
"assets/assets/images/quirurgico/reduccion_fijacion_fracturas.png": "94485bae72abfac390947f91eb8cd748",
"assets/assets/images/quirurgico/reseccion_transuretral_prostata.png": "18a4827535615df7409c847fcd9c8575",
"assets/assets/images/quirurgico/richardson.png": "037d36ceeb6aa2fed1fc75c8c41b8750",
"assets/assets/images/quirurgico/rochester_pean.png": "56e3a13440f8494b67f5b3288bd6dac1",
"assets/assets/images/quirurgico/satinsky.png": "6286066fa8a9973ade27a57b9df83f8b",
"assets/assets/images/quirurgico/senn.png": "e73bad23b1d273fc32f2980cc8d58e07",
"assets/assets/images/quirurgico/Sutura.png": "981208747c876ccc2cb563fd2653c399",
"assets/assets/images/quirurgico/volkman.png": "462ecae933e397cd0c73e5620714519b",
"assets/assets/images/quirurgico/yankauer.png": "d82f5867f611497ae17d7ca516b534e9",
"assets/assets/images/quirurgico.jpeg": "f6b1386dd91958b23b14f0231727e9d9",
"assets/FontManifest.json": "2b52acee7bee9f34d372a965ef37754f",
"assets/fonts/MaterialIcons-Regular.otf": "61505e12c10f3e42cacd9f2ce587beb9",
"assets/NOTICES": "780ffc5c373c635d5be0853089627ce7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf": "5b04fdfec4c8c36e8ca574e40b7148bb",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/highlight.png": "2aecc31aaa39ad43c978f209962a985c",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/squiggly.png": "68960bf4e16479abb83841e54e1ae6f4",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/strikethrough.png": "72e2d23b4cdd8a9e5e9cadadf0f05a3f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/underline.png": "59886133294dd6587b0beeac054b2ca3",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/highlight.png": "2fbda47037f7c99871891ca5e57e030b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/squiggly.png": "9894ce549037670d25d2c786036b810b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/strikethrough.png": "26f6729eee851adb4b598e3470e73983",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/underline.png": "a98ff6a28215341f764f96d627a5d0f5",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "321cd563f302302053b6416d77edd0da",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a552fb9f2cc105e5cac702c9384c3384",
"/": "a552fb9f2cc105e5cac702c9384c3384",
"main.dart.js": "7138171b9ae3d793d4198c46a531fb0f",
"manifest.json": "a94a4c222d780e5b9f306337de7b3224",
"version.json": "fdd9d0fa5418e65d02001a768367c321"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
