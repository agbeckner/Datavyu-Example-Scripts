# Also include the total number of error free utterances

## Parameters

codes_to_check = %w[onseterror speakererror parsingerror contenterror
  missingextrautterance]

## Body
require 'Datavyu_API.rb'

# get total transcriptions
transc_qa = get_column('transc_qa')
total = transc_qa.cells.length

# get total mom/child transcriptions
transcribe_clean = get_column('transcribe_clean')
ordinals_mom = transcribe_clean.cells.select{ |c| c.source_mc == 'm' }.map{
  |x| x.ordinal }
ordinals_child = transcribe_clean.cells.select{ |c| c.source_mc == 'c' }.map{
  |x| x.ordinal }
total_mom = ordinals_mom.length
total_child = ordinals_child.length

# get errors by source and code
error_total = {}
error_mom = {}
error_child = {}
codes_to_check.each do |code|
  error_total[code] = transc_qa.cells.select{ |x| x.get_code(code) == 'y' }.length
  error_mom[code] = transc_qa.cells.select{ |x| x.get_code(code) == 'y' &&
    ordinals_mom.include?(x.ordinal) }.length
  error_child[code] = transc_qa.cells.select{ |x| x.get_code(code) == 'y' &&
    ordinals_child.include?(x.ordinal) }.length
end

# get number of error free cells
error_free = transc_qa.cells.reject{ |x| codes_to_check.map { |c|
  x.get_code(c) == 'y' }.any? }.length

perc_free = (100*error_free.to_f/total).round(1)
puts "Of the #{total} total transcriptions, #{error_free} contain no errors (#{perc_free}%)."
puts "\n"

# print results
puts "Breakdown of errors by source and code:"
puts "\n"

codes_to_check.each do |code|
  total_errors = error_total[code]
  perc_total = (100*error_total[code].to_f/total).round(1)

  mom_errors = error_mom[code]
  perc_mom = (100*error_mom[code].to_f/total_mom).round(1)

  child_errors = error_child[code]
  perc_child = (100*error_child[code].to_f/total_child).round(1)

  puts "#{code}"
  puts "total errors: #{total_errors}/#{total} #{perc_total}%"
  puts "mom errors: #{mom_errors}/#{total_mom} #{perc_mom}%"
  puts "child errors: #{child_errors}/#{total_child} #{perc_child}%"
  puts "\n"

end
