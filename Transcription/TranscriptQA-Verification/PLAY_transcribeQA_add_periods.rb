## Parameters
# names of column in which to replace empty codes with periods
col_list = %w[transc_qa]
# replace empty codes with this argument
replace_arg = '.'

## Body
require 'Datavyu_API.rb'

col_list.each do |colname|
  # get the column
  col = get_column(colname)

  # loop over cells in column
  col.cells.each do |c|
    # loop over codes for current cell
    c.arglist.each do |a|
      # replace any empty code with .
      if c.get_code(a).empty?
        c.change_code(a,replace_arg)
      end
    end
  end
  # reflect changes in spreadsheet
  set_column(colname,col)
end
