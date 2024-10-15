# Load the PDB file
mol new md_25000ps.pdb
package require pbctools
pbc wrap -center com -centersel "protein" -compound residue -all
# Create selections for the hemes (excluding hydrogen atoms)
set sel_heme1 [atomselect top "index 17475 to 17547 and not hydrogen"]
set sel_heme2 [atomselect top "index 17548 to 17620 and not hydrogen"]
set sel_heme3 [atomselect top "index 17694 to 17766 and not hydrogen"]
set sel_heme4 [atomselect top "index 17621 to 17693 and not hydrogen"]
set sel_heme5 [atomselect top "index 17767 to 17839 and not hydrogen"]
set sel_heme6 [atomselect top "index 18716 to 18788 and not hydrogen"]
set sel_heme6s [atomselect top "index 17840 to 17912 and not hydrogen"]
# Create a procedure to calculate the minimum distance between two selections
proc calculate_minimum_distance {selection1 selection2} {
    set min_distance 20 ;# Initialize with a large value
    # Get the coordinates of atoms in selection1
    set coords1 [$selection1 get {x y z}]
    # Get the coordinates of atoms in selection2
    set coords2 [$selection2 get {x y z}]
    # Loop through the coordinates and calculate the minimum distance
    foreach coord1 $coords1 {
        foreach coord2 $coords2 {
            set distance [vecdist $coord1 $coord2]
            if {$distance < $min_distance} {
                set min_distance $distance
            }
        }
    }
    return $min_distance
}
# Calculate the nearest-neighbor distances
set distance_heme1_heme2 [calculate_minimum_distance $sel_heme1 $sel_heme2]
set distance_heme2_heme3 [calculate_minimum_distance $sel_heme2 $sel_heme3]
set distance_heme3_heme4 [calculate_minimum_distance $sel_heme3 $sel_heme4]
set distance_heme4_heme5 [calculate_minimum_distance $sel_heme4 $sel_heme5]
set distance_heme5_heme6 [calculate_minimum_distance $sel_heme5 $sel_heme6]
set distance_heme6s_heme1 [calculate_minimum_distance $sel_heme6s $sel_heme1]
# Print the distances
puts "Edge-to-edge distance between heme1-2: $distance_heme1_heme2"
puts "Edge-to-edge distance between heme2-3: $distance_heme2_heme3"
puts "Edge-to-edge distance between heme3-4: $distance_heme3_heme4"
puts "Edge-to-edge distance between heme4-5: $distance_heme4_heme5"
puts "Edge-to-edge distance between heme5-6: $distance_heme5_heme6"
puts "Edge-to-edge distance between heme6s-1: $distance_heme6s_heme1"
