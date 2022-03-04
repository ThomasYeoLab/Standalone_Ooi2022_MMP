classdef test_MARS2_readSbjMesh < matlab.unittest.TestCase
% Written by Jianzhong Chen and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

    methods (Test)
        function testLeftHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            % load ref output
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS2_readSbjMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'lh';
            params.SUBJECT = 'fsaverage6';
            params.read_surface = @MARS2_readSbjMesh;
            params.radius = 100;
            params.unfoldBool = 0;
            params.flipFacesBool = 1;
            params.surf_filename = 'sphere';
            params.metric_surf_filename = 'inflated';
            params.data_filename_cell = {'sulc', 'curv'};
            params.label_filename_cell = {'cortex'};

            newResult = MARS2_readSbjMesh(params);
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS2_readSbjMesh, testLeftHemisphere...');
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
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_lh.mat'), 'expectedResult');
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
                for i = 1:length(new_fields)
                    % 10th filed is a struct so we compare it seperately
                    if i ~= 10
                        equalsize = isequal(size(getfield(newResult,new_fields{i})), ...
                            size(getfield(expectedResult,new_fields{i})));
                        assert(equalsize, sprintf('size of %s is different', new_fields{i}));
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        assert(all(all(abserror< 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                            new_fields{i}, sum(sum(abserror))));
                   end
                end
                % check the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end
            
        end
        
        function testRightHemisphere(testCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            % load ref output
            cur_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'external_packages', 'SD', 'SDv1.5.1-svn593', ...
                'BasicTools', 'MARS2_readSbjMesh');
            load(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'));
            % input arguments
            params.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
            params.hemi = 'rh';
            params.SUBJECT = 'fsaverage';
            params.read_surface = @MARS2_readSbjMesh;
            params.radius = 80;
            params.unfoldBool = 1;
            params.flipFacesBool = 0;
            params.surf_filename = 'inflated';
            params.metric_surf_filename = 'white';
            params.data_filename_cell = {'sulc', 'curv'};
            params.annot_filename = 'Yeo2011_7Networks_N1000.annot';
            
            newResult = MARS2_readSbjMesh(params);
            new_fields = fieldnames(newResult);
            ref_fields = fieldnames(expectedResult);
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_MARS2_readSbjMesh, testRightHemisphere...');
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
                save(fullfile(cur_dir, 'ref_output', 'expectedResult_rh.mat'), 'expectedResult');
            else
                assert(isequal(new_fields,ref_fields),'fields of the output structure are different');
                for i = 1:length(new_fields)
                    % 10th filed is a struct so we compare it seperately
                    if i ~= 10
                        equalsize = isequal(size(getfield(newResult,new_fields{i})), ...
                            size(getfield(expectedResult,new_fields{i})));
                        assert(equalsize, sprintf('size of %s is different', new_fields{i}));
                        abserror = abs(getfield(newResult, new_fields{i}) - getfield(expectedResult, new_fields{i}));
                        assert(all(all(abserror< 1e-6)), sprintf('%s result off by %f (sum absolute difference)', ...
                            new_fields{i}, sum(sum(abserror))));
                    end
                end
                % check the 10th field
                assert(isequaln(newResult.MARS_ct,expectedResult.MARS_ct),'MARS_ct is different');
            end            
        end
    end

end
