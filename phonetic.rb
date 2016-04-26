#!/usr/bin/env ruby

# Author: Raul Cioldin (rcioldin@daitangroup.com)

class PhoneticSearch
	# searches phonetic word similarities	

	# letters that should be discarded in step 3
	@@discard_list = 'aeihouwy'

	# letter equivalences for step 4
	@@equivalence_groups =  {		
		"a" => "1", "e" => "1", "i" => "1", "o" => "1", "u" => "1", # 1		
		"c" => "2", "g" => "2", "j" => "2", "k" => "2", "q" => "2", 
		"s" => "2", "x" => "2", "y" => "2", "z" => "2", # 2
		"b" => "3", "f" => "3", "p" => "3", "v" => "3", "w" => "3", # 3
		"d" => "4", "t" => "4", # 4
		"m" => "5", "n" => "5" # 5
	}
	
	def initialize(args)		
		@raw_dictionary = []
		# collecting dictionary words from std stream
		while STDIN.gets
			@raw_dictionary << $_
		end	

		# script arguments
		@raw_words = args
	end

	def run				
		# parsing dictionary
		@dictionary = {}
		for raw_dict_word in @raw_dictionary
			raw_dict_word = raw_dict_word.strip # removes new line			
			encoded = self.parse(raw_dict_word)
			# use encoded word as key with original word as value
			# checks key ocurrence
			if @dictionary.has_key?(encoded)
				# appends to an existing array
				@dictionary[encoded] << raw_dict_word
			else
				# creates an array				
				@dictionary[encoded] = [raw_dict_word]
			end
		end		

		# parsing word arguments
		for word in @raw_words			
			encoded = self.parse(word)
			results = @dictionary[encoded]
			if not results.nil?
				puts "#{word}: #{results.join(" ")}"
			else
				puts "no equivalent for #{word} found"
			end
		end
	end

	def parse(word)		
		# steps 1 and 2
		# sanitizes word via letters regex match
		# (ignores alphabetic unicode letters)
		word = word.gsub(/[^a-zA-Z ]/,'').downcase # also lowercases the string	

		# step 3
		# drop all occurrences of 'discard list' after first letter
		word = word[0] + word[1..-1].tr(@@discard_list, '')

		return self.encode(word)
	end

	def encode(word)
		# encodes words according to equivalence groups
		encoded_word = ""
		# iterating over each letter
		word.each_char { |letter|
			# step 4
			# gets code for letter
			code = @@equivalence_groups[letter]
			# checks code equivalent
			if not code.nil?								
				# index-replaces letter by code
				encoded_word << code
			else
				# no code equivalent
				encoded_word << letter
			end

			# step 5
			# checking adjacent duplicates
			unless encoded_word.length == 1 # unless word is a single letter
				if encoded_word[-1] == encoded_word[-2]
					# duplicate		
					encoded_word = encoded_word[0..-2]
				end
			end			
		}		
		return encoded_word
	end
end

ps = PhoneticSearch.new(ARGV)
ps.run