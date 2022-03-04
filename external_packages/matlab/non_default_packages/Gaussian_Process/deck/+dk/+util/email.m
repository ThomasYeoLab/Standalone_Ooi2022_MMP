function email( dest, subject, msg, credentials, attach )
%
% email( dest, subject, msg, credentials, attach )
%
% Send an email using input credentials.
% Save a Matlab structure with 600 permission somewhere in your directory:
%   save('credentials.mat','-struct','credentials');
%
% INPUT
%
%   dest            recipient e-mail address
%   subject         title of the message
%   msg             the message body
%   credentials     structure with access parameters or name of .mat file
%   attachement     cell with paths to attachments
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 5
        attach = {};
    end
    
    if ischar(credentials)
        credentials = load(credentials);
    end
    
    setpref( 'Internet', 'E_mail',        credentials.mail   );
    setpref( 'Internet', 'SMTP_Server',   credentials.server );
    setpref( 'Internet', 'SMTP_Username', credentials.login  );
    setpref( 'Internet', 'SMTP_Password', credentials.pswd   );

    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', ...
                      'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');

    sendmail( dest, subject, msg, attach );
    
end
