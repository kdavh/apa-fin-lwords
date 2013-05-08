

# dict = []
# file = "eng_2of12.txt"


# File.foreach(file) do |line| 
#   line = line.strip
#   if line.length >= 3 && line.index(/[-']/) == nil
#     dict << line 
#   end
# end
# dict = " #{dict.join(' ')} "

# File.open('eng-dict', 'w') do |f|
#   f << dict
# end

p File.open('eng-dict').read
