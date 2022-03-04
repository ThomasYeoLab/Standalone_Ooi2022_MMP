classdef test_CBIG_write_delimited_txtfile < matlab.unittest.TestCase
    % Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
  
    methods(Test)
        function testWrittenCsv(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'utilities', 'CBIG_write_delimited_txtfile');
            
            input.headers = {'SITE_ID'; 'SUB_ID'; 'DX_GROUP'; 'AGE_AT_SCAN'; 'SEX'};
            input.alldata_str = {{'siteA'    'siteB'    'siteC'    'siteD'}, ...
                               {'aaaaa'    'ccccc'    'ddddd'    'eeeee'}, ...
                               {'1'    '0'    'NaN'    '1'}, ...
                               {'20.75'    '21.4346'    '13.25'    ''}, ...
                               {'1'    '1'    '1'    '1'}};
            
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            filename = fullfile(output_dir, 'output_testWrittenCsv.csv');
            out_field = {'SITE_ID','SUB_ID','DX_GROUP','SEX'};
            CBIG_write_delimited_txtfile(filename, input.headers, input.alldata_str, out_field);
            
            ref_file = fullfile(ref_dir, 'ref_output', 'output_testWrittenCsv.csv');
            status = system(['fc ' 'output_testWrittenCsv.csv' ' ' ref_file]); % if two files are different, status will be 1, else status is 0
            if(replace_unittest_flag)
               disp('Replacing unit test reference results for test_CBIG_write_delimited_txtfile, testWrittenCsv...');
               if logical(status)
                   disp('Written csv file is different from reference file.');

               end
               % save output as ref file
               CBIG_write_delimited_txtfile(ref_file, input.headers, input.alldata_str, out_field);
            else
                assert(logical(~status), 'Written csv file is different from reference file.');
            end
            
            rmdir(output_dir, 's');
        end
        
        function testWrittenTxt(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'utilities', 'CBIG_write_delimited_txtfile');
            
            input.headers = {'SITE_ID'; 'SUB_ID'; 'DX_GROUP'; 'AGE_AT_SCAN'; 'SEX'};
            input.alldata_str = {{'siteA'    'siteB'    'siteC'    'siteD'}, ...
                               {'aaaaa'    'ccccc'    'ddddd'    'eeeee'}, ...
                               {'1'    '0'    'NaN'    '1'}, ...
                               {'20.75'    '21.4346'    '13.25'    ''}, ...
                               {'1'    '1'    '1'    '1'}};
            
            output_dir = fullfile(ref_dir, 'output');
            mkdir(output_dir)
            filename = fullfile(output_dir, 'output_testWrittenTxt.txt');
            out_field = {'SITE_ID','SUB_ID','AGE_AT_SCAN'};
            CBIG_write_delimited_txtfile(filename, input.headers, input.alldata_str, out_field);
            
            ref_file = fullfile(ref_dir, 'ref_output', 'output_testWrittenTxt.txt');
            status = system(['fc ' 'output_testWrittenTxt.txt' ' ' ref_file]); % if two files are different, status will be 1, else status is 0
            if(replace_unittest_flag)
               disp('Replacing unit test reference results for test_CBIG_write_delimited_txtfile, testWrittenTxt...');
               if logical(status)
                   disp('Written csv file is different from reference file.');
               end
               % save output as ref file
               CBIG_write_delimited_txtfile(ref_file, input.headers, input.alldata_str, out_field);
            else
               assert(logical(~status), 'Written txt file is different from reference file.');
            end
            rmdir(output_dir, 's');
        end
        
    end
    
end
        