classdef test_MARS_computeFoldingGradFast < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function test(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS_computeFoldingGradFast');
            load(fullfile(cur_dir, 'input', 'input.mat'));
            ref_output_file = fullfile(cur_dir, 'ref_output', 'expectedResult.mat');
            load(ref_output_file);
            
            [newResult.energy,newResult.grad,newResult.list] = MARS_computeFoldingGradFast(input.curr_vertices,input.prior,input.list);

            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_computeFoldingGradFast");
                % display differences
                new_fields = fieldnames(newResult);
                ref_fields = fieldnames(expectedResult);
                if ~isequal(new_fields,ref_fields)
                    disp('Fields of output structure are different')
                else
                    for i = 1:length(new_fields)
                        disp(['Old field ' ref_fields{i} 'size is [' num2str(size(getfield(expectedResult,new_fields{i}))) ']'] );
                        disp(['New field ' new_fields{i} 'size is [' num2str(size(getfield(newResult,new_fields{i}))) ']']);
                        disp(['Sum of absolute difference in ' ref_fields{i} ' is ' ...
                            num2str(sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}))))) ]);             
                    end
                end
                
                % save and load new ref output file
                expectedResult = newResult;
                save(ref_output_file, 'expectedResult');
                load(ref_output_file);
            end  
            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            
            assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
            
            for i = 1:length(new_fields)
                assert(isequal(size(getfield(newResult,new_fields{i})),size(getfield(expectedResult,new_fields{i}))),sprintf('size of %s is different', new_fields{i}))
                assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i})) < 1e-6)), ...
                    sprintf('%s result off by %f (sum absolute difference)', new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}))))));
            end
            
        end
        
    end

end