classdef test_MARS_reorganizeCT < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test(testCase)
            % load input
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_annotation', 'ref_output', 'expectedResult_lh.mat'));
            input_annot = expectedResult;
            newResult = MARS_reorganizeCT(input_annot.colortable,{'7Networks_3','7Networks_2'});
            % load ref output
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_reorganizeCT');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult.mat'));
            % check
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
               disp('Replacing unit test reference results for test_MARS_reorganizeCT...');
               if ~isequal(new_fields,ref_fields)
                    disp('fields of the output structure are different');
               end
               for i = 1:length(new_fields)
                   if i ~= 3
                       disp(['Old field ' ref_fields{i} 'size is [' num2str(size(getfield(expectedResult,...
                           new_fields{i}))) ']'] );
                       disp(['New field ' new_fields{i} 'size is [' num2str(size(getfield(newResult, ...
                           new_fields{i}))) ']']);
                       abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                       disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                   end
               end
               % compare the 3rd field
               disp(['Old strcuct_names is ' expectedResult.struct_names{1} ' and ' expectedResult.struct_names{2}]);
               disp(['New strcuct_names is ' newResult.struct_names{1} ' and ' newResult.struct_names{2}]);
               expectedResult = newResult;
               save(fullfile(cur_dir, 'ref_output', 'expectedResult.mat'), 'expectedResult'); 
               
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
                for i = 1:length(new_fields)
                    % the 3rd field is a cell so we compare it seperately
                    if i ~= 3
                        assert(isequal(size(getfield(newResult,new_fields{i})), ...
                            size(getfield(expectedResult,new_fields{i}))),...
                            sprintf('size of %s is different', new_fields{i}))
                        assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                            new_fields{i})) < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                            new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                            new_fields{i}))))));
                    end
                end
                % compare the 3rd field
                assert(isequal(newResult.struct_names,expectedResult.struct_names),'struct_names is different');
            end
        end
        
    end

end