classdef test_read_annotation < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            
            % load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_annotation');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'lh';
            params.SUBJECT = 'fsaverage';
            params.annot_filename = 'Yeo2011_7Networks_N1000.annot';

            annot_file = fullfile(params.SUBJECTS_DIR, params.SUBJECT, 'label', ...
                strcat(params.hemi, '.', params.annot_filename));
            [newResult.vertices,newResult.label,newResult.colortable] = read_annotation(annot_file);
            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_annotation, testLeftHemisphere...');
                if ~isequal(new_fields,ref_fields)
                    disp('fields of the output structure are different');
                end 
                for i = 1:2 % check the vertices and lable
                    abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                    disp(['Old field ' ref_fields{i} ' size is [' num2str(size(getfield(expectedResult,new_fields{i}))) ']'] );
                    disp(['New field ' new_fields{i} ' size is [' num2str(size(getfield(newResult,new_fields{i}))) ']']);
                end
                if ~isequaln(newResult.colortable,expectedResult.colortable) % check colortable
                    disp('colortable is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult'); 
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different'); 

                for i = 1:2 % check the vertices and lable
                    assert(isequal(size(getfield(newResult,new_fields{i})),size(getfield(expectedResult,new_fields{i}))),...
                        sprintf('size of %s is different', new_fields{i}))
                    assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i})) ...
                    < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                        new_fields{i}))))));
                end

                % check colortable
                assert(isequaln(newResult.colortable,expectedResult.colortable),'colortable is different');
                
            end
        end
        
        function testRightHemisphere(testCase)
            
            % load ref output
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'read_annotation');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'rh';
            params.SUBJECT = 'fsaverage';
            params.annot_filename = 'Yeo2011_7Networks_N1000.annot';

            annot_file = fullfile(params.SUBJECTS_DIR, params.SUBJECT, 'label', ...
                strcat(params.hemi, '.', params.annot_filename));
            [newResult.vertices,newResult.label,newResult.colortable] = read_annotation(annot_file);
            
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_read_annotation, testRightHemisphere...');
                if ~isequal(new_fields,ref_fields)
                    disp('fields of the output structure are different');
                end 
                for i = 1:2 % check the vertices and lable
                    abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                    disp(['Total error (' new_fields{i} '): ' num2str(sum(sum(abserror)))]);
                    disp(['Old field ' ref_fields{i} ' size is [' num2str(size(getfield(expectedResult,new_fields{i}))) ']'] );
                    disp(['New field ' new_fields{i} ' size is [' num2str(size(getfield(newResult,new_fields{i}))) ']']);
                end
                if ~isequaln(newResult.colortable,expectedResult.colortable) % check colortable
                    disp('colortable is different');
                end
                expectedResult = newResult;
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult'); 
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different'); 

                for i = 1:2 % check the vertices and lable
                    assert(isequal(size(getfield(newResult,new_fields{i})),...
                        size(getfield(expectedResult,new_fields{i}))),sprintf('size of %s is different', new_fields{i}))
                    assert(all(all(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i})) ...
                    < 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                        new_fields{i}, sum(sum(abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, ...
                        new_fields{i}))))));
                end

                % check colortable
                assert(isequaln(newResult.colortable,expectedResult.colortable),'colortable is different');
                
            end
            
        end
    end

end