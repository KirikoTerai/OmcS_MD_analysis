#!/bin/bash

#SBATCH -n 1
#SBATCH -p et2,et3,et4,et4_long
#SBATCH -c 4
#SBATCH -J 275K_nndis_write_tcl
#SBATCH -o nndis_write_tcl.out
#SBATCH -e nndis_write_tcl.err
#SBATCH --mem=30000
#SBATCH -t 5-00:00:00

# Get the absolute path of the current directory
current_dir=$(pwd)

# Get a list of directories in the current directory
directories=$(find "$current_dir" -maxdepth 1 -type d ! -path "$current_dir")

# Generate and submit the job scripts as a job array
for dir in $directories; do

    dirname=$(basename "$dir")
    cd "$dir"
    rm "nndis_${dirname}ps.tcl"
    tcl_script="nndis_${dirname}ps.tcl"

    # Write the contents of the tcl script
    echo "# Load the PDB file" >> "$tcl_script"
    echo "mol new md_${dirname}ps.pdb" >> "$tcl_script"
    echo "package require pbctools" >> "$tcl_script"
    echo "pbc wrap -center com -centersel \"protein\" -compound residue -all" >> "$tcl_script"

    echo "# Create selections for the hemes (excluding hydrogen atoms)" >> "$tcl_script"
    echo "set sel_heme1 [atomselect top \"index 17475 to 17547 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme2 [atomselect top \"index 17548 to 17620 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme3 [atomselect top \"index 17694 to 17766 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme4 [atomselect top \"index 17621 to 17693 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme5 [atomselect top \"index 17767 to 17839 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme6 [atomselect top \"index 18716 to 18788 and not hydrogen\"]" >> "$tcl_script"
    echo "set sel_heme6s [atomselect top \"index 17840 to 17912 and not hydrogen\"]" >> "$tcl_script"

    echo "# Create a procedure to calculate the minimum distance between two selections" >> "$tcl_script"
    echo "proc calculate_minimum_distance {selection1 selection2} {" >> "$tcl_script"
    echo "    set min_distance 20 ;# Initialize with a large value" >> "$tcl_script"
        
    echo "    # Get the coordinates of atoms in selection1" >> "$tcl_script"
    echo "    set coords1 [\$selection1 get {x y z}]" >> "$tcl_script"
        
    echo "    # Get the coordinates of atoms in selection2" >> "$tcl_script"
    echo "    set coords2 [\$selection2 get {x y z}]" >> "$tcl_script"
        
    echo "    # Loop through the coordinates and calculate the minimum distance" >> "$tcl_script"
    echo "    foreach coord1 \$coords1 {" >> "$tcl_script"
    echo "        foreach coord2 \$coords2 {" >> "$tcl_script"
    echo "            set distance [vecdist \$coord1 \$coord2]" >> "$tcl_script"
    echo "            if {\$distance < \$min_distance} {" >> "$tcl_script"
    echo "                set min_distance \$distance" >> "$tcl_script"
    echo "            }" >> "$tcl_script"
    echo "        }" >> "$tcl_script"
    echo "    }" >> "$tcl_script"
        
    echo "    return \$min_distance" >> "$tcl_script"
    echo "}" >> "$tcl_script"

    echo "# Calculate the nearest-neighbor distances" >> "$tcl_script"
    echo "set distance_heme1_heme2 [calculate_minimum_distance \$sel_heme1 \$sel_heme2]" >> "$tcl_script"
    echo "set distance_heme2_heme3 [calculate_minimum_distance \$sel_heme2 \$sel_heme3]" >> "$tcl_script"
    echo "set distance_heme3_heme4 [calculate_minimum_distance \$sel_heme3 \$sel_heme4]" >> "$tcl_script"
    echo "set distance_heme4_heme5 [calculate_minimum_distance \$sel_heme4 \$sel_heme5]" >> "$tcl_script"
    echo "set distance_heme5_heme6 [calculate_minimum_distance \$sel_heme5 \$sel_heme6]" >> "$tcl_script"
    echo "set distance_heme6s_heme1 [calculate_minimum_distance \$sel_heme6s \$sel_heme1]" >> "$tcl_script"

    echo "# Print the distances" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme1-2: \$distance_heme1_heme2\"" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme2-3: \$distance_heme2_heme3\"" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme3-4: \$distance_heme3_heme4\"" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme4-5: \$distance_heme4_heme5\"" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme5-6: \$distance_heme5_heme6\"" >> "$tcl_script"
    echo "puts \"Edge-to-edge distance between heme6s-1: \$distance_heme6s_heme1\"" >> "$tcl_script"

done
