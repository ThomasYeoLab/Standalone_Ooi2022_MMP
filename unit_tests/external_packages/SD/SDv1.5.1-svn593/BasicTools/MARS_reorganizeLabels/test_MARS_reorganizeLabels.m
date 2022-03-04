classdef test_MARS_reorganizeLabels < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test(testCase)
            % load input and ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_reorganizeLabels');
            load(fullfile(cur_dir, 'input', 'input.mat'));
            load(fullfile(cur_dir, 'ref_output', 'expectedResult.mat'));
            
            [newResult.label,newResult.ct,newResult.index] = MARS_reorganizeLabels(...
                input.label,input.ct,input.vertexNbor');
                        
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS_reorganizeLabels...');
                if ~isequal(new_fields,ref_fields)
                    disp('fields of the output structure are different');
                end
                for i = 1:length(new_fields)
                    % the 2nd field is a cell so we compare it seperately
                    if i ~= 2
                        disp(['Old field ' ref_fields{i} 'size is [' num2str(size(getfield(expectedResult,...
                           new_fields{i}))) ']'] );
                        disp(['New field ' new_fields{i} 'size is [' num2str(size(getfield(newResult,...
                            new_fields{i}))) ']']);
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                    end
                end
                % compare the 2nd field
                if ~isequal(newResult.ct,expectedResult.ct)
                    disp('MARS_ct is different');
                end
                % save new result
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult.mat'), 'expectedResult'); 
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');

                for i = 1:length(new_fields)
                    % the 2nd field is a cell so we compare it seperately
                    if i ~= 2
                    assert(isequal(size(getfield(newResult,new_fields{i})), ...
                        size(getfield(expectedResult,new_fields{i}))),sprintf('size of %s is different', new_fields{i}))
                    assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                        new_fields{i})) < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                        new_fields{i}))))));
                    end
                end
                % compare the 2nd field
                assert(isequal(newResult.ct,expectedResult.ct),'MARS_ct is different');
            end
        end
        
    end

end