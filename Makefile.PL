#!/usr/bin/perl

# $Header: /home/photochr/perl/src/Photochrome/RCS/Makefile.PL,v 1.6 2017/12/14 19:36:30 photochr Exp $

# $Log: Makefile.PL,v $
# Revision 1.6  2017/12/14 19:36:30  photochr
# Change INSTALL_Base from $HOME/perl to $HOME.
#
# Revision 1.5  2014/12/13 03:13:27  photochr
# Set INSTALL_BASE instead of PREFIX.
#
# Revision 1.4  2014/12/10 03:08:36  photochr
# Install missing-image.jpg.
#
# Revision 1.3  2012/11/15 17:44:50  photochr
# Set mode 644 on copied files.
#
# Revision 1.2  2012/10/24 20:49:09  photochr
# Add -f option to cp commands.
#
# Revision 1.1  2012/10/24 20:31:37  photochr
# Initial revision
#

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
$Verbose = 1;
$HOME = $ENV{HOME};

#
# Override the standard "install" target to install support files
#
sub MY::install {
    package MY;
    my $inherited = shift->SUPER::install(@_);
    my $new; 
    for ( split( "\n", $inherited ) ) {
        if ( /^install :: / ) {
            $_ .= " support_files_install";
        }
        $new .= "$_\n";
    }
    return $new;
}

#
# Define target to install support files
#
sub MY::postamble {
    return qq[

$HOME/submissions/acktemplate.html : acktemplate.html
	\$(CP) -f acktemplate.html $HOME/submissions
	\$(CHMOD) 644 $HOME/submissions/acktemplate.html

$HOME/.procmailrc : .procmailrc
	\$(CP) -f .procmailrc $HOME
	\$(CHMOD) 644 $HOME/.procmailrc

support_files_install : $HOME/submissions/acktemplate.html $HOME/.procmailrc
					  ];
}

WriteMakefile(
	      'INSTALL_BASE' => "$HOME",
	      'NAME' => 'Photochrome',
	      'VERSION_FROM' => 'submitter.pl', # finds $VERSION
	      'dist' => { COMPRESS=>"gzip --recursive --best" },
	      'EXE_FILES'=> [ qw{submitter.pl missing-image.jpg} ],
	      );
