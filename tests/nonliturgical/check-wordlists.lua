function createSet(list)
   local set = {}
   for _,l in ipairs(list) do
      set[l] = true
   end
   return set
end

vowels = createSet{"A","a","E","e","I","i","O","o","U","u","Y","y","Æ","æ","Œ",
   "œ"}

accentedVowels = createSet{"Á","á","É","é","Í","í","Ó","ó","Ú","ú","Ý","ý","Ǽ",
   "ǽ","Œ́","œ́"}

-- q is intentionally left out here
consonants = createSet{"B","b","C","c","D","d","F","f","G","g","H","h","J","j",
   "K","k","L","l","M","m","N","n","P","p","R","r","S","s","T","t","V","v","W",
   "w","X","x","Z","z"}

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

function containsAccents(word)
   for _, code in utf8.codes(word) do
      if accentedVowels[utf8.char(code)] then
         return true
      end
   end
   return false
end

function containsItalianHyphenation(word)
   for i = 3, utf8.len(word)-3 do
      if utf8substring(word,i,i+2) == "-gn"
      or utf8substring(word,i,i+3) == "-sce"
      or utf8substring(word,i,i+3) == "-sci"
      or utf8substring(word,i,i+3) == "-scy"
      or utf8substring(word,i,i+3) == "-scæ"
      or utf8substring(word,i,i+3) == "-scœ" then
         return true
      end
   end
   return false
end

function removeItalianHyphenation(word)
   for i = 3, utf8.len(word)-3 do
      if utf8substring(word,i,i+2) == "-gn" then
         word = utf8substring(word,1,i-1).."g-n"..utf8substring(word,i+3)
      elseif utf8substring(word,i,i+3) == "-sce"
      or utf8substring(word,i,i+3) == "-sci"
      or utf8substring(word,i,i+3) == "-scy"
      or utf8substring(word,i,i+3) == "-scæ"
      or utf8substring(word,i,i+3) == "-scœ" then
         word = utf8substring(word,1,i-1).."s-c"..utf8substring(word,i+3)
      end
   end
   return word
end

function containsNonItalianHyphenation(word)
   for i = 2, utf8.len(word)-3 do
      if utf8substring(word,i,i+2) == "s-c"
      or utf8substring(word,i,i+2) == "s-p"
      or utf8substring(word,i,i+2) == "s-t" then
         return true
      end
   end
   return false
end

function removeNonItalianHyphenation(word)
   for i = 2, utf8.len(word)-3 do
      if utf8substring(word,i,i+2) == "s-c"
      or utf8substring(word,i,i+2) == "s-p"
      or utf8substring(word,i,i+2) == "s-t" then
         word = utf8substring(word,1,i-1).."-s"..utf8substring(word,i+2)
      end
   end
   return removeSingleVowelSyllables(word)
end

function containsSingleVowelSyllable(word)
   if utf8.len(word) > 2 and utf8substring(word,2,2) == "-" then
      return true
   end
   if utf8.len(word) > 2 and utf8substring(word,-2,-2) == "-" then
      return true
   end
   for i = 4, utf8.len(word)-3 do
      if utf8substring(word,i-1,i-1) == "-"
      and utf8substring(word,i+1,i+1) == "-" then
         return true
      end
   end
   return false
end

function removeSingleVowelSyllables(word)
   if utf8.len(word) > 2 and utf8substring(word,2,2) == "-" then
      word = utf8substring(word,1,1)..utf8substring(word,3)
   end
   if utf8.len(word) > 2 and utf8substring(word,-2,-2) == "-" then
      word = utf8substring(word,1,-3)..utf8substring(word,-1)
   end
   for i = 4, utf8.len(word)-3 do
      if utf8substring(word,i-1,i-1) == "-"
      and utf8substring(word,i+1,i+1) == "-" then
         if consonants[utf8substring(word,i-2,i-2)] then
            word = utf8substring(word,1,i)..utf8substring(word,i+2)
         else
            word = utf8substring(word,1,i-2)..utf8substring(word,i)
         end
      end
   end
   return word
end

function containsHiatus(word)
   for i = 3, utf8.len(word)-2 do
      if utf8substring(word,i,i) == "-" and vowels[utf8substring(word,i-1,i-1)]
      and vowels[utf8substring(word,i+1,i+1)] then
         return true
      end
   end
   return false
end

function removeHiatus(word)
   for i = 3, utf8.len(word)-2 do
      if utf8substring(word,i,i) == "-" and vowels[utf8substring(word,i-1,i-1)]
      and vowels[utf8substring(word,i+1,i+1)] then
         word = utf8substring(word,1,i-1)..utf8substring(word,i+1)
      end
   end
   return word
end

function readHyphenations(fileName,set,hyphenationStyle)
   local inputStream = assert(io.open(fileName,"r"))
   io.input(inputStream)
   for line in io.lines() do
      local word = string.lower(string.gsub(line,"-",""))
      --[[ We use the word without hyphens and in lowercase as key; the lower
      function does not work for accented characters, so there may be
      undetected duplicates beginning with an accented letter. ]]
      if set[word] then
         if hyphenationStyle == "original" then
            print('Duplicate in original file "'..fileName..'": '..set[word].."/"..line)
         else
            print("Duplicate for "..hyphenationStyle.." Latin: "..set[word].."/"..line)
         end
         duplicate = true
      else
         set[word] = line
      end
   end
end

function writeHyphenationCandidates(fileName,set)
   if next(set) == nil then
      local outputStream = assert(io.open(fileName,"w"))
      for _, word in pairs(set) do
         outputStream:write(word..'\n')
      end
      wordListsDiffer = true
   end
end

function sortFile(fileName)
	os.execute("sort -o "..fileName.." "..fileName)
end

-- sort word lists

liturgicalFile = "wordlist-liturgical-only.txt"
liturgicalClassicalFile = "wordlist-liturgical-classical.txt"
liturgicalItalianFile = "wordlist-liturgical-italian.txt"
classicalFile = "wordlist-classical-only.txt"
classicalItalianFile = "wordlist-classical-italian.txt"
italianFile = "wordlist-italian-only.txt"
allFile = "wordlist-all-styles.txt"

sortFile(liturgicalFile)
sortFile(liturgicalClassicalFile)
sortFile(liturgicalItalianFile)
sortFile(classicalFile)
sortFile(classicalItalianFile)
sortFile(italianFile)
sortFile(allFile)


-- read hyphenated words from word lists and store them in tables

originalFile = "../wordlist-liturgical.txt"
original = {}
liturgical = {}
classical = {}
italian = {}

duplicate = false

readHyphenations(originalFile,original,"original")

readHyphenations(liturgicalFile,liturgical,"liturgical")
readHyphenations(liturgicalClassicalFile,liturgical,"liturgical")
readHyphenations(liturgicalItalianFile,liturgical,"liturgical")
readHyphenations(allFile,liturgical,"liturgical")

readHyphenations(classicalFile,classical,"classical")
readHyphenations(liturgicalClassicalFile,classical,"classical")
readHyphenations(classicalItalianFile,classical,"classical")
readHyphenations(allFile,classical,"classical")

readHyphenations(italianFile,italian,"Italian")
readHyphenations(liturgicalItalianFile,italian,"Italian")
readHyphenations(classicalItalianFile,italian,"Italian")
readHyphenations(allFile,italian,"Italian")

if not duplicate then
   print("No duplicates were found.")
end


-- compare local word lists

wordListsDiffer = false

for key, word in pairs(liturgical) do
   if not classical[key] then
      print('"'..word..'" is missing for classical Latin.')
      wordListsDiffer = true
   end
   if not italian[key] then
      print('"'..word..'" is missing for Italian Latin.')
      wordListsDiffer = true
   end
end

for key, word in pairs(classical) do
   if not liturgical[key] then
      print('"'..word..'" is missing for liturgical Latin.')
      wordListsDiffer = true
   end
   if not italian[key] then
      print('"'..word..'" is missing for Italian Latin.')
      wordListsDiffer = true
   end
end

for key, word in pairs(italian) do
   if not liturgical[key] then
      print('"'..word..'" is missing for liturgical Latin.')
      wordListsDiffer = true
   end
   if not classical[key] then
      print('"'..word..'" is missing for classical Latin.')
      wordListsDiffer = true
   end
end

if not wordListsDiffer then
   print("The same words are present for all three hyphenation styles.")
end


-- compare liturgical word list with original word list

wordListsDiffer = false

for key, word in pairs(liturgical) do
   if not original[key] then
      -- missing word in the original file
      print('"'..word..'" is missing in the original file "'..originalFile..'".')
      wordListsDiffer = true
   elseif original[key] ~= word then
      -- different hyphenation in the original file
      print('"'..word..'" is hyphenated differently in the original file "'..originalFile..'".')
      wordListsDiffer = true
   end
end


-- write new words from the original file to candidate files

liturgicalCandidates = {}
liturgicalClassicalCandidates = {}
liturgicalItalianCandidates = {}
classicalCandidates = {}
classicalItalianCandidates = {}
italianCandidates = {}
allCandidates = {}

for _, word in pairs(original) do
   if containsSingleVowelSyllable(word) or containsHiatus(word)
   or containsAccents(word) then
      table.insert(liturgicalCandidates,word)
      word = removeSingleVowelSyllables(word)
      word = removeHiatus(word)
      if containsItalianHyphenation(word) then
         table.insert(classicalCandidates,removeItalianHyphenation(word))
         if containsNonItalianHyphenation(word) then
            table.insert(italianCandidates,removeNonItalianHyphenation(word))
         else
            table.insert(italianCandidates,word)
         end
      elseif containsNonItalianHyphenation(word) then
         table.insert(classicalCandidates,word)
         table.insert(italianCandidates,removeNonItalianHyphenation(word))
      else
         table.insert(classicalItalianCandidates,word)
      end
   elseif containsItalianHyphenation(word) then
      table.insert(classicalCandidates,removeItalianHyphenation(word))
      if containsNonItalianHyphenation(word) then
         table.insert(liturgicalCandidates,word)
         table.insert(italianCandidates,removeNonItalianHyphenation(word))
      else
         table.insert(liturgicalItalianCandidates,word)
      end
   elseif containsNonItalianHyphenation(word) then
      table.insert(liturgicalClassicalCandidates,word)
      table.insert(italianCandidates,removeNonItalianHyphenation(word))
   else
      table.insert(allCandidates,word)
   end
end

liturgicalFile = "candidates-liturgical-only.txt"
liturgicalClassicalFile = "candidates-liturgical-classical.txt"
liturgicalItalianFile = "candidates-liturgical-italian.txt"
classicalFile = "candidates-classical-only.txt"
classicalItalianFile = "candidates-classical-italian.txt"
italianFile = "candidates-italian-only.txt"
allFile = "candidates-all-styles.txt"

writeHyphenationCandidates(liturgicalFile,liturgicalCandidates)
writeHyphenationCandidates(liturgicalClassicalFile,liturgicalClassicalCandidates)
writeHyphenationCandidates(liturgicalItalianFile,liturgicalItalianCandidates)
writeHyphenationCandidates(classicalFile,classicalCandidates)
writeHyphenationCandidates(classicalItalianFile,classicalItalianCandidates)
writeHyphenationCandidates(italianFile,italianCandidates)
writeHyphenationCandidates(allFile,allCandidates)

if not wordListsDiffer then
   print('The hyphenations for liturgical Latin are identical to those of the original file "'..originalFile..'".')
end
