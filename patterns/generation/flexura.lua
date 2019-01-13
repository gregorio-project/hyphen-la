-- output error message for an invalid field
function invalidField(field)
   error('Invalid field "'..field..'" in line '..linecount)
end

-- output error message for an invalid line
function invalidLine()
   error('Input line '..linecount..' is invalid: "'..wholeLine..'"')
end

function firstCharacter(word)
   if utf8.len(word) > 1 then
      return string.sub(word,1,utf8.offset(word,2)-1)
   else
      return word
   end
end

function lastCharacter(word)
   if utf8.len(word) > 0 then
      return string.sub(word,utf8.offset(word,-1))
   else
      return word
   end
end

function utf8substring(s,i,j)
   if j then
      if j == -1 then
         return string.sub(s,utf8.offset(s,i))
      else
         return string.sub(s,utf8.offset(s,i),utf8.offset(s,j+1)-1)
      end
   else
      return string.sub(s,utf8.offset(s,i))
   end
end

function createSet(list)
   local set = {}
   for _, l in ipairs(list) do
      set[l] = true
   end
   return set
end

combiningAcute = utf8.char(769)

-- digraphs with macrons are not needed, as diphthongs are always long
vowels = createSet{"A","a","Ā","ā","E","e","Ē","ē","I","i","Ī","ī","O","o","Ō",
   "ō","U","u","Ū","ū","Y","y","Ȳ","ȳ","Æ","æ","Œ","œ"}

-- possible diphthongs are "au" and "eu", macrons are not used
firstVowelsOfDiphthongs = createSet{"A","a","E","e"}

consonants = createSet{"B","b","C","c","D","d","F","f","G","g","H","h","J","j",
   "K","k","L","l","M","m","N","n","P","p","Q","q","R","r","S","s","T","t","V",
   "v","W","w","X","x","Z","z"}

-- stop consonants, called "(litterae) mutae" in Latin
mutae = createSet{"B","b","P","p","D","d","T","t","G","g","C","c","K","k"}

-- liquid consonants, called "(litterae) liquidae" in Latin
liquidae = createSet{"L","l","R","r"}


function endsInTwoConsonants(word)
   if consonants[utf8substring(word,-1,-1)]
   and consonants[utf8substring(word,-2,-2)]
   and (consonants[utf8substring(word,-3,-3)]
   or not mutae[utf8substring(word,-2,-2)]
   or not liquidae[utf8substring(word,-1,-1)]) then
      return true
   else
      return false
   end
end

function endsIn(word,ending)
   if string.len(word) > string.len(ending)
   and string.sub(word,-string.len(ending)) == ending then
      return true
   else
      return false
   end
end

function beginWithSameLetter(wordA,wordB)
   if firstCharacter(wordA) == firstCharacter(wordB) then
      return true
   else
      return false
   end
end

-- adjectives with consonantal declension
adjectivesConsonantalDeclension = createSet{"compos","com-pos","dīves",
   "particeps","parti-ceps","pauper","prīnceps","prīn-ceps","sōspes",
   "super-stes","vetus"}

-- adjectives with superlative ending in "-limus"

adjectivesSuperlative_limus = createSet{"difficilis","dis-similis",
   "facilis","gracilis","humilis","similis"}

-- adjectives using declensed forms as adverb instead of a regular adverb

adjectivesWithDeclensedFormAdverb = createSet{"cēterus","cotīdiānus",
   "cottīdiānus","crēber","malus","meritus","multus","necessārius","nimius",
   "paullus","paulus","perpetuus","per-petuus","plērus","plērus-que","plūrimus",
   "plūrumus","postrēmus","potissimus","quotīdiānus","rārus","sēcrētus","sērus",
   "sōlus","subitus","sub-itus","tantus","tūtus"}
   -- the adverb of "malus" is "male" with short e (= vocative)


function addForm(word)
   print(word)
end

function attachEnding(root,ending)
   local c = firstCharacter(ending)
   if (firstVowelsOfDiphthongs[lastCharacter(root)] and c == "u")
   or ((string.sub(root,-2,-1) == "su" or string.sub(root,-2,-1) == "Su") and vowels[c]) then
      addForm(root.."|"..ending)
   elseif utf8.len(root) > 2 and utf8substring(root,-3) == "īn-" and c ~= "f" and c ~= "s" then
      addForm(utf8substring(root,1,-4).."in-"..ending)
   else
      addForm(root..ending)
   end
end

function attachEndings(root,endings)
   for _, ending in pairs(endings) do
      attachEnding(root,ending)
   end
end

function attachEndingsVowelConsonant(rootBeforeVowel,rootBeforeConsonant,endings)
   for _, ending in pairs(endings) do
      local root
      if vowels[firstCharacter(ending)] then
         root = rootBeforeVowel
      else
         root = rootBeforeConsonant
      end
      attachEnding(root,ending)
   end
end

function attachEndingsVowel_f_Consonant(rootBeforeVowel,rootBefore_f,rootBeforeConsonant,endings)
   for _, ending in pairs(endings) do
      local root
      if vowels[firstCharacter(ending)] then
         root = rootBeforeVowel
      elseif firstCharacter(ending) == "f" then
         root = rootBefore_f
      else
         root = rootBeforeConsonant
      end
      attachEnding(root,ending)
   end
end

function attachEndingsEnclitic(root,endings,enclitic)
   for _, ending in pairs(endings) do
      local fullEnding = ending.."-"..enclitic
      attachEnding(root,fullEnding)
   end
end

function addPerfectStemForms(firstPersonSingular)
   if endsIn(firstPersonSingular,"ī") then
      stem = utf8substring(firstPersonSingular,1,-2)
      for _, ending in pairs(perfectStemEndings) do
         attachEnding(stem,ending)
         if endsIn(stem,"īv") and utf8.len(ending) > 2
         and (utf8substring(ending,1,2) == "er" or utf8substring(ending,1,2) == "ēr") then
            attachEnding(utf8substring(stem,1,-3).."i",ending)
         elseif endsIn(stem,"v") and utf8.len(ending) > 2
         and (utf8substring(ending,1,2) == "er" or utf8substring(ending,1,2) == "ēr"
         or utf8substring(ending,1,2) == "is") then
            attachEnding(utf8substring(stem,1,-2),utf8substring(ending,2))
         end
      end
   else
      invalidField(firstPersonSingular)
   end
end

function addPerfectStemFormsImpersonal(thirdPersonSingular)
   if endsIn(thirdPersonSingular,"it") then
      stem = utf8substring(thirdPersonSingular,1,-3)
      attachEnding(stem,"it") -- perfect indicative active
      attachEnding(stem,"erit") -- perfect subjunctive active/future perfect active
      attachEnding(stem,"isse") -- infinitive perfect
      attachEnding(stem,"erat") -- pluperfect indicative active
      attachEnding(stem,"isset") -- pluperfect subjunctive active
   else
      invalidField(thirdPersonSingular)
   end
end

function addSupineStemForms(supine)
   if endsIn(supine,"um") then
      local stem = string.sub(supine,1,-3)
      attachEndings(stem,adjectiveEndings_us_a_um) -- perfect passive particple
      attachEndings(stem.."ūr",adjectiveEndings_us_a_um) -- future active participle 
      addForm(stem.."ū") -- second supine
   else
      invalidField(supine)
   end
end


-- endings of the nouns of the first declension
nounEndings1 = { "a","æ","am","ā","ārum","īs","ās" }
nounEndings1_greek = { "ēs","æ","am","ā","ārum","īs","ās" }
nounEndings1_ae_arum = { "æ","ārum","īs","ās" }

-- endings of the nouns of the second declension
nounEndings2_us = { "us","ī","ō","um","e","ōrum","īs","ōs" }
nounEndings2_ius = { "ius","iī","ī","iō","ium","iōrum","iīs","iōs" }
nounEndings2_jus = { "jus","jī","ī","jō","jum","jōrum","jīs","jōs" }
nounEndings2_us_neuter = { "us","ī","ō","a","ōrum","īs" }
nounEndings2_um = { "um","ī","ō","a","ōrum","īs" }
nounEndings2_ium = { "ium","iī","ī","iō","ia","iōrum","iīs" }
nounEndings2_jum = { "jum","jī","ī","jō","ja","jōrum","jīs" }
nounEndings2_r_ri = { "r","rī","rō","rum","rōrum","rīs","rōs" }
nounEndings2_er_ri = { "er","rī","rō","rum","rōrum","rīs","rōs" }
nounEndings2_i_orum = { "ī","ōrum","īs","ōs" }
nounEndings2_a_orum = { "a","ōrum","īs" }

-- endings of the nouns of the third declension
nounEndings3_i = { -- e.g. "turris"
   "is","ī","im","ēs","ium","ibus","īs"}
nounEndings3_i_neuter = { -- e.g. "mare", nom./acc. sing. is left out
   "is","ī","ia","ium","ibus"}
nounEndings3_i_plural = { -- e.g. "penātēs"
   "ēs","ium","ibus","īs"}
nounEndings3_i_neuterPlural = { -- e.g. "mœnia"
   "ia","ium","ibus"}
nounEndings3_mixed = { -- e.g. "pars", nom. sing. is left out
   "is","ī","em","e","ēs","ium","ibus","īs"}
nounEndings3_mixedNeuter = { -- e.g. "os", nom./acc. sing. is left out
   "is","ī","e","a","ium","ibus"}
nounEndings3_consonantal = { -- e.g. "cōnsul", nom. sing. is left out
   "is","ī","em","e","ēs","um","ibus"}
nounEndings3_consonantalNeuter = { -- e.g. "mūnus", nom./acc. sing. is left out
   "is","ī","e","a","um","ibus"}
nounEndings3_consonantalPlural = { -- e.g. "majōrēs"
   "ēs","um","ibus"}
nounEndings3_mixedAndConsonantal = { -- e.g. "parēns", nom. sing. is left out
   "is","ī","em","e","ēs","ium","um","ibus","īs"}

-- endings of the nouns of the fourth declension
nounEndings4_us = { -- e.g. "currus"
   "us","ūs","uī","um","ū","ūs","uum","ibus"}
nounEndings4_us_ubus = { -- e.g. "arcus"
   "us","ūs","uī","um","ū","ūs","uum","ubus"}
nounEndings4_us_plural = { -- e.g. "Īdūs"
   "ūs","uum","ibus"}
nounEndings4_u = { -- e.g. "cornū"
   "ū","ūs","ua","uum","ibus"}

-- endings of the nouns of the fifth declension
nounEndings5 = { -- e.g. "rēs"
   "ēs","eī","em","ē","ērum","ēbus"}
nounEndings5_afterVowel = { -- e.g. "diēs"
   "ēs","ēī","em","ē","ērum","ēbus"} -- long e in the genitive/dative sg.

-- endings of the adjectives of the first and second declension
adjectiveEndings_us_a_um = { -- e.g. "bonus"
   "us","a","um","ī","æ","ō","am","ā","e","ōrum","ārum","īs","ōs","ās"}

adjectiveEndings_us_a_um_withoutVocative = { -- e.g. "meus"
   "us","a","um","ī","æ","ō","am","ā","ōrum","ārum","īs","ōs","ās"}

adjectiveEndings_i_ae_a = { -- plural
   "ī","æ","a","ōrum","ārum","īs","ōs","ās"}

adjectiveEndings_r_ra_rum = { -- e.g. "liber", "satur"
   "r","ra","rum","rī","ræ","rō","ram","rā","rōrum","rārum","rīs","rōs","rās"}

adjectiveEndings_er_ra_rum = { -- e.g. "pulcher"
   "er","ra","rum","rī","ræ","rō","ram","rā","rōrum","rārum","rīs","rōs","rās"}

pronominalAdjectiveEndings = { -- e.g. "sōlus", "ūllus"
   "us","a","um","īus","ī","am","ō","ā","æ","ōrum","ārum","īs","ōs","ās"}

pronounEndings_e_a_ud = { -- e.g. "ille"
   "e","a","ud","īus","ī","um","am","ō","ā","æ","ōrum","ārum","īs","ōs","ās"}

pronounEndings_o_ae = { -- "duo" and "ambō", nominative ending in "o"/"ō" is left out
   "æ","ōrum","ārum","ōbus","ābus","ōs","ās"}

pronounForms_qui_quae_quod = {"quī","quæ","quod","cujus","cui","quem","quam",
   "quō","quā","quōrum","quārum","quibus","quōs","quās"}

pronounForms_quis_quid = {"quis","quid","cujus","cui","quem","quō"}

pronounForms_uter_utra_utrum = {"uter","utra","utrum","utrīus","utrī","utram",
   "utrō","utrā","utræ","utrōrum","utrārum","utrīs","utrōs","utrās"}

-- endings of the adjectives of the third declension
adjectiveEndings_er_ris_re = { -- e.g. "acer"
   "er","ris","re","rī","rem","rēs","ria","rium","ribus","rīs"}
   -- "rīs" is a variant of "rēs" for the accusative plural

adjectiveEndings_r_ris_re = { -- "celer"
   "r","ris","re","rī","rem","rēs","ria","rum","ribus","rīs"}
   -- "rīs" is a variant of "rēs" for the accusative plural

adjectiveEndings_is_e = { -- e.g. "brevis"
   "is","e","ī","em","ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_is_e_afterFullVowel = { -- e.g. "tenuis"
   "is","e","ī","em","ēs","ja","jum","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_ior_ius = { -- e.g. "altior"
   "ior","ius","iōris","iōrī","iōrem","iōre","iōrēs","iōra","iōrum","iōribus"}

adjectiveEndings_jor_jus = { -- e.g. "pējor"
   "jor","jus","jōris","jōrī","jōrem","jōre","jōrēs","jōra","jōrum","jōribus"}

adjectiveEndings_ans_antis = { -- e.g. "cōnstāns"
   "āns","antis","antī","antem","antēs","antia","antium","antibus","antīs"}
   -- "antīs" is a variant of "antēs" for the accusative plural

adjectiveEndings_ens_entis = { -- e.g. "vehemēns"
   "ēns","entis","entī","entem","entēs","entia","entium","entibus","entīs"}
   -- "entīs" is a variant of "entēs" for the accusative plural

adjectiveEndings_i_ium = { -- e.g. "atrōx", nom. sing. is left out
   "is","ī","em","ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_es_ium = { -- plural only, e.g. "trēs"
   "ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_i_um = { -- e.g. "memor", nom. sing. is left out
   "is","ī","em","ēs","um","ibus"}
   -- nominative and accusative neuter plural are not in use

adjectiveEndings_e_um = { -- e.g. "vetus", nom. sing. is left out
   "is","ī","em","e","ēs","a","um","ibus"}

-- the present active participles follow the mixed declension
participlePresentActiveEndingsA = { -- e.g. "laudāns" < "laudāre"
   "āns","antis","antī","antem","ante",
   "antēs","antia","antium","antibus","antīs"}
   -- "antīs" is a variant of "antēs" for the accusative plural

participlePresentActiveEndingsE = { -- e.g. "mittēns" < "mittere"
   "ēns","entis","entī","entem","ente",
   "entēs","entia","entium","entibus","entīs"}
   -- "entīs" is a variant of "entēs" for the accusative plural

participlePresentActiveForms_ire = {
   "iēns","euntis","euntī","euntem","eunte",
   "euntēs","euntia","euntium","euntibus","euntīs"}
   -- "euntīs" is a variant of "euntēs" for the accusative plural


function addEndings(list,bridge,endings)
   for _, ending in pairs(endings) do
      table.insert(list,bridge..ending)
   end
end

presentEndingsSubjunctiveActive_a = {"am","ās","at","āmus","ātis","ant"}
presentEndingsSubjunctiveActive_i = {"im","īs","it","īmus","ītis","int"}

imperfectEndingsIndicativeActive = {"bam","bās","bat","bāmus","bātis","bant"}
imperfectEndingsIndicativePassive = {"bar","bāris","bāre","bātur","bāmur","bāminī","bantur"}
imperfectEndingsSubjunctiveActive = {"rem","rēs","ret","rēmus","rētis","rent"}
imperfectEndingsSubjunctiveActiveWithout_r = {"em","ēs","et","ēmus","ētis","ent"}
imperfectEndingsSubjunctivePassive = {"rer","rēris","rēre","rētur","rēmur","rēminī","rentur"}
imperfectEndingsIndicativeActive_esse = {"eram","erās","erat","erāmus","erātis","erant"}

futureEndingsActive_b = {"bō","bis","bit","bimus","bitis","bunt"}
futureEndingsActive_a_e = {"am","ēs","et","ēmus","ētis","ent"}
futureEndingsPassive_b = {"bor","beris","bere","bitur","bimur","biminī","buntur"}
futureEndingsPassive_a_e = {"ar","ēris","ēre","ētur","ēmur","ēminī","entur"}

perfectEndingsSubjunctiveActiveAndFutureActive = {"erim","erīs","eris","erit","erīmus","erimus","erītis","eritis","erint","erō"}

-- endings of the first conjugation
presentStemEndingsActive1 = {
   "ō","ās","at","āmus","ātis","ant", -- indicative present
   "em","ēs","et","ēmus","ētis","ent", -- subjunctive present
   "ā","āte","ātō","ātōte","antō" -- imperative
   }

addEndings(presentStemEndingsActive1,"ā",imperfectEndingsIndicativeActive)
addEndings(presentStemEndingsActive1,"ā",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndingsActive1,"ā",futureEndingsActive_b)

presentStemEndingsPassive1 = {
   "or","āris","ātur","āmur","āminī","antur", -- indicative present
   "er","ēris","ēre","ētur","ēmur","ēminī","entur", -- subjunctive present
   "āre","ātor","antor", -- imperative
   "ārī" --infinitive
   }

addEndings(presentStemEndingsPassive1,"ā",imperfectEndingsIndicativePassive)
addEndings(presentStemEndingsPassive1,"ā",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndingsPassive1,"ā",futureEndingsPassive_b)

-- special forms for "dare" (the "a" is short except in "dās" and "dā")
presentStemEndings_dare = {
   "ō","ās","at","amus","atis","ant", -- indicative present active
   "em","ēs","et","ēmus","ētis","ent", -- subjunctive present active
   "ā","ate","atō","atōte","antō", -- imperative active
   "or","aris","atur","amur","aminī","antur", -- indicative present passive
   "er","ēris","ēre","ētur","ēmur","ēminī","entur", -- subjunctive present passive
   "are","ator","antor", -- imperative passive
   "arī" --infinitive passive
   }

addEndings(presentStemEndings_dare,"a",imperfectEndingsIndicativeActive)
addEndings(presentStemEndings_dare,"a",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndings_dare,"a",imperfectEndingsIndicativePassive)
addEndings(presentStemEndings_dare,"a",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndings_dare,"a",futureEndingsActive_b)
addEndings(presentStemEndings_dare,"a",futureEndingsPassive_b)


-- endings of the second conjugation
presentStemEndingsActive2 = {
   "eō","ēs","et","ēmus","ētis","ent", -- indicative present
   "ē","ēte","ētō","ētōte","entō" -- imperative
   }

addEndings(presentStemEndingsActive2,"e",presentEndingsSubjunctiveActive_a)
addEndings(presentStemEndingsActive2,"ē",imperfectEndingsIndicativeActive)
addEndings(presentStemEndingsActive2,"ē",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndingsActive2,"ē",futureEndingsActive_b)

presentStemEndingsPassive2 = {
   "eor","ēris","ētur","ēmur","ēminī","entur", -- indicative present
   "ear","eāris","eāre","eātur","eāmur","eāminī","eantur", -- subjunctive present
   "ēre","ētor","entor", -- imperative
   "ērī" --infinitive
   }

addEndings(presentStemEndingsPassive2,"ē",imperfectEndingsIndicativePassive)
addEndings(presentStemEndingsPassive2,"ē",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndingsPassive2,"ē",futureEndingsPassive_b)


-- endings of the third conjugation
presentStemEndingsActive3 = {
   "ō","is","it","imus","itis","unt", -- indicative present
   "ite","itō","itōte","untō" -- imperative
   }
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "dīcere" and
"dūcere" ]]

addEndings(presentStemEndingsActive3,"",presentEndingsSubjunctiveActive_a)
addEndings(presentStemEndingsActive3,"ē",imperfectEndingsIndicativeActive)
addEndings(presentStemEndingsActive3,"e",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndingsActive3,"",futureEndingsActive_a_e)

presentStemEndingsPassive3 = {
   "or","eris","itur","imur","iminī","untur", -- indicative present
   "āris","āre","ātur","āmur","āminī","antur", -- subjunctive present
   "ere","itor","untor", -- imperative
   "ī" --infinitive
   }

addEndings(presentStemEndingsPassive3,"ē",imperfectEndingsIndicativePassive)
addEndings(presentStemEndingsPassive3,"e",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndingsPassive3,"",futureEndingsPassive_a_e)


-- endings of the mixed third conjugation
presentStemEndingsActive3M = {
   "iō","is","it","imus","itis","iunt", -- indicative present
   "ite","itō","itōte","iuntō" -- imperative
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "facere" and
"calefacere" ]]
   }

addEndings(presentStemEndingsActive3M,"i",presentEndingsSubjunctiveActive_a)
addEndings(presentStemEndingsActive3M,"iē",imperfectEndingsIndicativeActive)
addEndings(presentStemEndingsActive3M,"e",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndingsActive3M,"i",futureEndingsActive_a_e)

presentStemEndingsPassive3M = {
   "ior","eris","itur","imur","iminī","iuntur", -- indicative present
   "iāris","iāre","iātur","iāmur","iāminī","iantur", -- subjunctive present
   "ere","itor","iuntor", -- imperative
   "ī" --infinitive
   }

addEndings(presentStemEndingsPassive3M,"iē",imperfectEndingsIndicativePassive)
addEndings(presentStemEndingsPassive3M,"e",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndingsPassive3M,"i",futureEndingsPassive_a_e)


-- endings of the fourth conjugation
presentStemEndingsActive4 = {
   "iō","īs","it","īmus","ītis","iunt", -- indicative present
   "ī","īte","īto","ītōte","iuntō" -- imperative
   }

addEndings(presentStemEndingsActive4,"i",presentEndingsSubjunctiveActive_a)
addEndings(presentStemEndingsActive4,"iē",imperfectEndingsIndicativeActive)
addEndings(presentStemEndingsActive4,"ī",imperfectEndingsSubjunctiveActive)
addEndings(presentStemEndingsActive4,"i",futureEndingsActive_a_e)

presentStemEndingsPassive4 = {
   "ior","īris","ītur","īmur","īminī","iuntur", -- indicative present
   "iāris","iāre","iātur","iāmur","iāminī","iantur", -- subjunctive present
   "īre","ītor","iuntor", -- imperative
   "īrī" --infinitive
   }

addEndings(presentStemEndingsPassive4,"iē",imperfectEndingsIndicativePassive)
addEndings(presentStemEndingsPassive4,"ī",imperfectEndingsSubjunctivePassive)
addEndings(presentStemEndingsPassive4,"i",futureEndingsPassive_a_e)


-- forms of "esse"
presentStemForms_esse = {
   "sum","es","est","sumus","estis","sunt", -- indicative present
   "erō","eris","erit","erimus","eritis","erunt", -- future
   "es","este","estō","estōte","suntō", -- imperative
   "esse" -- infinitve
   }

addEndings(presentStemForms_esse,"s",presentEndingsSubjunctiveActive_i)
addEndings(presentStemForms_esse,"",imperfectEndingsIndicativeActive_esse)
addEndings(presentStemForms_esse,"fo",imperfectEndingsSubjunctiveActive)
addEndings(presentStemForms_esse,"ess",imperfectEndingsSubjunctiveActiveWithout_r)


-- forms of "ferre"
presentStemForms_ferre = {
   "ferō","fers","fert","ferimus","fertis","ferunt", -- indicative present active
   "fer","ferte","fertō","fertōte","feruntō", -- imperative active
   "ferre", -- infinitve present active
   "feror","ferris","fertur","ferimur","feriminī","feruntur", -- indicative present passive
   "ferar","ferāris","ferāre","ferātur","ferāmur","ferāminī","ferantur", -- subjunctive present passive
   "fertor","feruntor", -- imperative passive
   "ferrī" --infinitive present passive
   }

addEndings(presentStemForms_ferre,"fer",presentEndingsSubjunctiveActive_a)
addEndings(presentStemForms_ferre,"ferē",imperfectEndingsIndicativeActive)
addEndings(presentStemForms_ferre,"fer",imperfectEndingsSubjunctiveActive)
addEndings(presentStemForms_ferre,"fer",futureEndingsActive_a_e)
addEndings(presentStemForms_ferre,"ferē",imperfectEndingsIndicativePassive)
addEndings(presentStemForms_ferre,"fer",imperfectEndingsSubjunctivePassive)
addEndings(presentStemForms_ferre,"fer",futureEndingsPassive_a_e)


-- forms of "īre"
presentStemForms_ire = {
   "eō","īs","it","īmus","ītis","eunt", -- indicative present
   "ī","īte","ītō","ītōte","euntō", -- imperative
   "īre", -- infinitve
   "eor","īris","ītur","īmur","īminī","euntur", -- indicative present
   "ear","eāris","eāre","eātur","eāmur","eāminī","eantur", -- subjunctive present
   "ītor","euntor", -- imperative
   "īrī" --infinitive
   }

addEndings(presentStemForms_ire,"e",presentEndingsSubjunctiveActive_a)
addEndings(presentStemForms_ire,"ī",imperfectEndingsIndicativeActive)
addEndings(presentStemForms_ire,"ī",imperfectEndingsSubjunctiveActive)
addEndings(presentStemForms_ire,"ī",imperfectEndingsIndicativePassive)
addEndings(presentStemForms_ire,"ī",imperfectEndingsSubjunctivePassive)
addEndings(presentStemForms_ire,"ī",futureEndingsActive_b)
addEndings(presentStemForms_ire,"ī",futureEndingsPassive_b)

perfectStemForms_ire = {"iī","īstī","iit","iimus","īstis","iērunt","iēre", -- perfect indicative active
   "īsse" -- infinitive perfect active
   }

addEndings(perfectStemForms_ire,"i",perfectEndingsSubjunctiveActiveAndFutureActive) -- perfect subjunctive active und future perfect active
addEndings(perfectStemForms_ire,"i",imperfectEndingsIndicativeActive_esse) -- pluperfect indicative active
addEndings(perfectStemForms_ire,"īss",imperfectEndingsSubjunctiveActiveWithout_r) -- pluperfect subjunctive active

-- forms of "posse"
presentStemForms_posse = {
   "possum","pot-es","pot-est","possumus","pot-estis","possunt", -- indicative present
   "pot-erō","pot-eris","pot-erit","pot-erimus","pot-eritis","pot-erunt", -- future
   "possiem","possies","possiet", -- old forms of the subjunctive present
   "potisset", -- old form of the subjunctive imperfect
   "posse","pot-esse" -- infinitve
   }

addEndings(presentStemForms_posse,"poss",presentEndingsSubjunctiveActive_i)
addEndings(presentStemForms_posse,"pot-",imperfectEndingsIndicativeActive_esse)
addEndings(presentStemForms_posse,"poss",imperfectEndingsSubjunctiveActiveWithout_r)


-- endings of the perfect stem
perfectStemEndings = {"ī","istī","it","imus","istis","ērunt","ēre", -- perfect indicative active
   "isse" -- infinitive perfect active
   }

addEndings(perfectStemEndings,"",perfectEndingsSubjunctiveActiveAndFutureActive) -- perfect subjunctive active und future perfect active
addEndings(perfectStemEndings,"",imperfectEndingsIndicativeActive_esse) -- pluperfect indicative active
addEndings(perfectStemEndings,"iss",imperfectEndingsSubjunctiveActiveWithout_r) -- pluperfect subjunctive active


-- generate positive forms of adjectives with three endings
function generatePositiveForms3(masculine,feminine)
   -- adjectives of the first and second declension ending in "us/a/um"
   if endsIn(masculine,"us") and feminine == nil then
      root = string.sub(masculine,1,-3)
      if masculine == "sōlus" then -- pronominal declension
         attachEndings(root,pronominalAdjectiveEndings)
      else
         attachEndings(root,adjectiveEndings_us_a_um)
      end

   -- plērusque
   elseif masculine == "plērus-que" and feminine == nil then
      attachEndingsEnclitic("plēr",adjectiveEndings_us_a_um,"que")

   -- adjectives of the first and second declension ending in "r/ra/rum"
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ra") then
      root = string.sub(masculine,1,-2)
      attachEndings(root,adjectiveEndings_r_ra_rum)

   -- adjectives of the first and second declension ending in "er/ra/rum"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine)
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ra") then
      root = string.sub(masculine,1,-3)
      attachEndings(root,adjectiveEndings_er_ra_rum)

   -- adjectives of the third declension ending in "er/ris/re"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ris") then
      root = string.sub(masculine,1,-3)
      attachEndings(root,adjectiveEndings_er_ris_re)

   -- adjectives of the third declension ending in "r/ris/re" ("celer")
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 2
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ris") then
      root = string.sub(masculine,1,-2)
      attachEndings(root,adjectiveEndings_r_ris_re)

   else
      invalidLine()
   end
end

-- generate comparative and superlative forms of adjectives with three endings
function generateComparativeAndSuperlative3(masculine,feminine)
   if masculine == "bonus" then
      attachEndings("mel",adjectiveEndings_ior_ius) -- comparative (melior)
      attachEndings("optim",adjectiveEndings_us_a_um) -- superlative (optimus)
      generateAdverb3("optimus") -- adverb of superlative

   elseif masculine == "citer" then
      attachEndings("citer",adjectiveEndings_ior_ius) -- comparative
      attachEndings("citim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3("citimus") -- adverb of superlative

   elseif masculine == "māgnus" then
      attachEndings("mā",adjectiveEndings_jor_jus) -- comparative (mājor)
      attachEndings("maxim",adjectiveEndings_us_a_um) -- superlative (maximus)
      generateAdverb3("maximus") -- adverb of superlative

   elseif masculine == "malus" then
      attachEndings("pē",adjectiveEndings_jor_jus) -- comparative (pējor)
      attachEndings("pessim",adjectiveEndings_us_a_um) -- superlative (pessimus)
      generateAdverb3("pessimus") -- adverb of superlative

   elseif masculine == "multus" then
      generatePositiveForms1("plūs","plūris")
      attachEndings("plūrim",adjectiveEndings_us_a_um) -- superlative
      attachEndings("plūrum",adjectiveEndings_us_a_um) -- superlative
      -- adverb is "plūrimum" (= accusative)

   elseif endsIn(masculine,"-dicus") then
      root = string.sub(masculine,1,-5).."īcent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   elseif endsIn(masculine,"-ficus") or endsIn(masculine,"-volus") then
      root = string.sub(masculine,1,-3).."ent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- adjectives of the first and second declension ending in "us/a/um"
   elseif endsIn(masculine,"us") then
      if string.len(masculine) > 3 and vowels[utf8substring(masculine,-3,-3)]
      and string.sub(masculine,-4) ~= "quus" then
         -- adjectives ending in vowel+"us" are not comparable
      else
         root = string.sub(masculine,1,-3)
         attachEndings(root,adjectiveEndings_ior_ius) -- comparative

         if masculine == "exterus" then
            attachEndings("extrēm",adjectiveEndings_us_a_um) -- superlative
            generateAdverb3("extrēmus") -- adverb of superlative
         elseif masculine == "īnferus" then
            attachEndings("īnfim",adjectiveEndings_us_a_um) -- first superlative
            attachEndings("īm",adjectiveEndings_us_a_um) -- second superlative
            generateAdverb3("īnfimus") -- adverb of first superlative
            generateAdverb3("īmus") -- adverb of second superlative
         elseif masculine == "posterus" then
            attachEndings("postrēm",adjectiveEndings_us_a_um) -- first superlative
            attachEndings("postum",adjectiveEndings_us_a_um) -- second superlative
            generateAdverb3("postrēmus") -- adverb of first superlative
            generateAdverb3("postumus") -- adverb of second superlative
         elseif masculine == "superus" then
            attachEndings("suprēm",adjectiveEndings_us_a_um) -- superlative
            generateAdverb3("suprēmus") -- adverb of superlative
         else
            attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
              generateAdverb3(root.."issimus") -- adverb of superlative
         end
      end

   -- adjectives of the first and second declension ending in "r/ra/rum"
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ra") then
      attachEndings(masculine,adjectiveEndings_ior_ius) -- comparative
      if masculine == "exter" then
         attachEndings("extrēm",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3("extrēmus") -- adverb of superlative
      else
         attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(masculine.."rimus") -- adverb of superlative
      end

   -- adjectives of the first and second declension ending in "er/ra/rum"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine)
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ra") then
      root = string.sub(feminine,1,-2)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative

   -- adjectives of the third declension ending in "er/ris/re"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ris") then
      root = string.sub(feminine,1,-3)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative

   -- adjectives of the third declension ending in "r/ris/re" ("celer")
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 2
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ris") then
      attachEndings(masculine,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative
   end
end

-- generate adverb of adjectives with three endings
function generateAdverb3(masculine,feminine)
   if masculine == "bonus" then
      addForm("bene")
   elseif masculine == "citus" then
      addForm("cito") -- short o
   elseif masculine == "māgnus" then
      addForm("magis")
      addForm("mage")
   elseif masculine == "parvus" then
      addForm("parum")
   elseif masculine == "rārus" then
      -- adverbs are "rārō" (= ablative) and "rārenter"
      addForm("rārenter")
   elseif adjectivesWithDeclensedFormAdverb[masculine] then
      -- no additional form required
   elseif endsIn(masculine,"r") then
      if endsIn(feminine,"ra") then
         addForm(string.sub(feminine,1,-2).."ē")
         -- e.g. "miserē"/"pulchrē"
      else
         addForm(string.sub(feminine,1,-3).."iter")
         -- e.g. "ācriter"/"celeriter"
      end
   else
      addForm(string.sub(masculine,1,-3).."ē")
   end
end

-- generate positive forms of adjectives with two endings
function generatePositiveForms2(adjective)
   if adjective == "complūrēs" or adjective == "com-plūrēs" then
      attachEndings("complūr",adjectiveEndings_es_ium)
      addForm("complūra") -- alternative neuter plural

   -- adjectives of the third declension ending in "is/e"
   elseif string.len(adjective) > 4 and endsIn(adjective,"is") then
      root = string.sub(adjective,1,-3)
      if vowels[string.sub(root,-1)] and string.sub(root,-2) ~= "qu" and string.sub(root,-3) ~= "ngu" then
         attachEndings(root,adjectiveEndings_is_e_afterFullVowel)
      else
         attachEndings(root,adjectiveEndings_is_e)
      end

   -- adjectives of the third declension ending in "ior/ius"
   elseif string.len(adjective) > 3 and endsIn(adjective,"ior") then
      root = string.sub(adjective,1,-4)
      attachEndings(root,adjectiveEndings_ior_ius)

   else
      invalidField(adjective)
   end
end

-- generate comparative and superlative forms of adjectives with two endings
function generateComparativeAndSuperlative2(adjective)
   -- adjectives of the third declension ending in "is/e"
   if string.len(adjective) > 4 and endsIn(adjective,"is") then
      root = string.sub(adjective,1,-3)
      if vowels[string.sub(root,-1)] and string.sub(root,-2) ~= "qu" and string.sub(root,-3) ~= "ngu" then
         attachEndings(root,adjectiveEndings_jor_jus) -- comparative (e.g. "tenujor")
      else
         attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      end
      if adjectivesSuperlative_limus[adjective] then
         attachEndings(root.."lim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."limus") -- adverb of superlative
      else
         attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."issimus") -- adverb of superlative
      end

   -- comparatives of the third declension ending in "ior/ius"
   elseif string.len(adjective) > 3 and endsIn(adjective,"ior") then
      if adjective == "dēterior" then
         attachEndings("dēterrim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3("dēterrimus") -- adverb of superlative
      elseif adjective == "propior" then
         attachEndings("proxim",adjectiveEndings_us_a_um) -- first superlative
         attachEndings("proxum",adjectiveEndings_us_a_um) -- second superlative
         generateAdverb3("proximus") -- adverb of first superlative
         generateAdverb3("proxumus") -- adverb of second superlative
      else
         root = string.sub(adjective,1,-4)
         attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."issimus") -- adverb of superlative
      end
   end
end

-- generate adverb of adjectives with two endings
function generateAdverb2(adjective)
   if adjective == "difficilis" then
      addForm("difficulter")
   elseif adjective == "facilis" then
      -- adverb is "facile" (= neuter)
   elseif endsIn(adjective,"ior") then
      -- adverb ends in "-ius" (= neuter)
   elseif endsIn(adjective,"is") then
      addForm(string.sub(adjective,1,-2).."ter")
   end
end

-- generate positive forms of adjectives with one ending
function generatePositiveForms1(nominative,genitive)
   -- adjectives of the third declension ending in "āns"
   if endsIn(nominative,"āns") then
      if genitive == nil then
         root = utf8substring(nominative,1,-4)
         attachEndings(root,adjectiveEndings_ans_antis)
      else
         invalidLine()
      end

   -- adjectives of the third declension ending in "ēns"
   elseif endsIn(nominative,"ēns") then
      if genitive == nil then
         root = utf8substring(nominative,1,-4)
         attachEndings(root,adjectiveEndings_ens_entis)
      else
         invalidLine()
      end

   -- adjectives endings in "ās"/"ātis" or "īs"/"ītis"
   elseif endsIn(nominative,"ās") or endsIn(nominative,"īs") then
      if genitive and endsIn(genitive,"tis")
      and utf8substring(genitive,1,-4) == utf8substring(nominative,1,-2) then
         addForm(utf8substring(nominative,1,-2)..combiningAcute.."s") -- nominative sg. with accent
         root = utf8substring(genitive,1,-3)
         attachEndings(root,adjectiveEndings_i_ium)
      else
         invalidField(genitive)
      end
   -- adjectives with consonantal declension
   elseif adjectivesConsonantalDeclension[nominative] == true then
      if genitive and beginWithSameLetter(nominative,genitive)
         and endsIn(genitive,"is") then
         addForm(nominative)
         root = string.sub(genitive,1,-3)
         attachEndings(root,adjectiveEndings_e_um)
      else
         invalidLine()
      end

   -- plūs
   elseif nominative == "plūs" and genitive == "plūris" then
      addForm("plūs") -- nominative/accusative
      addForm("plūris") -- genitive
      addForm("plūre") -- ablative (dative is missing)
      attachEndings("plūr",adjectiveEndings_es_ium) -- plural forms
      addForm("plūra") -- alternative neuter plural

   -- adjectives with abl. sing. ending in "-ī", but gen. pl. ending in "-um"
   elseif (nominative == "in-ops" and genitive == "in-opis") or
   (nominative == "memor" and genitive == "memoris") or
   (nominative == "vigil" and genitive == "vigilis") then
      addForm(nominative)
      root = string.sub(genitive,1,-3)
      attachEndings(root,adjectiveEndings_i_um)

   -- adjectives with ī declension
   else
      if genitive and utf8.len(genitive) >= utf8.len(nominative)
      and beginWithSameLetter(nominative,genitive)
      and endsIn(genitive,"is") then
         addForm(nominative)
         root = string.sub(genitive,1,-3)
         attachEndings(root,adjectiveEndings_i_ium)
      else
         invalidLine()
      end
   end
end

-- generate comparative and superlative forms of adjectives with one ending
function generateComparativeAndSuperlative1(nominative,genitive)
   if nominative == "vetus" and genitive == "veteris" then
      attachEndings("vetust",adjectiveEndings_ior_ius) -- comparative
      attachEndings("veterrim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3("veterrimus") -- adverb of superlative

   -- adjectives of the third declension ending in "āns"
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"āns") then
      root = utf8substring(nominative,1,-4).."ant"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- adjectives of the third declension ending in "ēns"
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"ēns") then
      root = utf8substring(nominative,1,-4).."ent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- plūs
   elseif nominative == "plūs" and genitive == "plūris" then
      attachEndings("plūrim",adjectiveEndings_us_a_um) -- superlative
      attachEndings("plūrum",adjectiveEndings_us_a_um) -- superlative
      -- adverb is "plūrimum" (= accusative)

   -- regular adjectives with genitive ending in "is"
   else
      root = string.sub(genitive,1,-3)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      if string.sub(nominative,-2,-1) == "er" then
         attachEndings(nominative.."rim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."rimus") -- adverb of superlative
      else
         attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."issimus") -- adverb of superlative
      end
      if nominative == "juvenis" and genitive == nominative then
         attachEndings("jūn",adjectiveEndings_ior_ius) -- second comparative
      end
   end
end


-- generate adverb of adjectives with one ending
function generateAdverb1(nominative,genitive)
   if nominative == "audāx" then
      addForm("audāciter")
      addForm("audācter")
   elseif nominative == "soll-ers" then
      addForm("soll-erter")
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"āns") then
      addForm(utf8substring(nominative,1,-4).."anter")
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"ēns") then
      addForm(utf8substring(nominative,1,-4).."enter")
   else
      addForm(string.sub(genitive,1,-2).."ter")
   end
end


-- read input line by line
linecount = 0
for line in io.lines() do
   linecount = linecount + 1
   wholeLine = line
   i = string.find(line,",")

   if i == nil then
      firstField = line
      secondField = nil
      thirdField = nil
      fourthField = nil
   else
      firstField = string.sub(line,1,i-1)
      line = string.sub(line,i+1,-1)
      i = string.find(line,",")

      if i == nil then
         secondField = line
         thirdField = nil
         fourthField = nil
      else
         secondField = string.sub(line,1,i-1)
         line = string.sub(line,i+1,-1)
         i = string.find(line,",")

         if i == nil then
            thirdField = line
            fourthField = nil
         else
            thirdField = string.sub(line,1,i-1)
            if thirdField == "" then
               thirdField = nil
            end
            fourthField = string.sub(line,i+1,-1)
         end
      end
   end

   -- uninflectable word
   if secondField == nil and thirdField == nil and fourthField == nil then
      addForm(firstField)

   -- verb of the first conjugation
   elseif secondField == "1" then
      if utf8.len(firstField) < 2 then
         invalidField(firstField)
      elseif firstField == "dō" or utf8.len(firstField) > 3
         and endsIn(firstField,"-dō") then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,presentStemEndings_dare)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == root.."edī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if fourthField == root.."atum" then
               addSupineStemForms(fourthField)
            else
               invalidField(fourthField)
            end
         end
      elseif endsIn(firstField,"ō") then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,presentStemEndingsActive1)
         attachEndings(root,presentStemEndingsPassive1)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == root.."āvī" then
               invalidField(thirdField)
            else
               addPerfectStemForms(thirdField)
            end
         else
            addPerfectStemForms(root.."āvī")
         end
         if fourthField then
            if fourthField == root.."ātum" then
               invalidField(fourthField)
            else
               addSupineStemForms(fourthField)
            end
         else
            addSupineStemForms(root.."ātum")
         end
      elseif string.sub(firstField,-2) == "or" then
         root = string.sub(firstField,1,-3)
         attachEndings(root,presentStemEndingsPassive1)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == root.."ātus" then
               invalidField(thirdField)
            elseif endsIn(thirdField,"us") then
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               invalidField(thirdField)
            end
         else
            addSupineStemForms(root.."ātum")
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- verb of the second conjugation
   elseif secondField == "2" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif endsIn(firstField,"eō") then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,presentStemEndingsActive2)
         attachEndings(root,presentStemEndingsPassive2)
         attachEndings(root,participlePresentActiveEndingsE)
         attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if endsIn(thirdField,"us") then -- semideponent verb
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               addPerfectStemForms(thirdField)
            end
         end
         if fourthField then
            addSupineStemForms(fourthField)
         end
      elseif endsIn(firstField,"et") then -- impersonal verb
         root = string.sub(firstField,1,-3)
         addForm(root.."et") -- present indicative
         addForm(root.."at") -- present subjunctive
         addForm(root.."ēbat") -- imperfect indicative
         addForm(root.."ēret") -- imperfect subjunctive
         addForm(root.."ēbit") -- future
         addForm(root.."ēre") -- infinitive present
         if thirdField then
            if endsIn(thirdField,"um") then -- semideponent verb
               addSupineStemForms(thirdField)
            else
               addPerfectStemFormsImpersonal(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      elseif endsIn(firstField,"eor") then -- deponent verb
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive2)
         attachEndings(root,participlePresentActiveEndingsE)
         attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if endsIn(thirdField,"us") then
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- verb of the third conjugation
   elseif secondField == "3" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif endsIn(firstField,"ō") then
         local c = utf8substring(firstField,-2,-2)
         if not consonants[c] and c ~= "u" then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            -- active forms
            attachEndings(root,presentStemEndingsActive3)
            -- second person singular of the imperative present
            if firstField == "dīcō" or firstField == "dūcō" then
               addForm(root) -- imperative "dīc"/"dūc"
            elseif utf8.len(firstField) > 5
            and (endsIn(firstField,"-dīcō") or endsIn(firstField,"-dūcō")) then
               addForm(utf8substring(firstField,1,-3)..combiningAcute.."c") -- imperative, e.g. "ab-dū́c"
            else
               addForm(root.."e") -- imperative, e.g. "mitte"
            end
            -- special forms of "edō"/"edere"/"ēsse" and compounds
            if firstField == "edō" or endsIn(firstField,"-edō") then
               local reducedRoot
               if firstField == "edō" then
                  reducedRoot = ""
               else
                  reducedRoot = utf8substring(firstField,1,-4)
               end
               addForm(reducedRoot.."ēs") -- 2nd person sg. present indicative/imperative active
               addForm(reducedRoot.."ēst") -- 3rd person sg. present indicative active
               addForm(reducedRoot.."ēstis") -- 2nd person pl. present indicative active
               attachEndings(root,presentEndingsSubjunctiveActive_i) -- present subjunctive active
               addForm(reducedRoot.."ēste") -- 2nd person pl. present imperative active
               addForm(reducedRoot.."ēsse") -- infinitive present
               attachEndings(reducedRoot.."ēss",imperfectEndingsSubjunctiveActiveWithout_r)
               addForm(reducedRoot.."ēstō") -- imperative sg. future
               addForm(reducedRoot.."ēstōte") -- imperative pl. future
               addForm(reducedRoot.."ēstur") -- 3rd person sg. present indicative passive
               addForm(reducedRoot.."ēssētur") -- 3rd person sg. imperfect subjunctive passive
            end
            -- passive forms
            attachEndings(root,presentStemEndingsPassive3)
            attachEndings(root,participlePresentActiveEndingsE)
            attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
            if thirdField then
               if endsIn(thirdField,"us") then -- semideponent verb
                  addSupineStemForms(string.sub(thirdField,1,-2).."m")
               else
                  addPerfectStemForms(thirdField)
               end
            end
            if fourthField then
               addSupineStemForms(fourthField)
            end
         end
      elseif endsIn(firstField,"it") then -- impersonal verb
         root = string.sub(firstField,1,-3)
         addForm(root.."it") -- present indicative
         addForm(root.."at") -- present subjunctive
         addForm(root.."ēbat") -- imperfect indicative
         addForm(root.."eret") -- imperfect subjunctive
         addForm(root.."et") -- future
         addForm(root.."ere") -- infinitive present
         if thirdField then
            addPerfectStemFormsImpersonal(thirdField)
         end
         if fourthField then
            invalidLine()
         end
      elseif endsIn(firstField,"or") then -- deponent verb
         local c = utf8substring(firstField,-3,-3)
         if not consonants[c] and c ~= "u" then
            invalidLine()
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,presentStemEndingsPassive3)
            attachEndings(root,participlePresentActiveEndingsE)
            attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
         end
         if thirdField then
            if endsIn(thirdField,"us") then
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- verb of the mixed third conjugation
   elseif secondField == "3M" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif endsIn(firstField,"iō") then
         if endsIn(firstField,"-jiciō") then -- compound of "jaciō"
            root = utf8substring(firstField,1,-7).."~jic"
         else
            root = utf8substring(firstField,1,-3)
         end
         -- active forms
         attachEndings(root,presentStemEndingsActive3M)
         -- second person singular of the imperative present
         if firstField == "cale-faciō" then
            addForm("cal-face")
         elseif firstField == "faciō" or utf8.len(firstField) > 6 and
            endsIn(firstField,"-faciō") then
            addForm(root) -- "fac"
         else
            addForm(root.."e") -- e.g. "cape"
         end
         attachEndings(root,presentStemEndingsPassive3M)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            addPerfectStemForms(thirdField)
         end
         if fourthField then
            addSupineStemForms(fourthField)
         end
      elseif string.sub(firstField,-3) == "ior" then
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive3M)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if endsIn(thirdField,"us") then
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- verb of the fourth conjugation
   elseif secondField == "4" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif endsIn(firstField,"iō") then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,presentStemEndingsActive4)
         attachEndings(root,presentStemEndingsPassive4)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == root.."īvī" then
               invalidField(thirdField)
            else
               addPerfectStemForms(thirdField)
            end
         else
            addPerfectStemForms(root.."īvī")
         end
         if fourthField then
            if fourthField == root.."ītum" then
               invalidField(fourthField)
            else
               addSupineStemForms(fourthField)
            end
         else
            addSupineStemForms(root.."ītum")
         end
      elseif string.sub(firstField,-3) == "ior" then
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive4)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == root.."ītus" then
               invalidField(thirdField)
            elseif endsIn(thirdField,"us") then
               addSupineStemForms(string.sub(thirdField,1,-2).."m")
            else
               invalidField(thirdField)
            end
         else
            addSupineStemForms(root.."ītum")
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- verb with perfect forms only
   elseif secondField == "VP" then
      if endsIn(firstField,"ī") then
         addPerfectStemForms(firstField)
         if firstField == "meminī" then
            addForm("mementō")
            addForm("mementōte")
         end
         if thirdField then
            addSupineStemForms(thirdField)
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidField(firstField)
      end

   -- irregular verb
   elseif secondField == "VI" then
      if firstField == "ajō" then
         addForm("ajō") -- 1st person sg. indicative present
         addForm("aīs") -- 2nd person sg. indicative present
         addForm("aī́n") -- < "aīs" + "ne"
         addForm("ait") -- 3rd person sg. indicative present
         addForm("ajunt") -- 3rd person pl. indicative present
         addForm("ajuntur") -- 3rd person pl. indicative present passive
         attachEndings("ajē",imperfectEndingsIndicativeActive) -- imperfect indicative
         addForm("aības") -- 2nd person sg. ind. imperfect
         addForm("aībat") -- 3rd person sg. ind. imperfect
         addForm("ajam") -- 1st person sg. subjunctive present
         addForm("ajās") -- 2nd person sg. subjunctive present
         addForm("ajat") -- 3rd person sg. subjunctive present
         addForm("ajant") -- 3rd person pl. subjunctive present
         addForm("ajeret") -- 3rd person sg. subjunctive imperfect
         addForm("ai") -- imperative present
         addForm("aje") -- imperative present
         addForm("ajere") -- infinitive present
         addForm("aistī") -- 2nd person sg. ind. perfect
         addForm("ajērunt") -- 3rd person pl. ind. perfect
         addForm("aisse") -- infinitive perfect
         attachEndings("aj",participlePresentActiveEndingsE) -- participle
         if thirdField or fourthField then
            invalidLine()
         end
      elseif firstField == "eō" then
         attachEndings("",presentStemForms_ire)
         attachEndings("",participlePresentActiveForms_ire)
         attachEndings("eund",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == "iī" then
               attachEndings("",perfectStemForms_ire)
            elseif thirdField == "īvī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if fourthField == "itum" then
               addSupineStemForms(fourthField)
            else
               invalidField(fourthField)
            end
         end
      elseif endsIn(firstField,"-eō") or firstField == "queō" or firstField == "ne-queō" then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,presentStemForms_ire)
         attachEndings(root,participlePresentActiveForms_ire)
         attachEndings(root.."eund",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if endsIn(thirdField,"iī") then
               attachEndings(utf8substring(thirdField,1,-3),perfectStemForms_ire)
            elseif endsIn(thirdField,"īvī") then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if endsIn(fourthField,"itum") then
               addSupineStemForms(fourthField)
            else
               invalidField(fourthField)
            end
         end
      elseif firstField == "ferō" then
         attachEndings("",presentStemForms_ferre)
         attachEndings("fer",participlePresentActiveEndingsE)
         attachEndings("ferend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if thirdField == "tulī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if fourthField == "lātum" then
               addSupineStemForms(fourthField)
            else
               invalidField(fourthField)
            end
         end
      elseif endsIn(firstField,"ferō") then
         root = utf8substring(firstField,1,-5)
         attachEndings(root,presentStemForms_ferre)
         attachEndings(root.."fer",participlePresentActiveEndingsE)
         attachEndings(root.."ferend",adjectiveEndings_us_a_um) -- gerundivum
         if thirdField then
            if endsIn(thirdField,"tulī") then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if endsIn(fourthField,"lātum") then
               addSupineStemForms(fourthField)
            else
               invalidField(fourthField)
            end
         end
      elseif firstField == "fīō" or endsIn(firstField,"-fīō") then
         if firstField == "fīō" then
            stem = ""
         else
            stem = utf8substring(firstField,1,-4)
         end
         addForm(stem.."fīō") -- 1st person sg. present indicative
         addForm(stem.."fīs") -- 2nd person sg. present indicative
         addForm(stem.."fit") -- 3rd person sg. present indicative
         addForm(stem.."fīmus") -- 1st person pl. present indicative
         addForm(stem.."fītis") -- 2nd person pl. present indicative
         addForm(stem.."fīunt") -- 3rd person pl. present indicative
         attachEndings(stem.."fī",presentEndingsSubjunctiveActive_a) -- present subjunctive
         addForm(stem.."fī") -- imperative present sg.
         addForm(stem.."fīte") -- imperative present pl.
         addForm(stem.."fierī") -- infinitive present
         attachEndings(stem.."fīē",imperfectEndingsIndicativeActive) -- imperfect indicative
         attachEndings(stem.."fie",imperfectEndingsSubjunctiveActive) -- imperfect subjunctive
         attachEndings(stem.."fī",futureEndingsActive_a_e) -- future
         if thirdField or fourthField then
            invalidLine()
         end
      elseif firstField == "in-quam" then
         addForm("in-quam") -- 1st person sg. present
         addForm("in-quiō") -- 1st person sg. present (late Latin)
         addForm("in-quīs") -- 2nd person sg. present
         addForm("in-quit") -- 3rd person sg. present
         addForm("in-quiat") -- 3rd person sg. present subjunctive
         addForm("in-quītis") -- 2nd person pl. present
         addForm("in-quiunt") -- 3rd person pl. present
         addForm("in-que") -- imperative
         addForm("in-quiēbat") -- 3rd person sg. imperfect
         addForm("in-quiēs") -- 2nd person sg. future
         addForm("in-quiet") -- 3rd person sg. future
         addForm("in-quiī") -- 1st person sg. perfect
         addForm("in-quī") -- 1st person sg. perfect
         addForm("in-quistī") -- 1st person sg. perfect
         attachEndings("in-qui",participlePresentActiveEndingsE)
         if thirdField or fourthField then
            invalidLine()
         end
      elseif firstField == "mālō" then
         addForm("mālō") -- 1st person sg. present indicative
         addForm("māvīs") -- 2nd person sg. present indicative
         addForm("māvult") -- 3rd person sg. present indicative
         addForm("mālumus") -- 1st person pl. present indicative
         addForm("māvultis") -- 2nd person pl. present indicative
         addForm("mālunt") -- 3rd person pl. present indicative
         attachEndings("māl",presentEndingsSubjunctiveActive_i) -- present subjunctive
         addForm("mālle") -- infinitive present
         attachEndings("mālē",imperfectEndingsIndicativeActive) -- imperfect indicative
         attachEndings("māll",imperfectEndingsSubjunctiveActiveWithout_r) -- imperfect subjunctive
         attachEndings("māl",futureEndingsActive_a_e) -- future
         if thirdField then
            if thirdField == "māluī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      elseif firstField == "nōlō" then
         addForm("nōlō") -- 1st person sg. present indicative
         addForm("nōlumus") -- 1st person pl. present indicative
         addForm("nōlunt") -- 3rd person pl. present indicative
         attachEndings("nōl",presentEndingsSubjunctiveActive_i) -- present subjunctive
         addForm("nōlī") -- imperative present sg.
         addForm("nōlīte") -- imperative present pl.
         addForm("nōlle") -- infinitive present
         attachEndings("nōlē",imperfectEndingsIndicativeActive) -- imperfect indicative
         attachEndings("nōll",imperfectEndingsSubjunctiveActiveWithout_r) -- imperfect subjunctive
         attachEndings("nōl",futureEndingsActive_a_e) -- future
         addForm("nōlītō") -- imperative future sg.
         addForm("nōlītōte") -- imperative future pl.
         if thirdField then
            if thirdField == "nōluī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      elseif firstField == "possum" then
         attachEndings("",presentStemForms_posse)
         if thirdField then
            if thirdField == "potuī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      elseif firstField == "quæsō" then
         addForm("quæsō") -- 1st person sg. indicative present
         addForm("quæsumus") -- 1st person pl. indicative present
         if thirdField or fourthField then
            invalidLine()
         end
      elseif firstField == "sum" then
         attachEndings("",presentStemForms_esse)
         attachEndings("",participlePresentActiveEndingsE) -- participle: ēns/entis
         if thirdField then
            if thirdField == "fuī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if fourthField == "futūrus" then
               attachEndings(string.sub(fourthField,1,-3),adjectiveEndings_us_a_um)
            else
               invalidField(fourthField)
            end
         end
      elseif endsIn(firstField,"sum") then
         root = string.sub(firstField,1,-4)
         if root == "as" then -- assum/ad-esse
            attachEndingsVowel_f_Consonant("ad-","af","as",presentStemForms_esse)
         elseif root == "dē-" then -- dē-sum/de-esse
            attachEndingsVowelConsonant("de-","dē-",presentStemForms_esse)
         elseif root == "prō-" then -- prō-sum/prōd-esse
            attachEndingsVowelConsonant("prōd-","prō-",presentStemForms_esse)
         else
            attachEndings(root,presentStemForms_esse)
         end
         attachEndings(root.."s",participlePresentActiveEndingsE) -- participle: -sēns/-sentis
         if thirdField then
            if endsIn(thirdField,"fuī") then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            if endsIn(fourthField,"futūrus") then
               attachEndings(string.sub(fourthField,1,-3),adjectiveEndings_us_a_um)
            else
               invalidField(fourthField)
            end
         end
      elseif firstField == "volō" then
         addForm("volō") -- 1st person sg. present indicative
         addForm("vīs") -- 2nd person sg. present indicative
         addForm("vult") -- 3rd person sg. present indicative
         addForm("volumus") -- 1st person pl. present indicative
         addForm("vultis") -- 2nd person pl. present indicative
         addForm("volunt") -- 3rd person pl. present indicative
         attachEndings("vel",presentEndingsSubjunctiveActive_i) -- present subjunctive
         addForm("velle") -- infinitive present
         attachEndings("vol",participlePresentActiveEndingsE) -- present active participle
         attachEndings("volē",imperfectEndingsIndicativeActive) -- imperfect indicative
         attachEndings("voll",imperfectEndingsSubjunctiveActiveWithout_r) -- imperfect subjunctive
         attachEndings("vol",futureEndingsActive_a_e) -- future
         if thirdField then
            if thirdField == "voluī" then
               addPerfectStemForms(thirdField)
            else
               invalidField(thirdField)
            end
         end
         if fourthField then
            invalidLine()
         end
      else
         invalidLine()
      end

   -- noun of the first declension
   elseif secondField == "D1" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"a") then
         root = string.sub(firstField,1,-2)
         attachEndings(root,nounEndings1)
         if firstField == "dea" then
            addForm("deābus") -- alternative genitive plural
         elseif firstField == "fīlia" then
            addForm("fīliābus") -- alternative genitive plural
         end
      elseif endsIn(firstField,"ēs") then -- greek word
         root = utf8substring(firstField,1,-3)
         attachEndings(root,nounEndings1_greek)
      elseif endsIn(firstField,"æ") then -- plurale tantum
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            attachEndings(root,nounEndings1_ae_arum)
         end
      else
         invalidField(firstField)
      end

   -- masculine/feminine noun of the second declension
   elseif secondField == "D2" then
      if fourthField then
         invalidLine()
      elseif endsIn(firstField,"us") then
         if thirdField then
            invalidLine()
         elseif firstField == "deus" then
            addForm("de|us") -- nominative/vocative sg.
            addForm("deī") -- genitive sg./nominative pl.
            addForm("deō") -- dative/ablative sg.
            addForm("de|um") -- accusative sg.
            addForm("diī") -- nominative pl.
            addForm("dī") -- nominative pl.
            addForm("deōrum") -- genitive pl.
            addForm("deīs") -- dative/ablative pl.
            addForm("diīs") -- dative/ablative pl.
            addForm("dīs") -- dative/ablative pl.
            addForm("deōs") -- accusative pl.
         elseif endsIn(firstField,"ius") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_ius)
         elseif endsIn(firstField,"jus") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_jus)
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_us)
            if firstField == "locus" then
               addForm("loca") -- alternative nom./acc. pl.
            end
         end
      elseif endsIn(firstField,"r") then
         if thirdField and utf8substring(thirdField,1,-2) == firstField
         and endsIn(thirdField,"ī") then -- e.g. "puer"
            root = string.sub(firstField,1,-2)
            attachEndings(root,nounEndings2_r_ri)
            if firstField == "vesper" then
               addForm("vespere") -- alternative abl. sg.
            end
         elseif thirdField
         and utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"rī") then -- e.g. "ager"
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_er_ri)
         else
            invalidLine()
         end
      elseif endsIn(firstField,"ī") then -- plurale tantum
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            attachEndings(root,nounEndings2_i_orum)
         end
      else
         invalidField(firstField)
      end

   -- neuter noun of the second declension
   elseif secondField == "D2N" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"um") then
         if endsIn(firstField,"ium") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_ium)
         elseif endsIn(firstField,"jum") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_jum)
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_um)
         end
      elseif endsIn(firstField,"us") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings2_us_neuter)
         if firstField == "vulgus" then
            addForm("vulgum") -- alternative accusative sg.
         elseif firstField == "volgus" then
            addForm("volgum") -- alternative accusative sg.
         end
      elseif endsIn(firstField,"a") then -- plurale tantum (neuter)
         root = string.sub(firstField,1,-2)
         attachEndings(root,nounEndings2_a_orum)
      end

   -- masculine/feminine noun of the third declension
   elseif secondField == "D3" then
      if string.len(firstField) < 2 or fourthField then
         invalidLine()
      -- noun ending in "-is" (with short i)
      elseif endsIn(firstField,"is") then
         if thirdField then
            -- i declension
            if string.sub(thirdField,1,-2) == string.sub(firstField,1,-2)
            and endsIn(thirdField,"im") then
               root = string.sub(firstField,1,-3)
               attachEndings(root,nounEndings3_i)
            -- consonantal declension
            elseif beginWithSameLetter(firstField,thirdField)
            and endsIn(thirdField,"is") then
               root = string.sub(thirdField,1,-3)
               attachEndings(root,nounEndings3_consonantal)
            else
               invalidField(thirdField)
            end
         -- consonantal declension
         elseif firstField == "canis" or firstField == "juvenis" then
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_consonantal)
         -- mixed or consonantal declension
         elseif firstField == "mēnsis" then
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         -- mixed declension
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_mixed)
         end
      -- noun ending in "-īs" (with long i)
      elseif endsIn(firstField,"īs") then
         -- vīs/vim/vī/vīrēs
         if firstField == "vīs" and thirdField == "vim" then
            addForm("vīs") -- nominative sg.
            addForm("vim") -- genitive sg.
            addForm("vī") -- ablative sg.
            root = "vīr"
            attachEndings(root,nounEndings3_i_plural)
         elseif not thirdField or utf8.len(thirdField) < 5 then
            invalidLine()
         -- "-īs/-ītis": mixed declension
         elseif utf8substring(thirdField,1,-5) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"ītis") then -- e.g. "Samnīs"
            root = utf8substring(thirdField,1,-3)
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         else
            invalidField(thirdField)
         end
      -- noun ending in "-ēs"
      elseif endsIn(firstField,"ēs") then
         if not thirdField or utf8.len(thirdField) < 3 then
            invalidLine()
         -- singular, genitive ending in "-is"
         elseif utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"is") then
            -- consonantal declension
            if firstField == "sēdēs" then
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_consonantal)
            -- mixed or consonantal declension
            elseif firstField == "vātēs" then
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_mixedAndConsonantal)
            -- mixed declension
            else
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_mixed)
            end
         -- singular, genitive ending in "-ētis"
         elseif utf8substring(thirdField,1,-5) == utf8substring(firstField,1,-3)
         and (endsIn(thirdField,"ētis") or endsIn(thirdField,"etis")) then
            addForm(firstField) -- nominative sg.
            root = utf8substring(thirdField,1,-3)
            attachEndings(root,nounEndings3_consonantal)
         -- plural, genitive ending in "-ium" (i declension)
         elseif utf8substring(thirdField,1,-4) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"ium") then
            root = utf8substring(firstField,1,-3)
            attachEndings(root,nounEndings3_i_plural)
         -- plural, genitive ending in "-um" (consonantal declension)
         elseif utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"um") then
            root = utf8substring(firstField,1,-3)
            attachEndings(root,nounEndings3_consonantalPlural)
         else
            invalidField(thirdField)
         end
      -- noun ending in "-dō" or "-gō"
      elseif endsIn(firstField,"dō") or endsIn(firstField,"gō") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2).."in"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-ēns"
      elseif endsIn(firstField,"ēns") then
         if thirdField then
            invalidLine()
         elseif firstField == "parēns" then -- mixed or consonantal declension
            root = "parent"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         else -- mixed declension
            root = utf8substring(firstField,1,-4).."ent"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         end
      -- noun ending in "-iō"
      elseif endsIn(firstField,"iō") then
         if thirdField then
            invalidLine()
         else
            root = firstField.."n"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-or"
      elseif endsIn(firstField,"or") then
         if thirdField then
            invalidLine()
         else
            root = string.sub(firstField,1,-3).."ōr"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-tās"
      elseif endsIn(firstField,"tās") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2).."t"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      elseif (endsIn(firstField,"ās") or endsIn(firstField,"īs")) and thirdField
      and endsIn(thirdField,"tis") and utf8substring(firstField,1,-2) == utf8substring(thirdField,1,-4) then
         root = utf8substring(thirdField,1,-3)
         if firstField == "abbās" then
            addForm(firstField) -- nominative sg.
         else
            addForm(utf8substring(firstField,1,-2)..combiningAcute.."s") -- nominative sg. with accent
         end
         if firstField == "optimās" then
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         else
            attachEndings(root,nounEndings3_consonantal)
         end
      elseif not thirdField or utf8.len(thirdField) < 4 then
         invalidLine()
      -- singular
      elseif endsIn(thirdField,"is") then
         root = string.sub(thirdField,1,-3)
         if firstField == "bōs" and thirdField == "bovis" then
            addForm("bōs") -- nominative sg.
            addForm("bovis") -- genitive sg.
            addForm("bovī") -- dative sg.
            addForm("bovem") -- accusative sg.
            addForm("bove") -- ablative sg.
            addForm("bovēs") -- nominative/accusative pl.
            addForm("bovum") -- genitive pl.
            addForm("boum") -- genitive pl.
            addForm("bōbus") -- dative/ablative pl.
            addForm("būbus") -- dative/ablative pl.
         -- mixed declension
         elseif (firstField == "faux" and thirdField == "faucis")
         or (firstField == "līs" and thirdField == "lītis")
         or (firstField == "nix" and thirdField == "nivis")
         or endsInTwoConsonants(root) then
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         -- mixed or consonantal declension
         elseif (firstField == "fraus" and thirdField == "fraudis")
         or (firstField == "mūs" and thirdField == "mūris") then
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         -- consonantal declension
         else
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      else
         invalidLine()
      end

   -- neuter noun of the third declension
   elseif secondField == "D3N" then
      if string.len(firstField) < 2 or fourthField then
         invalidLine()
      -- pār
      elseif firstField == "pār" and thirdField == "paris" then
         root = "par"
         addForm(firstField) -- nominative/accusative sg.
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-e"
      elseif endsIn(firstField,"e") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 1
      and string.sub(thirdField,1,-3) == string.sub(firstField,1,-2)
      and endsIn(thirdField,"is") then
         root = string.sub(firstField,1,-2)
         addForm(firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-al"
      elseif endsIn(firstField,"al") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 2
      and utf8substring(thirdField,1,-5) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"ālis") then
         root = string.sub(thirdField,1,-3)
         addForm(firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-ar"
      elseif endsIn(firstField,"ar") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 2
      and utf8substring(thirdField,1,-5) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"āris") then
         root = string.sub(thirdField,1,-3)
         addForm(firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- plurale tantum ending in "-ia"
      elseif endsIn(firstField,"ia") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 1
      and utf8substring(thirdField,1,-4) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"ium") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings3_i_neuterPlural)
      -- neuter noun ending in "-men"
      elseif endsIn(firstField,"men") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-3).."in"
            addForm(firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      elseif not thirdField or utf8.len(thirdField) < 4 then
         invalidLine()
      -- singular
      elseif endsIn(thirdField,"is") then
         root = string.sub(thirdField,1,-3)
         if firstField == "vās" and thirdField == "vāsis" then
            addForm("vās") -- nominative/accusative sg.
            addForm("vāsis") -- genitive sg.
            addForm("vāsī") -- dative sg.
            addForm("vāse") -- ablative sg.
            addForm("vāsa") -- nominative/accusative pl.
            addForm("vāsōrum") -- genitive pl.
            addForm("vāsīs") -- dative/ablative pl.
         -- root ending in two or more consonants: mixed declension
         elseif endsInTwoConsonants(root) then
            addForm(firstField) -- nominative/accusative sg.
            attachEndings(root,nounEndings3_mixedNeuter)
         -- consonantal declension
         else
            addForm(firstField) -- nominative/accusative sg.
            attachEndings(root,nounEndings3_consonantalNeuter)
         end
      else
         invalidLine()
      end

   -- masculine/feminine noun of the fourth declension
   elseif secondField == "D4" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"us") then
         root = string.sub(firstField,1,-3)
         if firstField == "domus" then
            addForm("domus") -- nominative sg.
            addForm("domūs") -- gen. sg./nom. pl./acc. pl.
            addForm("domuī") -- dative sg.
            addForm("domum") -- accusative sg.
            addForm("domō") -- ablative sg.
            addForm("domī") -- locative sg.
            addForm("domōrum") -- genitive pl.
            addForm("domuum") -- genitive pl.
            addForm("domibus") -- dative/ablative pl.
            addForm("domōs") -- accusative pl.
         elseif firstField == "arcus" or firstField == "artus"
         or firstField == "tribus" then
            attachEndings(root,nounEndings4_us_ubus)
         else
            attachEndings(root,nounEndings4_us)
         end
      elseif endsIn(firstField,"ūs") then -- plurale tantum
         root = utf8substring(firstField,1,-3)
         attachEndings(root,nounEndings4_us_plural)
      else
         invalidField(firstField)
      end

   -- neuter noun of the fourth declension
   elseif secondField == "D4N" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"ū") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings4_u)
      else
         invalidField(firstField)
      end

   -- masculine/feminine noun of the fifth declension
   elseif secondField == "D5" then
      if utf8.len(firstField) < 3 or thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"ēs") then
         root = utf8substring(firstField,1,-3)
         if vowels[utf8substring(firstField,-3,-3)] then
            attachEndings(root,nounEndings5_afterVowel)
         else
            attachEndings(root,nounEndings5)
         end
      else
         invalidField(firstField)
      end

   -- adjective with three endings with comparison
   elseif secondField == "AC3" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms3(firstField,thirdField)
         generateAdverb3(firstField,thirdField)
         generateComparativeAndSuperlative3(firstField,thirdField)
      end

   -- adjective with two endings with comparison
   elseif secondField == "AC2" then
      if thirdField or fourthField then
         invalidLine()
      else
         generatePositiveForms2(firstField)
         generateAdverb2(firstField)
         generateComparativeAndSuperlative2(firstField)
      end

   -- adjective with one ending with comparison
   elseif secondField == "AC1" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms1(firstField,thirdField)
         generateAdverb1(firstField,thirdField)
         generateComparativeAndSuperlative1(firstField,thirdField)
      end

   -- adjective with three endings without comparison
   elseif secondField == "AI3" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms3(firstField,thirdField)
         generateAdverb3(firstField,thirdField)
      end

   -- adjective with two endings without comparison
   elseif secondField == "AI2" then
      if thirdField or fourthField then
         invalidLine()
      else
         generatePositiveForms2(firstField)
         generateAdverb2(firstField)
      end

   -- adjective with one ending without comparison
   elseif secondField == "AI1" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms1(firstField,thirdField)
         generateAdverb1(firstField,thirdField)
      end

   -- pronoun
   elseif secondField == "P" then
      if thirdField or fourthField then
         invalidLine()
      elseif firstField == "ali-quantus" then
         attachEndings("ali-quant",adjectiveEndings_us_a_um_withoutVocative)
      elseif firstField == "ali-quī" then
         attachEndings("ali-",pronounForms_qui_quae_quod)
         addForm("qua") -- nominative sg. fem./nom./acc. pl. neuter
      elseif firstField == "ali-quis" then
         attachEndings("ali-",pronounForms_quis_quid)
      elseif firstField == "alius" then
         addForm("alius") -- nominative sg.
         addForm("alia") -- nominative sg./nom./acc. pl.
         addForm("aliud") -- nominative/accusative sg.
         addForm("aliī") -- dative sg./nominative pl.
         addForm("alium") -- accusative sg.
         addForm("aliam") -- accusative sg.
         addForm("aliō") -- ablative sg.
         addForm("aliā") -- ablative sg.
         addForm("aliæ") -- nominative pl.
         addForm("aliōrum") -- genitive pl.
         addForm("aliārum") -- genitive pl.
         addForm("aliīs") -- dative/ablative pl.
         addForm("aliōs") -- accusative pl.
         addForm("aliās") -- accusative pl.
      elseif firstField == "alter" then
         attachEndings("alte",adjectiveEndings_r_ra_rum)
         addForm("alterīus") -- genitive sg.
      elseif firstField == "alter-uter" then
         attachEndings("alter-",pronounForms_uter_utra_utrum)
      elseif firstField == "ambō" then
         addForm("ambō") -- nominative
         attachEndings("amb",pronounEndings_o_ae)
      elseif firstField == "ego" then
         addForm("ego") -- nominative
         addForm("egomet") -- nominative
         addForm("egō") -- nominative
         addForm("egōmet") -- nominative
         addForm("meī") -- genitive
         addForm("mihī") -- dative
         addForm("mihīmet") -- dative
         addForm("mihīpte") -- dative
         addForm("mihi") -- dative
         addForm("mihimet") -- dative
         addForm("mihipte") -- dative
         addForm("mē") -- accusative/ablative
         addForm("mēd") -- accusative/ablative
         addForm("mēmet") -- accusative/ablative
         addForm("mēpte") -- accusative/ablative
         addForm("mē-cum") -- "cum" + ablative
      elseif firstField == "hic" then
         addForm("hic") -- nominative sg.
         addForm("hæc") -- nominative sg./nom./acc. pl.
         addForm("hoc") -- nom./acc. sg.
         addForm("hujus") -- genitive sg.
         addForm("hujusce") -- genitive sg.
         addForm("huic") -- dative sg.
         addForm("hunc") -- accusative sg.
         addForm("hanc") -- accusative sg.
         addForm("hōc") -- ablative sg.
         addForm("hāc") -- ablative sg.
         addForm("hīc") -- locative
         addForm("heic") -- locative
         addForm("hīce") -- locative
         addForm("hinc") -- adverb
         addForm("hūc") -- adverb
         addForm("hī") -- nominative pl.
         addForm("hæ") -- nominative pl.
         addForm("hōrum") -- genitive pl.
         addForm("hārum") -- genitive pl.
         addForm("hīs") -- dative/ablative pl.
         addForm("hīsce") -- dative/ablative pl.
         addForm("hōs") -- accusative pl.
         addForm("hōsce") -- accusative pl.
         addForm("hās") -- accusative pl.
         addForm("hāsce") -- accusative pl.
      elseif firstField == "īdem" then
         addForm("īdem") -- nominative sg./pl.
         addForm("eadem") -- nominative sg./pl./acc. pl.
         addForm("idem") -- nominative/accusative sg.
         addForm("ejusdem") -- genitive sg.
         addForm("eīdem") -- dative sg.
         addForm("eundem") -- accusative sg.
         addForm("eandem") -- accusative sg.
         addForm("eōdem") -- ablative sg.
         addForm("eādem") -- ablative sg.
         addForm("iīdem") -- nominative pl.
         addForm("eædem") -- nominative pl.
         addForm("eōrundem") -- genitive pl.
         addForm("eārundem") -- genitive pl.
         addForm("eīsdem") -- dative/ablative pl.
         addForm("iīsdem") -- dative/ablative pl.
         addForm("īsdem") -- dative/ablative pl.
         addForm("eōsdem") -- accusative pl.
         addForm("eāsdem") -- accusative pl.
      elseif firstField == "ille" then
         attachEndings("ill",pronounEndings_e_a_ud)
         addForm("illic") -- nominative sg.
         addForm("illice") -- nominative sg.
         addForm("illicine")
         addForm("illicinest")
         addForm("illuc") -- nom./acc. sg.
         addForm("illucce") -- nom./acc. sg.
         addForm("illīusce") -- genitive sg.
         addForm("illúnc") -- accusative sg.
         addForm("illánc") -- accusative sg.
         addForm("illancin") -- accusative sg.
         addForm("illāce") -- ablative sg.
         addForm("illæc") -- nominative pl.
         addForm("illīsce") -- dative/ablative pl.
         addForm("illōsce") -- accusative pl.
         addForm("illāsce") -- accusative pl.
         addForm("illā́c") -- adverb
         addForm("illī́c") -- adverb
         addForm("illim") -- adverb
         addForm("illínc") -- adverb
         addForm("illṓc") -- adverb
         addForm("illū́c") -- adverb
      elseif firstField == "ipse" then
         attachEndings("ips",adjectiveEndings_i_ae_a) -- plural
         addForm("ipse") -- nominative sg.
         addForm("ipsum") -- nominative/accusative sg.
         addForm("ipsīus") -- genitive sg.
         addForm("ipsam") -- accusative sg.
         addForm("ipsō") -- ablative sg.
         addForm("ipsā") -- ablative sg.
      elseif firstField == "is" then
         attachEndings("e",adjectiveEndings_i_ae_a) -- plural
         addForm("is") -- nominative sg.
         addForm("id") -- nominative sg.
         addForm("ejus") -- genitive sg.
         addForm("ei") -- dative sg. (besides "eī")
         addForm("eum") -- accusative sg.
         addForm("im") -- alternative accusative sg.
         addForm("eam") -- accusative sg.
         addForm("eō") -- ablative sg.
         addForm("eā") -- ablative sg.
         addForm("iī") -- nominative pl.
         addForm("ī") -- nominative pl.
         addForm("iīs") -- dative/ablative pl.
         addForm("īs") -- dative/ablative pl.
         addForm("sīs") -- alternative dative pl.
         addForm("ībus") -- alternative ablative pl.
      elseif firstField == "iste" then
         attachEndings("ist",pronounEndings_e_a_ud)
         addForm("istic") -- nominative sg.
         addForm("istice") -- nominative sg.
         addForm("istoc") -- nominative sg.
         addForm("istúnc") -- acc. sg.
         addForm("istánc") -- acc. sg.
         addForm("istuc") -- nom./acc. sg.
         addForm("istuce") -- nom./acc. sg.
         addForm("istucce") -- nom./acc. sg.
         addForm("istucine") -- nom./acc. sg.
         addForm("istamcine") -- nom./acc. sg.
         addForm("istius") -- genitive sg. (besides "istīus")
         addForm("istīusce") -- genitive sg.
         addForm("istiusce") -- genitive sg.
         addForm("istúnc") -- accusative sg.
         addForm("istánc") -- accusative sg.
         addForm("istṓc") -- ablative sg.
         addForm("istā́c") -- ablative sg.
         addForm("istōcine") -- ablative sg.
         addForm("istācine") -- ablative sg.
         addForm("istāce") -- ablative sg.
         addForm("istācine") -- ablative sg.
         addForm("istǽc") -- nominative pl.
         addForm("istæce") -- nominative pl.
         addForm("istīsce") -- dative/ablative pl.
         addForm("istōscine") -- accusative pl.
         addForm("istīsce") -- ablative pl.
         addForm("istī́c") -- adverb
         addForm("istim") -- adverb
         addForm("istinc") -- adverb
         addForm("istūc") -- adverb
      elseif firstField == "meus" then
         attachEndings("me",adjectiveEndings_us_a_um_withoutVocative)
         addForm("mī") -- vocative masc.
         addForm("meōpte") -- ablative sg.
         addForm("meāpte") -- ablative sg.
         addForm("meāmet") -- ablative sg.
         addForm("mīs") -- dative pl.
      elseif firstField == "nēmō" then
         addForm("nēmō") -- nominative sg.
         addForm("nēmo") -- nominative sg.
         addForm("nēminis") -- genitive sg.
         addForm("nēminī") -- dative sg.
         addForm("nēminem") -- accusative sg.
         addForm("nēmine") -- ablative sg.
      elseif firstField == "ne-uter" then
         attachEndings("ne-",pronounForms_uter_utra_utrum)
      elseif firstField == "nōs" then
         addForm("nōs") -- nominative/accusative
         addForm("nōs-met") -- nominative/accusative
         addForm("nostrī") -- genitive
         addForm("nostrum") -- genitive
         addForm("nōbīs") -- dative/ablative
         addForm("nōbīs-cum") -- "cum" + ablative
      elseif firstField == "noster" then
         attachEndings("nost",adjectiveEndings_er_ra_rum)
         addForm("nostrāpte") -- ablative sg.
      elseif firstField == "nūllus" then
         attachEndings("nūll",pronominalAdjectiveEndings)
      elseif firstField == "quālis" then
         attachEndings("quāl",adjectiveEndings_is_e)
      elseif firstField == "quālis-cum-que" then
         attachEndingsEnclitic("quāl",adjectiveEndings_is_e,"cum-que")
      elseif firstField == "quālis-libet" then
         attachEndingsEnclitic("quāl",adjectiveEndings_is_e,"libet")
      elseif firstField == "quantulus-cum-que" then
         attachEndingsEnclitic("quantul",adjectiveEndings_us_a_um_withoutVocative,"cum-que")
      elseif firstField == "quantulus-libet" then
         attachEndingsEnclitic("quantul",adjectiveEndings_us_a_um_withoutVocative,"libet")
      elseif firstField == "quantus" then
         attachEndings("quant",adjectiveEndings_us_a_um_withoutVocative)
      elseif firstField == "quantus-cum-que" then
         attachEndingsEnclitic("quant",adjectiveEndings_us_a_um_withoutVocative,"cum-que")
      elseif firstField == "quantus-libet" then
         attachEndingsEnclitic("quant",adjectiveEndings_us_a_um_withoutVocative,"libet")
      elseif firstField == "quantus-vīs" then
         attachEndingsEnclitic("quant",adjectiveEndings_us_a_um_withoutVocative,"vīs")
      elseif firstField == "quī" then
         attachEndings("",pronounForms_qui_quae_quod)
         addForm("qua") -- variant of "quæ" when used as indefinite pronoun
         addForm("quojus") -- genitive sg.
         addForm("quoi") -- dative sg.
         addForm("queis") -- dative/ablative pl.
         addForm("quīs") -- dative/ablative pl.
         addForm("quō-cum") -- "cum" + ablative
         addForm("quā-cum") -- "cum" + ablative
         addForm("quī-cum") -- "cum" + (old) ablative
         addForm("quibus-cum") -- "cum" + ablative
      elseif firstField == "quī-cum-que" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"cum-que")
      elseif firstField == "quī-dam" then
         addForm("quī-dam") -- nominative sg./pl.
         addForm("quæ-dam") -- nominative sg./pl./acc. pl.
         addForm("quid-dam") -- nom./acc. sg.
         addForm("quod-dam") -- nom./acc. sg.
         addForm("cujus-dam") -- genitive sg.
         addForm("cui-dam") -- dative sg.
         addForm("quen-dam") -- accusative sg.
         addForm("quan-dam") -- accusative sg.
         addForm("quō-dam") -- ablative sg.
         addForm("quā-dam") -- ablative sg.
         addForm("quōrun-dam") -- genitive pl.
         addForm("quārun-dam") -- genitive pl.
         addForm("quibus-dam") -- dative/ablative pl.
         addForm("quōs-dam") -- accusative pl.
         addForm("quās-dam") -- accusative pl.
      elseif firstField == "quī-libet" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"libet")
         addForm("quid-libet")
      elseif firstField == "quī-lubet" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"lubet")
         addForm("quid-lubet")
      elseif firstField == "quī-nam" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"nam")
      elseif firstField == "quis" then
         attachEndings("",pronounForms_quis_quid)
         addForm("quō-cum") -- "cum" + ablative
      elseif firstField == "quis-nam" then
         attachEndingsEnclitic("",pronounForms_quis_quid,"nam")
      elseif firstField == "quis-piam" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"piam")
         addForm("quis-piam")
         addForm("quid-piam")
         addForm("quippiam")
      elseif firstField == "quis-quam" then
         attachEndingsEnclitic("",pronounForms_quis_quid,"quam")
         addForm("quic-quam")
      elseif firstField == "quis-que" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"que")
         addForm("quis-que")
         addForm("quid-que")
      elseif firstField == "quis-quis" then
         addForm("quis-quis")
         addForm("quid-quid")
         addForm("quic-quid")
         addForm("quō-quō")
      elseif firstField == "quī-vīs" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"vīs")
         addForm("quid-vīs")
      elseif firstField == "quī-vīs-cum-que" then
         attachEndingsEnclitic("",pronounForms_qui_quae_quod,"vīs-cum-que")
      elseif firstField == "quod-libeticus" then
         attachEndings("quod-libetic",adjectiveEndings_us_a_um_withoutVocative)
      elseif firstField == "suī" then -- reflexive pronoun
         addForm("su|ī") -- genitive
         addForm("sibī") -- dative
         addForm("sibi") -- dative
         addForm("sibīmet") -- dative
         addForm("sibimet") -- dative
         addForm("sibīmet-ipsīs") -- dative pl.
         addForm("sibimet-ipsīs") -- dative pl.
         addForm("sē") -- accusative/ablative
         addForm("sēsē") -- accusative/ablative
         addForm("sēmet") -- accusative/ablative
         addForm("sēmet-ipsum") -- accusative sg.
         addForm("sēmet-ipsam") -- accusative sg.
         addForm("sēmet-ipsōs") -- accusative pl.
         addForm("sēmet-ipsō") -- ablative sg.
         addForm("sēmet-ipsā") -- ablative sg.
         addForm("sēmet-ipsīs") -- ablative pl.
         addForm("sēpse") -- accusative/ablative
         addForm("sē-cum") -- "cum" + ablative
      elseif firstField == "quot-ennis" then
         attachEndings("quot-enn",adjectiveEndings_is_e)
      elseif firstField == "quotus" then
         attachEndings("quot",adjectiveEndings_us_a_um_withoutVocative)
      elseif firstField == "quotus-cum-que" then
         attachEndingsEnclitic("quot",adjectiveEndings_us_a_um_withoutVocative,"cum-que")
      elseif firstField == "quotus-quis-que" then
         addForm("quotus-quis-que") -- nominative sg.
         addForm("quota-quæ-que") -- nominative sg.
         addForm("quotum-quid-que") -- nominative/accusative sg.
         addForm("quotum-quod-que") -- nominative/accusative sg.
         addForm("quotī-cujus-que") -- genitive sg.
         addForm("quotæ-cujus-que") -- genitive sg.
         addForm("quotō-cui-que") -- dative sg.
         addForm("quotæ-cui-que") -- dative sg.
         addForm("quotum-quem-que") -- accusative sg.
         addForm("quotam-quam-que") -- accusative sg.
         addForm("quotō-quō-que") -- ablative sg.
         addForm("quotā-quā-que") -- ablative sg.
      elseif firstField == "suus" then
         attachEndings("su",adjectiveEndings_us_a_um_withoutVocative)
         addForm("su|amet") -- nominative sg./accusative pl.
         addForm("su|apte") -- nominative sg./accusative pl.
         addForm("su|īmet") -- genitive sg.
         addForm("su|ompte") -- accusative sg.
         addForm("su|ōmet") -- ablative sg.
         addForm("su|āmet") -- ablative sg.
         addForm("su|ōpte") -- ablative sg.
         addForm("su|āpte") -- ablative sg.
         addForm("su|īs-met") -- ablative pl.
      elseif firstField == "tālis" then
         attachEndings("tāl",adjectiveEndings_is_e)
      elseif firstField == "tantus" then
         attachEndings("tant",adjectiveEndings_us_a_um_withoutVocative)
      elseif firstField == "tantus-dem" then
         attachEndingsEnclitic("tant",adjectiveEndings_us_a_um_withoutVocative,"dem")
         addForm("tantun-dem") -- nom./acc. sg. neuter
      elseif firstField == "tū" then
         addForm("tū") -- nominative
         addForm("tūte") -- nominative
         addForm("tūtemet") -- nominative
         addForm("tūtimet") -- nominative
         addForm("tūtin") -- nominative
         addForm("tuī") -- genitive
         addForm("tuīmet") -- genitive
         addForm("tibī") -- dative
         addForm("tibīmet") -- dative
         addForm("tibi") -- dative
         addForm("tibimet") -- dative
         addForm("tē") -- accusative/ablative
         addForm("tēmet") -- accusative/ablative
         addForm("tēte") -- accusative/ablative
         addForm("tē-cum") -- "cum" + ablative
      elseif firstField == "tōtus" then
         attachEndings("tōt",pronominalAdjectiveEndings)
      elseif firstField == "tuus" then
         attachEndings("tu",adjectiveEndings_us_a_um_withoutVocative)
         addForm("tuīpte") -- genitive sg.
         addForm("tuom") -- accusative sg.
         addForm("tuōpte") -- ablative sg.
         addForm("tuāpte") -- ablative sg.
      elseif firstField == "ūllus" then
         attachEndings("ūll",pronominalAdjectiveEndings)
      elseif firstField == "ūnus-quis-que" then
         addForm("ūnus-quis-que") -- nominative sg.
         addForm("ūna-quæ-que") -- nominative sg.
         addForm("ūnum-quid-que") -- nom./acc. sg.
         addForm("ūnum-quod-que") -- nom./acc. sg.
         addForm("ūnīus-cujus-que") -- genitive sg.
         addForm("ūnī-cui-que") -- dative sg.
         addForm("ūnum-quem-que") -- accusative sg.
         addForm("ūnam-quam-que") -- accusative sg.
         addForm("ūnō-quō-que") -- ablative sg.
         addForm("ūnā-quā-que") -- ablative sg.
      elseif firstField == "uter" then
         attachEndings("",pronounForms_uter_utra_utrum)
      elseif firstField == "uter-cum-que" then
         attachEndingsEnclitic("",pronounForms_uter_utra_utrum,"cum-que")
      elseif firstField == "uter-libet" then
         attachEndingsEnclitic("",pronounForms_uter_utra_utrum,"libet")
      elseif firstField == "uter-que" then
         attachEndingsEnclitic("",pronounForms_uter_utra_utrum,"que")
         addForm("utrim-que") -- adverb
         addForm("utrin-que") -- adverb
      elseif firstField == "uter-vīs" then
         attachEndingsEnclitic("",pronounForms_uter_utra_utrum,"vīs")
      elseif firstField == "vester" then
         attachEndings("vest",adjectiveEndings_er_ra_rum)
         addForm("vestrāpte") -- ablative sg.
      elseif firstField == "vōs" then
         addForm("vōs") -- nominative/accusative
         addForm("vōs-met") -- nominative/accusative
         addForm("vestrī") -- genitive
         addForm("vestrum") -- genitive
         addForm("vōbīs") -- dative/ablative
         addForm("vōbīs-met") -- dative/ablative
         addForm("vōbīs-cum") -- "cum" + ablative
      elseif firstField == "voster" then
         attachEndings("vost",adjectiveEndings_er_ra_rum)
      else
         invalidField(firstField)
      end

   -- numeral
   elseif secondField == "N" then
      if thirdField or fourthField then
         invalidLine()
      elseif firstField == "ūnus" then
         attachEndings("ūn",pronominalAdjectiveEndings)
         -- the plural forms are used for some pluralia tantum
      elseif firstField == "duo" then
         addForm("duo") -- nominative masc./neuter
         attachEndings("du",pronounEndings_o_ae)
      elseif firstField == "trēs" then
         attachEndings("tr",adjectiveEndings_es_ium)
      elseif firstField == "mīlle" then
         addForm("mīlle") -- singular
         addForm("mīlia") -- nom./acc. plural
         addForm("mīlium") -- gen. plural
         addForm("mīlibus") -- dat/abl. plural
      elseif endsIn(firstField,"us") then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,adjectiveEndings_us_a_um)
      elseif endsIn(firstField,"ī") then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,adjectiveEndings_i_ae_a)
      else
         invalidField(firstField)
      end

   -- invalid line
   else
      invalidLine()
   end
end
