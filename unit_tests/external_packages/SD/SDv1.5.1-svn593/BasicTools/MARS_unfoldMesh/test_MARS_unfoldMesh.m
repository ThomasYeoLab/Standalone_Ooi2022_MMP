classdef test_MARS_unfoldMesh < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_unfoldMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            load(fullfile(cur_dir, 'input', 'input_lh.mat'));
            [newResult.vertices,newResult.list] = MARS_unfoldMesh(...
                input.MARS_atlas,input.sbjWarp,input.energy,...
                input.stepsize,input.maxstep,input.lambda,input.list,input.max_iter);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_unfoldMesh, testLeftHemisphere...');
                % check vertices
                if all(size(newResult.vertices) ~= size(expectedResult.vertices))
                    disp('size of vertices is different');
                end
                abserror = abs(newResult.vertices - expectedResult.vertices);
                disp(['Total error (' 'vertrices' '): ' num2str(sum(sum(abserror)))]);
                % check list
                disp(['Old field ' 'size of list is [' num2str(size(expectedResult.list)) ']'] );
                disp(['New field ' 'size of list is [' num2str(size(newResult.list)) ']'] );
                if all(all(newResult.list ~= expectedResult.list))
                    disp('list is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else
                % check vertices
                assert(all(size(newResult.vertices) == size(expectedResult.vertices)), 'size of vertices is different')
                assert(all(all(abs(newResult.vertices - expectedResult.vertices) < 1e-6)), ...
                    sprintf('vertices off by %f', sum(sum(abs(newResult.vertices - expectedResult.vertices)))));
                % check list
                assert(all(size(newResult.list) == size(expectedResult.list)), 'size of list is different')
                assert(all(all(newResult.list == expectedResult.list)), sprintf('list is different'));
            end
            
        end
        
        function testRightHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_unfoldMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            load(fullfile(cur_dir, 'input', 'input_rh.mat'));
            [newResult.vertices,newResult.list] = MARS_unfoldMesh(...
                input.MARS_atlas,input.sbjWarp,input.energy,...
                input.stepsize,input.maxstep,input.lambda,input.list,input.max_iter);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_unfoldMesh, testRightHemisphere...');
                % check vertices
                if all(size(newResult.vertices) ~= size(expectedResult.vertices))
                    disp('size of vertices is different');
                end
                abserror = abs(newResult.vertices - expectedResult.vertices);
                disp(['Total error (' 'vertrices' '): ' num2str(sum(sum(abserror)))]);
                % check list
                disp(['Old field ' 'size of list is [' num2str(size(expectedResult.list)) ']'] );
                disp(['New field ' 'size of list is [' num2str(size(newResult.list)) ']'] );
                if all(all(newResult.list ~= expectedResult.list))
                    disp('list is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else
                % check vertices
                assert(all(size(newResult.vertices) == size(expectedResult.vertices)), 'size of vertices is different')
                assert(all(all(abs(newResult.vertices - expectedResult.vertices) < 1e-6)), ...
                    sprintf('vertices off by %f', sum(sum(abs(newResult.vertices - expectedResult.vertices)))));
                % check list
                assert(all(size(newResult.list) == size(expectedResult.list)), 'size of list is different')
                assert(all(all(newResult.list == expectedResult.list)), sprintf('list is different'));
            end
        end
    end

end