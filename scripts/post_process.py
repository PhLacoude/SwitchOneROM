# Read the head.bas file and print it out, which contains the BASIC lines to 
# load the binary data
def read_head_bas(filename = "head.bas"):
    with open(filename, "r") as f:
        return f.read().rstrip("\n")

# Add DATA statements for the binary data in the PRG file, starting at line 1000
# and incrementing by 10 for each line.  Each line will contain 6 bytes of data, 
# except for the last line which may contain fewer if the total byte count is not 
# a multiple of 6. A sentinel value of -1 is added at the end to indicate the end 
# of the data.
def bin_to_basic(filename, start_line=10000, bytes_per_line=6):
    with open(filename, "rb") as f:
        bindata = f.read() 
    # Build BASIC lines with DATA statements
    lines = []
    line_num = start_line
    for i in range(0, len(bindata), bytes_per_line):
        chunk = bindata[i:i+bytes_per_line]
        data_str = ",".join(str(b) for b in chunk)
        lines.append(f"{line_num} data {data_str}")
        line_num += 10
    # Sentinel value to indicate end of data
    lines.append(f"{line_num} data -1")
    return "\n".join(lines)

# add main code here
if __name__ == "__main__":
    output_parts = [
        read_head_bas(".\\scripts\\head.bas"),
        bin_to_basic(".\\build\\main.bin")
    ]

    with open(".\\build\\main.bas", "w", newline="\n") as out_file:
        out_file.write("\n".join(part for part in output_parts if part) + "\n")

