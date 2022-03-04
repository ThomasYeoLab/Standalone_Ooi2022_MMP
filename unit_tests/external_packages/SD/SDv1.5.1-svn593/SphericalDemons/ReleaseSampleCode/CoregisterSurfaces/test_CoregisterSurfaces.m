classdef test_CoregisterSurfaces < matlab.unittest.TestCase
%
% Written by Yang Qing and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
       
    methods (Test)

        function test_LH_two_Sub_Case(testCase)
            %% path setting
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'SphericalDemons', 'ReleaseSampleCode', 'CoregisterSurfaces');      
            ref_dir = fullfile(cur_dir, 'ref_output');
            out_dir = fullfile(cur_dir, 'output'); % this output dir is case specific
            
            % create output dir (IMPORTANT)
            if(exist(out_dir, 'dir'))
                rmdir(out_dir, 's')
            end
            mkdir(out_dir);
            
            
            %% load reference result
            ref_file1 = fullfile(ref_dir, 'OAS1_0001_MR1_lh.sphere.SD.reg');
            ref_file2 = fullfile(ref_dir, 'OAS1_0003_MR1_lh.sphere.SD.reg');
            [ref001_vertex_coords, ref001_faces] = read_surf(ref_file1);
            [ref003_vertex_coords, ref003_faces] = read_surf(ref_file2);
            
            
            %% copy over files to create a fake SUBJECTS_DIR
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/ic4.tri ', out_dir, '/ic4.tri']);
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/ic5.tri ', out_dir, '/ic5.tri']);
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/ic6.tri ', out_dir, '/ic6.tri']);
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/ic7.tri ', out_dir, '/ic7.tri']);
            mkdir([out_dir, '/example_surfaces']);
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/example_surfaces/OAS1_0001_MR1 ', ...
                out_dir, '/example_surfaces']);
            system(['cp -r $CBIG_CODE_DIR/external_packages/SD/SDv1.5.1-svn593/example_surfaces/OAS1_0003_MR1 ', ...
                out_dir, '/example_surfaces']);
            system(['rm -r ', out_dir, '/example_surfaces/OAS1_0001_MR1/SD']);
            system(['rm -r ', out_dir, '/example_surfaces/OAS1_0003_MR1/SD']);
            % these files should be newly generated
            system(['rm ', out_dir, '/example_surfaces/OAS1_0001_MR1/surf/lh.sphere.SD.reg']);
            system(['rm ', out_dir, '/example_surfaces/OAS1_0003_MR1/surf/lh.sphere.SD.reg']);

            
            %% parameter setting
            hemi = 'lh';
            SUBJECTS_DIR = fullfile(out_dir, 'example_surfaces');
            subject_cell = {'OAS1_0001_MR1' ,'OAS1_0003_MR1'};
            DISPLAY_ATLAS = 0;
            
            % this is because the original function uses relative path
            cd(fullfile(out_dir, 'example_surfaces', 'OAS1_0001_MR1'));
            
            
            %% generate new lh.sphere.SD.reg
            CoregisterSurfaces(hemi, SUBJECTS_DIR, subject_cell, DISPLAY_ATLAS)
            
            %% compare new lh.sphere.SD.reg with reference lh.sphere.SD.reg
            output_file1 = fullfile(out_dir, 'example_surfaces', 'OAS1_0001_MR1', 'surf', 'lh.sphere.SD.reg');
            output_file2 = fullfile(out_dir, 'example_surfaces', 'OAS1_0003_MR1', 'surf', 'lh.sphere.SD.reg');
            [new001_vertex_coords, new001_faces] = read_surf(output_file1);
            [new003_vertex_coords, new003_faces] = read_surf(output_file2);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CoregisterSurfaces, test_LH_two_Sub_Case...');
                
                abserror = abs(ref001_vertex_coords - new001_vertex_coords);
                disp(['Total error (new001_vertex_coords): ' num2str(sum(sum(abserror)))]);
                
                abserror = abs(ref001_faces - new001_faces);
                disp(['Total error (new001_faces): ' num2str(sum(sum(abserror)))]);
                
                abserror = abs(ref003_vertex_coords - new003_vertex_coords);
                disp(['Total error (new003_vertex_coords): ' num2str(sum(sum(abserror)))]);
                
                abserror = abs(ref003_faces - new003_faces);
                disp(['Total error (new003_faces): ' num2str(sum(sum(abserror)))]);
                
                copyfile(output_file1, ref_file1);
                copyfile(output_file2, ref_file2);
            else

                % check for sub OAS1_0001_MR1
                % check whether vertex_coords are the same
                diff = abs(ref001_vertex_coords - new001_vertex_coords);
                assert(all(all(diff < 1e-12)), sprintf(['[OAS1_0001_MR1 lh.sphere.SD.reg] vertex_coords off by %f ', ...
                    '(max absolute difference) \n This test also calls read_surf, please check.'], max(diff)));

                % check whether faces are the same
                diff = abs(ref001_faces - new001_faces);
                assert(all(all(diff < 1e-12)), sprintf(['[OAS1_0001_MR1 lh.sphere.SD.reg] faces off by %f ', ...
                    '(max absolute difference) \n This test also calls read_surf, please check.'], max(diff)));

                % check for sub OAS1_0003_MR1
                % check whether vertex_coords are the same
                diff = abs(ref003_vertex_coords - new003_vertex_coords);
                assert(all(all(diff < 1e-12)), sprintf(['[OAS1_0003_MR1 lh.sphere.SD.reg] vertex_coords off by %f ',...
                    '(max absolute difference) \n This test also calls read_surf, please check.'], max(diff)));

                % check whether faces are the same
                diff = abs(ref003_faces - new003_faces);
                assert(all(all(diff < 1e-12)), sprintf(['[OAS1_0003_MR1 lh.sphere.SD.reg] faces off by %f ',...
                    '(max absolute difference) \n This test also calls read_surf, please check.'], max(diff)));
            end            
            
            %% remove intermediate output data (IMPORTANT)
            rmdir(out_dir, 's');
            
        end
    end
end
 