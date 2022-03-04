classdef test_CBIG_read_annotation < matlab.unittest.TestCase
    % Written by Siyi Tang and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function testFsaverage6(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'utilities', 'CBIG_read_annotation');
            input_lh = fullfile(ref_dir, 'input', 'fsaverage6', 'lh.Schaefer2018_400Parcels_17Networks_order.annot');
            input_rh = fullfile(ref_dir, 'input', 'fsaverage6', 'rh.Schaefer2018_400Parcels_17Networks_order.annot');
            
            [lh_vertex_label, lh_colortable] = CBIG_read_annotation(input_lh);
            [rh_vertex_label, rh_colortable] = CBIG_read_annotation(input_rh);

            % load reference result
            result = load(fullfile(ref_dir, 'ref_output', 'result_testFsaverage6.mat'));
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_annotation, testFsaverage6...');
                % check lh
                if ~isequal(size(lh_vertex_label),size(result.lh_vertex_label))
                    disp('lh_vertex_label is of wrong size.');
                end
                abserror = abs(result.lh_vertex_label - lh_vertex_label);
                disp(['Maximum absolute error (' 'lh_vertex_label' '):' num2str(max(abserror))]);
                
                result_fields = fieldnames(result.lh_colortable);
                output_fields = fieldnames(lh_colortable);
                
                if ~length(result_fields) == length(output_fields)
                    disp('lh_colortable has wrong length of structure fields.');
                end
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.lh_colortable, result_fields{i});
                    curr_output_field = getfield(lh_colortable, output_fields{i});
                    if ~isequal(size(curr_result_field), size(curr_output_field))
                        msg = sprintf('structure field %s is of wrong size.', output_fields{i});
                        disp(msg);
                    end
                    if iscell(curr_output_field)
                        if ~all(all(cellfun(@isequal,curr_result_field, curr_output_field)))
                            msg = sprintf('structure field %s is different from reference.', output_fields{i});
                            disp(msg);
                        end
                    else
                        abserror = abs(curr_result_field - curr_output_field);
                        disp(['Maximum absolute error (' output_fields{i} '):' num2str(max(abserror))]);
                    end
                end
                % check rh
                if ~isequal(size(rh_vertex_label),size(result.rh_vertex_label))
                    disp('rh_vertex_label is of wrong size.');
                end
                abserror = abs(result.rh_vertex_label - rh_vertex_label);
                disp(['Maximum absolute error (' 'rh_vertex_label' '):' num2str(max(abserror))]);
                
                result_fields = fieldnames(result.rh_colortable);
                output_fields = fieldnames(rh_colortable);

                if ~length(result_fields) == length(output_fields)
                    disp('rh_colortable has wrong length of structure fileds.');
                end
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.rh_colortable, result_fields{i});
                    curr_output_field = getfield(rh_colortable, output_fields{i});
                    if ~isequal(size(curr_result_field), size(curr_output_field))
                        msg = sprintf('structure field %s is of wrong size.', output_fields{i});
                        disp(msg);
                    end
                    if iscell(curr_output_field)
                        if ~all(all(cellfun(@isequaln,curr_result_field, curr_output_field)))
                            msg = sprintf('structure field %s is different from reference.', output_fields{i});
                            disp(msg);
                        end
                    else
                        abserror = abs(curr_result_field - curr_output_field);
                        disp(['Maximum absolute error (' output_fields{i} '):' num2str(max(abserror))]);
                    end
                end
                % save reference result
                result.lh_vertex_label = lh_vertex_label;
                result.lh_colortable = lh_colortable;
                result.rh_vertex_label = rh_vertex_label;
                result.rh_colortable = rh_colortable;
                save(fullfile(ref_dir, 'ref_output', 'result_testFsaverage6.mat'), 'result');

            else
                % check lh
                assert(isequal(size(lh_vertex_label),size(result.lh_vertex_label)), ...
                    'lh_vertex_label is of wrong size.');
                assert(all(abs(result.lh_vertex_label - lh_vertex_label) < 1e-12), ...
                    sprintf('lh_vertex_label differed by (max abs diff) %f.', ...
                    max(abs(result.lh_vertex_label - lh_vertex_label))));

                result_fields = fieldnames(result.lh_colortable);
                output_fields = fieldnames(lh_colortable);

                assert(length(result_fields) == length(output_fields), ...
                    'lh_colortable has wrong length of structure fileds.');
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.lh_colortable, result_fields{i});
                    curr_output_field = getfield(lh_colortable, output_fields{i});
                    assert(isequal(size(curr_result_field), size(curr_output_field)), ...
                        sprintf('structure field %s is of wrong size.', output_fields{i}));
                    if iscell(curr_output_field)
                        assert(all(all(cellfun(@isequal,curr_result_field, curr_output_field))), ...
                            sprintf('structure field %s is different from reference.', output_fields{i}));
                    else
                        assert(isequal(curr_result_field, curr_output_field), ...
                            sprintf('structure field %s differed by (max abs diff) %f.', ...
                            output_fields{i}, max(max(abs(curr_result_field - curr_output_field)))));
                    end
                end

                % check rh
                assert(isequal(size(rh_vertex_label),size(result.rh_vertex_label)), ...
                    'rh_vertex_label is of wrong size.');
                assert(all(abs(result.rh_vertex_label - rh_vertex_label) < 1e-12), ...
                    sprintf('rh_vertex_label differed by (max abs diff) %f.', ...
                    max(abs(result.rh_vertex_label - rh_vertex_label))));

                result_fields = fieldnames(result.rh_colortable);
                output_fields = fieldnames(rh_colortable);

                assert(length(result_fields) == length(output_fields), ...
                    'lh_colortable has wrong length of structure fields.');
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.rh_colortable, result_fields{i});
                    curr_output_field = getfield(rh_colortable, output_fields{i});
                    assert(isequal(size(curr_result_field), size(curr_output_field)), ...
                        sprintf('structure field %s is of wrong size.', output_fields{i}));
                    if iscell(curr_output_field)
                        assert(all(all(cellfun(@isequaln,curr_result_field, curr_output_field))), ...
                            sprintf('structure field %s is different from reference.', output_fields{i}));
                    else
                        assert(isequaln(curr_result_field, curr_output_field), ...
                            sprintf('structure field %s differed by (max abs diff) %f.', ...
                            output_fields{i}, max(max(abs(curr_result_field - curr_output_field)))));
                    end
                end
            end
        end
        
        function testFsaverage5(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'utilities', 'CBIG_read_annotation');
            input_lh = fullfile(ref_dir, 'input', 'fsaverage5', 'lh.Schaefer2018_400Parcels_17Networks_order.annot');
            input_rh = fullfile(ref_dir, 'input', 'fsaverage5', 'rh.Schaefer2018_400Parcels_17Networks_order.annot');
            
            [lh_vertex_label, lh_colortable] = CBIG_read_annotation(input_lh);
            [rh_vertex_label, rh_colortable] = CBIG_read_annotation(input_rh);
            
            % load reference result
            result = load(fullfile(ref_dir, 'ref_output', 'result_testFsaverage5.mat'));
            
            if(replace_unittest_flag)
                disp('Replacing unit test reference results for test_CBIG_read_annotation, testFsaverage5...');
                % check lh
                if ~isequal(size(lh_vertex_label),size(result.lh_vertex_label))
                    disp('lh_vertex_label is of wrong size.');
                end
                abserror = abs(result.lh_vertex_label - lh_vertex_label);
                disp(['Maximum absolute error (' 'lh_vertex_label' '):' num2str(max(abserror))]);
                
                result_fields = fieldnames(result.lh_colortable);
                output_fields = fieldnames(lh_colortable);
                
                if ~length(result_fields) == length(output_fields)
                    disp('lh_colortable has wrong length of structure fields.');
                end
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.lh_colortable, result_fields{i});
                    curr_output_field = getfield(lh_colortable, output_fields{i});
                    if ~isequal(size(curr_result_field), size(curr_output_field))
                        msg = sprintf('structure field %s is of wrong size.', output_fields{i});
                        disp(msg);
                    end
                    if iscell(curr_output_field)
                        if ~all(all(cellfun(@isequal,curr_result_field, curr_output_field)))
                            msg = sprintf('structure field %s is different from reference.', output_fields{i});
                            disp(msg);
                        end
                    else
                        abserror = abs(curr_result_field - curr_output_field);
                        disp(['Maximum absolute error (' output_fields{i} '):' num2str(max(abserror))]);
                    end
                end
                % check rh
                if ~isequal(size(rh_vertex_label),size(result.rh_vertex_label))
                    disp('rh_vertex_label is of wrong size.');
                end
                abserror = abs(result.rh_vertex_label - rh_vertex_label);
                disp(['Maximum absolute error (' 'rh_vertex_label' '):' num2str(max(abserror))]);
                result_fields = fieldnames(result.rh_colortable);
                output_fields = fieldnames(rh_colortable);

                if ~length(result_fields) == length(output_fields)
                    disp('rh_colortable has wrong length of structure fields.');
                end
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.rh_colortable, result_fields{i});
                    curr_output_field = getfield(rh_colortable, output_fields{i});
                    if ~isequal(size(curr_result_field), size(curr_output_field))
                        msg = sprintf('structure field %s is of wrong size.', output_fields{i});
                        disp(msg);
                    end
                    if iscell(curr_output_field)
                        if ~all(all(cellfun(@isequaln,curr_result_field, curr_output_field)))
                            msg = sprintf('structure field %s is different from reference.', output_fields{i});
                            disp(msg);
                        end
                    else
                        abserror = abs(curr_result_field - curr_output_field);
                        disp(['Maximum absolute error (' output_fields{i} '):' num2str(max(abserror))]);
                    end
                end
                % save reference result
                result.lh_vertex_label = lh_vertex_label;
                result.lh_colortable = lh_colortable;
                result.rh_vertex_label = rh_vertex_label;
                result.rh_colortable = rh_colortable;
                save(fullfile(ref_dir, 'ref_output', 'result_testFsaverage5.mat'), 'result');

            else
                % check lh
                assert(isequal(size(lh_vertex_label),size(result.lh_vertex_label)), ...
                    'lh_vertex_label is of wrong size.');
                assert(all(abs(result.lh_vertex_label - lh_vertex_label) < 1e-12), ...
                    sprintf('lh_vertex_label differed by (max abs diff) %f.', ...
                    max(abs(result.lh_vertex_label - lh_vertex_label))));

                result_fields = fieldnames(result.lh_colortable);
                output_fields = fieldnames(lh_colortable);

                assert(length(result_fields) == length(output_fields), ...
                    'lh_colortable has wrong length of structure fileds.');
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.lh_colortable, result_fields{i});
                    curr_output_field = getfield(lh_colortable, output_fields{i});
                    assert(isequal(size(curr_result_field), size(curr_output_field)), ...
                        sprintf('structure field %s is of wrong size.', output_fields{i}));
                    if iscell(curr_output_field)
                        assert(all(all(cellfun(@isequal,curr_result_field, curr_output_field))), ...
                            sprintf('structure field %s is different from reference.', output_fields{i}));
                    else
                        assert(isequal(curr_result_field, curr_output_field), ...
                            sprintf('structure field %s differed by (max abs diff) %f.', ...
                            output_fields{i}, max(max(abs(curr_result_field - curr_output_field)))));
                    end
                end

                % check rh
                assert(isequal(size(rh_vertex_label),size(result.rh_vertex_label)), ...
                    'rh_vertex_label is of wrong size.');
                assert(all(abs(result.rh_vertex_label - rh_vertex_label) < 1e-12), ...
                    sprintf('rh_vertex_label differed by (max abs diff) %f.', ...
                    max(abs(result.rh_vertex_label - rh_vertex_label))));

                result_fields = fieldnames(result.rh_colortable);
                output_fields = fieldnames(rh_colortable);

                assert(length(result_fields) == length(output_fields), ...
                    'rh_colortable has wrong length of structure fields.');
                for i = 1:length(result_fields)
                    curr_result_field = getfield(result.rh_colortable, result_fields{i});
                    curr_output_field = getfield(rh_colortable, output_fields{i});
                    assert(isequal(size(curr_result_field), size(curr_output_field)), ...
                        sprintf('structure field %s is of wrong size.', output_fields{i}));
                    if iscell(curr_output_field)
                        assert(all(all(cellfun(@isequaln,curr_result_field, curr_output_field))), ...
                            sprintf('structure field %s is different from reference.', output_fields{i}));
                    else
                        assert(isequaln(curr_result_field, curr_output_field), ...
                            sprintf('structure field %s differed by (max abs diff) %f.', ...
                            output_fields{i}, max(max(abs(curr_result_field - curr_output_field)))));
                    end
                end
            end

            
        end
        
    end
    
end
