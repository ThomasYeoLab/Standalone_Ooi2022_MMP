classdef test_CBIG_Projectfsaverage2MNI_Ants < matlab.unittest.TestCase
    % Written by Siyi Tang, Jingwei Li and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md
    
    methods (Test)
        function testLinearInterp(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'transforms', 'CBIG_Projectfsaverage2MNI_Ants');
            
            % load input
            lh_input = repmat(1:42, 1, 3901);
            rh_input = repmat(1:42, 1, 3901) + 42;
            
            output = CBIG_Projectfsaverage2MNI_Ants(lh_input', rh_input', 'linear');
            output.niftihdr.cal_max = max(output.vol(:));
            
            % load reference result
            ref_output = MRIread([ref_dir '/ref_output/result_linearInterp.nii.gz']);
            
            ref_fields = fieldnames(ref_output);
            output_fields = fieldnames(output);
            
            
            if (replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_Projectfsaverage2MNI_Ants linear Interp.');
                
                MRIwrite(output,[ref_dir '/ref_output/result_linearInterp.nii.gz']);
                
                %print out the difference between current output and
                %ref_output
                for i = 1:length(output_fields)
                    if (~isequal(output_fields{i},'pwd')) && (~isequal(output_fields{i},'fspec'))
                        curr_ref = getfield(ref_output, ref_fields{i});
                        curr_output = getfield(output, output_fields{i});
                        
                        if (~isequal(size(curr_ref),size(curr_output)))
                            sprintf('Output structure field %s is of wrong size.\n', ...
                                output_fields{i});
                        end
                        if (~isequaln(curr_ref, curr_output))
                            sprintf('Output structure field %s differed from reference result.\n',...
                                output_fields{i});
                        end
                        
                    end
                end
                
            else
                assert(isequal(size(ref_fields),size(output_fields)), ...
                    'Output structure field is of wrong size.');
                assert(isequal(ref_fields,output_fields), ...
                    'Output structure field differed from reference result.');
                
                for i = 1:length(output_fields)
                    if (~isequal(output_fields{i},'pwd')) && (~isequal(output_fields{i},'fspec'))
                        curr_ref = getfield(ref_output, ref_fields{i});
                        curr_output = getfield(output, output_fields{i});
                        
                        assert(isequal(size(curr_ref),size(curr_output)), ...
                            sprintf('Output structure field %s is of wrong size.', ...
                            output_fields{i}));
                        assert(isequaln(curr_ref, curr_output), ...
                            sprintf('Output structure field %s differed from reference result.',...
                            output_fields{i}));
                    end
                end
            end
            
        end
        
        function testNearestInterp(TestCase)
            CBIG_CODE_DIR = getenv('CBIG_CODE_DIR');
            
            load(fullfile(CBIG_CODE_DIR, 'unit_tests', 'replace_unittest_flag'));
            
            ref_dir = fullfile(CBIG_CODE_DIR, 'unit_tests', 'utilities', ...
                'matlab', 'transforms', 'CBIG_Projectfsaverage2MNI_Ants');
            
            % load input
            lh_input = repmat(1:42, 1, 3901);
            rh_input = repmat(1:42, 1, 3901) + 42;
            
            output = CBIG_Projectfsaverage2MNI_Ants(lh_input', rh_input', 'nearest');
            output.niftihdr.cal_max = max(output.vol(:));
            
            % load reference result
            ref_output = MRIread([ref_dir '/ref_output/result_nearestInterp.nii.gz']);
            
            ref_fields = fieldnames(ref_output);
            output_fields = fieldnames(output);
            
            if (replace_unittest_flag)
                disp('Replacing unit test reference results for CBIG_Projectfsaverage2MNI_Ants nearest Interp.');
                
                MRIwrite(output,[ref_dir '/ref_output/result_nearestInterp.nii.gz']);
                
                %print out the difference between current output and
                %ref_output
                for i = 1:length(output_fields)
                    if (~isequal(output_fields{i},'pwd')) && (~isequal(output_fields{i},'fspec'))
                        curr_ref = getfield(ref_output, ref_fields{i});
                        curr_output = getfield(output, output_fields{i});
                        
                        if (~isequal(size(curr_ref),size(curr_output)))
                            sprintf('Output structure field %s is of wrong size.\n', ...
                                output_fields{i});
                        end
                        if (~isequaln(curr_ref, curr_output))
                            sprintf('Output structure field %s differed from reference result.\n',...
                                output_fields{i});
                        end
                        
                    end
                end

            else
                assert(isequal(size(ref_fields),size(output_fields)), ...
                    'Output structure field is of wrong size.');
                assert(isequal(ref_fields,output_fields), ...
                    'Output structure field differed from reference result.');
                
                for i = 1:length(output_fields)
                    if (~isequal(output_fields{i}, 'pwd')) && (~isequal(output_fields{i},'fspec'))
                        curr_ref = getfield(ref_output, ref_fields{i});
                        curr_output = getfield(output, output_fields{i});
                        
                        assert(isequal(size(curr_ref),size(curr_output)), ...
                            sprintf('Output structure field %s is of wrong size.', ...
                            output_fields{i}));
                        assert(isequaln(curr_ref, curr_output), ...
                            sprintf('Output structure field %s differed from reference result.', ...
                            output_fields{i}));
                    end
                end
            end
            
        end
        
    end
    
end
