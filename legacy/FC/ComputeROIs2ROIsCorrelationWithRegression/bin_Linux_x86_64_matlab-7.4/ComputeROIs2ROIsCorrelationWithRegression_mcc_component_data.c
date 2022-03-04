/*
 * MATLAB Compiler: 4.6 (R2007a)
 * Date: Sat Aug  3 04:15:13 2013
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v"
 * "ComputeROIs2ROIsCorrelationWithRegression.m" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_ComputeROIs2ROIsCorrelationWithRegression_session_key[] = {
        '1', 'A', '4', 'E', '2', '1', 'E', '8', '4', 'C', 'A', '8', '5', 'B',
        '8', '2', '1', '8', '5', '6', '8', 'C', '0', '8', '6', '7', '1', 'C',
        '5', 'A', '5', '1', '4', 'F', '1', 'A', 'F', '8', 'F', 'D', '6', '4',
        '7', 'D', 'D', '5', '3', 'B', '5', 'F', '7', 'F', '9', '5', 'B', 'E',
        '8', '1', '4', 'F', 'D', '7', '2', '5', '4', '4', '1', '5', '0', '2',
        '3', '5', '6', '4', 'C', '9', 'A', '9', '9', 'D', '4', '2', '3', '6',
        '9', '7', '1', 'D', '3', 'E', '1', '1', '1', '3', '4', 'F', '9', 'E',
        'E', 'F', '8', '0', '1', 'D', '9', '7', '1', '2', '7', '1', '6', '2',
        '8', '9', '1', '5', 'C', '0', 'E', '8', '4', '7', '5', '5', '2', 'C',
        '2', '2', 'D', '7', '0', '3', '7', 'F', '2', '1', '7', '1', '0', 'C',
        '4', '7', 'B', 'B', 'A', 'D', 'D', '6', '1', '7', 'D', '6', '7', '0',
        '8', '4', 'F', 'C', 'D', '3', 'A', '7', '1', '7', '4', 'A', 'B', '3',
        '5', 'F', '1', 'B', 'E', 'C', '3', '1', 'D', 'A', 'B', '3', '4', '6',
        'A', '6', 'D', '5', '4', '4', '2', '2', '5', '4', 'B', '4', '1', '6',
        'B', '4', '7', '9', '8', '0', 'C', '8', '0', 'F', '3', 'A', '8', 'E',
        'E', 'D', '9', '5', '3', 'F', '8', '0', 'F', '4', '3', '0', '2', '3',
        '9', '6', '1', '8', '3', '7', '3', '0', 'E', '0', 'C', '9', 'F', '1',
        'B', 'C', 'C', 'F', 'F', '7', '0', 'D', '3', 'B', '1', '0', '4', '0',
        '9', '3', '8', '1', '\0'};

const unsigned char __MCC_ComputeROIs2ROIsCorrelationWithRegression_public_key[] = {
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

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_matlabpath_data[] = 
    { "ComputeROIs2ROIsCorrelationWithRegression/",
      "toolbox/compiler/deploy/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable4/matlab/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable4/fsfast/toolbox/",
      "autofs/cluster/nrg/tools/apps/arch/linux_x86_64/sd/1.5.1/BasicTools/",
      "autofs/cluster/nrg/tools/apps/arch/linux_x86_64/sd/1.5.1/",
      "autofs/cluster/nexus/12/users/ythomas/code/RLB_buffer/code/lib/matlab/ythomas/FC/surf/",
      "autofs/cluster/nexus/12/users/ythomas/code/RLB_buffer/code/lib/matlab/ythomas/FC/utilities/",
      "autofs/cluster/nexus/12/users/ythomas/code/RLB_buffer/code/lib/matlab/ythomas/FC/",
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

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_classpath_data[] = 
    { "" };

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_libpath_data[] = 
    { "" };

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_app_opts_data[] = 
    { "" };

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_run_opts_data[] = 
    { "" };

static const char * MCC_ComputeROIs2ROIsCorrelationWithRegression_warning_state_data[] = 
    { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_ComputeROIs2ROIsCorrelationWithRegression_component_data = { 

    /* Public key data */
    __MCC_ComputeROIs2ROIsCorrelationWithRegression_public_key,

    /* Component name */
    "ComputeROIs2ROIsCorrelationWithRegression",

    /* Component Root */
    "",

    /* Application key data */
    __MCC_ComputeROIs2ROIsCorrelationWithRegression_session_key,

    /* Component's MATLAB Path */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_matlabpath_data,

    /* Number of directories in the MATLAB Path */
    42,

    /* Component's Java class path */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_classpath_data,
    /* Number of directories in the Java class path */
    0,

    /* Component's load library path (for extra shared libraries) */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_libpath_data,
    /* Number of directories in the load library path */
    0,

    /* MCR instance-specific runtime options */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_app_opts_data,
    /* Number of MCR instance-specific runtime options */
    0,

    /* MCR global runtime options */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_run_opts_data,
    /* Number of MCR global runtime options */
    0,
    
    /* Component preferences directory */
    "ComputeROIs2ROIsCorrelationWithRegression_77B176E7C6D7E79402877452FBC47F1F",

    /* MCR warning status data */
    MCC_ComputeROIs2ROIsCorrelationWithRegression_warning_state_data,
    /* Number of MCR warning status modifiers */
    1,

    /* Path to component - evaluated at runtime */
    NULL

};

#ifdef __cplusplus
}
#endif


