function [S, tstat, adj, sz_links, NULL] = nbs_tstat(X,Y,THRESH,K,TAIL)
% NBS: Computes the network-based (t) statistic (NBS) as described in [1]. 
%
% USAGE: S = NBS(X,Y,THRESH) performs the NBS for populations X and Y for a
% T-statistic threshold of THRESH. This isolates the components of an 
% undirected connectivity matrix that differ significantly between two 
% distinct populations X and Y.
% 
% X, Y     -  Connectivity values of population X and Y. Each variable is a
%             3D matrix with first 2 dimensions refer to connectivity value
%             of particular edge comprising connectivity matrix. For 
%             example, X(i,j,k) stores the connectivity value corresponding
%             to the edge between i and j for the kth member of population.
% THRESH   -  Threshold for T-Statistic 
% K        -  Emables number of permutations tp be generated to estimate 
%             the empirical null distribution of maximal component size. 
%             Default : K = 1000.
% TAIL     -  This is to specify the type of alternative hypothesis. If TAIL is
%             'both' - alternative hypothesis is means are not equal (default)
%             'left'  - mean of population X < mean of population Y
%             'right' - mean of population X > mean of population Y          
% S        -  Structure to store components and their sizes.
%             S.componentArr - Array of all components
%             S.compSizes - Array of sizes of these components edge-links
%             S.nCompArr - Array of component number
%             S.allComponents - All components together
% TSTAT    -  2D Matrix having T-Value for stats between X and Y
% ADJ      -  Adjacency matrix identifying edges comprising each component
%             Values are from 1 to number of components with more than 1 node. 
% SZ_LINKS -  Size of maximal component size
% NULL     -  Estimate of null distribution of maximal component size for K
%             independent permutations.
%
%
%     This function is dependent on CBIG_components_subgraphs.m andcomponents.m, 
%     which is available as part of Matlab BGL: 
%     http://www.stanford.edu/~dgleich/programs/matlab_bgl/
%
%     ALGORITHM DESCRIPTION 
%     The NBS is a nonparametric statistical test used to isolate the 
%     components of an N x N undirected connectivity matrix that differ 
%     significantly between two distinct populations. Each element of the 
%     connectivity matrix stores a connectivity value and each member of 
%     the two populations possesses a distinct connectivity matrix. A 
%     component of a connectivity matrix is defined as a set of 
%     interconnected edges. 
%
%     The NBS is essentially a procedure to control the family-wise error 
%     rate, in the weak sense, when the null hypothesis is tested 
%     independently at each of the N(N-1)/2 edges comprising the 
%     connectivity matrix. The NBS can provide greater statistical power 
%     than conventional procedures for controlling the family-wise error 
%     rate, such as the false discovery rate, if the set of edges at which
%     the null hypothesis is rejected constitues a large component or
%     components.
%     The NBS comprises fours steps:
%     1. Perfrom a two-sample T-test at each edge indepedently to test the
%        hypothesis that the value of connectivity between the two
%        populations come from distributions with equal means. 
%     2. Threshold the T-statistic available at each edge to form a set of
%        suprathreshold edges. 
%     3. Identify any components in the adjacency matrix defined by the set
%        of suprathreshold edges. These are referred to as observed 
%        components. Compute the size of each observed component 
%        identified; that is, the number of edges it comprises. 
%     4. Repeat K times steps 1-3, each time randomly permuting members of
%        the two populations and storing the size of the largest component 
%        identified for each permuation. This yields an empirical estimate
%        of the null distribution of maximal component size. A corrected 
%        p-value for each observed component is then calculated using this
%        null distribution.
%
%     [1] Zalesky A, Fornito A, Bullmore ET (2010) Network-based statistic:
%         Identifying differences in brain networks. NeuroImage.
%         10.1016/j.neuroimage.2010.06.041
%
%     Written by: Andrew Zalesky, azalesky@unimelb.edu.au


%Error checking
if nargin<3
    error('Not enough inputs\n');
end
if nargin<4
    TAIL='both'; 
end
if nargin<5
    K=1000;
end    
[Ix,Jx,nx]=size(X);
[Iy,Jy,ny]=size(Y);
[a, b] = meshgrid(1:Ix, 1:Jx);
if any([Ix~=Jx,Iy~=Jy,Ix~=Jy])
    error('Matrices are not square, or are not of equal dimensions\n');
end

%Number of nodes
N=Ix; M=Iy;
tstat = zeros(N, M);
%T-Statistic between X and Y
for i = 1:N
    for j = 1:M
        if(i~=j)
            tstat(i,j)= CBIG_ttest2_stat_only(X(i,j,:), Y(i,j,:));
        end
    end
end
tstat(a == b) = 0; 
if strcmp(TAIL,'both')
    tstat = abs(tstat);
elseif strcmp(TAIL,'left')
    tstat = -tstat;
elseif strcmp(TAIL,'right')
else
    error('Tail option not recognized\n');
end

%Threshold the T-Stat with THRESH value
tstat_thresh = double(tstat > THRESH);
tstat_thresh = sparse(tstat_thresh);

%Get the adjacency matrix and size of component edge-links
[adj, sz_links] = CBIG_components_subgraphs(tstat_thresh); 
if ~isempty(sz_links)
    max_sz=max(sz_links);
else
    max_sz=0;
end
fprintf('Max component links is: %d\n',max_sz); 

%Empirically estimate null distribution of maximum component size by
%generating K independent permutations. 
fprintf('Estimating null distribution with permutation testing\n');
hit=0; 
X_reshaped = reshape(X,[Ix*Jx,nx]); 
Y_reshaped = reshape(Y,[Iy*Jy,ny]); 
for k=1:K

   d = zeros(N*M,nx+ny);
   d = [X_reshaped, Y_reshaped];
   indperm = randperm(nx+ny); %Permuting here
   tstat_perm = zeros(size(d,1),1);
   d = d(:,indperm);
   for i = 1:size(d,1)
       tstat_perm(i) = CBIG_ttest2_stat_only(d(i,1:nx),d(i,nx+1:nx+ny));
   end
   tstat_perm = reshape(tstat_perm,N,M); 
   tstat_perm(a == b) = 0; 
   if strcmp(TAIL,'both')
       tstat_perm = abs(tstat_perm);
   elseif strcmp(TAIL,'left')
       tstat_perm = -tstat_perm;
   elseif strcmp(TAIL,'right')
   else
       error('Tail option not recognized\n');
   end
   
   %Thresholding for current permutation
   tstat_perm_thresh = double(tstat_perm > THRESH);
   tstat_perm_thresh = sparse(tstat_perm_thresh);   
   [~, sz_links_perm] = CBIG_components_subgraphs(tstat_perm_thresh);
   if ~isempty(sz_links_perm)
       NULL(k) = max(sz_links_perm);
   else
       NULL(k) = 0;
   end
   if NULL(k) >= max_sz;
       hit = hit+1;
   end
   fprintf('Perm %d of %d. Perm max is: %d. Observed max is: %d. P-val estimate is: %0.3f\n',k,K,NULL(k),max_sz,hit/k);
   clear tmp rstat_perm rstat_perm_thresh;
end


%Compute Components for given THRESH 
cutOff = prctile(NULL,95);
fprintf('\nCUT OFF FOR 95 PERCENTILE FOR THRESH %3.3f - %f\n',THRESH,cutOff);
S = []; hh = 1; componentArr = []; compSizes = []; nCompArr = [];
idx_sz_cutoff = find(sz_links > cutOff);
for nLink = 1:length(idx_sz_cutoff)
    tmp = (full(adj) == nLink);
    if nnz(tmp)>0
        componentArr(:,:,hh) = tmp;
        compSizes(hh) = sz_links(idx_sz_cutoff(nLink));
        nCompArr(hh) = nLink;
        hh = hh + 1;
    end
    clear tmp;
end

S.componentArr = componentArr;
S.compSizes = compSizes;
S.nCompArr = nCompArr;
S.allComponents = double(sum(componentArr, 3) > 0); %OR of all components

clear componentArr compSizes nCompArr 

% %Calculate p-values
% for i=1:length(sz_links)
%     PVAL(i)=length(find(NULL>=sz_links(i)))/K;
% end
