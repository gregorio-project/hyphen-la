sort -o index_verborum index_verborum
lua5.3 flexura.lua < index_verborum | sort | uniq > index_formarum
lua5.3 divisio.lua --suppress-hiatus < index_formarum | lua5.3 variatio.lua | sort | uniq > patgen_input_classical
