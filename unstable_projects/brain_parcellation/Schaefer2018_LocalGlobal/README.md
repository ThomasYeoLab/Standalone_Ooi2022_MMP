Background
==========
Resting state fMRI data from 1489 subjects were registered using surface-based alignment. 
A gradient weighted markov random field approach was employed to identify cortical areas.
More details can be found in Schaefer et al. 2018.

Parcellations Downloads
===========================
The parcellations can be found in ```Schaefer2018_Parcellations```. There are three subfolders corresponding to three different 
spaces ```Freesurfer5.3```, ```MNI``` and ```HCP```. The parcellations were computed in Freesurfer ```fsaverage6``` space and projected to 
HCP ```fslr32k``` and FSL ```MNI``` space. Each parcel was matched to a corresponding network in the 7 and 17 network parcellation by Yeo et al. 2011.  

References
==========
+ Schaefer A, Kong R, Gordon EM, Zuo XN, Holmes AJ, Eickhoff SB, Yeo BT, (accepted), Local-Global Parcellation of the Human Cerebral Cortex From Intrinsic Functional Connectivity MRI, Cerebral Cortex
+ Yeo BT, Krienen FM, Sepulcre J, Sabuncu MR, Lashkari D, Hollinshead M, Roffman JL, Smoller JW, Zollei L., 
Polimeni JR, Fischl B, Liu H, Buckner RL (2011) [The organization of the human cerebral cortex estimated 
by functional connectivity.](http://jn.physiology.org/content/106/3/1125.long) J. Neurophysiol.
