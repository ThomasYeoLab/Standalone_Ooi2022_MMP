classdef test_CBIG_parse_delimited_txtfile < matlab.unittest.TestCase
% Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

methods (Test)
        function testParsedData(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'utilities', 'CBIG_parse_delimited_txtfile');
            input = fullfile(ref_dir, 'input/behavior_scores.csv');
            
            fieldname_str_cell = {'SITE_ID','SUB_ID'};
            fieldname_num_cell = {'DX_GROUP','AGE_AT_SCAN','SEX'};
            filter_fieldname = 'SUB_ID';
            filter_val_str_cell = {'aaaaa','ccccc','ddddd', 'eeeee'};
            [subdata_str_cell, subdata_num, headers, alldata_str] = CBIG_parse_delimited_txtfile(input, fieldname_str_cell, fieldname_num_cell,filter_fieldname, filter_val_str_cell);
            
            % load reference result
            ref_result_path = fullfile(ref_dir, 'ref_output', 'expectedResult.mat');
            load(ref_result_path);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_parse_delimited_txtfile...');
                if ~isequal(size(ref_subdata_str_cell),size(subdata_str_cell))
                    disp('subdata_str_cell is of wrong size.');
                end
                if ~all(all(cellfun(@isequaln,ref_subdata_str_cell,subdata_str_cell)))
                    disp('subdata_str_cell different from reference result.');
                end
                
                if ~isequal(size(ref_subdata_num),size(subdata_num))
                    disp('subdata_num is of wrong size.');
                end
                if ~all(all(isequaln(ref_subdata_num,subdata_num)))
                    disp('subdata_num different from reference result.');
                end
                
                if ~isequal(size(ref_headers), size(headers))
                    disp('headers is of wrong size.');
                end
                if ~all(all(cellfun(@isequaln,ref_headers,headers)))
                    disp('headers different from reference result.');
                end
                
                if ~isequal(size(ref_alldata_str),size(alldata_str))
                    disp('alldata_str is of wrong size.');
                end
                if ~all(all(cellfun(@isequaln,ref_alldata_str,alldata_str)))
                    disp('alldata_str different from reference result.');
                end
                % save ref result
                ref_alldata_str = alldata_str;
                ref_headers = headers;
                ref_subdata_num = subdata_num;
                ref_subdata_str_cell = subdata_str_cell;
                save(ref_result_path, 'ref_alldata_str', 'ref_headers', 'ref_subdata_num', 'ref_subdata_str_cell');
                
            else
                assert(isequal(size(ref_subdata_str_cell),size(subdata_str_cell)), 'subdata_str_cell is of wrong size.');
                assert(all(all(cellfun(@isequaln,ref_subdata_str_cell,subdata_str_cell))), 'subdata_str_cell different from reference result.');

                assert(isequal(size(ref_subdata_num),size(subdata_num)), 'subdata_num is of wrong size.');
                assert(all(all(isequaln(ref_subdata_num,subdata_num))), 'subdata_num different from reference result.');

                assert(isequal(size(ref_headers), size(headers)), 'headers is of wrong size.');
                assert(all(all(cellfun(@isequaln,ref_headers,headers))), 'headers different from reference result.');

                assert(isequal(size(ref_alldata_str),size(alldata_str)), 'alldata_str is of wrong size.');
                assert(all(all(cellfun(@isequaln,ref_alldata_str,alldata_str))), 'alldata_str different from reference result.');
            end
                  
        end
            
end

end
            