function createSet (list)
   local set = {}
   for _, l in ipairs(list) do
      set[l] = true
   end
   return set
end

-- digraphs with macrons are not needed, as diphthongs are always long
vowels = createSet{"A","a","Ā","ā","E","e","Ē","ē","I","i","Ī","ī","O","o","Ō",
   "ō","U","u","Ū","ū","Y","y","Ȳ","ȳ","Æ","æ","Œ","œ"}

longVowels = createSet{"Ā","ā","Ē","ē","Ī","ī","Ō","ō","Ū","ū","Ȳ","ȳ"}

shortVowels = createSet{"A","a","E","e","I","i","O","o","U","u","Y","y"}

function contains_j(word)
   if string.find(word,"j") or string.find(word,"J") then
      return true
   else
      return false
   end
end

function contains_U_or_v(word) -- U/v are modern, V/u are classical
   if string.find(word,"v") or string.find(word,"U") or string.find(word,"Ū") then
      return true
   else
      return false
   end
end

function containsDigraph(word)
   if string.find(word,"Æ") or string.find(word,"æ")
   or string.find(word,"Œ") or string.find(word,"œ") then
      return true
   else
      return false
   end
end

function containsDiphthong(word)
   if string.find(word,"Au") or string.find(word,"au")
   or string.find(word,"Eu") or string.find(word,"eu") then
      return true
   else
      return false
   end
end

function firstCharacter(word)
   if utf8.len(word) > 1 then
      return string.sub(word,1,utf8.offset(word,2)-1)
   else
      return word
   end
end

function secondCharacter(word)
   if utf8.len(word) > 2 then
      return string.sub(word,utf8.offset(word,2),utf8.offset(word,3)-1)
   elseif utf8.len(word) == 2 then
      return string.sub(word,utf8.offset(word,2))
   else
      return nil
   end
end

function thirdCharacter(word)
   if utf8.len(word) > 3 then
      return string.sub(word,utf8.offset(word,3),utf8.offset(word,4)-1)
   elseif utf8.len(word) == 3 then
      return string.sub(word,utf8.offset(word,3))
   else
      return nil
   end
end

function splitHead(word)
   local c1 = firstCharacter(word)
   local c2 = secondCharacter(word)
   local head -- Au, au, Eu, eu, Æ·, æ·, ·æ, Œ·, œ·, ·œ, Qu, qu, gu, Su, su, or a single character
   local tail

   if (c1 == "A" or c1 == "a" or c1 == "E" or c1 == "e") and c2 == "u" then
      head = c1..c2
      if string.len(word) > 2 then
         tail = string.sub(word,3)
      else
         tail = ""
      end
   elseif utf8.len(word) > 2
   and (c1 == "Æ" or c1 == "æ" or c1 == "Œ" or c1 == "œ") and c2 == "·" then
      head = c1..c2
      tail = string.sub(word,utf8.offset(word,3))
   elseif c1 == "·" and (c2 == "æ" or c2 == "œ") then
      head = c1..c2
      if utf8.len(word) > 2 then
         tail = string.sub(word,utf8.offset(word,3))
      else
         tail = ""
      end
   elseif utf8.len(word) > 2 and (c1 == "Q" or c1 == "q") and c2 == "u" then
      head = c1..c2
      tail = string.sub(word,3)
   elseif utf8.len(word) > 2 and (c1 == "g" or c1 == "S" or c1 == "s")
   and c2 == "u" and vowels[thirdCharacter(word)] then
      head = c1..c2
      tail = string.sub(word,3)
   else
      head = c1
      if utf8.len(word) > 1 then
         tail = string.sub(word,utf8.offset(word,2))
      else
         tail = ""
      end
   end

   return head, tail
end

function containsLongVowel(word)
   for _, code in utf8.codes(word) do
      if longVowels[utf8.char(code)] then
         return true
      end
   end

   return false
end

function containsShortVowel(word)
   while word ~= "" do
      c, word = splitHead(word)
      if shortVowels[c] then
         return true
      end
   end

   return false
end

function insertVariants(list,character,endings)
   if next(endings) == nil then
      table.insert(list,character)
   else
      for _, ending in pairs(endings) do
         table.insert(list,character..ending)
      end
   end
end

function insertDigraphVariants(list,digraph,firstLetter,secondLetter,endingVariants,useDigraphs,digraphType,diphthongType)
   if useDigraphs then
      if digraphType == "plain" or mixedDiacritics then
         insertVariants(list,digraph,endingVariants)
      end
      if digraphType == "macron" or (mixedDiacritics and createMacronVariants) then
         if digraph == "Æ" then
            insertVariants(list,"Ǣ",endingVariants)
         elseif digraph == "æ" then
            insertVariants(list,"ǣ",endingVariants)
         else
            insertVariants(list,digraph..utf8.char(772),endingVariants)
         end
      end
   else
      insertDiphthongVariants(list,firstLetter,secondLetter,endingVariants,diphthongType)
   end
end

function insertDiphthongVariants(list,firstLetter,secondLetter,endingVariants,diphthongType)
   if diphthongType == "plain" or mixedDiacritics then
      insertVariants(list,firstLetter..secondLetter,endingVariants)
   end
   if diphthongType == "tie" or (mixedDiacritics and createTieVariants) then
      insertVariants(list,firstLetter..utf8.char(865)..secondLetter,endingVariants)
   end
   if diphthongType == "macron" or (mixedDiacritics and createMacronVariants) then
      insertVariants(list,firstLetter..utf8.char(862)..secondLetter,endingVariants)
   end
end

function createVariants(list,word,use_j,use_Uv,useDigraphs,useMacrons,useBreves,digraphType,diphthongType)
   if utf8.len(word) >= 1 then
      local c, ending = splitHead(word)
      local endingVariants = createVariants({},ending,use_j,use_Uv,useDigraphs,useMacrons,useBreves,digraphType,diphthongType)

      if longVowels[c] then
         -- variant without macron
         if not useMacrons or mixedDiacritics then
            if c == "Ā" then ch = "A"
            elseif c == "ā" then ch = "a"
            elseif c == "Ē" then ch = "E"
            elseif c == "ē" then ch = "e"
            elseif c == "Ī" then ch = "I"
            elseif c == "ī" then ch = "i"
            elseif c == "Ō" then ch = "O"
            elseif c == "ō" then ch = "o"
            elseif c == "Ū" then if use_Uv then ch = "U" else ch = "V" end
            elseif c == "ū" then ch = "u"
            elseif c == "Ȳ" then ch = "Y"
            elseif c == "ȳ" then ch = "y"
            end
            insertVariants(list,ch,endingVariants)
         end
         -- variant with macron
         if useMacrons then
            if c == "Ū" and not use_Uv then
               ch = "V̄"
            else
               ch = c
            end
            insertVariants(list,ch,endingVariants)
         end
      elseif shortVowels[c] then
         -- variant without breve
         if not useBreves or mixedDiacritics then
            if c == "U" and not use_Uv then
               ch = "V"
            else
               ch = c
            end
            insertVariants(list,ch,endingVariants)
         end
         -- variant with breve
         if useBreves then
            if c == "A" then ch = "Ă"
            elseif c == "a" then ch = "ă"
            elseif c == "E" then ch = "Ĕ"
            elseif c == "e" then ch = "ĕ"
            elseif c == "I" then ch = "Ĭ"
            elseif c == "i" then ch = "ĭ"
            elseif c == "O" then ch = "Ŏ"
            elseif c == "o" then ch = "ŏ"
            elseif c == "U" then if use_Uv then ch = "Ŭ" else ch = "V̆" end
            elseif c == "u" then ch = "ŭ"
            elseif c == "Y" then ch = "Y̆"
            elseif c == "y" then ch = "y̆"
            end
            insertVariants(list,ch,endingVariants)
         end
      elseif c == "Æ" then
         insertDigraphVariants(list,"Æ","A","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "æ" then
         insertDigraphVariants(list,"æ","a","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "Æ·" then
         insertDigraphVariants(list,"Æ","A","e-",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "æ·" then
         insertDigraphVariants(list,"æ","a","e-",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "·æ" then
         insertDigraphVariants(list,"æ","-a","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "Œ" then
         insertDigraphVariants(list,"Œ","O","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "œ" then
         insertDigraphVariants(list,"œ","o","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "Œ·" then
         insertDigraphVariants(list,"Œ","O","e-",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "œ·" then
         insertDigraphVariants(list,"œ","o","e-",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "·œ" then
         insertDigraphVariants(list,"œ","-o","e",endingVariants,useDigraphs,digraphType,diphthongType)
      elseif c == "Au" then
         insertDiphthongVariants(list,"A","u",endingVariants,diphthongType)
      elseif c == "au" then
         insertDiphthongVariants(list,"a","u",endingVariants,diphthongType)
      elseif c == "Eu" then
         insertDiphthongVariants(list,"E","u",endingVariants,diphthongType)
      elseif c == "eu" then
         insertDiphthongVariants(list,"e","u",endingVariants,diphthongType)
      elseif c == "J" then
         if use_j then
            insertVariants(list,"J",endingVariants)
         else
            insertVariants(list,"I",endingVariants)
         end
      elseif c == "j" then
         if use_j then
            insertVariants(list,"j",endingVariants)
         else
            insertVariants(list,"i",endingVariants)
         end
      elseif c == "v" then
         if use_Uv then
            insertVariants(list,"v",endingVariants)
         else
            insertVariants(list,"u",endingVariants)
         end
      elseif c == "." then -- syllable boundary that is no hyphenation point
         insertVariants(list,"",endingVariants)
      else
         insertVariants(list,c,endingVariants)
      end
   end

   return list
end

create_j_variants = true
create_v_variants = true
createDigraphVariants = true
createMacronVariants = true
createBreveVariants = true
createTieVariants = true
mixedDiacritics = false

-- read arguments from command line
i = 1
while arg[i] do
   if arg[i] == "--no-j" then
      create_j_variants = false
   elseif arg[i] == "--no-v" then
      create_v_variants = false
   elseif arg[i] == "--no-digraphs" then
      createDigraphVariants = false
   elseif arg[i] == "--no-macrons" then
      createMacronVariants = false
   elseif arg[i] == "--no-breves" then
      createBreveVariants = false
   elseif arg[i] == "--no-ties" then
      createTieVariants = false
   elseif arg[i] == "--mixed" then
      mixedDiacritics = true
   else
      error('Invalid argument "'..arg[i]..'".')
   end
   i = i+1
end

j_index = 5

-- read input line by line
linecount = 0
for word in io.lines() do
   linecount = linecount + 1

   local outputlist = {}

   for j_index = 0, 1 do
      if j_index == 0 or (create_j_variants and contains_j(word)) then
         for v_index = 0, 1 do
            if v_index == 0 or (create_v_variants and contains_U_or_v(word)) then
               for digraphIndex = 0, 1 do
                  if digraphIndex == 0 or (createDigraphVariants and containsDigraph(word)) then
                     local use_j = j_index > 0
                     local use_Uv = v_index > 0
                     local useDigraphs = digraphIndex > 0

                     if mixedDiacritics then
                        outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,createMacronVariants,createBreveVariants,"","")
                     else
                        -- (1) variant without macrons and breves
                        outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,false,false,"plain","plain")
                        -- (2) variant with ties on diphthongs, but without macrons and breves
                        if createTieVariants and ((not useDigraphs and containsDigraph(word)) or containsDiphthong(word)) then
                           outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,false,false,"plain","tie")
                        end
                        if createMacronVariants and containsLongVowel(word) then
                           -- (3) variant with macrons, but without breves
                              outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,true,false,"plain","plain")
                           -- (4) variant with macrons and with ties on diphthongs, but without breves
                           if createTieVariants and ((not useDigraphs and containsDigraph(word)) or containsDiphthong(word)) then
                              outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,true,false,"plain","tie")
                           end
                        end
                        -- (5) variant with macrons even on digraphs, but without breves
                        if createMacronVariants and useDigraphs then
                           outputlist = createVariants(outputlist,word,use_j,use_Uv,true,true,false,"macron","plain")
                        end
                        -- (6) variant with macrons even on digraphs and diphthongs, but without breves
                        if createMacronVariants and ((not useDigraphs and containsDigraph(word)) or containsDiphthong(word)) then
                           outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,true,false,"macron","macron")
                        end
                        if createBreveVariants and containsShortVowel(word) then
                           -- (7) variant with (macrons and) breves
                           outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,createMacronVariants,true,"plain","plain")
                           -- (8) variant with (macrons and) breves and with ties on diphthongs
                           if createTieVariants and ((not useDigraphs and containsDigraph(word)) or containsDiphthong(word)) then
                              outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,true,true,"plain","tie")
                           end
                           -- (9) variant with macrons even on digraphs and with breves
                           if createMacronVariants and useDigraphs then
                              outputlist = createVariants(outputlist,word,use_j,use_Uv,true,true,true,"macron","plain")
                           end
                           -- (10) variant with macrons even on digraphs and diphthongs and with breves
                           if createMacronVariants and ((not useDigraphs and containsDigraph(word)) or containsDiphthong(word)) then
                              outputlist = createVariants(outputlist,word,use_j,use_Uv,useDigraphs,true,true,"macron","macron")
                           end
                        end
                     end
                  end
               end
            end
         end
      end
   end

   for _, word in pairs(outputlist) do
      print(word)
   end
end
