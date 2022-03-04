classdef test_MARS_computeFoldingEnergyFast < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testTwoInput(testCase)
            % we use expectedResult in test_MARS2_readSbjMesh as the input
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'BasicTools', 'MARS2_readSbjMesh', 'ref_output', 'expectedResult_lh.mat'));
            input_mesh = expectedResult;
            % reverse face
            faces = input_mesh.faces;
            input_mesh.faces = [faces(3,:); faces(2,:); faces(1,:)];
            
            [newResult.energy,newResult.list] = MARS_computeFoldingEnergyFast(input_mesh.vertices,input_mesh);
            %load ref output
            ref_output_file = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'BasicTools', 'MARS_computeFoldingEnergyFast', 'ref_output', 'expectedResult_2inputs.mat');
            load(ref_output_file);
            
            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_computeFoldingEnergyFast, testTwoInput");
                % display differences
                disp(['Old energy size is [' num2str(size(newResult.energy)) ']'] );
                disp(['New energy size is [' num2str(size(expectedResult.energy)) ']']);
                disp(['Sum of absolute difference for energy is ' num2str(sum(sum(abs(newResult.energy - expectedResult.energy)))) ]);             
                disp(['Old list size is [' num2str(size(newResult.list)) ']'] );
                disp(['New list size is [' num2str(size(expectedResult.list)) ']']);
                disp(['Sum of absolute difference for energy is ' num2str(sum(sum(abs(newResult.list - expectedResult.list)))) ]); 
                
                % save and load new ref output file
                expectedResult = newResult;
                save(ref_output_file, 'expectedResult');
                load(ref_output_file);
            end  
            
            % check energy
            assert(all(size(newResult.energy) == size(expectedResult.energy)), 'size of energy is different')
            assert(all(all(abs(newResult.energy - expectedResult.energy) < 1e-6)), sprintf('energy off by %f', sum(sum(abs(newResult.energy - expectedResult.energy)))));
            % check list
            assert(all(size(newResult.list) == size(expectedResult.list)), 'size of list is different')
            assert(all(all(newResult.list == expectedResult.list)), sprintf('list is different'));
                        
        end
        
        function testThreeInputs(testCase)
            % we use expectedResult in test_MARS2_readSbjMesh as the input
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            replace_unit_test = load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'BasicTools', 'MARS2_readSbjMesh', 'ref_output', 'expectedResult_lh.mat'));
            input_mesh = expectedResult;
            % reverse face
            faces = input_mesh.faces;
            input_mesh.faces = [faces(3,:); faces(2,:); faces(1,:)];
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', 'BasicTools', ...
                'MARS_computeFoldingEnergyFast', 'ref_output', 'expectedResult_2inputs.mat'));
            folded_vertices = expectedResult.list;
            [newResult.energy,newResult.list] = MARS_computeFoldingEnergyFast(input_mesh.vertices,input_mesh,folded_vertices);
            % load ref output
            ref_output_file = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', ...
                'SDv1.5.1-svn593', 'BasicTools', 'MARS_computeFoldingEnergyFast', 'ref_output', 'expectedResult_3inputs.mat')
            load(ref_output_file);
            
            % replace unit test if flag is 1
            if replace_unit_test
                disp("Replacing unit test for MARS_computeFoldingEnergyFast, testThreeInput");
                % display differences
                disp(['Old energy size is [' num2str(size(newResult.energy)) ']'] );
                disp(['New energy size is [' num2str(size(expectedResult.energy)) ']']);
                disp(['Sum of absolute difference for energy is ' num2str(sum(sum(abs(newResult.energy - expectedResult.energy)))) ]);             
                disp(['Old list size is [' num2str(size(newResult.list)) ']'] );
                disp(['New list size is [' num2str(size(expectedResult.list)) ']']);
                disp(['Sum of absolute difference for energy is ' num2str(sum(sum(abs(newResult.list - expectedResult.list)))) ]); 
                
                % save and load new ref output file
                expectedResult = newResult;
                save(ref_output_file, 'expectedResult');
                load(ref_output_file);
            end 
            
            % check energy
            assert(all(size(newResult.energy) == size(expectedResult.energy)), 'size of energy is different')
            assert(all(all(abs(newResult.energy - expectedResult.energy) < 1e-6)), sprintf('energy off by %f', sum(sum(abs(newResult.energy - expectedResult.energy)))));
            % check list
            assert(all(size(newResult.list) == size(expectedResult.list)), 'size of list is different')
            assert(all(all(newResult.list == expectedResult.list)), sprintf('list is different'));
        end
    end

end