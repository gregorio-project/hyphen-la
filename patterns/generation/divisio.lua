function createSet (list)
   local set = {}
   for _,l in ipairs(list) do
      set[l] = true
   end
   return set
end

-- digraphs with macrons are not needed, as diphthongs are always long
vowels = createSet{"A", "a", "Ā", "ā", "E", "e", "Ē", "ē", "I", "i", "Ī", "ī",
   "O", "o", "Ō", "ō", "U", "u", "Ū", "ū", "Y", "y", "Ȳ", "ȳ", "Æ", "æ", "Œ",
   "œ"}

digraphs = createSet{"Æ", "æ", "Œ", "œ"}

-- possible diphthongs are "au" and "eu", macrons are not used
firstVowelsOfDiphthongs = createSet{"A", "a", "E", "e"}

-- q is intentionally left out here
consonants = createSet{"B", "b", "C", "c", "D", "d", "F", "f", "G", "g", "H",
   "h", "J", "j", "K", "k", "L", "l", "M", "m", "N", "n", "P", "p", "R", "r",
   "S", "s", "T", "t", "V", "v", "W", "w", "X", "x", "Z", "z"}

-- stop consonants, called "(litterae) mutae" in Latin
mutae = createSet{"B", "b", "P", "p", "D", "d", "T", "t", "G", "g", "C", "c",
   "K", "k"}

-- the voiceless stop consonants are aspirated when h follows
voicelessStops = createSet{"P", "p", "T", "t", "C", "c"}

-- liquid consonants, called "(litterae) liquidae" in Latin
liquidae = createSet{"L", "l", "R", "r"}

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
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output..c
            state = "vowel"
         elseif consonants[c] == true then
            output = output..c
            -- the state stays the same
         else
            invalidWord(word)
         end
      -- read s at beginning; u may follow
      elseif state == "potential su at beginning" then
         if c == "U" or c == "u" then
            output = output..c
            state = "potential nonsyllabic u"
         elseif c == "Q" or c == "q" then
            output = output..c
            state = "potential qu"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output..c
            state = "vowel"
         elseif consonants[c] == true then
            output = output..c
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read a or e; u may follow and form a diphthong
      elseif state == "potential diphthong" then
         if c == "U" or c == "u" then
            output = output..c
            state = "vowel"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..c
            -- the state stays the same
         elseif vowels[c] == true then
            output = output.."-"..c
            state = "vowel"
         elseif c == "Q" or c == "q" then
            output = output.."-"..c
            state = "potential qu"
         elseif c == "S" or c == "s" then
            store = c
            state = "potential su"
         elseif c == "N" or c == "n" then
            store = c
            state = "potential ng"
         elseif c == "R" or c == "r" then
            store = c
            state = "potential rh"
         elseif voicelessStops[c] == true then
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
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
         if c == "Q" or c == "q" then
            output = output.."-"..c
            state = "potential qu"
         elseif c == "S" or c == "s" then
            store = c
            state = "potential su"
         elseif c == "N" or c == "n" then
            store = c
            state = "potential ng"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..c
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..c
            -- the state stays the same
         elseif c == "R" or c == "r" then
            store = c
            state = "potential rh"
         elseif voicelessStops[c] == true then
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
            store = c
            state = "consonant"
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
      -- read q; u has to follow
      elseif state == "potential qu" then
         if c == "U" or c == "u" then
            output = output..c
            state = "qu"
         else
            invalidWord(word)
         end
      -- read s; u may follow
      elseif state == "potential su" then
         if c == "U" or c == "u" then
            output = output.."-"..store..c
            store = ""
            state = "potential nonsyllabic u"
         elseif c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            -- the state stays the same
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "R" or c == "r" then
            output = output..store
            store = c
            state = "potential rh"
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
            output = output..store
            store = c
            state = "consonant"
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."-"
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
         elseif c == "-" then -- word boundary
            output = output..store.."="
            store = ""
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read qu; vowel has to follow
      elseif state == "qu" then
         if firstVowelsOfDiphthongs[c] == true then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output..c
            state = "vowel"
         else
            invalidWord(word)
         end
      -- read r; h may follow
      elseif state == "potential rh" then
         if c == "H" or c == "h" then
            store = store..c
            state = "consonant"
         elseif c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "R" or c == "r" then
            output = output..store
            store = c
            -- the state stays the same
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
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
      -- read c, p, or t; h may follow
      elseif state == "potential aspirate" then
         if c == "H" or c == "h" then
            store = store..c
            state = "potential muta cum liquida"
         elseif liquidae[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            -- the state stays the same
         elseif mutae[c] == true then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
            output = output..store
            store = c
            state = "consonant"
         else
            invalidWord(word)
         end
      -- read muta; liquida may follow
      elseif state == "potential muta cum liquida" then
         if liquidae[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "muta cum liquida"
         elseif c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            output = output..store
            store = c
            -- the state stays the same
         elseif consonants[c] == true then
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
      -- read muta cum liquida
      elseif state == "muta cum liquida" then
         if firstVowelsOfDiphthongs[c] == true then
            output = output..c
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output..c
            state = "vowel"
         else
            invalidWord(word)
         end
      -- read "n" after a vowel; "gu" + vowel may follow and lead
      -- to a nonsyllabic u
      elseif state == "potential ng" then
         if c == "G" or c == "g" then
            output = output..store
            store = c
            state = "potential ngu"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif c == "R" or c == "r" then
            output = output..store
            store = c
            state = "potential rh"
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
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
      -- read "ng"; "u" + vowel may follow and lead to a nonsyllabic u
      elseif state == "potential ngu" then
         if c == "U" or c == "u" then
            output = output.."-"..store..c
            store = ""
            state = "potential nonsyllabic u"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif liquidae[c] == true then
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
         if vowels[c] == true then
            output = output..c
            state = "vowel"
         elseif c == "N" or c == "n" then
            store = c
            state = "potential ng"
         elseif liquidae[c] == true or c == "M" or c == "m" or c == "S"
            or c == "s" then
            store = c
            state = "consonant"
         elseif c == "|" then -- u is a syllabic vowel
            state = "vowel"
         elseif c == "-" then
            output = output.."="
            state = "beginning"
         else
            invalidWord(word)
         end
      -- read consonant after the last vowel of the syllable
      elseif state == "consonant" then
         if c == "Q" or c == "q" then
            output = output..store.."-"..c
            store = ""
            state = "potential qu"
         elseif c == "S" or c == "s" then
            output = output..store
            store = c
            state = "potential su"
         elseif firstVowelsOfDiphthongs[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "potential diphthong"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         elseif c == "R" or c == "r" then
            output = output..store
            store = c
            state = "potential rh"
         elseif voicelessStops[c] == true then
            output = output..store
            store = c
            state = "potential aspirate"
         elseif mutae[c] == true then
            output = output..store
            store = c
            state = "potential muta cum liquida"
         elseif consonants[c] == true then
            output = output..store
            store = c
            -- the state stays the same
         elseif c == "^" then -- extraordinary hyphenation point for Greek words
            if greek then
               output = output..store.."-"
               store = ""
               state = "beginning"
            end -- the state stays the same if greek is false
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

   for i, code in utf8.codes(input) do
      local c = utf8.char(code)

      if state == "beginning" then
         if digraphs[c] == true then
            output = output..c
            state = "digraph at beginning"
         elseif vowels[c] == true then
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
            -- suppress hyphen
            state = "normal"
         elseif c == "=" then
            -- suppress hyphen
            state = "beginning"
         else
            output = output..c
            state = "normal"
         end
      elseif state == "vowel" then
         if c == "=" then
            output = output.."-"
            state = "beginning"
         elseif c == "-" then
            state = "hyphen after vowel"
         elseif vowels[c] == true then
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
         elseif vowels[c] == true then
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
            output = output..store.."-"
            store = ""
            state = "beginning"
         elseif c == "-" then
            output = output..store
            store = ""
            state = "hyphen after vowel"
         elseif vowels[c] == true then
            output = output.."-"..store..c
            store = ""
            state = "vowel"
         else
            output = output.."-"..store..c
            store = ""
            state = "normal"
         end
      elseif state == "hyphen after digraph at beginning" then
         if vowels[c] == true then
            output = output..c
            state = "vowel"
         else
            output = output.."·"..c
            state = "normal"
         end
      elseif state == "hyphen after vowel" then
         if digraphs[c] == true then
            if suppressHiatus then
               output = output..c
               state = "vowel"
            else
               store = c
               state = "potential single digraph"
            end
         elseif vowels[c] == true then
            if suppressHiatus then
               output = output..c
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
         elseif vowels[c] == true then
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
      output = output..store
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
for word in io.lines() do
   linecount = linecount + 1
   hyphenatedWord = classicalHyphenation(word)

   if chant then
      hyphenatedWord = string.gsub(hyphenatedWord,"=","-")
   else
      hyphenatedWord = removeUnwantedHyphens(hyphenatedWord)
   end

   print(hyphenatedWord)
end
