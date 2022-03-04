classdef test_read_surf < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            % laod expected results
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_surf');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            %input parameters
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'lh';
            params.SUBJECT = 'fsaverage6';           
            params.surf_filename = 'sphere';
                        
            [newResult.vertices,newResult.faces] = read_surf(...
                [params.SUBJECTS_DIR '/' params.SUBJECT '/surf/' params.hemi '.' params.surf_filename]);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_surf, testLeftHemisphere...');
                % check vertices
                if all(size(newResult.vertices) ~= size(expectedResult.vertices))
                    disp('size of vertices is different');
                end
                abserror = abs(newResult.vertices - expectedResult.vertices);
                disp(['Total error (' 'vertices' '): ' num2str(sum(sum(abserror)))]);
                % check faces
                if all(size(newResult.faces) ~= size(expectedResult.faces))
                    disp('size of faces is different');
                end
                if all(all(newResult.faces ~= expectedResult.faces))
                    disp('faces is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult'); 
            else
                % check vertices
                assert(all(size(newResult.vertices) == size(expectedResult.vertices)), 'size of vertices is different')
                assert(all(all(abs(newResult.vertices - expectedResult.vertices) < 1e-6)), ...
                    sprintf('vertices off by %f', sum(sum(abs(newResult.vertices - expectedResult.vertices)))));
                % check faces
                assert(all(size(newResult.faces) == size(expectedResult.faces)), 'size of faces is different')
                assert(all(all(newResult.faces == expectedResult.faces)), sprintf('faces is different'));
            end
            
        end
        
        function testRightHemisphere(testCase)
            % laod expected results
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_surf');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            %input parameters
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'rh';
            params.SUBJECT = 'fsaverage';           
            params.surf_filename = 'inflated';
                        
            [newResult.vertices,newResult.faces] = read_surf(...
                [params.SUBJECTS_DIR '/' params.SUBJECT '/surf/' params.hemi '.' params.surf_filename]);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_surf, testRightHemisphere...');
                % check vertices
                if all(size(newResult.vertices) ~= size(expectedResult.vertices))
                    disp('size of vertices is different');
                end
                abserror = abs(newResult.vertices - expectedResult.vertices);
                disp(['Total error (' 'vertices' '): ' num2str(sum(sum(abserror)))]);
                % check faces
                if all(size(newResult.faces) ~= size(expectedResult.faces))
                    disp('size of faces is different');
                end
                if all(all(newResult.faces ~= expectedResult.faces))
                    disp('faces is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult'); 
            else
                % check vertices
                assert(all(size(newResult.vertices) == size(expectedResult.vertices)), 'size of vertices is different')
                assert(all(all(abs(newResult.vertices - expectedResult.vertices) < 1e-6)), ...
                    sprintf('vertices off by %f', sum(sum(abs(newResult.vertices - expectedResult.vertices)))));
                % check faces
                assert(all(size(newResult.faces) == size(expectedResult.faces)), 'size of faces is different')
                assert(all(all(newResult.faces == expectedResult.faces)), sprintf('faces is different'));
            end
            
        end
    end

end