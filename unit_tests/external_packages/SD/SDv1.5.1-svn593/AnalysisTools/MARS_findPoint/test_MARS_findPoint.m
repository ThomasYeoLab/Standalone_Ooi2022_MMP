classdef test_MARS_findPoint < matlab.unittest.TestCase
% Written by Kong Xiaolu and CBIG under MIT license: http://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        
        function Test(testCase)
            
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'AnalysisTools', 'MARS_findPoint');

            % get the current output using artificial data
            load(fullfile(ref_dir, 'input', 'input.mat'));
            vertex_num_test = MARS_findPoint(vertices,point);
            load(fullfile(ref_dir, 'ref_output', 'output.mat'));
            
            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_findPoint");
                % display differences
                disp(['Old size is [' num2str(size(vertex_num)) ']'] );
                disp(['New size is [' num2str(size(vertex_num_test)) ']']);
                disp(['Old result vertex index is ' num2str(vertex_num) ] );
                disp(['New result vertex index is ' num2str(vertex_num_test) ]);             
                
                % save and load new output file
                vertex_num = vertex_num_test;
                output_file = fullfile(ref_dir, 'ref_output','output.mat');
                save(output_file, 'vertex_num');
                load(output_file);
            end

            % compare the current output with expected output
            assert(size(vertex_num_test,1) == 1,'no. of rows must be 1')
            assert(size(vertex_num_test,2) == 1,'no. of columns must be 1')
            assert(all(all(vertex_num_test == vertex_num)),sprintf('result index is not correct'))
             
        end

    end
    
end
