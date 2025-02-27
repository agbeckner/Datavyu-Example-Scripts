# Insert transcribeQA and transcribe_clean column, after running ReliabilityBlocks script on a complete transcript.

##Parameters for creating transcribe_clean column
source_column = 'transcribe'
destination_column = 'transcribe_clean'

require 'Datavyu_API.rb'

# Create new column for transc_qa
begin
   transcript = getColumn('transcribe')
   transcriptcells = transcript.cells

   # Get reliability block cells
   blockcells = get_column('relblocks').cells

   transc_qa = createColumn("transc_qa", 'OnsetError', 'SpeakerError', 'ParsingError', 'ContentError', 'MissingExtraUtterance')

   #duplicate blocked cells into QA column
   for cell in transcriptcells.select{ |x| blockcells.any?{ |y| y.overlaps_cell(x) } }
     transc_qacell = transc_qa.new_cell
     transc_qacell.onset = cell.onset
     transc_qacell.offset = cell.onset
   end

    set_column(transc_qa)
end

#Create clean transcribe column
set_column(destination_column, get_column(source_column))

hide_columns(*get_column_list)
show_columns('relblocks', 'transc_qa', 'transcribe_clean')
