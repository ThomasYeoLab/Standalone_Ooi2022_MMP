function CBIG_WriteFSLabelsInTxtFilesToCaretPaint(hemi, mesh_name, input_label_files_txt, output_caret_number_vec_txt, output_file, exit_flag)

% CBIG_WriteFSLabelsInTxtFilesToCaretPaint(hemi, mesh_name, input_label_files_txt, output_caret_number_vec_txt, output_file, exit_flag)
% 
% This is a wrapper to call CBIG_WriteFSLabelToCaretPaint. Essentially, it reads in the text files input_label_files_txt,
% output_caret_number_vec_txt into a cell and a vector and pass it to CBIG_WriteFSLabelToCaretPaint
%
% hemi = 'lh' or 'rh'
% mesh_name = freesurfer mesh resolution: fsaverage4, fsaverage5, fsaverage6, fsaverage 
% input_label_files_txt = txt file where each line corresponds to a *.label file. For example, the text might look like:
%                                          <full_path>/lh.something1.label
%                                          <full_path>/lh.something2.label
%
% caret_num_txt  = txt file of numbers telling how each input label file is mapped into caret labels FS.???.label
%                  For example, the text might look like:
%                                 2
%                                 5
%
% so that lh.something1.label is mapped to the name FS.002.label and lh.something2.label is mapped to the name FS.005.label
% Note that the numbers should also be unique.       
%
% output_file = caret output ; accepted format = .paint
% exit_flag = if 1, then exit matlab at the end of this function. This is
% useful if calling from shell
%
% example usage: 
%     CBIG_WriteFSLabelToCaretPaint('lh', 'fsaverage5', 'labels.txt', 'caret_num_txt', 'test/lh.test.paint', 0)
%
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


% read in both left and right text files.
fid = fopen(input_label_files_txt, 'r');
i = 0;
while(1);
   tmp = fscanf(fid, '%s\n', 1);
   if(isempty(tmp))
       break
   else
       i = i + 1;
       label_files{i} = tmp;
   end
end
fclose(fid);

% read in both left and right text files.
fid = fopen(output_caret_number_vec_txt, 'r');
i = 0;
while(1);
   tmp = fscanf(fid, '%s\n', 1);
   if(isempty(tmp))
       break
   else
       i = i + 1;
       caret_num_vec(i) = str2num(tmp);
   end
end
fclose(fid);

CBIG_WriteFSLabelToCaretPaint(hemi, mesh_name, label_files, caret_num_vec, output_file, exit_flag);
