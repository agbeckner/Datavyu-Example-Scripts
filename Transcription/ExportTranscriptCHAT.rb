# Convert transcription in Datavyu to CHAT format.
# Currently designed to export transcription for PLAY project.

## Parameters
# languages_column_name = 'languages'
# participants_column_name = 'participants'
transcript_column_name = 'transcribe'
transcript_source_code = 'source'
transcript_content_code = 'content'

# Codes from ID column


source_map = { # mapping from transcript_source codes to 3-letter speaker ids
	'm'	=>	{
		:id => 'MOT',
		:name => nil,
		:role => 'Mother'
	},
	'c'	=>	{
		:id => 'CHI',
		:name => nil,
		:role => 'Child'
	},

}

## Body
require 'Datavyu_API.rb'
require 'date'

java_import javax::swing::JFileChooser
java_import javax::swing::filechooser::FileNameExtensionFilter

# Globals
utf_marker = '@UTF8'
time_marker = "\x15" # hex code before time marker

output = []
output << utf_marker
output << '@Begin'

# Add participants header from source_map
# NOTE: first name field not implemented yet since birthdate must be anonymized if included
puts "Adding participants header..."
header_participants = "@Participants:\t" + source_map.map{ |k, v| [v[:id], v[:role]].join(' ') }.join(', ')
output << header_participants
#I think this id code above is what gives us the error in CLAN:  TIER "@ID:", ASSOCIATED WITH A SELECTED SPEAKER, HASN'T BEEN FOUND IN THE INPUT DATA!

# Iterate over transcript cells
puts "Adding transcription data..."
transcript_col = get_column(transcript_column_name)
transcript_col.cells.each do |t|
	speaker = t.get_code(transcript_source_code)
	transcript = t.get_code(transcript_content_code).strip

	# replace @ with @l to match chat convention
	transcript.gsub!('@','@l')

	# replace b with @b to match chat convention for babbles
	transcript.gsub!(/^[b]$/, '&=babbles')
	transcript.gsub!(/^[d]$/, '&=cries')
	transcript.gsub!(/^[v]$/, '&=vocalizes')

	# Replace using substitutions hash
	#transcript.gsub!(Regexp.union(trans_substitutions.keys), trans_substitutions) unless trans_substitutions.empty?

	# Append a period to transcript unless it has ending.
	transcript += ' .' unless %w(. ? !).any?{ |x| transcript.end_with?(x) }

	# Make sure there is a space before punctuations.
	transcript.gsub!(/([^ ])([,.?!])/, '\\1 \\2')

	if speaker == 'm'
		line = "*#{source_map[speaker][:id]}:\t#{transcript} #{time_marker}#{t.onset}_#{t.offset+1}#{time_marker}"
		output << line
	end

	if speaker == 'c'
		line = "*#{source_map[speaker][:id]}:\t#{transcript} #{time_marker}#{t.onset}_#{t.offset+1}#{time_marker}"
 		output << line
	end

end
output << '@End'

# Prompt user for output file.
puts "Writing data to file..."
chaFilter = FileNameExtensionFilter.new('Chat file','cha')
jfc = JFileChooser.new()
jfc.setAcceptAllFileFilterUsed(false)
jfc.setFileFilter(chaFilter)
jfc.setMultiSelectionEnabled(false)
jfc.setDialogTitle('Select file to export data to.')

ret = jfc.showSaveDialog(javax.swing.JPanel.new())

if ret != JFileChooser::APPROVE_OPTION
	puts "Invalid selection. Aborting."
	return
end

output_file = jfc.getSelectedFile().getPath()
output_file += '.cha' unless output_file.end_with?('.cha')

# Write data to file.
outfile = File.open(output_file, 'w+')
outfile.puts output
outfile.close
####
# Get the languages and construct the languages header
# lang_cells = get_column(languages_column_name).cells
# header_languages = '@Languages:\t' + lang_cells.map{ |x| x.language }.join(', ')
