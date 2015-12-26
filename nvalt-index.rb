#!/usr/bin/env ruby
# Written by James Scott-Brown
require 'optparse'

 options = {}

 optparse = OptionParser.new do|opts|
   opts.banner = "Usage: nvtool.rb command [options]\n Command is either --tabulate, or --links\n"

   options[:tabulate] = false
   opts.on( '-t', '--tabulate', 'Tabulate metadata in notes (must specify a --tag)' ) do
     options[:tabulate] = true
   end

   options[:links] = false
   opts.on( '-l', '--links', 'Produce graphviz .dot file representing links between notes' ) do
     options[:links] = true
   end

   options[:dir] = "~/Library/Application\ Support/Notational\ Data/"
   opts.on( '-D', '--dir directory', 'Path to directory containing notes. Defaults to ~/Library/Application\ Support/Notational\ Data/' ) do |file|
     options[:dir] = file
   end

   opts.on_tail( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 end

 optparse.parse!
 
 options[:cutoff] = 2

 excludedFiles = ["Notes & Settings", ".DS_Store", "Interim Note-Changes", "Index.md"]
 path = File.expand_path( options[:dir] )


 def graphLinks(path, excludedFiles)
	puts "digraph {"

	Dir.new(path).each { |file|    
	  unless File::directory?(path+'/'+file) or excludedFiles.rindex(file)
	     File.open(path+'/'+file).each{ |line| 
	        
	        sourceFileName = file.chomp(File.extname(file) )
			links = line.scan(/\[\[(.+?)\]\]/)
	        links.each{ |link|  
	        	targetFileName = link[0].to_s
	        	if Dir.glob(path + '/' +  targetFileName + '.*').any?
	        		print '"' + sourceFileName + '" -> "' + targetFileName + '";' + "\n"
	        	end	        	
	        }
	             
	     }
	  end
	}

	puts "}"
end


def tabulateAll(path, excludedFiles, options)
	totals, tagged = countTags(path, excludedFiles, options)

	totals.sort{|a,b| b[1]<=>a[1]}.each{ |elem|
		title = elem[0][0][1..-1]
		count = elem[1]
	  	puts "# #{title} (#{count})"

	  	options[:tag] = "#" + title
	  	tabulate(path, excludedFiles, options)

	  	puts "\n\n\n\n"
	}

end


def countTags(path, excludedFiles, options)
	totals=Hash.new
	tagged=Hash.new

	Dir.new(path).each { |file|    
	    
	  unless File::directory?(path+'/'+file) or excludedFiles.rindex(file)
	    File.read(path+'/'+file).scan(/(#[a-zA-Z0-9_]+?)\W*?(?=#|\n)/).each{ |tag|
	      if tag.to_s.length>1
	        totals[tag] = totals[tag].nil? ? (1):(totals[tag]+1)
	        tagged[tag] = tagged[tag].nil? ? (file):(tagged[tag] + "\n#{file}" )
	      end 
	    }
	  end
	}

    totals.reject!{ |tag, count| count < options[:cutoff]}

	return totals, tagged
end
 

def tabulate(path,excludedFiles,options)
    abort("Must specify a tag for the tabulate command") if options[:tag].empty? 

	filenumber=0
	keys=Array.new
	keys[0]='File'
	file_data = Hash.new
	data = Hash.new

	Dir.new(path).each { |file|    
	    
	  unless File::directory?(path+'/'+file) or excludedFiles.rindex(file)
	    header = 1
	    file_data.clear
	    
	     File.open(path+'/'+file).each{ |line| 

	        #first read in any line that looks like "Key: Value" and and store it as file_data[key]=value 
	          if (header==1)  
	            if line =~ /.:./
	              line =~ /([^:\n]+?):([^\n]+\n)/
	              file_data[$1]=$2
	            else
	              header=0
	            end
	          end

	          #then, if we find the hash-tag in the file, we save the file_data hash into the data hash
	          #the (key, value) pair is stored as data[filenumber, index]=value, where keys[index]=key
	          if header==0 and line.include?(options[:tag])
	            data[[filenumber, 0]] = file.chomp(File.extname(file) )

	            file_data.each_pair {|key, value| 
	              keys.push(key) if keys.index(key).nil?
	              data[[filenumber, keys.index(key)]] = value.chomp
	            }
	            filenumber=filenumber+1
	          end
	     }
	  end
	}

	#Finally, dump out all that data
	printTable(keys,filenumber,data)
	
end


def printTable(keys,filenumber,data)

	puts "|" + keys.join("|") + "|"

	listOfDashes = ["-"] * keys.length()
	puts "|" + listOfDashes.join("|") + "|"

	for i in 0..(filenumber-1)

	  print "| [[" + (data[[i, 0]].nil? ? (" "):( data[[i, 0]]) ) + "]] "

	  for j in 1..(keys.length-2)
	    print " | " + (data[[i, j]].nil? ? (" "):( data[[i, j]]) )
	  end   

	  print " | " + (data[[i, keys.length-1]].nil? ? (" "):(data[[i, keys.length-1]]) )  + " | \n"
	end
end


if options[:tabulate]
    tabulateAll(path, excludedFiles, options)
elsif options[:links]
	graphLinks(path, excludedFiles)
else
	puts optparse.help()
end
