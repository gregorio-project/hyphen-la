function createSet(list)
   local set = {}
   for _,l in ipairs(list) do
      set[l] = true
   end
   return set
end

vowels = createSet{"A","a","E","e","I","i","O","o","U","u","Y","y","Æ","æ","Œ",
   "œ"}

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

function contains(list,element)
   for _, v in pairs(list) do
      if v == element then
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
      if utf8substring(word,i,i+2) == "s-b"
      or utf8substring(word,i,i+2) == "s-c"
      or utf8substring(word,i,i+2) == "s-m"
      or utf8substring(word,i,i+2) == "s-p"
      or utf8substring(word,i,i+2) == "s-t" then
         return true
      end
   end
   return false
end

function removeNonItalianHyphenation(word)
   for i = 2, utf8.len(word)-3 do
      if utf8substring(word,i,i+2) == "s-b"
      or utf8substring(word,i,i+2) == "s-c"
      or utf8substring(word,i,i+2) == "s-m"
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

function readHyphenations(fileName,list,hyphenationStyle)
   local inputStream = assert(io.open(fileName,"r"))
   io.input(inputStream)
   for line in io.lines() do
      local word = string.gsub(line,"-","")
      if list[word] then
         if hyphenationStyle == "liturgical" then
            print('Duplicate in file "'..fileName..'": '..list[word].."/"..line)
         else
            print("Duplicate for "..hyphenationStyle.." Latin: "..list[word].."/"..line)
         end
         duplicate = true
      else
         list[word] = line
      end
   end
end

function containsAccent(word)
   if string.find(word, "á") then
      return true
   elseif string.find(word, "é") then
      return true
   elseif string.find(word, "í") then
      return true
   elseif string.find(word, "ó") then
      return true
   elseif string.find(word, "ú") then
      return true
   elseif string.find(word, "ý") then
      return true
   elseif string.find(word, "ǽ") then
      return true
   elseif string.find(word, "œ́") then
      return true
   elseif string.find(word, "Á") then
      return true
   elseif string.find(word, "É") then
      return true
   elseif string.find(word, "Í") then
      return true
   elseif string.find(word, "Ó") then
      return true
   elseif string.find(word, "Ú") then
      return true
   elseif string.find(word, "Ý") then
      return true
   elseif string.find(word, "Ǽ") then
      return true
   elseif string.find(word, "Œ́") then
      return true
   else
      return false
   end
end

function readAccentedWords(fileName,list)
   local inputStream = assert(io.open(fileName,"r"))
   io.input(inputStream)
   for line in io.lines() do
      if containsAccent(line) then
         local word = string.gsub(line,"á","a")
         word = string.gsub(word,"é","e")
         word = string.gsub(word,"í","i")
         word = string.gsub(word,"ó","o")
         word = string.gsub(word,"ú","u")
         word = string.gsub(word,"ý","y")
         word = string.gsub(word,"ǽ","æ")
         word = string.gsub(word,"œ́","œ")
         word = string.gsub(word,"Á","A")
         word = string.gsub(word,"É","E")
         word = string.gsub(word,"Í","I")
         word = string.gsub(word,"Ó","O")
         word = string.gsub(word,"Ú","U")
         word = string.gsub(word,"Ý","Y")
         word = string.gsub(word,"Ǽ","Æ")
         word = string.gsub(word,"Œ́","Œ")
         if list[word] then
            -- print('Duplicate in file "'..fileName..'": '..list[word].."/"..line)
            -- duplicate = true
         else
            list[word] = line
         end
      else
         print('Entry without accent in file "'..fileName..'": '..line)
      end
   end
end

function sortFile(fileName)
   local file = io.open(fileName,"r")
   if file ~= nil then
      io.close(file)
      os.execute("sort -o "..fileName.." "..fileName)
   end
end

function deleteFile(fileName)
   os.execute("rm -f "..fileName)
end

function writeHyphenationCandidates(fileName,list,with_hyphens)
   if next(list) ~= nil then
      local outputStream = assert(io.open(fileName,"w"))
      for _, word in pairs(list) do
         if with_hyphens then
            outputStream:write(word..'\n')
         else
            outputStream:write(string.gsub(word,"-","")..'\n')
         end
      end
      wordListsDiffer = true
      io.close(outputStream)
      sortFile(fileName)
      print('Missing words have been written to "'..fileName..'":')
      os.execute("cat "..fileName)
   end
end


-- sort word lists

liturgicalFile = "wordlist-liturgical.txt"
classicalItalianFile = "wordlist-classical-italian.txt"
classicalFile = "wordlist-classical.txt"
italianFile = "wordlist-italian.txt"
accentFile = "wordlist-accents.txt"

sortFile(liturgicalFile)
sortFile(classicalItalianFile)
sortFile(classicalFile)
sortFile(italianFile)
sortFile(accentFile)


-- read hyphenated words from word lists and store them in tables

liturgical = {}
classical = {}
italian = {}
accented = {}

duplicate = false

readHyphenations(liturgicalFile,liturgical,"liturgical")
readHyphenations(classicalFile,classical,"classical")
readHyphenations(classicalItalianFile,classical,"classical")
readHyphenations(italianFile,italian,"Italian")
readHyphenations(classicalItalianFile,italian,"Italian")
readAccentedWords(accentFile,accented)

if not duplicate then
   print("No duplicates were found.")
end


-- compare local word lists

wordListsDiffer = false
missingWords = {}
missingAccentWords = {}

for key, word in pairs(liturgical) do
   if not classical[key] then
      wordListsDiffer = true
      missingWords[key] = word
   end
   if not italian[key] then
      wordListsDiffer = true
      missingWords[key] = word
   end
   local _, n = string.gsub(word, "-", "")
   if n > 1 and not accented[key] then
      wordListsDiffer = true
      missingAccentWords[key] = word
   elseif n < 2 and accented[key] then
      print('Superfluous entry in file "'..accentFile..'": '..accented[key])
   end
end

for key, word in pairs(classical) do
   if not liturgical[key] then
      print('Missing word in file "'..liturgicalFile..'": '..word)
      wordListsDiffer = true
   end
end

for key, word in pairs(italian) do
   if not liturgical[key] then
      print('Missing word in file "'..liturgicalFile..'": '..word)
      wordListsDiffer = true
   end
end

if not wordListsDiffer then
   print("The same words are present for all three hyphenation styles.")
end


-- write new words from the original file to candidate files

classicalCandidates = {}
classicalItalianCandidates = {}
italianCandidates = {}

for _, word in pairs(missingWords) do
   if containsSingleVowelSyllable(word) or containsHiatus(word) then
      word = removeSingleVowelSyllables(word)
      word = removeHiatus(word)
      if containsItalianHyphenation(word) then
         candidate = removeItalianHyphenation(word)
         if not contains(classical,candidate) then
            table.insert(classicalCandidates,candidate)
         end
         if containsNonItalianHyphenation(word) then
            candidate = removeNonItalianHyphenation(word)
            if not contains(italian,candidate) then
               table.insert(italianCandidates,candidate)
            end
         elseif not contains(italian,word) then
            table.insert(italianCandidates,word)
         end
      elseif containsNonItalianHyphenation(word) then
         if not contains(classical,word) then
            table.insert(classicalCandidates,word)
         end
         candidate = removeNonItalianHyphenation(word)
         if not contains(italian,candidate) then
            table.insert(italianCandidates,candidate)
         end
      elseif not contains(classical,word) or not contains(italian,word) then
         table.insert(classicalItalianCandidates,word)
      end
   elseif containsItalianHyphenation(word) then
      candidate = removeItalianHyphenation(word)
      if not contains(classical,candidate) then
         table.insert(classicalCandidates,candidate)
      end
      if containsNonItalianHyphenation(word) then
         candidate = removeNonItalianHyphenation(word)
         if not contains(italian,candidate) then
            table.insert(italianCandidates,candidate)
         end
      elseif not contains(italian,word) then
         table.insert(italianCandidates,word)
      end
   elseif containsNonItalianHyphenation(word) then
      if not contains(classical,word) then
         table.insert(classicalCandidates,word)
      end
      candidate = removeNonItalianHyphenation(word)
      if not contains(italian,candidate) then
         table.insert(italianCandidates,candidate)
      end
   else
      table.insert(classicalItalianCandidates,word)
   end
end

classicalItalianFile = "candidates-classical-italian.txt"
classicalFile = "candidates-classical.txt"
italianFile = "candidates-italian.txt"
accentFile = "candidates-accents.txt"

deleteFile(classicalItalianFile)
deleteFile(classicalFile)
deleteFile(italianFile)
deleteFile(accentFile)

writeHyphenationCandidates(classicalItalianFile,classicalItalianCandidates,true)
writeHyphenationCandidates(classicalFile,classicalCandidates,true)
writeHyphenationCandidates(italianFile,italianCandidates,true)
writeHyphenationCandidates(accentFile,missingAccentWords)
