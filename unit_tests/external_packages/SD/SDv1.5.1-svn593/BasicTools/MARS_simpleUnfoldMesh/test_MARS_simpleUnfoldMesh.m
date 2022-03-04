classdef test_MARS_simpleUnfoldMesh < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleUnfoldMesh');
            load(fullfile(ref_dir, 'input', 'input_lh.mat'));
            newResult = MARS_simpleUnfoldMesh(input_mesh,1,100);
            load(fullfile(ref_dir, 'ref_output', 'expectedResult_lh.mat'));

            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleUnfoldMesh, testLeftHemisphere...');
                for i = 1:length(new_fields)
                    if i ~= 10
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                   end
                end
                if(~isequaln(newResult.MARS_ct,expectedResult.MARS_ct))
                    disp('MARS_ct is different.');
                end
                expectedResult = newResult;
                save(fullfile(ref_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult');
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
                for i = 1:length(new_fields)
                    % the 10th field is a structure so we compare it seperately
                    if i ~= 10
                        assert(isequal(size(getfield(newResult,new_fields{i})),size(getfield(expectedResult,new_fields{i}))),sprintf('size of %s is different', new_fields{i}))
                        assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i})) < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}))))));
                    end
                end
                % compare the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end            
        end
        
        function testRightHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_simpleUnfoldMesh');
            load(fullfile(ref_dir, 'input', 'input_rh.mat'));
            newResult = MARS_simpleUnfoldMesh(input_mesh,1,100);
            load(fullfile(ref_dir, 'ref_output', 'expectedResult_rh.mat'));
            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_simpleUnfoldMesh, testRightHemisphere...');
                for i = 1:length(new_fields)
                    if i ~= 10
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                   end
                end
                if(~isequaln(newResult.MARS_ct,expectedResult.MARS_ct))
                    disp('MARS_ct is different.');
                end
                expectedResult = newResult;
                save(fullfile(ref_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
                for i = 1:length(new_fields)
                    % the 10th field is a structure so we compare it seperately
                    if i ~= 10
                        assert(isequal(size(getfield(newResult,new_fields{i})),size(getfield(expectedResult,new_fields{i}))),sprintf('size of %s is different', new_fields{i}))
                        assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i})) < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}))))));
                    end
                end
                % compare the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end
        end
    end

end