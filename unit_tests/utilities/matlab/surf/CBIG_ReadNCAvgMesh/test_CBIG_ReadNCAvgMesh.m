classdef test_CBIG_ReadNCAvgMesh < matlab.unittest.TestCase
% Written by Jianzhong Chen, Zhang Shaoshi and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            % load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'surf', 'CBIG_ReadNCAvgMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            newResult = CBIG_ReadNCAvgMesh('lh','fsaverage6','inflated','cortex');
            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ReadNCAvgMesh, leftHemishpere...');
                for i = 1:length(new_fields)
                    if i ~= 10
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);                        
                    end
                end 
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult');
            else           
                assert(isequal(new_fields,ref_fields),'fileds of the output structure are different');

                for i = 1:length(new_fields)
                    % 10th filed is a struct so we compare it separately
                    if i ~= 10
                        equalsize = isequal(size(getfield(newResult,new_fields{i})), ...
                            size(getfield(expectedResult,new_fields{i})));
                        assert(equalsize, sprintf('testLeftHemisphere: size of %s is different', new_fields{i}))
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        assert(all(all(abserror< 1e-6)), ...
                            sprintf('testLeftHemisphere: %s result off by %f (sum absolute difference)', ...
                            new_fields{i}, sum(sum(abserror))));
                    end
                end
                % check the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end
        end
        
        function testRightHemisphere(testCase)
            % load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', 'matlab', 'surf', 'CBIG_ReadNCAvgMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            
            newResult = CBIG_ReadNCAvgMesh('rh','fsaverage','sphere','Yeo2011_7Networks_N1000.annot');            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);

            if(replace_unittest_flag)
                disp('Replacing unit test reference results fo ReadNCAvgMesh, reftHemishpere...');
                for i = 1:length(new_fields)
                    if i ~= 10
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);                        
                    end
                end 
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else             
                assert(isequal(new_fields,ref_fields),'fileds of the output structure are different');

                for i = 1:length(new_fields)
                    % 10th filed is a struct so we compare it separately
                    if i ~= 10
                        equalsize = isequal(size(getfield(newResult,new_fields{i})), ...
                            size(getfield(expectedResult,new_fields{i})));
                        assert(equalsize, sprintf('testRighttHemisphere: size of %s is different', new_fields{i}))
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        assert(all(all(abserror< 1e-6)), ...
                            sprintf('testRightHemisphere: %s result off by %f (sum absolute difference)', ...
                            new_fields{i}, sum(sum(abserror))));
                    end
                end
                % check the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end
        end
    end

end