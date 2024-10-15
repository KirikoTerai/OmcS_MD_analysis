import MDAnalysis as mda
import os

# Load the trajectory and topology files
gro_file = "/home/kt193/nanowires/reorgE/275/md_50ns_275K.gro"
xtc_file = "/home/kt193/nanowires/reorgE/275/md_50ns_275K.xtc"
u = mda.Universe(gro_file, xtc_file)

# Define the time range for extraction (25ns to 50ns)
start_time = 25000  # in picoseconds (ps)
end_time = 50000    # in picoseconds (ps)

# Define the selection to include protein, hemes, and water solvents
selection = "protein or resname HEME or resname SOL or resname NA or resname CL"

# Iterate over each frame in the trajectory within the specified time range
for ts in u.trajectory:
    time_ps = int(ts.time)  # current time in picoseconds

    # Check if the current time is within the desired range
    if start_time <= time_ps <= end_time:
        # Make directory for each time frame
        time_ps_directory = f"{time_ps}"
        os.mkdir(time_ps_directory)
        # Extract protein structure as a PDB file
        atoms = u.select_atoms(selection)
        pdb_filename = f"/home/kt193/nanowires/reorgE/275/{time_ps_directory}/md_{time_ps}ps.pdb"
        atoms.write(pdb_filename)

        print(f"Snapshot extracted at {time_ps}ps as {pdb_filename}")

print("Extraction process completed.")

