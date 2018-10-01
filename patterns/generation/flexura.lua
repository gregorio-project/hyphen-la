-- output error message for an invalid field
function invalidField(field,linenumber)
	error('Invalid field "'..field..'" in line '..linenumber)
end

function utf8substring(s,i,j)
	if j then
		return string.sub(s,utf8.offset(s,i),utf8.offset(s,j))
	else
		return string.sub(s,utf8.offset(s,i))
	end
end

-- list of all generated forms
outputlist = {}

-- endings of the first conjugation
presentStemEndingsActive1 = {
	"ō","ās","at","āmus","ātis","ant", -- present indicative
	"ābam","ābās","ābat","ābāmus","ābātis","ābant", -- imperfect indicative
	"ābō","ābis","ābit","ābimus","ābitis","ābunt", -- future
	"em","ēs","et","ēmus","ētis","ent", -- present subjunctive
	"ārem","ārēs","āret","ārēmus","ārētis","ārent", -- imperfect subjunctive
	"ā","āte","ātō","ātōte","antō" -- imperative
	}

presentStemEndingsPassive1 = {
	"or","āris","ātur","āmur","āminī","antur", -- present indicative
	"ābar","ābāris","ābātur","ābāmur","ābāminī","ābantur", -- imperfect indicative
	"ābor","āberis","ābitur","ābimur","ābiminī","ābuntur", -- future
	"er","ēris","ētur","ēmur","ēminī","entur", -- present subjunctive
	"ārer","ārēris","ārētur","ārēmur","ārēminī","ārentur", -- imperfect subjunctive
	"āre","ātor","antor", -- imperative
	"ārī" --infinitive
	}

-- special forms for "dare" (the "a" is short except in "dās" and "dā")
presentStemEndingsDare = {
	"ō","ās","at","amus","atis","ant", -- present indicative active
	"abam","abās","abat","abāmus","abātis","abant", -- imperfect indicative active
	"abō","abis","abit","abimus","abitis","abunt", -- future active
	"em","ēs","et","ēmus","ētis","ent", -- present subjunctive active
	"arem","arēs","aret","arēmus","arētis","arent", -- imperfect subjunctive active
	"ā","ate","atō","atōte","antō", -- imperative active
	"or","aris","atur","amur","aminī","antur", -- present indicative passive
	"abar","abāris","abātur","abāmur","abāminī","abantur", -- imperfect indicative passive
	"abor","aberis","abitur","abimur","abiminī","abuntur", -- future passive
	"er","ēris","ētur","ēmur","ēminī","entur", -- present subjunctive passive
	"arer","arēris","arētur","arēmur","arēminī","arentur", -- imperfect subjunctive passive
	"are","ator","antor", -- imperative passive
	"arī" --infinitive passive
	}

-- endings of the second conjugation
presentStemEndingsActive2 = {
	"eō","ēs","et","ēmus","ētis","ent", -- present indicative
	"ēbam","ēbās","ēbat","ēbāmus","ēbātis","ēbant", -- imperfect indicative
	"ēbō","ēbis","ēbit","ēbimus","ēbitis","ēbunt", -- future
	"eam","eās","eat","eāmus","eātis","eant", -- present subjunctive
	"ērem","ērēs","ēret","ērēmus","ērētis","ērent", -- imperfect subjunctive
	"ē","ēte","ētō","ētōte","entō" -- imperative
	}

presentStemEndingsPassive2 = {
	"eor","ēris","ētur","ēmur","ēminī","entur", -- present indicative
	"ēbar","ēbāris","ēbātur","ēbāmur","ēbāminī","ēbantur", -- imperfect indicative
	"ēbor","ēberis","ēbitur","ēbimur","ēbiminī","ēbuntur", -- future
	"ear","eāris","eātur","eāmur","eāminī","eantur", -- present subjunctive
	"ērer","ērēris","ērētur","ērēmur","ērēminī","ērentur", -- imperfect subjunctive
	"ēre","ētor","entor", -- imperative
	"ērī" --infinitive
	}

-- endings of the third conjugation
presentStemEndingsActive3 = {
	"ō","is","it","imus","itis","unt", -- present indicative
	"ēbam","ēbās","ēbat","ēbāmus","ēbātis","ēbant", -- imperfect indicative
	"am","ēs","et","ēmus","ētis","ent", -- future
	"ās","at","āmus","ātis","ant", -- present subjunctive
	"erem","erēs","eret","erēmus","erētis","erent", -- imperfect subjunctive
	"ite","itō","itōte","untō" -- imperative
	}
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "dīcere" and
"dūcere" ]]

presentStemEndingsPassive3 = {
	"or","eris","itur","imur","iminī","untur", -- present indicative
	"ēbar","ēbāris","ēbātur","ēbāmur","ēbāminī","ēbantur", -- imperfect indicative
	"ar","ēris","ētur","ēmur","ēminī","entur", -- future
	"āris","ātur","āmur","āminī","antur", -- present subjunctive
	"erer","erēris","erētur","erēmur","erēminī","erentur", -- imperfect subjunctive
	"ere","itor","untor", -- imperative
	"ī" --infinitive
	}

-- endings of the mixed third conjugation
presentStemEndingsActive3M = {
	"iō","is","it","imus","itis","iunt", -- present indicative
	"iēbam","iēbās","iēbat","iēbāmus","iēbātis","iēbant", -- imperfect indicative
	"iam","iēs","iet","iēmus","iētis","ient", -- future
	"iās","iat","iāmus","iātis","iant", -- present subjunctive
	"erem","erēs","eret","erēmus","erētis","erent", -- imperfect subjunctive
	"ite","itō","itōte","iuntō" -- imperative
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "facere" and
"calefacere" ]]
	}

presentStemEndingsPassive3M = {
	"ior","eris","itur","imur","iminī","iuntur", -- present indicative
	"iēbar","iēbāris","iēbātur","iēbāmur","iēbāminī","iēbantur", -- imperfect indicative
	"iar","iēris","iētur","iēmur","iēminī","ientur", -- future
	"iāris","iātur","iāmur","iāminī","iantur", -- present subjunctive
	"erer","erēris","erētur","erēmur","erēminī","erentur", -- imperfect subjunctive
	"ere","itor","iuntor", -- imperative
	"ī" --infinitive
	}

-- endings of the forth conjugation
presentStemEndingsActive4 = {
	"iō","īs","it","īmus","ītis","iunt", -- present indicative
	"iēbam","iēbās","iēbat","iēbāmus","iēbātis","iēbant", -- imperfect indicative
	"iam","iēs","iet","iēmus","iētis","ient", -- future
	"iās","iat","iāmus","iātis","iant", -- present subjunctive
	"īrem","īrēs","īret","īrēmus","īrētis","īrent", -- imperfect subjunctive
	"ī","īte","īto","ītōte","iuntō" -- imperative
	}

presentStemEndingsPassive4 = {
	"ior","īris","ītur","īmur","īminī","iuntur", -- present indicative
	"iēbar","iēbāris","iēbātur","iēbāmur","iēbāminī","iēbantur", -- imperfect indicative
	"iar","iēris","iētur","iēmur","iēminī","ientur", -- future
	"iāris","iātur","iāmur","iāminī","iantur", -- present subjunctive
	"īrer","īrēris","īrētur","īrēmur","īrēminī","īrentur", -- imperfect subjunctive
	"īre","ītor","iuntor", -- imperative
	"īrī" --infinitive
	}


-- read input line by line
linecount = 0
for line in io.lines() do
	linecount = linecount + 1
	i = string.find(line,",")

	if i == nil then
		firstField = line
		secondField = nil
		thirdField = nil
		forthField = nil
	else
		firstField = string.sub(line,1,i-1)
		line = string.sub(line,i+1,-1)
		i = string.find(line,",")

		if i == nil then
			secondField = line
			thirdField = nil
			forthField = nil
		else
			secondField = string.sub(line,1,i-1)
			line = string.sub(line,i+1,-1)
			i = string.find(line,",")

			if i == nil then
				thirdField = line
				forthField = nil
			else
				thirdField = string.sub(line,1,i-1)
				forthField = string.sub(line,i+1,-1)
			end
		end
	end

	-- invariant word
	if secondField == nil then
		table.insert(outputlist,firstField)

	-- verb of the first conjugation
	elseif secondField == "1" then
		if utf8.len(firstField) < 2 then
			invalidField(firstField,linecount)
		elseif firstField == "dō" or utf8.len(firstField) > 3
			and utf8substring(firstField,-3) == "-dō" then
			root = utf8substring(firstField,1,-2)
			for _,ending in pairs(presentStemEndingsDare) do
				table.insert(outputlist,root..ending)
			end
		elseif utf8substring(firstField,-1) == "ō" then
			root = utf8substring(firstField,1,-2)
			for _,ending in pairs(presentStemEndingsActive1) do
				table.insert(outputlist,root..ending)
			end
			for _,ending in pairs(presentStemEndingsPassive1) do
				table.insert(outputlist,root..ending)
			end
		elseif string.sub(firstField,-2) == "or" then
			root = string.sub(firstField,1,-3)
			for _,ending in pairs(presentStemEndingsPassive1) do
				table.insert(outputlist,root..ending)
			end
		else
			invalidField(firstField,linecount)
		end

	-- verb of the second conjugation
	elseif secondField == "2" then
		if utf8.len(firstField) < 3 then
			invalidField(firstField,linecount)
		elseif utf8substring(firstField,-2) == "eō" then
			root = utf8substring(firstField,1,-3)
			for _,ending in pairs(presentStemEndingsActive2) do
				table.insert(outputlist,root..ending)
			end
			for _,ending in pairs(presentStemEndingsPassive2) do
				table.insert(outputlist,root..ending)
			end
		elseif string.sub(firstField,-3) == "eor" then
			root = string.sub(firstField,1,-4)
			for _,ending in pairs(presentStemEndingsPassive2) do
				table.insert(outputlist,root..ending)
			end
		else
			invalidField(firstField,linecount)
		end

	-- verb of the third conjugation
	elseif secondField == "3" then
		if utf8.len(firstField) < 2 then
			invalidField(firstField,linecount)
		elseif utf8substring(firstField,-1) == "ō" then
			root = utf8substring(firstField,1,-2)
			-- active forms
			for _,ending in pairs(presentStemEndingsActive3) do
				table.insert(outputlist,root..ending)
			end
			-- second person singular of the imperative present
			if firstField == "dīcō" or firstField == "dūcō" or
				utf8.len(firstField) > 5 and
					(utf8substring(firstField,-5) == "-dīcō"
						or utf8substring(firstField,-5) == "-dūcō")
				then
				table.insert(outputlist,root) -- "dīc"/"dūc"
			else
				table.insert(outputlist,root.."e") -- e.g. "mitte"
			end
			-- passive forms
			for _,ending in pairs(presentStemEndingsPassive3) do
				table.insert(outputlist,root..ending)
			end
		elseif string.sub(firstField,-2) == "or" then
			root = string.sub(firstField,1,-3)
			for _,ending in pairs(presentStemEndingsPassive3) do
				table.insert(outputlist,root..ending)
			end
		else
			invalidField(firstField,linecount)
		end

	-- verb of the mixed third conjugation
	elseif secondField == "3M" then
		if utf8.len(firstField) < 3 then
			invalidField(firstField,linecount)
		elseif utf8substring(firstField,-2) == "iō" then
			root = utf8substring(firstField,1,-3)
			-- active forms
			for _,ending in pairs(presentStemEndingsActive3M) do
				table.insert(outputlist,root..ending)
			end
			-- second person singular of the imperative present
			if firstField == "cale-faciō" then
				table.insert(outputlist,"cal-face")
			elseif firstField == "faciō" or utf8.len(firstField) > 6 and
				utf8substring(firstField,-6) == "-faciō" then
				table.insert(outputlist,root) -- "fac"
			else
				table.insert(outputlist,root.."e") -- e.g. "cape"
			end
			for _,ending in pairs(presentStemEndingsPassive3M) do
				table.insert(outputlist,root..ending)
			end
		elseif string.sub(firstField,-3) == "ior" then
			root = string.sub(firstField,1,-4)
			for _,ending in pairs(presentStemEndingsPassive3M) do
				table.insert(outputlist,root..ending)
			end
		else
			invalidField(firstField,linecount)
		end

	-- verb of the forth conjugation
	elseif secondField == "4" then
		if utf8.len(firstField) < 3 then
			invalidField(firstField,linecount)
		elseif utf8substring(firstField,-2) == "iō" then
			root = utf8substring(firstField,1,-3)
			for _,ending in pairs(presentStemEndingsActive4) do
				table.insert(outputlist,root..ending)
			end
			for _,ending in pairs(presentStemEndingsPassive4) do
				table.insert(outputlist,root..ending)
			end
		elseif string.sub(firstField,-3) == "ior" then
			root = string.sub(firstField,1,-4)
			for _,ending in pairs(presentStemEndingsPassive4) do
				table.insert(outputlist,root..ending)
			end
		else
			invalidField(firstField,linecount)
		end

	-- invalid word type
	else
		invalidField(secondField,linecount)
	end
end

for _,word in pairs(outputlist) do
	print(word)
end
