local K, C = unpack(select(2, ...))
if C["WorldMap"].WorldMapPlus ~= true then
	return
end

local dnTex, rdTex = "Dungeon", "Raid"
local chTex = "ChallengeMode-icon-chest"
local pATex, pHTex, pNTex = "TaxiNode_Continent_Alliance", "TaxiNode_Continent_Horde", "TaxiNode_Continent_Neutral"

K.WorldMapPlusData = {
	[1194] = {["128:110:464:33"] = "271427", ["160:120:413:476"] = "2212659", ["160:190:474:384"] = "271426", ["190:180:462:286"] = "271440", ["190:200:327:60"] = "271439", ["200:240:549:427"] = "271437", ["210:160:427:78"] = "271428", ["215:215:355:320"] = "271443", ["220:230:432:170"] = "271421", ["230:230:301:189"] = "271422", ["445:160:244:0"] = "271435, 271442",},
	[1200] = {["128:120:473:260"] = "272185", ["128:155:379:242"] = "272178", ["128:205:303:307"] = "272176", ["170:128:458:369"] = "272180", ["185:128:291:0"] = "272172", ["205:128:395:0"] = "272179", ["205:230:502:16"] = "272169", ["210:180:255:214"] = "272181", ["215:240:428:80"] = "272177", ["225:235:532:238"] = "272186", ["256:190:523:356"] = "272170", ["256:200:367:303"] = "272173", ["280:240:249:59"] = "272187, 272171", ["470:243:270:425"] = "272168, 272165",},
	[1202] = {["100:165:564:52"] = "270569", ["115:110:507:294"] = "852702", ["120:110:555:0"] = "270553", ["120:125:384:115"] = "270560", ["125:115:492:63"] = "270584", ["125:125:556:189"] = "270585", ["125:165:442:298"] = "852696", ["128:100:412:0"] = "852705", ["128:105:419:63"] = "270554", ["128:128:306:130"] = "852699", ["128:128:341:537"] = "852704", ["128:128:431:479"] = "852694", ["140:128:498:119"] = "270574", ["145:125:365:350"] = "852697", ["150:120:527:307"] = "852701", ["155:115:407:553"] = "852703", ["155:128:335:462"] = "852695", ["155:128:481:211"] = "270565", ["155:155:431:118"] = "270559", ["170:120:456:0"] = "270564", ["175:185:365:177"] = "852700", ["200:145:317:29"] = "270572", ["200:185:340:234"] = "852693", ["210:150:355:402"] = "852698", ["95:100:581:247"] = "270573",},
	[1205] = {["160:175:225:478"] = "768731", ["165:197:314:471"] = "768752", ["190:170:317:372"] = "768732", ["195:288:399:380"] = "768721, 768722", ["200:200:406:279"] = "768730", ["220:280:196:131"] = "768738, 769205", ["235:200:462:77"] = "768753", ["255:255:270:197"] = "768739", ["255:320:462:307"] = "768744, 768745", ["280:240:334:162"] = "768723, 769200", ["285:230:276:0"] = "768728, 768729", ["300:300:26:262"] = "769201, 769202, 769203, 769204", ["330:265:44:403"] = "768734, 768735, 768736, 768737", ["350:370:626:253"] = "768717, 768718, 768719, 768720", ["370:300:549:105"] = "768748, 768749, 768750, 768751",},
	[1206] = {["160:230:558:112"] = "270360", ["170:155:419:293"] = "2212546", ["175:225:370:186"] = "270352", ["180:210:472:165"] = "270350", ["190:210:138:54"] = "270347", ["190:240:87:138"] = "2212539", ["200:220:355:412"] = "270348", ["205:250:655:120"] = "270336", ["210:185:286:310"] = "270346", ["215:210:559:333"] = "270353", ["215:235:432:362"] = "270342", ["230:195:531:276"] = "270343", ["230:240:192:90"] = "270351", ["240:230:108:287"] = "270358", ["245:245:232:145"] = "270349", ["256:215:171:424"] = "270361",},
	[1207] = {["195:200:325:148"] = "270543", ["200:195:445:120"] = "270532", ["220:220:551:48"] = "270530", ["230:230:349:256"] = "2212608", ["240:255:0:148"] = "2212593", ["245:205:389:7"] = "2212606", ["245:205:498:209"] = "2212592", ["255:205:17:310"] = "270529", ["255:220:12:428"] = "270520", ["255:280:501:341"] = "270540, 270527", ["265:270:345:389"] = "270522, 270550, 270528, 270536", ["270:275:159:199"] = "270525, 270521, 2212603, 2212605", ["285:240:148:384"] = "2212599, 2212601", ["370:455:611:110"] = "270534, 270551, 270546, 270535",},
	[1209] = {["170:145:405:123"] = "391431", ["170:200:472:9"] = "391433", ["185:155:310:133"] = "391425", ["185:190:559:30"] = "391432", ["195:180:361:15"] = "391435", ["225:170:501:140"] = "391430", ["245:195:361:195"] = "391434", ["265:220:453:259"] = "391437, 391436", ["384:450:212:178"] = "391429, 391428, 391427, 391426",},
	[1210] = {["128:158:537:299"] = "273015", ["150:128:474:327"] = "273016", ["173:128:694:289"] = "273000", ["174:220:497:145"] = "273020", ["175:247:689:104"] = "272996", ["186:128:395:277"] = "2213434", ["201:288:587:139"] = "273009, 273002", ["211:189:746:125"] = "2213425", ["216:179:630:326"] = "273006", ["230:205:698:362"] = "2213418", ["237:214:757:205"] = "272999", ["243:199:363:349"] = "273003", ["245:205:227:328"] = "273001", ["256:156:239:250"] = "273017", ["256:210:335:139"] = "273019", ["315:235:463:361"] = "2213428, 2213430",},
	[1211] = {["140:125:391:446"] = "2213067", ["160:170:470:261"] = "272598", ["165:185:382:252"] = "272616", ["175:165:402:65"] = "2213080", ["180:128:323:128"] = "2213065", ["180:185:457:144"] = "2213082", ["185:165:286:37"] = "272610", ["210:160:352:168"] = "272620", ["210:215:379:447"] = "272609", ["220:160:364:359"] = "272613", ["240:180:491:417"] = "272599", ["240:240:494:262"] = "272614", ["250:215:593:74"] = "272600", ["256:160:465:0"] = "2213063", ["256:220:459:13"] = "2213084",},
	[1212] = {["160:125:300:311"] = "273113", ["160:200:566:198"] = "273121", ["170:165:600:412"] = "273107", ["170:190:451:323"] = "273102", ["180:205:520:250"] = "273094", ["205:340:590:86"] = "273122, 273103", ["220:150:381:265"] = "2212523", ["220:180:382:164"] = "273114", ["225:185:137:293"] = "273120", ["285:230:260:355"] = "2212522, 2212521", ["300:206:355:462"] = "273108, 273101", ["340:288:307:16"] = "273095, 273111, 273100, 273090", ["370:270:504:343"] = "273119, 273092, 273112, 273093",},
	[1213] = {["165:160:537:367"] = "271544", ["175:245:716:299"] = "271533", ["180:160:592:241"] = "271542", ["185:150:172:477"] = "271512", ["190:205:620:128"] = "271520", ["190:205:79:98"] = "271522", ["195:275:620:291"] = "271543, 271530", ["200:205:156:360"] = "271551", ["205:165:291:401"] = "271548", ["205:165:614:30"] = "271554", ["205:250:409:345"] = "2212700", ["210:179:309:489"] = "271514", ["210:210:271:261"] = "271536", ["220:360:7:231"] = "2212705, 2212706", ["225:215:722:166"] = "271537", ["230:150:422:36"] = "271535", ["230:235:442:199"] = "271523", ["240:195:457:109"] = "271521", ["240:200:194:9"] = "271529", ["245:170:717:471"] = "271553", ["250:175:537:463"] = "271532", ["360:270:169:83"] = "271518, 271527, 2212703, 2212704",},
	[1214] = {["125:100:109:482"] = "271904", ["165:200:175:275"] = "2212736", ["205:155:414:154"] = "271897", ["215:240:541:236"] = "2212742", ["220:310:509:0"] = "271894, 2212744", ["230:320:524:339"] = "2212737, 2212738", ["235:270:418:201"] = "271905, 2212743", ["240:275:637:294"] = "271885, 271877", ["285:155:208:368"] = "2212746, 2212747", ["288:225:2:192"] = "271876, 271881", ["305:275:198:155"] = "271883, 271892, 2212739, 2212740", ["384:365:605:75"] = "271872, 271898, 271882, 271891",},
	[1215] = {["145:220:158:149"] = "271927", ["160:145:512:232"] = "271933", ["170:170:319:302"] = "271934", ["170:310:693:303"] = "271938, 271916", ["180:170:408:260"] = "271929", ["185:195:237:185"] = "271928", ["195:185:240:387"] = "271937", ["200:165:373:365"] = "271922", ["205:195:374:164"] = "271910", ["225:200:171:306"] = "770218", ["235:285:505:333"] = "271912, 271920", ["255:205:13:245"] = "271917", ["275:275:509:19"] = "271908, 271935, 271936, 271909", ["280:205:571:239"] = "271915, 271921",},
	[1216] = {["115:115:252:249"] = "2212640", ["125:125:217:287"] = "271398", ["128:120:792:279"] = "2212654", ["128:128:573:280"] = "271389", ["128:165:502:221"] = "2212651", ["128:165:759:173"] = "2212653", ["128:180:281:167"] = "271392", ["128:190:347:163"] = "271418", ["150:128:295:385"] = "271406", ["155:128:522:322"] = "271401", ["155:170:694:273"] = "271409", ["165:165:608:291"] = "271408", ["180:128:274:296"] = "2212641", ["180:165:166:184"] = "2212644", ["200:185:314:311"] = "271400", ["200:200:386:294"] = "271417", ["240:185:155:403"] = "2212639", ["315:200:397:163"] = "271410, 271396",},
	[1220] = {["275:235:77:366"] = "254503, 254504", ["305:220:494:300"] = "2201968, 2201949", ["305:230:545:407"] = "254527, 254528", ["360:280:247:388"] = "2201972, 2201970, 2201969, 2201971", ["405:430:85:30"] = "254509, 254510, 254511, 254512", ["425:325:250:170"] = "254529, 254530, 254531, 254532", ["460:365:422:8"] = "254505, 254506, 254507, 254508",},
	[1224] = {["220:225:707:168"] = "270927", ["225:220:36:109"] = "270938", ["245:265:334:114"] = "270912, 270909", ["256:280:173:101"] = "270919, 270911", ["270:285:513:99"] = "270922, 270934, 270923, 270937", ["270:310:589:279"] = "270920, 270914, 270908, 270929", ["280:355:722:46"] = "270944, 270910, 270935, 270945", ["294:270:708:311"] = "270906, 270918, 270936, 270942", ["320:270:377:285"] = "270933, 270943, 270921, 270928", ["415:315:56:258"] = "270941, 270925, 270926, 270917",},
	[1228] = {["225:220:422:332"] = "271560", ["240:220:250:270"] = "271567", ["255:250:551:292"] = "271573", ["256:210:704:330"] = "271578", ["256:237:425:431"] = "271582", ["256:240:238:428"] = "271576", ["256:249:577:419"] = "271559", ["256:256:381:147"] = "271572", ["256:341:124:327"] = "2212708, 2212709", ["306:233:696:435"] = "271557, 271583", ["310:256:587:190"] = "271584, 271565", ["485:405:0:0"] = "2212713, 2212714, 2212715, 2212716",},
	[1233] = {["270:270:426:299"] = "271092, 271085, 271086, 271089", ["300:245:269:337"] = "271095, 271079", ["380:365:249:76"] = "271075, 271076, 271080, 271081",},
	[1235] = {["160:330:19:132"] = "271453, 271454", ["195:145:102:302"] = "2212669", ["200:175:653:120"] = "271466", ["220:220:690:353"] = "2212676", ["220:340:504:117"] = "271470, 271477", ["235:250:390:382"] = "271449", ["250:230:539:369"] = "271455", ["255:285:243:348"] = "271448, 271456", ["275:250:55:342"] = "271444, 271483", ["315:280:631:162"] = "271471, 271461, 271450, 271451", ["350:300:85:149"] = "271473, 271463, 271467, 271464", ["360:420:298:79"] = "2212678, 2212679, 2212680, 2212681", ["910:210:89:31"] = "271481, 271460, 271474, 271468",},
	[1236] = {["195:250:109:370"] = "252899", ["230:300:125:12"] = "252882, 252883", ["235:270:229:11"] = "252884, 2212852", ["255:285:215:348"] = "252886, 252887", ["256:230:217:203"] = "252898", ["290:175:339:11"] = "2212855, 2212856", ["295:358:309:310"] = "252862, 252863, 2212828, 2212829", ["315:235:542:48"] = "252880, 252881", ["320:410:352:87"] = "252894, 252895, 252896, 252897", ["345:256:482:321"] = "252866, 252867", ["370:295:546:199"] = "252890, 252891, 252892, 252893",},
	[1237] = {["235:270:399:129"] = "272334, 2212936", ["250:250:654:161"] = "272372", ["255:300:500:215"] = "2212977, 2212978", ["275:256:277:0"] = "272357, 272342", ["320:210:595:320"] = "272347, 272371", ["340:195:83:197"] = "272351, 272340", ["365:245:121:72"] = "272362, 272356", ["365:350:0:284"] = "272364, 272348, 272358, 272359", ["430:290:187:333"] = "272344, 272354, 272350, 272339", ["465:255:484:361"] = "272369, 272363", ["535:275:133:240"] = "272335, 272343, 2212940, 2212942, 2212943, 2212945",},
	[1238] = {["105:110:311:131"] = "2213161", ["105:125:387:64"] = "2213191", ["110:105:260:132"] = "2213150", ["110:110:306:301"] = "2213171", ["110:140:371:129"] = "2213145", ["115:115:156:42"] = "2213197", ["120:120:345:276"] = "2213148", ["125:120:314:493"] = "2213152", ["125:125:280:368"] = "2213159", ["125:140:196:3"] = "2213173", ["128:125:331:59"] = "2213158", ["128:125:364:231"] = "2213194", ["128:175:432:94"] = "2213162", ["140:110:269:26"] = "2213165", ["145:128:203:433"] = "2213147", ["155:150:388:0"] = "2213156", ["165:175:194:284"] = "2213146", ["165:190:229:422"] = "2213192", ["170:125:394:212"] = "2213174", ["170:90:284:0"] = "2213168", ["190:175:152:90"] = "2213188", ["200:185:235:189"] = "2213187", ["245:220:483:8"] = "2213196", ["90:115:211:359"] = "2213164", ["90:80:241:92"] = "2213143", ["95:95:299:88"] = "2213154", ["95:95:350:335"] = "2213170",},
	[1239] = {["215:365:724:120"] = "272739, 272746", ["235:205:171:145"] = "272736", ["240:245:0:262"] = "2213206", ["245:305:0:140"] = "272759, 272750", ["256:668:746:0"] = "272756, 272737, 272769", ["275:240:129:236"] = "272747, 272763", ["300:275:565:218"] = "272772, 272760, 2213215, 2213216", ["315:235:286:110"] = "272768, 272770", ["345:250:552:378"] = "272740, 272773", ["360:315:279:237"] = "272742, 272751, 272752, 272764", ["365:305:492:0"] = "2213200, 2213202, 2213203, 2213204",},
	[1240] = {["165:200:488:0"] = "273143", ["195:240:442:241"] = "273137", ["200:185:208:375"] = "273142", ["200:240:524:252"] = "273125", ["210:215:387:11"] = "273145", ["215:215:307:29"] = "2212528", ["220:200:317:331"] = "273130", ["225:205:328:148"] = "273126", ["225:210:459:105"] = "273146", ["225:256:220:102"] = "273149", ["256:175:339:418"] = "273124", ["280:190:205:467"] = "273141, 2212527", ["288:235:523:377"] = "273131, 273134", ["305:210:204:260"] = "273129, 273133",},
	[1243] = {["175:128:13:314"] = "273156", ["185:240:456:125"] = "2212531", ["190:160:628:176"] = "273181", ["195:185:247:205"] = "273155", ["200:185:349:115"] = "273173", ["200:240:237:41"] = "2212533", ["205:180:401:21"] = "273164", ["205:245:527:264"] = "273177", ["225:185:347:218"] = "273159", ["225:190:89:142"] = "273171", ["230:190:470:371"] = "273174", ["240:175:77:245"] = "273163", ["256:250:507:115"] = "2212535", ["300:240:92:82"] = "273178, 273167", ["350:360:611:230"] = "2213613, 2213614, 2212532, 2212534",},
	[1244] = {["128:100:494:548"] = "2213328", ["128:190:335:313"] = "272807", ["160:210:382:281"] = "272826", ["170:240:272:127"] = "272830", ["180:256:377:93"] = "272822", ["185:128:368:443"] = "272814", ["190:128:462:323"] = "2213323", ["200:200:561:292"] = "272815", ["225:225:491:153"] = "272811", ["256:185:436:380"] = "272810", ["315:256:101:247"] = "272806, 272812",},
	[1247] = {["150:215:318:162"] = "769206", ["170:195:468:85"] = "769211", ["175:158:329:510"] = "271044", ["175:183:229:485"] = "769210", ["180:195:365:181"] = "769207", ["190:205:324:306"] = "271045", ["195:215:510:0"] = "271043", ["200:170:305:412"] = "769209", ["230:190:375:94"] = "769208",},
	[1248] = {["128:195:131:137"] = "270380", ["146:200:856:151"] = "270387", ["155:150:260:373"] = "270398", ["165:175:189:324"] = "2212540", ["180:245:520:238"] = "270402", ["200:160:796:311"] = "270390", ["200:205:392:218"] = "2212541", ["205:185:272:251"] = "270386", ["210:185:463:141"] = "270400", ["215:305:205:38"] = "2212542, 2212543", ["220:195:104:259"] = "2212548", ["225:255:597:258"] = "270401", ["235:205:547:426"] = "270375", ["245:245:19:28"] = "270376", ["245:255:713:344"] = "270405", ["255:195:203:158"] = "270389", ["275:240:356:347"] = "2212544, 2212545", ["285:185:694:225"] = "270388, 2212547",},
	[1249] = {["190:190:31:155"] = "272968", ["205:195:259:131"] = "272962", ["210:180:205:70"] = "272963", ["210:190:357:264"] = "272954", ["210:195:391:192"] = "2213363", ["240:220:492:250"] = "2213395", ["250:240:179:200"] = "2213369", ["305:310:0:0"] = "2213348, 2213349, 2213351, 2213352", ["320:365:610:300"] = "2213371, 2213372, 2213374, 2213375",},
	[1250] = {["125:125:475:433"] = "2213093", ["125:86:663:582"] = "272650", ["145:107:572:561"] = "272628", ["150:150:389:320"] = "272646", ["190:97:718:571"] = "2213087", ["200:215:390:145"] = "272624", ["225:120:668:515"] = "2213088", ["230:355:210:234"] = "272633, 272647", ["270:205:247:0"] = "272632, 272641", ["288:355:457:282"] = "272648, 272634, 272635, 272623", ["320:275:553:197"] = "272630, 272649, 272642, 272636",},
	[1251] = {["100:100:241:6"] = "2212638", ["170:160:555:181"] = "2212635", ["190:220:447:102"] = "271111", ["195:242:293:426"] = "271122", ["200:250:554:0"] = "271114", ["205:145:431:0"] = "271126", ["205:195:690:444"] = "271105", ["205:250:311:61"] = "2212632", ["205:285:590:365"] = "2212636, 2212637", ["220:220:607:215"] = "2212634", ["230:230:167:389"] = "271125", ["245:285:212:215"] = "271106, 271129", ["275:250:387:244"] = "271127, 2212633", ["285:245:625:33"] = "271104, 271124", ["285:280:399:380"] = "271108, 271112, 271113, 271109",},
	[1252] = {["110:110:493:70"] = "2212732", ["110:170:478:386"] = "2212728", ["115:115:486:329"] = "2212726", ["120:195:623:167"] = "2212729", ["140:165:690:141"] = "271696", ["145:320:404:256"] = "271700, 271682", ["150:125:454:0"] = "2212721", ["155:160:689:233"] = "271675", ["180:180:208:234"] = "2212734", ["190:155:305:0"] = "2212733", ["190:250:540:320"] = "271699", ["215:293:192:375"] = "2212730, 2212731", ["225:180:751:198"] = "271680", ["230:195:454:201"] = "271687", ["240:220:618:298"] = "2212735", ["285:245:319:75"] = "271705, 271686",},
	[1253] = {["200:195:660:21"] = "271494", ["230:205:534:224"] = "271500", ["250:315:422:0"] = "271507, 271504", ["255:250:257:313"] = "2212689", ["280:270:230:0"] = "2212685, 2212686, 2212687, 2212688", ["285:240:367:381"] = "271503, 271509", ["400:255:239:189"] = "2212683, 2212684",},
	[1254] = {["110:140:611:147"] = "2213315", ["110:180:473:234"] = "272800", ["120:135:533:104"] = "2213275", ["150:160:291:434"] = "2213311", ["155:150:561:256"] = "272789", ["155:150:592:75"] = "2213281", ["160:150:395:346"] = "272798", ["160:190:629:220"] = "2213273", ["165:180:509:168"] = "2213313", ["175:165:421:91"] = "272774", ["180:200:252:199"] = "272792", ["185:250:203:286"] = "272781", ["195:175:299:100"] = "272776", ["195:210:323:359"] = "272784", ["205:145:325:289"] = "272782", ["205:157:445:511"] = "272801", ["210:175:254:0"] = "272788", ["215:175:499:293"] = "272795", ["215:180:363:194"] = "272799", ["220:210:449:372"] = "272805",},
	[1259] = {["120:155:818:107"] = "270434", ["145:215:422:95"] = "2212573", ["160:210:404:194"] = "270412", ["190:200:681:153"] = "2212567", ["200:150:77:331"] = "2212555", ["215:175:84:229"] = "2212574", ["220:255:191:369"] = "2212554", ["225:180:35:422"] = "2212564", ["235:140:478:44"] = "2212560", ["235:270:250:106"] = "2212571, 2212572", ["240:125:552:499"] = "270410", ["240:155:499:119"] = "2212568", ["245:185:644:40"] = "270432", ["265:280:238:221"] = "270414, 2212561, 2212562, 2212563", ["270:300:479:201"] = "2212550, 2212551, 2212552, 2212553", ["315:200:296:429"] = "270409, 2212559", ["370:220:389:353"] = "2212565, 2212566", ["395:128:396:540"] = "2212569, 2212570", ["570:170:366:0"] = "2212556, 2212557, 2212558",},
	[1260] = {["145:159:496:509"] = "271657", ["160:145:548:90"] = "271653", ["165:155:332:465"] = "271663", ["175:135:408:533"] = "271658", ["185:160:405:429"] = "271659", ["195:170:330:29"] = "271652", ["215:215:420:54"] = "271673", ["235:145:292:263"] = "271666", ["235:155:297:381"] = "271664", ["235:200:307:123"] = "271665", ["240:145:483:0"] = "271660", ["245:128:271:331"] = "271669",},
	[1261] = {["285:285:582:67"] = "273051, 2213483, 2213484, 2213486", ["295:270:367:178"] = "273042, 273065, 273050, 273036", ["310:355:560:240"] = "273072, 273039, 273037, 273063", ["315:345:121:151"] = "273043, 273075, 273069, 273061", ["345:285:158:368"] = "273046, 273053, 273071, 273047", ["345:285:367:380"] = "273059, 273066, 273073, 273054", ["570:265:160:6"] = "273052, 273062, 273057, 273058, 2213490, 2213491",},
	[1263] = {["555:510:244:89"] = "252844, 252845, 252846, 252847, 2212870, 2212872",},
	[1264] = {["288:256:116:413"] = "272564, 272553", ["320:256:344:197"] = "272573, 272545", ["320:289:104:24"] = "272581, 272562, 2213052, 2213053", ["384:384:500:65"] = "272580, 272544, 2213048, 2213049", ["384:512:97:144"] = "272559, 272543, 272574, 272575", ["512:320:265:12"] = "272565, 272566, 272577, 272546", ["512:384:245:285"] = "272567, 272547, 272555, 272548",},
	[1266] = {["125:165:611:242"] = "273206", ["145:125:617:158"] = "273200", ["165:140:593:340"] = "273199", ["165:200:509:107"] = "273191", ["175:185:555:27"] = "273203", ["185:160:392:137"] = "273207", ["185:180:493:258"] = "273185", ["200:160:523:376"] = "273198", ["215:185:401:198"] = "273192", ["230:120:229:243"] = "273187", ["240:140:222:172"] = "273202", ["250:180:368:7"] = "273184", ["255:205:447:441"] = "2213650",},
	[1273] = {["235:290:399:375"] = "270314, 270315", ["270:240:348:13"] = "270331, 270325", ["300:300:335:172"] = "270320, 270321, 270322, 270323",},
}

K.WorldMapPlusPinData = {
	-- Eastern Kingdoms
	-- Dun Morogh
	[27] = {{31.1, 37.9, "Gnomeregan", "Dungeon", dnTex},},
	-- Badlands
	[15] = {{41.7, 11.6, "Uldaman", "Dungeon", dnTex},},
	-- Uldaman
	[16] = {{36.7, 29.4, "Uldaman", "Dungeon", dnTex},},
	-- Tirisfal Glades
	[18] = {{82.5, 33.3, "Scarlet Halls" .. ", " .. "Scarlet Monastery", "Dungeon", dnTex},},
	-- Scarlet Monastery Entrance
	[19] = {{69.2, 24.4, "Scarlet Monastery", "Dungeon", dnTex}, {78.6, 58.9, "Scarlet Halls", "Dungeon", dnTex},},
	-- Silverpine Forest
	[21] = {{44.8, 67.8, "Shadowfang Keep", "Dungeon", dnTex},},
	-- Western Plaguelands
	[22] = {{69.6, 73.2, "Scholomance", "Dungeon", dnTex},},
	-- Eastern Plaguelands
	[23] = {{27.7, 11.6, "Stratholme: Crusader's Square", "Dungeon", dnTex}, {43.5, 19.4, "Stratholme: The Gauntlet", "Dungeon", dnTex},},
	-- New Tinkertown
	[30] = {{30.2, 74.7, "Gnomeregan", "Dungeon", dnTex},},
	-- Searing Gorge
	[32] = {{34.9, 83.9, "Blackrock Mountain", "Blackrock Caverns" .. "," .. "Blackrock Depths" .. "|n" .. "Blackrock Spire" .. "," .. "Blackwing Lair" .. "," .. "Molten Core", dnTex},},
	-- Blackrock Mountain
	[33] = {{66.5, 60.7, "Blackrock Caverns", "Dungeon", dnTex}, {64.3, 70.9, "Blackwing Lair", "Raid", rdTex}, {65.9, 41.9, "Blackrock Spire", "Dungeon", dnTex}, {80.3, 40.7, "Lower Blackrock Spire", "Dungeon", dnTex}, {79.0, 33.7, "Upper Blackrock Spire", "Dungeon", dnTex},},
	-- Blackrock Mountain
	[34] = {{71.9, 53.5, "Blackrock Caverns", "Dungeon", dnTex},},
	-- Blackrock Mountain
	[35] = {{54.3, 83.4, "Molten Core", "Raid", rdTex}, {39.0, 18.3, "Blackrock Depths", "Dungeon", dnTex},},
	-- Burning Steppes
	[36] = {{21.0, 37.9, "Blackrock Mountain", "Blackrock Caverns" .. "," .. "Blackrock Depths" .. "|n" .. "Blackrock Spire" .. "," .. "Blackwing Lair" .. "," .. "Molten Core", dnTex}, {23.0, 26.3, "Blackwing Descent", "Raid", rdTex},},
	-- Elwynn Forest
	[37] = {{19.1, 36.9, "The Stockade", "Dungeon", dnTex},},
	-- Deadwind Pass
	[42] = {{46.9, 74.7, "Karazhan", "Raid", rdTex}, {46.7, 70.2, "Return to Karazhan", "Dungeon", dnTex},},
	-- Northern Stranglethorn
	[50] = {{72.1, 32.9, "Zul'Gurub", "Dungeon", dnTex},},
	-- Swamp of Sorrows
	[51] = {{69.7, 53.5, "Temple of Atal'Hakkar", "Dungeon", dnTex},},
	-- Westfall
	[52] = {{42.6, 71.8, "The Deadmines", "Dungeon", dnTex},},
	-- The Deadmines
	[55] = {{25.5, 51.1, "The Deadmines", "Dungeon", dnTex},},
	-- Stormwind City
	[84] = {{49.5, 69.5, "The Stockade", "Dungeon", dnTex},},
	-- Ghostlands
	[95] = {{82.1, 64.3, "Zul'Aman", "Dungeon", dnTex},},
	-- The Exodar
	[103] = {{48.3, 62.9, "Stormwind", "Portal", pATex},},
	-- Isle of Quel'Danas
	[122] = {{61.2, 30.9, "Magisters' Terrace", "Dungeon", dnTex}, {44.3, 45.6, "Sunwell Plateau", "Raid", rdTex},},
	-- Vashj'ir
	[203] = {{49.1, 42.4, "Throne of the Tides", "Dungeon", dnTex},},
	-- Abyssal Depths
	[204] = {{70.8, 29.0, "Throne of the Tides", "Dungeon", dnTex},},
	-- Stranglethorn Vale
	[224] = {{63.5, 21.6, "Zul'Gurub", "Dungeon", dnTex},},
	-- Twilight Highlands
	[241] = {{34.0, 78.0, "The Bastion of Twilight", "Raid", rdTex}, {19.2, 54.0, "Grim Batol", "Dungeon", dnTex},},
	-- Blackrock Depths
	[243] = {{68.4, 38.3, "Molten Core", "Raid", rdTex},},
	-- Tol Barad
	[244] = {{46.3, 47.9, "Baradin Hold", "Raid", rdTex},},
	-- New Tinkertown
	[469] = {{32.6, 37.0, "Gnomeregan", "Dungeon", dnTex},},

	-- Kalimdor
	-- Northern Barrens
	[10] = {{38.9, 69.1, "Wailing Caverns", "Dungeon", dnTex},},
	-- Wailing Caverns
	[11] = {{55.1, 65.9, "Wailing Caverns", "Dungeon", dnTex},},
	-- Ashenvale
	[63] = {{14.2, 13.9, "Blackfathom Deeps", "Dungeon", dnTex},},
	-- Thousand Needles
	[64] = {{41.5, 29.4, "Razorfen Downs", "Dungeon", dnTex},},
	-- Desolace
	[66] = {{29.1, 62.6, "Maraudon", "Dungeon", dnTex},},
	-- Maraudon
	[67] = {{78.2, 56.0, "Maraudon: Foulspore Cavern", "Dungeon", dnTex},},
	-- Maraudon
	[68] = {{44.4, 76.8, "Maraudon: Earth Song Falls", "Dungeon", dnTex}, {52.0, 24.5, "Maraudon: The Wicked Grotto", "Dungeon", dnTex},},
	-- Feralas
	[69] = {{60.3, 31.3, "Dire Maul: Capital Gardens", "Dungeon", dnTex}, {64.8, 30.2, "Dire Maul: Warpwood Quarter", "Dungeon", dnTex}, {62.5, 24.9, "Dire Maul: Gordok Commons", "Dungeon", dnTex},},
	-- Dustwallow Marsh
	[70] = {{52.2, 75.7, "Onyxia's Lair", "Raid", rdTex},},
	-- Tanaris
	[71] = {{39.2, 21.3, "Zul'Farrak", "Dungeon", dnTex}, {64.8, 50.0, "Caverns of Time", "Black Morass" .. ", " .. "Culling of Stratholme" .. ",|n" .. "Dragon Soul" .. ", " .. "End Time" .. ", " .. "Hour of Twilight" .. ",|n" .. "Hyjal Summit" .. ", " .. "Old Hillsbrad Foothills" .. ",|n" .. "Well of Eternity", dnTex},},
	-- Caverns of Time
	[75] = {{57.5, 82.6, "The Culling of Stratholme", "Dungeon", dnTex}, {36.7, 83.0, "The Black Morass", "Dungeon", dnTex}, {22.5, 64.4, "Well of Eternity", "Dungeon", dnTex}, {26.9, 35.8, "Old Hillsbrad Foothills", "Dungeon", dnTex}, {35.5, 15.6, "Hyjal Summit", "Raid", rdTex}, {57.3, 29.6, "End Time", "Dungeon", dnTex}, {61.6, 26.6, "Dragon Soul", "Raid", rdTex}, {66.9, 29.4, "Hour of Twilight", "Dungeon", dnTex},},
	-- Orgrimmar
	[85] = {{55.2, 51.2, "Ragefire Chasm", "Dungeon", dnTex},},
	-- Orgrimmar
	[86] = {{70.0, 49.2, "Ragefire Chasm", "Dungeon", dnTex},},
	-- Silvermoon City
	[110] = {{58.5, 18.7, "Orgrimmar", "Portal", pHTex},},
	-- Mount Hyjal
	[198] = {{47.3, 78.0, "Firelands", "Raid", rdTex},},
	-- Southern Barrens
	[199] = {{41.0, 94.6, "Razorfen Kraul", "Dungeon", dnTex},},
	-- Uldum
	[249] = {{71.6, 52.2, "Halls of Origination", "Dungeon", dnTex}, {60.5, 64.2, "Lost City of the Tol'vir", "Dungeon", dnTex}, {76.7, 84.4, "The Vortex Pinnacle", "Dungeon", dnTex}, {38.4, 80.6, "Throne of the Four Winds", "Raid", rdTex},},
	-- Ahn'Qiraj: The Fallen Kingdom
	[327] = {{46.8, 7.5, "Temple of Ahn'Qiraj", "Raid", rdTex}, {58.9, 14.3, "Ruins of Ahn'Qiraj", "Raid", rdTex},},

	-- Kalimdor (Dungeons)
	-- Ruins of Ahn'Qiraj
	[247] = {{59.3, 28.7, "Scarab Coffer", "Chest", chTex}, {60.8, 51.0, "Scarab Coffer", "Chest", chTex}, {73.0, 66.4, "Scarab Coffer", "Chest", chTex}, {57.4, 78.3, "Scarab Coffer", "Chest", chTex}, {54.8, 87.5, "Scarab Coffer", "Chest", chTex}, {41.0, 76.9, "Scarab Coffer", "Chest", chTex}, {34.0, 53.0, "Scarab Coffer", "Chest", chTex}, {41.1, 32.2, "Scarab Coffer", "Chest", chTex}, {41.6, 46.3, "Scarab Coffer", "Chest", chTex}, {46.7, 42.0, "Scarab Coffer", "Chest", chTex},},
	-- Temple of Ahn'Qiraj
	[319] = {{33.1, 48.4, "Large Scarab Coffer", "Chest", chTex}, {64.5, 25.5, "Large Scarab Coffer", "Chest", chTex}, {58.4, 49.9, "Large Scarab Coffer", "Chest", chTex}, {47.5, 54.7, "Large Scarab Coffer", "Chest", chTex}, {56.2, 66.0, "Large Scarab Coffer", "Chest", chTex}, {50.7, 78.1, "Large Scarab Coffer", "Chest", chTex}, {51.4, 83.2, "Large Scarab Coffer", "Chest", chTex}, {48.4, 85.4, "Large Scarab Coffer", "Chest", chTex}, {48.0, 81.1, "Large Scarab Coffer", "Chest", chTex}, {34.2, 83.5, "Large Scarab Coffer", "Chest", chTex}, {39.2, 68.4, "Large Scarab Coffer", "Chest", chTex},},

	-- Outland
	-- Hellfire Peninsula
	[100] = {{46.6, 52.8, "Magtheridon's Lair", "Raid", rdTex}, {47.7, 53.6, "Hellfire Ramparts", "Dungeon", dnTex}, {47.7, 52.0, "The Shattered Halls", "Dungeon", dnTex}, {46.0, 51.8, "The Blood Furnace", "Dungeon", dnTex},},
	-- Zangarmarsh
	[102] = {{50.4, 40.9, "Coilfang Reservoir", "Serpentshrine Cavern" .. ", " .. "Slave Pens" .. ",|n" .. "Steamvault" .. ", " .. "Underbog", dnTex},},
	-- Shadowmoon Valley
	[104] = {{71.0, 46.4, "Black Temple", "Raid", rdTex},},
	-- Blade's Edge Mountains
	[105] = {{68.7, 24.3, "Gruul's Lair", "Raid", rdTex},},
	-- Terokkar Forest
	[108] = {{43.2, 65.6, "Sethekk Halls", "Dungeon", dnTex}, {36.1, 65.6, "Auchenai Crypts", "Dungeon", dnTex}, {39.6, 71.0, "Shadow Labyrinth", "Dungeon", dnTex}, {39.7, 60.2, "Mana-Tombs", "Dungeon", dnTex},},
	-- Netherstorm
	[109] = {{70.6, 69.7, "The Mechanar", "Dungeon", dnTex}, {73.7, 63.7, "The Eye", "Raid", rdTex}, {71.7, 55.0, "The Botanica", "Dungeon", dnTex}, {74.4, 57.7, "The Arcatraz", "Dungeon", dnTex},},

	-- Northrend
	-- Borean Tundra
	[114] = {{27.6, 26.6, "The Nexus", "The Nexus" .. ", " .. "The Oculus" .. ",|n" .. "The Eye of Eternity", dnTex},},
	-- Dragonblight
	[115] = {{59.6, 51.1, "Wyrmrest Temple", "The Ruby Sanctum" .. ", " .. "The Obsidian Sanctum", dnTex}, {87.4, 51.1, "Naxxramas", "Raid", rdTex}, {26.2, 49.6, "Azjol-Nerub", "Azjol-Nerub" .. ", " .. "The Old Kingdom", dnTex},},
	-- Grizzly Hills
	[116] = {{17.5, 27.0, "Drak'Tharon Keep", "Dungeon", dnTex},},
	-- Howling Fjord
	[117] = {{57.3, 46.8, "Utgarde Keep", "Utgarde Keep" .. ", " .. "Utgarde Pinnacle", dnTex},},
	-- Icecrown
	[118] = {{53.3, 85.5, "Icecrown Citadel", "Raid", rdTex}, {52.6, 89.4, "The Frozen Halls", "The Forge of Souls" .. ", " .. "The Pit of Saron" .. ",|n" .. "The Halls of Reflection", dnTex}, {74.2, 20.5, "Trial of the Champion", "Dungeon", dnTex}, {75.1, 21.8, "Trial of the Crusader", "Raid", rdTex},},
	-- The Storm Peaks
	[120] = {{39.6, 26.9, "Halls of Stone", "Dungeon", dnTex}, {45.4, 21.4, "Halls of Lightning", "Dungeon", dnTex}, {41.6, 17.8, "Ulduar", "Raid", rdTex},},
	-- Zul'Drak
	[121] = {{29.0, 83.9, "Drak'Tharon Keep", "Dungeon", dnTex}, {76.2, 21.1, "Gundrak", "Dungeon", dnTex}, {81.2, 28.9, "Gundrak (rear entrance)", "Dungeon", dnTex},},
	-- Wintergrasp
	[123] = {{50.5, 16.4, "Vault of Archavon", "Raid", rdTex},},
	-- Dalaran
	[125] = {{66.8, 68.2, "The Violet Hold", "Dungeon", dnTex},},

	-- Cataclysm
	-- Deepholm
	[207] = {{47.6, 52.0, "The Stonecore", "Dungeon", dnTex},},

	-- Pandaria
	-- The Jade Forest
	[371] = {{56.2, 57.9, "Temple of the Jade Serpent", "Dungeon", dnTex},},
	-- Valley of the Four Winds
	[376] = {{36.1, 69.2, "Stormstout Brewery", "Dungeon", dnTex},},
	-- Kun-Lai Summit
	[379] = {{59.6, 39.2, "Mogu'shan Vaults", "Raid", rdTex}, {36.7, 47.4, "Shado-Pan Monastery", "Dungeon", dnTex},},
	-- Townlong Steppes
	[388] = {{34.7, 81.5, "Siege of Niuzao Temple", "Dungeon", dnTex}, {49.7, 68.7, "Throne of Thunder", "Raid", rdTex},},
	-- Vale of Eternal Blossoms
	[390] = {{80.9, 32.7, "Mogu'shan Palace", "Dungeon", dnTex}, {72.4, 44.2, "Siege of Orgrimmar", "Raid", rdTex}, {15.8, 74.3, "Gate of the Setting Sun", "Dungeon", dnTex},},
	-- Dread Wastes
	[422] = {{38.8, 35.0, "Heart of Fear", "Raid", rdTex},},
	-- The Veiled Stair
	[433] = {{48.4, 61.4, "Terrace of Endless Spring", "Raid", rdTex},},
	-- Isle of Thunder
	[504] = {{63.6, 32.3, "Throne of Thunder", "Raid", rdTex},},

	-- Draenor
	-- Frostfire Ridge
	[525] = {{49.8, 24.7, "Bloodmaul Slag Mines", "Dungeon", dnTex},},
	-- Tanaan Jungle
	[534] = {{45.7, 53.5, "Hellfire Citadel", "Raid", rdTex},},
	-- Talador
	[535] = {{46.3, 73.9, "Auchindoun", "Dungeon", dnTex},},
	-- Shadowmoon Valley
	[539] = {{31.9, 42.5, "Shadowmoon Burial Grounds", "Dungeon", dnTex},},
	-- Spires of Arak
	[542] = {{35.6, 33.6, "Skyreach", "Dungeon", dnTex},},
	-- Gorgrond
	[543] = {{51.3, 28.6, "Blackrock Foundry", "Raid", rdTex}, {55.2, 31.9, "Grimrail Depot", "Dungeon", dnTex}, {59.6, 45.5, "The Everbloom", "Dungeon", dnTex}, {45.4, 13.5, "Iron Docks", "Dungeon", dnTex},},
	-- Nagrand
	[550] = {{32.9, 38.4, "Highmaul", "Raid", rdTex},},
	-- Stormshield
	[622] = {{60.8, 38.0, "Stormwind", "Portal", pATex}, {36.4, 41.1, "Lion's Watch", "Portal", pATex, 38445},},
	-- Warspear
	[624] = {{60.6, 51.6, "Orgrimmar", "Portal", pHTex}, {53.0, 43.9, "Vol'mar", "Portal", pHTex, 37935},},

	-- Broken Isles
	-- Felsoul Hold
	[682] = {{53.6, 36.8, "Shal'Aran", "Portal", pNTex, 41575,},},
	-- Shattered Locus
	[684] = {{40.9, 13.7, "Shal'Aran", "Portal", pNTex, 42230,},},
	-- Suramar
	[680] = {{21.6, 28.5, "Falanaar", "Portal", pNTex, 42230,}, {39.7, 76.2, "Felsoul Hold", "Portal", pNTex, 41575,}, {30.8, 11.0, "Moon Guard Stronghold", "Portal", pNTex, 43808,}, {43.7, 79.2, "Lunastre Estate", "Portal", pNTex, 43811,}, {36.1, 47.2, "Ruins of Elune'eth", "Portal", pNTex, 40956,}, {52.0, 78.8, "Evermoon Terrace", "Portal", pNTex, 42889,}, {43.4, 60.6, "Sanctum of Order", "Portal", pNTex, 43813,}, {42.0, 35.2, "Tel'anor", "Portal", pNTex, 43809,}, {64.0, 60.4, "Twilight Vineyards", "Portal", pNTex, 44084,}, {54.5, 69.4, "Astravar Harbor", "Portal", pNTex, 44740,}, {47.7, 81.4, "The Waning Crescent", "Portal", pNTex, 42487, 38649,},},

}