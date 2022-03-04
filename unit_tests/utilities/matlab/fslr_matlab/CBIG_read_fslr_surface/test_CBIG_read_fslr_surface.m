classdef test_CBIG_read_fslr_surface < matlab.unittest.TestCase
%
% Target function:
%                 output_mesh = CBIG_read_fslr_surface(hemi, mesh_name, surf_type, label)
%
% Case design:
%                 Case 1 = read in lh fsLR32k mesh, with surf_type
%                 'very_inflated', label 'aparc.annot'
%
%                 Case 2 = read in rh fsLR32k mesh with surf_type
%                 'midthickness_orig', label 'medialwall.annot'
%
%                 Case 3 = read in lh fsLR164k mesh, with surf_type
%                 'very_inflated', label 'aparc.annot'
%                 ('very_inflated is commonly used, so we also test for 164k)
%
%                 Case 4 = read in rh fsLR164k mesh with surf_type
%                 'sphere', label 'aparc.annot'
%                  ('medialwall.annot' is not available for 164k)
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function test_lh_fslr32kCase(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_read_fslr_surface/';
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_fs_LR_32k')); % a reference lh fslr32k surface mesh: ref
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % parameter setting
            hemi = 'lh';
            mesh_name = 'fs_LR_32k';
            surf_type = 'very_inflated';
            label = 'aparc.annot';
            
            % generate new surface mesh
            new = CBIG_read_fslr_surface(hemi, mesh_name, surf_type, label);
            
            % compare new surface mesh with reference surface mesh
            % check whether they have same fields
            new_fields = fieldnames(new);
            ref_fields = fieldnames(ref);
            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_fslr_surface, test_lh_fslr32kCase...');
                
                for i = 1: length(new_fields) - 1
                    abserror = abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                end
                ref = new;
                save(fullfile(ReferenceDir, '/ref_lh_fs_LR_32k'), 'ref');
            else
                assert(isequal(new_fields, ref_fields), ...
                    'fields of resulting fslr surface struct are different!')
                
                % check whether the value of each field is the same
                for i = 1: length(new_fields) - 1 % MARS_ct is excluded here because itself is a struct, will test separately
                    
                    assert(isequal(size(getfield(new, new_fields{i})), size(getfield(ref, ref_fields{i}))),...
                        sprintf('size of field %s is different', new_fields{i}))
                    
                    assert(all(all(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i})) < 1e-12)), ...
                        sprintf('result field %s off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}))))));
                    
                end
                
                assert(isequaln(new.MARS_ct, ref.MARS_ct), 'result field MARS_ct is different')
            end
            
        end
        
        
        
        function test_rh_fslr32kCase(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_read_fslr_surface/';
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_rh_fs_LR_32k')); % a reference rh fslr32k surface mesh: ref
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % parameter setting
            hemi = 'rh';
            mesh_name = 'fs_LR_32k';
            surf_type = 'midthickness_orig';
            label = 'medialwall.annot';
            
            % generate new surface mesh
            new = CBIG_read_fslr_surface(hemi, mesh_name, surf_type, label);
            
            % compare new surface mesh with reference surface mesh
            % check whether they have same fields
            new_fields = fieldnames(new);
            ref_fields = fieldnames(ref);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_fslr_surface, test_rh_fslr32kCase...');
                
                for i = 1: length(new_fields) - 1
                    abserror = abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                end
                ref = new;
                save(fullfile(ReferenceDir, '/ref_rh_fs_LR_32k'), 'ref');
            else
                assert(isequal(new_fields, ref_fields), ...
                    'fields of resulting fslr surface struct are different!')
                
                % check whether the value of each field is the same
                for i = 1: length(new_fields) - 1 % MARS_ct is excluded here because itself is a struct, will test separately
                    
                    assert(isequal(size(getfield(new, new_fields{i})), size(getfield(ref, ref_fields{i}))),...
                        sprintf('size of field %s is different', new_fields{i}))
                    
                    assert(all(all(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i})) < 1e-12)), ...
                        sprintf('result field %s off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}))))));
                    
                end
                
                assert(isequaln(new.MARS_ct, ref.MARS_ct), 'result field MARS_ct is different')
            end
        end
        
        
        
        function test_lh_fslr164kCase(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_read_fslr_surface/';
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_lh_fs_LR_164k')); % a reference lh fslr164k surface mesh: ref
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % parameter setting
            hemi = 'lh';
            mesh_name = 'fs_LR_164k';
            surf_type = 'very_inflated';
            label = 'aparc.annot';
            
            % generate new surface mesh
            new = CBIG_read_fslr_surface(hemi, mesh_name, surf_type, label);
            
            % compare new surface mesh with reference surface mesh
            % check whether they have same fields
            new_fields = fieldnames(new);
            ref_fields = fieldnames(ref);
            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_fslr_surface, test_lh_fslr164kCase...');
                
                for i = 1: length(new_fields) - 1
                    abserror = abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                end
                ref = new;
                save(fullfile(ReferenceDir, '/ref_lh_fs_LR_164k'), 'ref');
            else
                
                assert(isequal(new_fields, ref_fields), ...
                    'fields of resulting fslr surface struct are different!')
                
                % check whether the value of each field is the same
                for i = 1: length(new_fields) - 1 % MARS_ct is excluded here because itself is a struct, will test separately
                    
                    assert(isequal(size(getfield(new, new_fields{i})), size(getfield(ref, ref_fields{i}))),...
                        sprintf('size of field %s is different', new_fields{i}))
                    
                    assert(all(all(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i})) < 1e-12)), ...
                        sprintf('result field %s off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}))))));
                    
                end
                
                assert(isequaln(new.MARS_ct, ref.MARS_ct), 'result field MARS_ct is different')
            end
        end
        
        
        
        function test_rh_fslr164kCase(testCase)
            
            % path setting
            UnitTestDir = [getenv('CBIG_CODE_DIR') '/unit_tests'];
            FolderStructure = 'utilities/matlab/fslr_matlab/CBIG_read_fslr_surface/';
            ReferenceDir = fullfile(UnitTestDir, FolderStructure, 'ref_output');
            
            % load reference result
            load(fullfile(ReferenceDir, '/ref_rh_fs_LR_164k')); % a reference rh fslr164k surface mesh: ref
            load(fullfile(UnitTestDir, 'replace_unittest_flag'));
            
            % parameter setting
            hemi = 'rh';
            mesh_name = 'fs_LR_164k';
            surf_type = 'sphere';
            label = 'aparc.annot';
            
            % generate new surface mesh
            new = CBIG_read_fslr_surface(hemi, mesh_name, surf_type, label);
            
            % compare new surface mesh with reference surface mesh
            % check whether they have same fields
            new_fields = fieldnames(new);
            ref_fields = fieldnames(ref);
            
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_fslr_surface, test_rh_fslr164kCase...');
                
                for i = 1: length(new_fields) - 1
                    abserror = abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                end
                ref = new;
                save(fullfile(ReferenceDir, '/ref_rh_fs_LR_164k'), 'ref');
            else
                
                assert(isequal(new_fields, ref_fields), ...
                    'fields of resulting fslr surface struct are different!')
                
                % check whether the value of each field is the same
                for i = 1: length(new_fields) - 1 % MARS_ct is excluded here because itself is a struct, will test separately
                    
                    assert(isequal(size(getfield(new, new_fields{i})), size(getfield(ref, ref_fields{i}))),...
                        sprintf('size of field %s is different', new_fields{i}))
                    
                    assert(all(all(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i})) < 1e-12)), ...
                        sprintf('result field %s off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(new, new_fields{i}) - getfield(ref, ref_fields{i}))))));
                    
                end
                
                assert(isequaln(new.MARS_ct, ref.MARS_ct), 'result field MARS_ct is different')
            end
        end
        
    end
    
end