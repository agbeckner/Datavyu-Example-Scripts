## Parameters
# hash map from transcribeQA codes to allowed arguments
code_map = {'onseterror' => %w(y .),
  'speakererror' => %w(y .),
  'parsingerror' => %w(y .),
  'contenterror' => %w(y .),
  'missingextrautterance' => %w(y .)
}

## Body
require 'Datavyu_API.rb'

transc_qa = get_column('transc_qa')

puts "Checking transc_qa for typos..."
transc_qa.cells.each do |c|
  unless c.arglist.map{ |a| code_map[a].include?(c.get_code(a)) }.all?
    puts "Typo in transc_qa cell #{c.ordinal}"
  end
end
