
def main
  ARGV.each do | file |
    data = read_tsv(file)
    csv = write_csv(data)
    puts csv
  end
end

def read_tsv(file)
  f = File.open(file, 'r')
  tsv_lines = f.readlines
  f.close

  lines = []
  tsv_lines.each do | tsv_line |
    lines << tsv_line.split("\t")
  end

  return lines
end

def write_csv(lines)
  csv = []
  lines.each do | fields |
    csv << fields.map{|f| "\"#{f.strip}\""}.join(',')
  end
  csv.join("\n")
end

if __FILE__ == $PROGRAM_NAME
  main
end

