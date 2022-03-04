/*
 * MATLAB Compiler: 4.6 (R2007a)
 * Date: Tue Nov  8 17:12:34 2011
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v"
 * "ComputeROIs2WholeBrainCorrelationWithRegression.m" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_ComputeROIs2WholeBrainCorrelationWithRegression_session_key[] = {
        '6', '9', 'D', '7', '8', '3', 'D', '3', '1', '5', 'D', 'B', '8', 'A',
        'F', '7', '2', '3', '2', '5', 'E', '6', 'E', '5', 'D', '5', '5', '1',
        '5', '7', 'A', '8', 'D', '7', 'E', 'C', '6', '2', '9', '3', '9', '9',
        '1', 'A', 'F', '8', '1', '0', '5', '0', '7', '4', 'A', 'B', '5', '0',
        '2', '1', '0', '1', 'C', '6', '1', '8', '2', '7', 'A', 'C', 'D', '8',
        'C', 'D', '5', '6', 'E', '3', 'E', 'D', '3', '3', 'E', 'F', '7', '9',
        '6', 'E', 'D', '2', '2', '1', '9', '2', '4', 'D', '6', '8', '9', 'B',
        '4', 'D', 'C', '9', 'C', '9', 'F', '6', '5', '2', 'D', '4', 'C', 'B',
        '3', '5', 'D', '2', 'F', 'F', 'A', 'D', '6', 'D', 'C', 'C', '3', '2',
        'C', '8', '9', 'E', '9', 'A', 'E', 'D', 'A', 'E', '5', '3', '2', 'D',
        '4', '5', 'D', 'D', '1', 'B', '7', '1', 'A', 'B', '2', '0', 'D', 'D',
        '8', '1', '6', 'A', '3', 'A', 'C', '8', '7', '2', '3', '9', 'B', 'A',
        '5', '6', 'F', '2', '7', '7', '0', '8', '2', 'A', '3', '1', '0', 'F',
        '6', '5', '2', 'B', '8', 'B', '3', '1', '3', '7', '6', 'B', '3', '1',
        '7', '0', '8', '1', 'F', 'D', '7', 'C', 'F', 'C', 'E', '6', '5', 'C',
        'F', 'B', 'D', 'B', 'B', 'B', '7', '1', '5', '4', '3', 'F', '6', '1',
        '8', '4', '5', '1', 'A', '3', 'F', 'C', '3', '9', 'A', 'C', '5', 'D',
        '0', '8', 'D', 'F', 'A', 'C', '0', 'B', 'E', 'C', '9', '5', 'F', '0',
        '6', 'C', '2', '9', '\0'};

const unsigned char __MCC_ComputeROIs2WholeBrainCorrelationWithRegression_public_key[] = {
        '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9',
        '2', 'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1',
        '0', '1', '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B',
        '0', '0', '3', '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1',
        '0', '0', 'C', '4', '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3',
        'A', '5', '2', '0', '6', '5', '8', 'F', '6', 'F', '8', 'E', '0', '1',
        '3', '8', 'C', '4', '3', '1', '5', 'B', '4', '3', '1', '5', '2', '7',
        '7', 'E', 'D', '3', 'F', '7', 'D', 'A', 'E', '5', '3', '0', '9', '9',
        'D', 'B', '0', '8', 'E', 'E', '5', '8', '9', 'F', '8', '0', '4', 'D',
        '4', 'B', '9', '8', '1', '3', '2', '6', 'A', '5', '2', 'C', 'C', 'E',
        '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4', 'D', '0', '8', '5',
        'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2', 'E', 'D', 'E',
        '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6', '3', '7',
        '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E', '6',
        '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
        '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1',
        'B', 'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9',
        '9', '0', '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0',
        'B', '6', '1', 'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B',
        '5', '8', 'F', 'C', '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6',
        'E', 'B', '7', 'E', 'C', 'D', '3', '1', '7', '8', 'B', '5', '6', 'A',
        'B', '0', 'F', 'A', '0', '6', 'D', 'D', '6', '4', '9', '6', '7', 'C',
        'B', '1', '4', '9', 'E', '5', '0', '2', '0', '1', '1', '1', '\0'};

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_matlabpath_data[] = 
    { "ComputeROIs2WholeBrainCorrelationWithRegression/",
      "toolbox/compiler/deploy/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable4/matlab/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable4/fsfast/toolbox/",
      "autofs/cluster/vc/buckner/apps/SDv1.5.1/BasicTools/",
      "autofs/cluster/vc/buckner/apps/SDv1.5.1/",
      "autofs/cluster/nexus/13/users/ythomas/code/projects/RLB/code/lib/matlab/ythomas/FC/surf/",
      "autofs/cluster/nexus/13/users/ythomas/code/projects/RLB/code/lib/matlab/ythomas/FC/utilities/",
      "autofs/cluster/nexus/13/users/ythomas/code/projects/RLB/code/lib/matlab/ythomas/FC/",
      "autofs/homes/011/ythomas/", "$TOOLBOXMATLABDIR/general/",
      "$TOOLBOXMATLABDIR/ops/", "$TOOLBOXMATLABDIR/lang/",
      "$TOOLBOXMATLABDIR/elmat/", "$TOOLBOXMATLABDIR/elfun/",
      "$TOOLBOXMATLABDIR/specfun/", "$TOOLBOXMATLABDIR/matfun/",
      "$TOOLBOXMATLABDIR/datafun/", "$TOOLBOXMATLABDIR/polyfun/",
      "$TOOLBOXMATLABDIR/funfun/", "$TOOLBOXMATLABDIR/sparfun/",
      "$TOOLBOXMATLABDIR/scribe/", "$TOOLBOXMATLABDIR/graph2d/",
      "$TOOLBOXMATLABDIR/graph3d/", "$TOOLBOXMATLABDIR/specgraph/",
      "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
      "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
      "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
      "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
      "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
      "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/demos/",
      "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
      "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
      "toolbox/local/" };

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_classpath_data[] = 
    { "" };

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_libpath_data[] = 
    { "" };

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_app_opts_data[] = 
    { "" };

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_run_opts_data[] = 
    { "" };

static const char * MCC_ComputeROIs2WholeBrainCorrelationWithRegression_warning_state_data[] = 
    { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_ComputeROIs2WholeBrainCorrelationWithRegression_component_data = { 

    /* Public key data */
    __MCC_ComputeROIs2WholeBrainCorrelationWithRegression_public_key,

    /* Component name */
    "ComputeROIs2WholeBrainCorrelationWithRegression",

    /* Component Root */
    "",

    /* Application key data */
    __MCC_ComputeROIs2WholeBrainCorrelationWithRegression_session_key,

    /* Component's MATLAB Path */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_matlabpath_data,

    /* Number of directories in the MATLAB Path */
    42,

    /* Component's Java class path */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_classpath_data,
    /* Number of directories in the Java class path */
    0,

    /* Component's load library path (for extra shared libraries) */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_libpath_data,
    /* Number of directories in the load library path */
    0,

    /* MCR instance-specific runtime options */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_app_opts_data,
    /* Number of MCR instance-specific runtime options */
    0,

    /* MCR global runtime options */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_run_opts_data,
    /* Number of MCR global runtime options */
    0,
    
    /* Component preferences directory */
    "ComputeROIs2WholeBrainCorrelationWithRegression_0EC068DC0591A03A3EA7BA4E90431E2F",

    /* MCR warning status data */
    MCC_ComputeROIs2WholeBrainCorrelationWithRegression_warning_state_data,
    /* Number of MCR warning status modifiers */
    1,

    /* Path to component - evaluated at runtime */
    NULL

};

#ifdef __cplusplus
}
#endif


