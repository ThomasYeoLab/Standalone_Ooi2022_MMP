function [ROIdata] = aCompCor_Gab(funcfile, roifile)
% This script will extract 5 principal components from time series of the roi (specified by roifile)
% Adapted from Chai et al, 2012
% Created by Jesisca Tandi and Thomas Yeo

nROI = 1;
nPC = 5;
% nPCoriginal = 5;
cluster = 1;
NaNrep = 1;
% 
% funcfile = '/Network/Tera2b/Experiments/ALFIE/Preprocessed_fMRI/ALFIE_RW_Resting/test/vol/ALFIE04_bld005_rest_reorient_skip_faln_mc_FS1mm_MNI1mm_MNI2mm_sm4.nii';
% roifile = '/Network/Tera2b/Experiments/ALFIE/Preprocessed_fMRI/ALFIE_RW_Resting/test/vol/ec2norm_MNI152_1mm_reintp_modified.nii';
% outfile = 'WM_CSF.txt'
% motionfiles = '/Network/Tera2b/Experiments/ALFIE/Preprocessed_fMRI/ALFIE_RW_Resting/test/bold/005/ALFIE04_bld005_rest_reorient_skip_faln_mc.txt';

params.rois = roifile;
params.sources = funcfile;
params.level = 'rois';
params.select_clusters = 0; % Make only 1 cluster
params.mindist = 20;
params.maxpeak = 32;
params.dims = nPC;
% params.VF = spm_vol(params.sources);
params.summary_measure = 'eigenvariate';
params.covariates = [];
params.scaling = 'roi';


nCluster = 1;

% %        case {'.img','.nii'}
% [XYZMM,XYZWW,XYZNN,XYZnames,ROIa,ROIb] = rex_image(params.rois,params.level,'image',params.select_clusters,params.mindist,params.maxpeak,params.dims(min(nPC,length(params.dims))));
% XYZmm = XYZMM{cluster};


funcdata = MRIread(params.sources);
roidata = MRIread(params.rois);
nvol = funcdata.nframes;
sessions=ones(nvol,1);
g=zeros(2,max(sessions));


% for i = 1:length(params.VF)
%     iM{i} = inv(params.VF(i).mat);
% end

data = zeros(nvol,nvol);

funcroi = funcdata.vol(repmat(logical(roidata.vol~=0), [1 1 1 nvol]));
funcroi = reshape(funcroi, [sum(roidata.vol(:)~=0) nvol])';


datamean=zeros(1,size(funcroi,2));

disp(['Precomputing covariance structure'])
for n1 = 1:1e3:size(funcroi,2)
    idx=n1:min(size(funcroi,2),n1-1+1e3);
        %         temp1(i,:) = spm_sample_vol(params.VF(i),XYZ(1,:),XYZ(2,:),XYZ(3,:),0);
    temp1 = funcroi(:,idx);
    %     end
    idxnan = find(isnan(temp1));
    if ~isempty(idxnan),
        datamean(idx) = sum(~isnan(temp1),1);
        temp1(idxnan) = 0;
        datamean(idx) = sum(temp1,1)./max(eps,datamean(idx));
        [idxnani,idxnanj] = ind2sub(size(temp1),idxnan);
        temp1(idxnan) = datamean(idx(idxnanj));
    else
        datamean(idx) = mean(temp1,1); % datamean = mean signal of voxels in the ROI across time, resulting in [1xnvoxels]
    end
    data=data+temp1*temp1'; % Covariance matrix of all voxels in the ROI
end

% % Remove covariates from ROI??
% covariates = load(motionfiles);
% cov0=ones(nvol,1);
% cov1=detrend(params.covariates,'constant'); % Params.covariates [nvolxncov], e.g. [180x7] consists of 6 motion parms, 1 resting state
% proj=eye(size(params.covariates,1))-[cov1,0*cov0]*pinv([cov1,cov0]); % removes covariates keeping scale unchanged
% data=proj*data*proj';


[q1,q2,nill] = svd(data);
temp = min(size(q1,2),params.dims(min(nROI,length(params.dims))));
data = q1(:,1:temp)*diag(sqrt(diag(q2(1:temp,1:temp)))); %principal component of the covariates
basis = zeros(size(funcroi,2),temp);


ROIdata=nan+zeros(nvol,nROI);
ROIdat=ROIdata;
for cluster = 1:nCluster
    
    
    rr = 1;
    if strcmpi(params.summary_measure,'eigenvariate')
        rrx=rr-1+(1:min(params.dims(min(nROI,length(params.dims))),min(nvol,size(funcroi,2))));
        tempx='.eig';
    end
    for i = 1:nvol
        % Convert to XYZmm to pixel coordinates in XYZ
        %iM=inv(params.VF(i).mat);
%         XYZ = iM{i}(1:3,:)*[XYZmm; ones(1,size(XYZmm,2))];
        % resample data at voxel in ROI
%         d = spm_get_data(params.VF(i),XYZ);
        %case 'eigenvariate',
        d = funcroi(i,:);
        d3=d;
%         NaNrep = spm_type(params.VF(i).dt(1),'nanrep');
        if NaNrep==0
            d3(~d3) = datamean(~d3);
        end
        d3((isnan(d3))) = datamean((isnan(d3)));
        
        basis=basis+d3(:)*data(i,:);
        ROIdat(i,rr)=mean(d3);
        %data(i,:)=d(:)';ROIdat(i,rr)=mean(d2);
        %if step==1, data(i,:)=d(:)';
        %elseif step==2, temp=weight.*d(:); temp(isnan(temp))=0; ROIdat(i,rr)=sum(temp); end
        
        
        
        if strcmpi(params.scaling,'roi'),% && ~(strcmpi(params.summary_measure,'eigenvariate')&&step==1),
            % Computes within-roi scaling
            g(:,sessions(i))=g(:,sessions(i))+[ROIdat(i,rr);1];
        end
    end
    
    if strcmpi(params.summary_measure,'eigenvariate'),%step==1&
        basis=basis*diag(1./max(eps,sqrt(sum(basis.^2,1))));
        temp=sign(sum(basis,1))./max(eps,sum(abs(basis),1));
        basis=basis*diag(temp);
        data=data*diag(temp);
    end
    
    if strcmpi(params.level,'voxels')||strcmpi(params.level,'subsetvoxels')||strcmpi(params.summary_measure,'eigenvariate'),ROIdat(:,rrx)=data; end
    
    
    %     switch(lower(params.scaling)),
    %         case {'global','roi'},
    %         ROIdata(idx,rrx)=ROIdat(idx,rrx)/(sum(g(1,n1))/sum(g(2,n1)))*100;
    %         otherwise,              ROIdata(idx,rrx)=ROIdat(idx,rrx);
    %     end
    for n1=1:max(sessions),
        idx=find(sessions==n1);
        if ~isempty(idx),
            %                 switch(lower(params.scaling)),
            %                     case {'global','roi'},  ROIdata(idx,rrx)=ROIdat(idx,rrx)/(sum(g(1,n1))/sum(g(2,n1)))*100;
            %                     otherwise,
            ROIdata(idx,rrx)=ROIdat(idx,rrx);
            %                 end
        end
    end
    
    rr=rr+length(rrx);
    
end

ROIdata = detrend(ROIdata, 'constant');
end

