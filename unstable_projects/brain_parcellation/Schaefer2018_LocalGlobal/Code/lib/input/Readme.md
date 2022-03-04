## Input folder

This folder containes example input files for the local gradient. The files are created by Gordon et al.  as described in 
the corresponding paper from 2016 [https://www.ncbi.nlm.nih.gov/pubmed/25316338]. The gradients are based on 120 subjects with both invidual timeseries smoothing and later group level smoothing. 

The files used in the paper are stored as `3_smooth_lh_borders_120_gordon_subjects_3_postsmoothing_6.mat` and `3_smooth_rh_borders_120_gordon_subjects_3_postsmoothing_6.mat` 
These correspond to directly taking the gradient vectors from the above mentioned paper and assigning the gradient value of each
vertex to its 6-neighborhood by using the function `CBIG_gradient_vector_to_matrix`. 


Other attemps have been made in our progress and stored for completeness:
- `fs5` is the same gradient but in fsaverage5
- `min` takes the minimum gradient from the 6 vertex neighborhood
- `water` after performing a watershed transformation on the gradient map
