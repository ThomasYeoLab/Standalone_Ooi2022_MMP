#! /bin/csh -f

if ($?LD_LIBRARY_PATH) then
    setenv LD_LIBRARY_PATH "/usr/pubsw/common/matlab/7.4/bin/glnxa64":"/usr/pubsw/common/matlab/7.4/sys/os/glnxa64/":"$LD_LIBRARY_PATH"
else
    setenv LD_LIBRARY_PATH "/usr/pubsw/common/matlab/7.4/bin/glnxa64":"/usr/pubsw/common/matlab/7.4/sys/os/glnxa64/"
endif

# Lateral Parietal 
CreateSingleVertexSurfaceROI fsaverage5 8788 Yeo2011_surface_seeds/lh.SPL7A.mgh
CreateSingleVertexSurfaceROI fsaverage5 6509 Yeo2011_surface_seeds/lh.IPS2.mgh
CreateSingleVertexSurfaceROI fsaverage5 4593 Yeo2011_surface_seeds/lh.IPS3m.mgh
CreateSingleVertexSurfaceROI fsaverage5 2593 Yeo2011_surface_seeds/lh.SPL7P.mgh
CreateSingleVertexSurfaceROI fsaverage5 5805 Yeo2011_surface_seeds/lh.PGa.mgh
CreateSingleVertexSurfaceROI fsaverage5 5811 Yeo2011_surface_seeds/lh.IPS1.mgh
CreateSingleVertexSurfaceROI fsaverage5 8358 Yeo2011_surface_seeds/lh.IPS3l.mgh
CreateSingleVertexSurfaceROI fsaverage5 6280 Yeo2011_surface_seeds/lh.PGpd.mgh
CreateSingleVertexSurfaceROI fsaverage5  765 Yeo2011_surface_seeds/lh.PGpv.mgh
CreateSingleVertexSurfaceROI fsaverage5 4201 Yeo2011_surface_seeds/lh.TPJ.mgh
CreateSingleVertexSurfaceROI fsaverage5 5028 Yeo2011_surface_seeds/lh.PF.mgh

# Lateral Prefrontal
CreateSingleVertexSurfaceROI fsaverage5 3077 Yeo2011_surface_seeds/lh.PFCl.mgh
CreateSingleVertexSurfaceROI fsaverage5 1883 Yeo2011_surface_seeds/lh.PFCla.mgh
CreateSingleVertexSurfaceROI fsaverage5 8671 Yeo2011_surface_seeds/lh.PFClp.mgh
CreateSingleVertexSurfaceROI fsaverage5 3413 Yeo2011_surface_seeds/lh.PFCda.mgh
CreateSingleVertexSurfaceROI fsaverage5  217 Yeo2011_surface_seeds/lh.PFCdp.mgh
CreateSingleVertexSurfaceROI fsaverage5 2131 Yeo2011_surface_seeds/lh.PFCd.mgh
CreateSingleVertexSurfaceROI fsaverage5 2223 Yeo2011_surface_seeds/lh.PFCv.mgh
CreateSingleVertexSurfaceROI fsaverage5 7661 Yeo2011_surface_seeds/lh.PFCva.mgh

# Medial Prefrontal
CreateSingleVertexSurfaceROI fsaverage5 2800 Yeo2011_surface_seeds/lh.PFCfp.mgh
CreateSingleVertexSurfaceROI fsaverage5 7581 Yeo2011_surface_seeds/lh.PFCdm.mgh
CreateSingleVertexSurfaceROI fsaverage5 1600 Yeo2011_surface_seeds/lh.PFCm.mgh
CreateSingleVertexSurfaceROI fsaverage5 6971 Yeo2011_surface_seeds/lh.Cingm.mgh
CreateSingleVertexSurfaceROI fsaverage5 3642 Yeo2011_surface_seeds/lh.PFCmp.mgh
CreateSingleVertexSurfaceROI fsaverage5 2873 Yeo2011_surface_seeds/lh.OFC.mgh

# Premotor
CreateSingleVertexSurfaceROI fsaverage5 2792 Yeo2011_surface_seeds/lh.FEF.mgh
CreateSingleVertexSurfaceROI fsaverage5 4423 Yeo2011_surface_seeds/lh.PrCv.mgh
CreateSingleVertexSurfaceROI fsaverage5 8169 Yeo2011_surface_seeds/lh.PMd.mgh
CreateSingleVertexSurfaceROI fsaverage5 4885 Yeo2011_surface_seeds/lh.6vr+.mgh
CreateSingleVertexSurfaceROI fsaverage5 5007 Yeo2011_surface_seeds/lh.PrCO.mgh
CreateSingleVertexSurfaceROI fsaverage5 2377 Yeo2011_surface_seeds/lh.5Ci.mgh
CreateSingleVertexSurfaceROI fsaverage5 4805 Yeo2011_surface_seeds/lh.Cinga.mgh

# Medial temporal / Parietal
CreateSingleVertexSurfaceROI fsaverage5 5751 Yeo2011_surface_seeds/lh.PHC.mgh
CreateSingleVertexSurfaceROI fsaverage5 5416 Yeo2011_surface_seeds/lh.RSP.mgh
CreateSingleVertexSurfaceROI fsaverage5 9736 Yeo2011_surface_seeds/lh.PCC.mgh
CreateSingleVertexSurfaceROI fsaverage5 6936 Yeo2011_surface_seeds/lh.pCun.mgh
CreateSingleVertexSurfaceROI fsaverage5 2448 Yeo2011_surface_seeds/lh.TempP.mgh

# Lateral Temporal
CreateSingleVertexSurfaceROI fsaverage5 9936 Yeo2011_surface_seeds/lh.STSmid.mgh
CreateSingleVertexSurfaceROI fsaverage5 9505 Yeo2011_surface_seeds/lh.STSp.mgh
CreateSingleVertexSurfaceROI fsaverage5  152 Yeo2011_surface_seeds/lh.STSa.mgh
CreateSingleVertexSurfaceROI fsaverage5 3295 Yeo2011_surface_seeds/lh.MT+.mgh
CreateSingleVertexSurfaceROI fsaverage5 5563 Yeo2011_surface_seeds/lh.MT+v.mgh
CreateSingleVertexSurfaceROI fsaverage5 2295 Yeo2011_surface_seeds/lh.MT+d.mgh
CreateSingleVertexSurfaceROI fsaverage5 7954 Yeo2011_surface_seeds/lh.aMT+.mgh
CreateSingleVertexSurfaceROI fsaverage5  620 Yeo2011_surface_seeds/lh.ITG.mgh

# Occipital
CreateSingleVertexSurfaceROI fsaverage5  6365 Yeo2011_surface_seeds/lh.V1c.mgh
CreateSingleVertexSurfaceROI fsaverage5  7124 Yeo2011_surface_seeds/lh.V1p.mgh
CreateSingleVertexSurfaceROI fsaverage5  9601 Yeo2011_surface_seeds/lh.V1pd.mgh
CreateSingleVertexSurfaceROI fsaverage5  2515 Yeo2011_surface_seeds/lh.V1pv.mgh
CreateSingleVertexSurfaceROI fsaverage5  9649 Yeo2011_surface_seeds/lh.V1cd.mgh
CreateSingleVertexSurfaceROI fsaverage5 10109 Yeo2011_surface_seeds/lh.V1cv.mgh
CreateSingleVertexSurfaceROI fsaverage5  1997 Yeo2011_surface_seeds/lh.V3cv.mgh
CreateSingleVertexSurfaceROI fsaverage5  5649 Yeo2011_surface_seeds/lh.V3pv.mgh
CreateSingleVertexSurfaceROI fsaverage5  7814 Yeo2011_surface_seeds/lh.V3A.mgh
CreateSingleVertexSurfaceROI fsaverage5  3331 Yeo2011_surface_seeds/lh.V4.mgh
CreateSingleVertexSurfaceROI fsaverage5   140 Yeo2011_surface_seeds/lh.ExP.mgh
CreateSingleVertexSurfaceROI fsaverage5  9675 Yeo2011_surface_seeds/lh.ExC.mgh

# Sensorimotor Yeo2011_Surface_Seeds
CreateSingleVertexSurfaceROI fsaverage5 2567 Yeo2011_surface_seeds/lh.M1H.mgh
CreateSingleVertexSurfaceROI fsaverage5 1839 Yeo2011_surface_seeds/rh.M1H.mgh
CreateSingleVertexSurfaceROI fsaverage5 4641 Yeo2011_surface_seeds/lh.M1F.mgh
CreateSingleVertexSurfaceROI fsaverage5 4028 Yeo2011_surface_seeds/rh.M1F.mgh
CreateSingleVertexSurfaceROI fsaverage5 7474 Yeo2011_surface_seeds/lh.M1T.mgh
CreateSingleVertexSurfaceROI fsaverage5 6588 Yeo2011_surface_seeds/rh.M1T.mgh
CreateSingleVertexSurfaceROI fsaverage5 1565 Yeo2011_surface_seeds/lh.S1H.mgh
CreateSingleVertexSurfaceROI fsaverage5 3595 Yeo2011_surface_seeds/rh.S1H.mgh
CreateSingleVertexSurfaceROI fsaverage5 2993 Yeo2011_surface_seeds/lh.S1F.mgh
CreateSingleVertexSurfaceROI fsaverage5 3572 Yeo2011_surface_seeds/rh.S1F.mgh
CreateSingleVertexSurfaceROI fsaverage5 4531 Yeo2011_surface_seeds/lh.S1T.mgh
CreateSingleVertexSurfaceROI fsaverage5 2597 Yeo2011_surface_seeds/rh.S1T.mgh
