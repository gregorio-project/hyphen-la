function createSet (list)
   local set = {}
   for _, l in ipairs(list) do
      set[l] = true
   end
   return set
end

function lastCharacter(word)
   return string.sub(word,utf8.offset(word,-1))
end

combiningAcute = utf8.char(769)

-- digraphs with macrons are not needed, as diphthongs are always long
vowels = createSet{"A","a","á","Ā","ā","E","e","Ē","ē","I","i","Ī","ī","í","O","o","Ō",
   "ō","U","u","ú","Ū","ū","Y","y","Ȳ","ȳ","Æ","æ","ǽ","Œ","œ"}

vowelsNeedingCombiningAccent = createSet{"ā","ē","ī","ō","ū","ū","ȳ","œ"}

digraphs = createSet{"Æ","æ","Œ","œ"}

-- possible diphthongs are "au" and "eu", macrons are not used
firstVowelsOfDiphthongs = createSet{"A","a","E","e"}

-- q is intentionally left out here
consonants = createSet{"B","b","C","c","D","d","F","f","G","g","H","h","J","j",
   "K","k","L","l","M","m","N","n","P","p","R","r","S","s","T","t","V","v","W",
   "w","X","x","Z","z"}

-- the voiceless stop consonants are aspirated when h follows
voicelessStops = createSet{"p","t","c","k"}

-- liquid consonants, called "(litterae) liquidae" in Latin
liquidae = createSet{"L","l","R","r"}

function addHyphenation(hyphenatedWord,comment)
   print(hyphenatedWord..comment)
end

function invalidWord(word)
   error('Invalid word "'..word..'" in line '..linecount)
end

-- insert hyphens using a finite-state machine
function classicalHyphenation(word)
   local state = "beginning"
   local output = ""
   local store = ""

   for _, code in utf8.codes(word) do
      local c = utf8.char(code)

      -- beginning of the syllable, waiting for a vowel
      if state == "beginning" then
         if c == "Q" or c == "q" then
            output = output..c
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..c
            state = "potential su at beginning"
         elseif firstVowelsOfDiphthongs[c] then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         elseif consonants[c] then
            output = output..c
            -- the state stays the same
         elseif c == "-" then -- shortened prefix (e.g. "d-ēmō")
            output = output.."&"
            -- the state stays the same
         else
            invalidWord(word)
         end
      -- read s at beginning; u may follow
      elseif state == "potential su at beginning" then
         if c == "u" then
            output = output..c
            state = "potential nonsyllabic u"
         elseif c == "q" then
            output = output..c
            state = "potential qu"
         elseif firstVowelsOfDiphthongs[c] then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         elseif consonants[c] then
            output = output..c
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read a or e; u may follow and form a diphthong
      elseif state == "potential diphthong" then
         if c == "u" then
            output = output..c
            state = "vowel"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..c
            -- the state stays the same
         elseif vowels[c] then
            output = output.."-"..c
            state = "vowel"
         elseif c == "q" then
            output = output.."-"..c
            state = "potential qu"
         elseif c == "s" then
            store = c
            state = "potential su"
         elseif c == "n" then
            store = c
            state = "potential ng"
         elseif c == "r" then
            store = c
            state = "potential rh"
         elseif voicelessStops[c] then
            store = c
            state = "potential aspirate"
         elseif c == "g" then
            store = c
            state = "potential gn"
         elseif c == "b" or c == "d" then
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] then
            store = c
            state = "consonant"
         elseif c == "|" then -- divide diphthong
            state = "vowel"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output.."-"
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "-" then -- word boundary
            output = output.."="
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read single vowel or second vowel of a diphthong
      elseif state == "vowel" then
         if c == "q" then
            output = output.."-"..c
            state = "potential qu"
         elseif c == "s" then
            store = c
            state = "potential su"
         elseif c == "n" then
            store = c
            state = "potential ng"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..c
            -- the state stays the same
         elseif c == "r" then
            store = c
            state = "potential rh"
         elseif voicelessStops[c] then
            store = c
            state = "potential aspirate"
         elseif c == "g" then
            store = c
            state = "potential gn"
         elseif c == "b" or c == "d" then
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] then
            store = c
            state = "consonant"
         elseif c == combiningAcute and vowelsNeedingCombiningAccent[lastCharacter(output)] then -- combining acute
            output = output..c
            -- the state stays the same
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output.."-"
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output.."-"
            else
               output = output..c
            end
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output.."="
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read q; u has to follow
      elseif state == "potential qu" then
         if c == "u" then
            output = output..c
            state = "qu"
         else
            invalidWord(word)
         end
      -- read s; u may follow
      elseif state == "potential su" then
         if c == "u" then
            output = output.."-"..store..c
            store = ""
            state = "potential nonsyllabic u"
         elseif c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "s" then
            output = output..store
            store = c
            -- the state stays the same
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif voicelessStops[c] then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif c == "b" or c == "d" then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif c == "m" then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output..store.."-"
               store = ""
            else
               output = output..store..c
               store = ""
            end
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read qu; vowel has to follow
      elseif state == "qu" then
         if firstVowelsOfDiphthongs[c] then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         elseif c == "-" then -- word boundary, hyphenation point suppressed
            if not chant then
               output = output.."&"
            end
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read r; h may follow
      elseif state == "potential rh" then
         if c == "h" then
            store = store..c
            state = "consonant"
         elseif c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "r" then
            output = output..store
            store = c
            -- the state stays the same
         elseif voicelessStops[c] then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif c == "g" then
            output = output..store
            store = c
            state = "potential gn"
         elseif c == "b" or c == "d" then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output..store.."-"
               store = ""
            else
               output = output..store..c
               store = ""
            end
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read c, p, or t; h may follow
      elseif state == "potential aspirate" then
         if c == "h" then
            store = store..c
            state = "potential muta cum liquida"
         elseif liquidae[c] then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif voicelessStops[c] then
            output = output..store
            store = c
            -- the state stays the same
         elseif c == "m" or c == "n" then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "-" then
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "g"
      elseif state == "potential gn" then
         if c == "n" then
            output = output..store.."-"..c
            store = ""
            state = "gn"
         elseif liquidae[c] then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "g" then
            output = output..store
            store = c
            -- the state stays the same
         elseif c == "d" then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif c == "m" then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "-" then
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "b", "d", "g", "ph", "th", or "ch"
      elseif state == "potential muta cum liquida" then
         if liquidae[c] then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "t" then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif c == "b" or c == "d" or c == "g" then
            output = output..store
            store = c
            -- the state stays the same
         elseif c == "h" or c == "m" or c == "n" then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output..store.."-"
            else
               output = output..store..c
            end
            store = ""
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read muta cum liquida
      elseif state == "muta cum liquida" then
         if firstVowelsOfDiphthongs[c] then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            -- the state stays the same, the hyphenation point is ignored
         elseif c == "-" then -- word boundary, hyphenation point suppressed
            if not chant then
               output = output.."&"
            end
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "gn"
      elseif state == "gn" then
         if firstVowelsOfDiphthongs[c] then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         elseif c == "-" then -- word boundary, hyphenation point suppressed
            if not chant then
               output = output.."&"
            end
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "n" after a vowel; "gu" + vowel may follow and lead
      -- to a nonsyllabic u
      elseif state == "potential ng" then
         if c == "g" then
            output = output..store
            store = c
            state = "potential ngu"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif voicelessStops[c] then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif c == "d" then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif c == "f" or c == "n" or c == "x" then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output..store.."-"
            else
               output = output..store..c
            end
            store = ""
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "ng"; "u" + vowel may follow and lead to a nonsyllabic u
      elseif state == "potential ngu" then
         if c == "u" then
            output = output.."-"..store..c
            store = ""
            state = "potential nonsyllabic u"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif liquidae[c] then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif c == "-" then
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "ngu" or "su"; vowel may follow and lead to a nonsyllabic u
      elseif state == "potential nonsyllabic u" then
         if vowels[c] then
            output = output..c
            state = "vowel"
         elseif c == "s" then
            store = c
            state = "potential su"
         elseif c == "n" then
            store = c
            state = "potential ng"
         elseif c == "r" then
            store = c
            state = "potential rh"
         elseif voicelessStops[c] then
            store = c
            state = "potential aspirate"
         elseif c == "b" then
            store = c
            state = "potential muta cum liquida"
         elseif c == "l" or c == "m" then
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output.."-"
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "|" then -- u is a syllabic vowel
            state = "vowel"
         elseif c == "-" then -- word boundary
            output = output.."="
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read "~", j has to follow
      elseif state == "word boundary before ji" then
         if c == "j" then
            output = output..c
            state = "j before i"
         else
            invalidWord(word)
         end
      -- read "~j", i has to follow
      elseif state == "j before i" then
         if c == "i" then
            output = output..c
            state = "ji"
         else
            invalidWord(word)
         end
      -- read "~ji", c has to follow
      elseif state == "ji" then
         if c == "c" then
            if chant then
               output = output.."-"..c
            else
               output = output.."·"..c
            end
            state = "jic"
         else
            invalidWord(word)
         end
      -- read "~jic", vowel has to follow
      elseif state == "jic" then
         if vowels[c] then
            output = output..c
            state = "vowel"
         else
            invalidWord(word)
         end
      -- read consonant after the last vowel of the syllable
      elseif state == "consonant" then
         if c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "r" then
            output = output..store
            store = c
            state = "potential rh"
         elseif voicelessStops[c] then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif c == "b" or c == "d" or c == "g" then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] then
            output = output..store
            store = c
            -- the state stays the same
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."="
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "~" then -- word boundary before "ji"
            if chant then
               output = output..store.."-"
            else
               output = output..store..c
            end
            store = ""
            state = "word boundary before ji"
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      end

      if traceStates then
         io.write(output)
         if store ~= "" then
            io.write("[",store,"]")
         end
         io.write(" (",state,") ")
      end
   end

   -- return the hyphenated word if a final state was reached
   if state == "potential diphthong" or state == "vowel"
   or state == "potential su" or state == "potential ng"
   or state == "potential rh" or state == "potential aspirate"
   or state == "potential muta cum liquida" or state == "consonant" then
      output = output..store

      if traceStates then
         print(output)
      end

      return output
   else
      invalidWord(word)
   end
end

-- remove typographically unwanted hyphens using a finite-state machine
function removeUnwantedHyphens(input)
   local state = "beginning"
   local store = ""
   local output = ""

   for _, code in utf8.codes(input) do
      local c = utf8.char(code)

      if state == "beginning" then
         if digraphs[c] then
            output = output..c
            state = "digraph at beginning"
         elseif vowels[c] then
            output = output..c
            state = "vowel at beginning"
         else
            output = output..c
            state = "normal"
         end
      elseif state == "digraph at beginning" then
         if c == "-" then
            state = "hyphen after digraph at beginning"
         else
            output = output..c
            state = "normal"
         end
      elseif state == "vowel at beginning" then
         if c == "-" then
            output = output.."."
            state = "normal"
         elseif c == "=" then
            output = output.."."
            state = "beginning"
         elseif c == "~" then -- word boundary before "ji"
            output = output.."_"
            state = "beginning"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         else
            output = output..c
            state = "normal"
         end
      elseif state == "vowel" then
         if c == "=" then
            output = output.."-"
            state = "beginning"
         elseif c == "&" then
            state = "beginning"
         elseif c == "-" then
            state = "hyphen after vowel"
         elseif vowels[c] then
            output = output..c
            -- the state stays the same
         else
            output = output..c
            state = "normal"
         end
      elseif state == "potential single digraph" then
         if c == "=" then
            output = output.."·"..store.."-"
            store = ""
            state = "beginning"
         elseif c == "-" then
            output = output.."·"..store
            store = ""
            state = "hyphen after vowel"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         else
            output = output.."-"..store..c
            store = ""
            state = "normal"
         end
      elseif state == "potential single vowel" then
         if c == "=" then
            output = output.."."..store.."-"
            store = ""
            state = "beginning"
         elseif c == "-" then
            output = output.."."..store
            store = ""
            state = "hyphen after vowel"
         elseif vowels[c] then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         else
            output = output.."-"..store..c
            store = ""
            state = "normal"
         end
      elseif state == "hyphen after digraph at beginning" then
         if vowels[c] then
            output = output..c
            state = "vowel"
         else
            output = output.."·"..c
            state = "normal"
         end
      elseif state == "hyphen after vowel" then
         if digraphs[c] then
            if suppressHiatus then
               output = output.."."..c
               state = "vowel"
            else
               store = c
               state = "potential single digraph"
            end
         elseif vowels[c] then
            if suppressHiatus then
               output = output.."."..c
               state = "vowel"
            else
               store = c
               state = "potential single vowel"
            end
         else
            output = output.."-"..c
            state = "normal"
         end
      elseif state == "normal" then
         if c == "=" then
            output = output.."-"
            state = "beginning"
         elseif c == "&" then
            state = "beginning"
         elseif vowels[c] then
            output = output..c
            state = "vowel"
         else
            output = output..c
            -- the state stays the same
         end
      end

      if traceStates then
         io.write(output)
         if store ~= "" then
            io.write("[",store,"]")
         end
         io.write(" (",state,") ")
      end
   end

   if state == "potential single vowel" then
      output = output.."."..store
   elseif state == "potential single digraph" then
      output = output.."·"..store
   elseif state == "vowel at beginning" and string.find(output,"-") then
      output = string.sub(output,1,utf8.offset(output,-2)-1).."."..string.sub(output,utf8.offset(output,-1))
   end

   if traceStates then
      print(output)
   end

   return output
end

-- read arguments from command line
i = 1
while arg[i] do
   if arg[i] == "--trace-states" then
      traceStates = true
   elseif arg[i] == "--chant" then
      chant = true
   elseif arg[i] == "--greek" then
      greek = true
   elseif arg[i] == "--suppress-hiatus" then
      suppressHiatus = true
   else
      error('Invalid argument "'..arg[i]..'".')
   end
   i = i+1
end

-- read input line by line
linecount = 0
for line in io.lines() do
   linecount = linecount + 1
   local i = string.find(line," ")
   if i then
      word = string.sub(line,1,i-1)
      comment = string.sub(line,i)
   else
      word = line
      comment = ""
   end

   hyphenatedWord = classicalHyphenation(word)

   if chant then
      hyphenatedWord = string.gsub(hyphenatedWord,"=","-")
      hyphenatedWord = string.gsub(hyphenatedWord,"&","")
   else
      hyphenatedWord = removeUnwantedHyphens(hyphenatedWord)
   end

   addHyphenation(hyphenatedWord,comment)
end
