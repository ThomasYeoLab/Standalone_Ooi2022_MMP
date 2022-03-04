/*
 * MATLAB Compiler: 4.6 (R2007a)
 * Date: Wed Jul  6 14:49:51 2011
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe" "-v"
 * "CreateSingleVertexSurfaceROI" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_CreateSingleVertexSurfaceROI_session_key[] = {
        '0', 'D', 'A', '4', '9', '9', '5', 'A', '8', 'D', '2', 'A', 'C', 'E',
        'B', '4', '2', 'B', 'D', '7', '3', '7', 'B', '9', '0', '6', 'C', '9',
        'C', '1', 'E', 'F', 'E', '9', 'B', '7', '3', 'E', '7', '3', 'A', 'C',
        '9', '1', 'B', '8', '4', '5', '3', '0', '9', '1', 'E', 'F', 'B', '1',
        'D', '0', 'E', 'F', '1', 'F', 'B', '5', 'C', '3', 'B', 'E', '5', 'B',
        '9', '9', '5', 'D', 'F', '8', '8', '9', 'D', '1', '5', 'A', '5', 'A',
        '1', '3', '1', '8', '1', '6', 'E', 'B', 'D', '6', 'A', 'A', 'F', 'E',
        '3', 'E', '8', 'C', '6', '0', '8', '1', '0', 'D', 'D', '2', 'E', '3',
        'C', '2', 'F', '4', '2', '5', 'C', '6', '7', '6', '3', 'A', '1', '2',
        '7', '4', '9', '6', '8', 'F', 'B', 'D', 'D', '0', 'E', 'A', 'E', '8',
        'A', '2', '6', '9', 'E', '0', '9', '5', '2', '9', '4', 'D', '4', '8',
        '1', '5', 'F', 'E', '3', '5', '0', 'C', '4', '4', '4', '6', '0', '3',
        'C', '9', '2', '2', 'A', 'F', '4', '1', '1', '1', '7', '9', 'C', '0',
        '9', 'C', 'F', 'E', '5', 'F', '1', '8', '3', '0', '2', '2', 'D', 'F',
        'B', 'B', '5', '0', '3', 'D', '5', '0', 'B', '4', 'A', '3', 'E', 'E',
        '2', '2', '3', 'C', 'D', 'E', '6', '4', '0', '2', '4', '7', 'F', 'F',
        '0', '3', '2', 'C', 'D', 'F', '4', 'B', '9', '8', '3', '1', '1', 'F',
        '4', 'B', '4', 'D', '8', '2', '9', 'A', '4', '6', '2', '4', 'F', 'C',
        'D', 'B', 'D', '8', '\0'};

const unsigned char __MCC_CreateSingleVertexSurfaceROI_public_key[] = {
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

static const char * MCC_CreateSingleVertexSurfaceROI_matlabpath_data[] = 
    { "CreateSingleVertexSurfaceROI/", "toolbox/compiler/deploy/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable5_0_0/matlab/",
      "autofs/cluster/freesurfer/centos4.0_x86_64/stable5_0_0/fsfast/toolbox/",
      "autofs/cluster/nexus/7/software/apps/SDv1.5.1/BasicTools/",
      "autofs/cluster/nexus/7/software/apps/SDv1.5.1/",
      "autofs/cluster/nexus/7/software/code/lib/matlab/ythomas/FC/surf/",
      "autofs/cluster/nexus/7/software/code/lib/matlab/ythomas/FC/utilities/",
      "autofs/cluster/nexus/7/software/code/lib/matlab/ythomas/FC/",
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

static const char * MCC_CreateSingleVertexSurfaceROI_classpath_data[] = 
    { "" };

static const char * MCC_CreateSingleVertexSurfaceROI_libpath_data[] = 
    { "" };

static const char * MCC_CreateSingleVertexSurfaceROI_app_opts_data[] = 
    { "" };

static const char * MCC_CreateSingleVertexSurfaceROI_run_opts_data[] = 
    { "" };

static const char * MCC_CreateSingleVertexSurfaceROI_warning_state_data[] = 
    { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_CreateSingleVertexSurfaceROI_component_data = { 

    /* Public key data */
    __MCC_CreateSingleVertexSurfaceROI_public_key,

    /* Component name */
    "CreateSingleVertexSurfaceROI",

    /* Component Root */
    "",

    /* Application key data */
    __MCC_CreateSingleVertexSurfaceROI_session_key,

    /* Component's MATLAB Path */
    MCC_CreateSingleVertexSurfaceROI_matlabpath_data,

    /* Number of directories in the MATLAB Path */
    42,

    /* Component's Java class path */
    MCC_CreateSingleVertexSurfaceROI_classpath_data,
    /* Number of directories in the Java class path */
    0,

    /* Component's load library path (for extra shared libraries) */
    MCC_CreateSingleVertexSurfaceROI_libpath_data,
    /* Number of directories in the load library path */
    0,

    /* MCR instance-specific runtime options */
    MCC_CreateSingleVertexSurfaceROI_app_opts_data,
    /* Number of MCR instance-specific runtime options */
    0,

    /* MCR global runtime options */
    MCC_CreateSingleVertexSurfaceROI_run_opts_data,
    /* Number of MCR global runtime options */
    0,
    
    /* Component preferences directory */
    "CreateSingleVertexSurfaceROI_047953E17CE62C0CAA29CD04FBE8B307",

    /* MCR warning status data */
    MCC_CreateSingleVertexSurfaceROI_warning_state_data,
    /* Number of MCR warning status modifiers */
    1,

    /* Path to component - evaluated at runtime */
    NULL

};

#ifdef __cplusplus
}
#endif


